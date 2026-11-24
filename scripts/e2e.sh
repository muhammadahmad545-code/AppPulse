#!/bin/bash
# Clocked end-to-end checks. Sourced by smoke.sh, which provides PKG and the helpers
# (tap_text, tap_contains, expect, expect_not, scroll_to, shot, back, alive, launch, fail, pass ...).

# The CI emulator screen is small; scroll relative to its real size instead of fixed coordinates.
read SW SH < <(adb shell wm size | grep -oE '[0-9]+x[0-9]+' | tail -1 | tr 'x' ' ')
SW=${SW:-1080}; SH=${SH:-1920}
swipe_up() { adb shell input swipe $((SW / 2)) $((SH * 70 / 100)) $((SW / 2)) $((SH * 30 / 100)) 300; sleep 1; }
scroll_to() {
  for i in $(seq 1 8); do has_text "$1" && return 0; swipe_up; done
  has_text "$1"
}
scroll_top() { for i in 1 2 3 4 5 6 7 8; do adb shell input swipe $((SW / 2)) $((SH * 30 / 100)) $((SW / 2)) $((SH * 75 / 100)) 200; done; sleep 1; }

# Find an app row (one merged accessibility node) by app name plus a word from its detail line.
_row_xy() {
  python3 - "$1" "$2" <<'PY'
import re, sys, html
name, detail = sys.argv[1], sys.argv[2]
try:
    xml = open('/tmp/ui.xml', encoding='utf-8', errors='ignore').read()
except Exception:
    sys.exit(0)
for m in re.finditer(r'<node [^>]*>', xml):
    n = m.group(0)
    for v in re.findall(r' (?:text|content-desc)="([^"]*)"', n):
        lines = html.unescape(v).split('\n')
        if name in lines and any(detail in l for l in lines if l != name):
            b = re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', n)
            if b:
                x1, y1, x2, y2 = map(int, b.groups())
                print((x1 + x2) // 2, (y1 + y2) // 2)
                sys.exit(0)
PY
}
has_row() { dump; [ -n "$(_row_xy "$1" "$2")" ]; }
wait_row() { for i in $(seq 1 ${3:-10}); do has_row "$1" "$2" && return 0; sleep 3; done; return 1; }
tap_row() { local xy; dump; xy=$(_row_xy "$1" "$2"); [ -n "$xy" ] && adb shell input tap $xy && echo "tapped row $1 at $xy"; }
expect_row() {
  if wait_row "$1" "$2" 8; then pass "$3"; return 0; fi
  for i in 1 2 3 4 5; do swipe_up; has_row "$1" "$2" && { pass "$3"; return 0; }; done
  fail "$3 (no row '$1' with '$2')"; shot "fail-$(echo "$3" | tr -c 'a-zA-Z0-9' '-' | cut -c1-40)"; return 1
}
tab() { tap_text "$1"; sleep 3; }

# 1. Without usage access, Today explains what to do instead of showing zeros.
launch; sleep 4
tab "Today"
expect "Allow usage access" 10 "usage access card shown before access is granted"
expect "Open settings" 5 "usage access card has an Open settings button"
shot e2e-01-no-access

# 2. Create real usage: Settings for a while, then another app, then home.
adb shell monkey -p com.android.settings -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; sleep 25
adb shell am start -a android.settings.DISPLAY_SETTINGS >/dev/null 2>&1; sleep 10
adb shell input keyevent 3; sleep 3
for app in com.google.android.contacts com.android.contacts com.google.android.deskclock com.android.deskclock; do
  if adb shell pm list packages | grep -q "package:$app\$"; then
    adb shell monkey -p "$app" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; sleep 12; break
  fi
done
adb shell input keyevent 3; sleep 2

# 3. Grant access and return: the resume refresh must pick it up without a restart.
adb shell appops set "$PKG" GET_USAGE_STATS allow
launch; sleep 8
expect "Screen time today" 20 "Today shows screen time once access is granted"
if has_text "Screen time today: 0m"; then fail "Today still shows zero screen time"; else pass "Today shows non-zero screen time"; fi
expect_row "Settings" "open" "Settings appears in Most used"
shot e2e-02-today
scroll_top

# 4. Apps tab lists Settings; open it and set a daily limit.
tab "Apps"
expect_row "Settings" "open" "Settings appears in the Apps list"
shot e2e-03-apps
tap_row "Settings" "open"; sleep 3
expect "Set a daily limit" 10 "app details open with a limit row"
shot e2e-04-app-detail
tap_text "Set a daily limit"; sleep 2
expect "Daily limit for Settings" 8 "limit sheet opens"
tap_text "45m"; sleep 1
tap_text "Save limit"; sleep 3
expect "45m a day" 10 "limit saved and shown on the app page"
shot e2e-05-limit-saved
back
alive || fail "app died after saving a limit"

# 5. The limit is listed in App limits with today's usage.
tab "Settings"
scroll_top
tap_text "App limits"; sleep 3
expect_row "Settings" "of 45m" "limit listed in App limits"
shot e2e-06-limits
back

# 6. Focus: start a 25 minute session, stop it, and see it in the history.
scroll_top
tap_text "Focus mode"; sleep 3
tap_text "25 min"; sleep 1
tap_text "Start focus"; sleep 3
expect "Stop session" 10 "focus session starts with a countdown"
expect "left" 5 "countdown is shown"
shot e2e-07-focus-running
tap_text "Stop session"; sleep 2
tap_text "Stop"; sleep 3
expect "Session stopped" 10 "stopping shows a summary"
shot e2e-08-focus-summary
tap_text "Done"; sleep 2
expect "Stopped" 8 "stopped session is in the focus history"
back

# 7. Reports: the CSV export reaches Android's share sheet.
scroll_top
scroll_to "Reports"
tap_text "Reports"; sleep 3
expect "Share CSV" 10 "reports screen opens"
shot e2e-09-reports
tap_text "Share CSV"; sleep 5
if adb shell dumpsys window | grep -E "mCurrentFocus|mFocusedApp" | grep -qiE "chooser|intentresolver|resolver"; then
  pass "CSV report reached the share sheet"
else
  fail "share sheet did not open for the CSV report"
fi
shot e2e-10-share-sheet
back; sleep 1
if ! adb shell dumpsys window | grep -E "mCurrentFocus" | grep -q "$PKG"; then back; fi
tap_text "Share PDF"; sleep 5
if adb shell dumpsys window | grep -E "mCurrentFocus|mFocusedApp" | grep -qiE "chooser|intentresolver|resolver"; then
  pass "PDF report reached the share sheet"
else
  fail "share sheet did not open for the PDF report"
fi
back; sleep 1
if ! adb shell dumpsys window | grep -E "mCurrentFocus" | grep -q "$PKG"; then back; fi
back

# 8. Insights: overview and timeline.
tab "Insights"
scroll_top
expect "DAILY SCREEN TIME" 10 "insights overview shows daily totals"
shot e2e-11-insights
scroll_top
tap_text "Timeline"; sleep 3
expect "sessions ·" 10 "timeline lists the day's sessions"
shot e2e-12-timeline

# 9. Accuracy check against Android's own totals.
tab "Settings"
scroll_to "Accuracy check"
tap_text "Accuracy check"; sleep 6
expect "TODAY BY APP" 15 "accuracy check compares with Android"
shot e2e-13-accuracy
back

# 10. Dark theme.
scroll_to "Theme"
tap_text "Theme"; sleep 2
tap_text "Dark"; sleep 2
tab "Today"
shot e2e-14-dark-today
tab "Settings"
scroll_to "Theme"
tap_text "Theme"; sleep 2
tap_text "System"; sleep 2

# 11. Everything persists after a restart.
adb shell am force-stop "$PKG"; sleep 2
launch; sleep 6
tab "Settings"
scroll_top
tap_text "App limits"; sleep 3
expect_row "Settings" "of 45m" "limit persists after restart"
back
scroll_top
tap_text "Focus mode"; sleep 3
expect "Stopped" 8 "focus history persists after restart"
shot e2e-15-after-restart
back
alive || fail "app is not running at the end"

# The app is called Clocked everywhere a user can see.
tap_text "Settings"; sleep 3
expect "Clocked can read screen time" 10 "Settings uses the new name"

# ---------------------------------------------------------------------------------------------
# 2.1: widget, launcher shortcuts, Focus tile, downtime and the weekly summary.
adb shell pm grant "$PKG" android.permission.POST_NOTIFICATIONS >/dev/null 2>&1 || true
notified() { adb shell dumpsys notification --noredact 2>/dev/null | grep -qE "$1"; }

# 12. The home-screen widget is registered.
if adb shell dumpsys appwidget | grep -q "$PKG/$PKG.UsageWidget"; then pass "home-screen widget is registered"; else fail "home-screen widget is not registered"; fi

# 13. Launcher shortcuts are published.
SC=$(adb shell dumpsys shortcut | grep -A80 "Package: $PKG")
echo "$SC" | grep -q "id=focus" && pass "Start focus shortcut is published" || fail "Start focus shortcut missing"
echo "$SC" | grep -q "id=limits" && pass "App limits shortcut is published" || fail "App limits shortcut missing"

# 14. The App limits shortcut opens the limits screen.
adb shell am force-stop "$PKG"; sleep 2
adb shell am start -n "$PKG/.MainActivity" --es clocked.action limits >/dev/null 2>&1; sleep 8
expect "Downtime schedule" 12 "App limits shortcut opens the limits screen"
shot e2e-16-shortcut-limits

# 15. The Start focus shortcut starts a 25-minute session; stop it in the app.
adb shell am force-stop "$PKG"; sleep 2
adb shell am start -n "$PKG/.MainActivity" --es clocked.action focus >/dev/null 2>&1; sleep 8
expect "Stop session" 12 "Start focus shortcut starts a session"
expect "Focusing until" 5 "shortcut session shows its end time"
shot e2e-17-shortcut-focus
tap_text "Stop session"; sleep 2
tap_text "Stop"; sleep 3
tap_text "Done"; sleep 2
expect "Start focus" 8 "shortcut session stopped in the app"

# 16. The Focus tile starts a session with the app closed; the app shows it running.
adb shell am force-stop "$PKG"; sleep 2
TILE="$PKG/.FocusTileService"
adb shell cmd statusbar add-tile "$TILE"; sleep 3
# Click with Quick Settings open, as a person would (a click on an unbound tile can be dropped).
click_tile() { adb shell cmd statusbar expand-settings; sleep 3; adb shell cmd statusbar click-tile "$TILE"; sleep 3; adb shell cmd statusbar collapse; sleep 2; }
adb shell cmd statusbar collapse; sleep 1
click_tile
if notified "Focus session"; then pass "Focus tile posts the focus countdown notification"; else fail "no focus notification after tapping the tile"; fi
launch; sleep 6
tab "Settings"
scroll_top
tap_text "Focus mode"; sleep 4
expect "Stop session" 12 "focus screen shows the session the tile started"
expect "left" 5 "tile session has a countdown in the app"
shot e2e-18-tile-running

# 17. Tapping the tile again stops it, and the open focus screen follows.
click_tile
expect "Start focus" 12 "tile stop is reflected in the open focus screen"
expect_not "Stop session" 2 "no session is running after the tile stops it"
shot e2e-19-tile-stopped
back

# 18. Downtime: a window with an app, saved and kept after a restart.
adb shell am force-stop "$PKG"; sleep 2
launch; sleep 5
tab "Settings"
scroll_top
tap_text "Downtime"; sleep 3
expect "Honest limits" 10 "downtime screen opens and says nothing is blocked"
tap_text "Starts"; sleep 3
tap_text "OK"; sleep 2
alive || fail "app died after the downtime time picker"
tap_text "Add app"; sleep 5
expect "Choose an app" 10 "downtime app picker opens"
tap_class EditText 0; sleep 1
type_text "Settin"; sleep 2
tap_text "Settings"; sleep 3
hide_keyboard
scroll_top
expect "Every day" 10 "adding the first app turns downtime on"
expect_row "Settings" "Reminder during downtime" "app saved in the downtime list"
shot e2e-20-downtime
adb shell am force-stop "$PKG"; sleep 2
launch; sleep 5
tab "Settings"
scroll_top
tap_text "Downtime"; sleep 3
expect_row "Settings" "Reminder during downtime" "downtime app persists after restart"
expect "Every day" 5 "downtime window persists after restart"
back

# 19. Weekly summary: on by default; the preview posts a notification.
scroll_to "Send a preview now"
expect "Monday summary" 5 "weekly summary setting is in Settings"
tap_text "Send a preview now"; sleep 5
if notified "Weekly summary|Last week"; then pass "weekly summary preview notification posted"; else fail "no weekly summary notification"; fi
scroll_to "Focus tile"
expect "Focus tile" 5 "Settings explains the widget, tile and shortcuts"
shot e2e-21-settings-quick-access
alive || fail "app is not running at the end of the 2.1 checks"
