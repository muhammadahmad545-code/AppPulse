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

# ---------------------------------------------------------------------------------------------
# 2.2: limit reminders arrive on time (real usage on the emulator, no shortcuts).
adb shell svc power stayon true
adb shell appops set "$PKG" SYSTEM_ALERT_WINDOW allow
adb shell am force-stop "$PKG"; sleep 2
launch; sleep 6
tab "Settings"
scroll_top
tap_text "App limits"; sleep 3
# Turn on the card on top of the app (overlay permission granted above).
tap_contains "Card on top of the app"; sleep 3
card_switch_on() { dump; grep -o '<node [^>]*android.widget.Switch[^>]*>' /tmp/ui.xml | head -1 | grep -q 'checked="true"'; }
if card_switch_on; then pass "card on top of the app turned on by tapping its row"; else fail "card on top of the app did not turn on"; fi
alive || fail "app died turning on the card on top of the app"

# 20. Lower the Settings limit to 5 minutes with the slider.
set_slider_min() {
  dump
  local SEEK SEEK_L
  SEEK=$(_find class SeekBar 0.5 0.5 first)
  SEEK_L=$(_find class SeekBar 0.0 0.5 first)
  if [ -n "$SEEK" ] && [ -n "$SEEK_L" ]; then
    adb shell input swipe $SEEK ${SEEK_L%% *} ${SEEK##* } 600; sleep 1
    adb shell input swipe ${SEEK_L%% *} ${SEEK##* } 0 ${SEEK##* } 300; sleep 1
  else
    fail "limit slider not found"
  fi
}
tap_row "Settings" "of 45m"; sleep 3
expect "Daily limit for Settings" 8 "limit sheet opens for an existing limit"
set_slider_min
shot e2e-22-limit-5m
tap_text "Save limit"; sleep 3
expect_row "Settings" "of 5m" "limit lowered to 5 minutes"
shot e2e-23-limits-5m

# 21. The limit watcher runs (silent notification + foreground service).
sleep 3
if adb shell dumpsys activity services "$PKG" | grep -q "LimitGuard"; then pass "limit watcher service is running"; else fail "limit watcher service is not running"; fi
if notified "Watching your app limits"; then pass "limit watcher notification is shown"; else fail "no limit watcher notification"; fi

# 22. Use Settings until the limit: the reminder must come within seconds of the 5-minute mark.
USED_MS=$(adb shell dumpsys usagestats 2>/dev/null | tr -d '\r' | grep -m1 -oE "package=com.android.settings totalTimeUsed=\"[0-9:]+\"" || true)
echo "Android's own Settings usage before the run: $USED_MS"
adb shell monkey -p com.android.settings -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
START=$(date +%s)
REACHED=0
for i in $(seq 1 75); do
  sleep 5
  if notified "Settings: daily limit reached"; then REACHED=$(( $(date +%s) - START )); break; fi
done
echo "limit reminder after ${REACHED}s in Settings"
if [ "$REACHED" -gt 0 ] && [ "$REACHED" -le 300 ]; then
  pass "limit reminder arrived on time (${REACHED}s after opening Settings, limit 5m)"
else
  fail "limit reminder did not arrive within 5 minutes of use (got ${REACHED}s)"
fi
# (Android's Settings app hides other apps' cards on top of it, so the card is checked on another app.)

# 23. The card on top of the app: a 5-minute limit on an ordinary app, used past its limit.
adb shell input keyevent 3; sleep 2
OTHER=""; OTHER_NAME=""
for cand in "com.google.android.deskclock:Clock" "com.android.deskclock:Clock" "com.google.android.contacts:Contacts" "com.android.contacts:Contacts"; do
  if adb shell pm list packages | tr -d '\r' | grep -q "package:${cand%%:*}\$"; then OTHER=${cand%%:*}; OTHER_NAME=${cand##*:}; break; fi
done
echo "card test app: $OTHER ($OTHER_NAME)"
adb shell am force-stop "$PKG"; sleep 2
adb shell am start -n "$PKG/.MainActivity" --es clocked.action limits >/dev/null 2>&1; sleep 8
expect "Downtime schedule" 12 "limits screen open for the card test"
tap_text "Add limit"; sleep 5
expect "Choose an app" 10 "limit app picker opens"
tap_class EditText 0; sleep 1
type_text "$OTHER_NAME"; sleep 2
hide_keyboard
tap_text "$OTHER_NAME"; sleep 3
expect "Daily limit for $OTHER_NAME" 8 "limit sheet opens for $OTHER_NAME"
set_slider_min
tap_text "Save limit"; sleep 3
expect_row "$OTHER_NAME" "of 5m" "5-minute limit added for $OTHER_NAME"
scroll_top
if card_switch_on; then pass "card on top of the app is on"; else fail "card on top of the app is not on"; fi
adb shell monkey -p "$OTHER" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
START=$(date +%s)
CARD=0
for i in $(seq 1 75); do
  sleep 4
  if adb shell dumpsys window windows | tr -d '\r' | grep -q "ClockedLimitCard"; then CARD=$(( $(date +%s) - START )); break; fi
done
sleep 1
shot e2e-24-limit-card
echo "card on top of $OTHER_NAME after ${CARD}s"
if [ "$CARD" -gt 0 ] && [ "$CARD" -le 305 ]; then pass "card on top of $OTHER_NAME appeared at the limit (${CARD}s)"; else fail "card on top of $OTHER_NAME did not appear (got ${CARD}s)"; fi
if notified "$OTHER_NAME: daily limit reached"; then pass "$OTHER_NAME limit notification posted"; else fail "no $OTHER_NAME limit notification"; fi

# 24. The app shows the same: Settings is past its 5-minute limit today.
adb shell input keyevent 3; sleep 2
adb shell am force-stop "$PKG"; sleep 2
launch; sleep 8
tab "Settings"
scroll_top
tap_text "App limits"; sleep 4
expect_row "Settings" "reached" "App limits shows Settings as reached"
shot e2e-25-limits-reached
adb shell svc power stayon false
alive || fail "app is not running at the end of the 2.2 checks"

# 25. Backup and restore (2.3).
# a) Save a password-protected backup through Android's "Save to" screen.
# b) Restore it: a wrong password is refused, the right one opens it, and nothing is added twice
#    (every day it holds is already on this phone).
# c) Restore a prepared backup holding an older day and a limit for an app this phone has never
#    seen: both come back, and a second restore adds nothing.
tap_any() { for t in "$@"; do tap_text "$t" && return 0; done; return 1; }
# Scroll until the text is on screen, then a little more so it sits clear of the bottom tab bar.
reach() { scroll_to "$1" >/dev/null; adb shell input swipe $((SW / 2)) $((SH * 60 / 100)) $((SW / 2)) $((SH * 40 / 100)) 300; sleep 1; }
open_settings() { adb shell am force-stop "$PKG"; sleep 2; launch; sleep 8; tab "Settings"; scroll_top; }
pick_file() {
  sleep 4
  if ! has_text "$1"; then tap_any "Show roots" >/dev/null; sleep 2; tap_any "Downloads" "Download" >/dev/null; sleep 4; fi
  tap_text "$1"; sleep 5
}
adb shell "rm -f /sdcard/Download/clocked-backup-*" >/dev/null 2>&1
open_settings
reach "Back up to a file"
tap_text "Back up to a file"; sleep 3
expect "Protect this backup?" 10 "backup asks about a password"
tap_class EditText 0; type_text "secret123"
tap_class EditText 1; type_text "secret123"
# No Escape here: it closes a Flutter dialog. The dialog sits above the keyboard.
tap_text "Save with password"; sleep 8
shot e2e-26-save-screen
for i in 1 2 3 4 5; do tap_any "SAVE" "Save" && break; sleep 3; done; sleep 3
expect "are in the file" 30 "backup saved through Android's Save screen"
shot e2e-27-backup-saved
tap_text "OK"; sleep 2
BACKUP=$(adb shell "ls /sdcard/Download/clocked-backup-*.json" 2>/dev/null | tr -d '\r' | head -1)
if [ -n "$BACKUP" ]; then pass "backup file written ($BACKUP)"; else fail "backup file written to Downloads"; fi
adb exec-out cat "$BACKUP" > "$OUT/backup.json" 2>/dev/null
if grep -q '"encrypted":true' "$OUT/backup.json"; then pass "backup file is encrypted"; else fail "backup file is encrypted"; fi
if grep -q "com.android.settings" "$OUT/backup.json"; then fail "app names are not readable in the encrypted file"; else pass "app names are not readable in the encrypted file"; fi

NAME=$(basename "${BACKUP:-clocked-backup.json}")
reach "Restore from a backup"
tap_text "Restore from a backup"
pick_file "$NAME"
expect "Backup password" 15 "a protected backup asks for its password"
tap_class EditText 0; type_text "wrongpass"
tap_text "Open backup"; sleep 6
expect "That password is not right" 20 "a wrong password is refused"
tap_class EditText 0; type_text "secret123"
tap_text "Open backup"; sleep 6
expect "Restore this backup?" 20 "the right password opens the backup"
shot e2e-28-restore-confirm
tap_text "Restore"; sleep 6
expect "Restore finished" 30 "restore of this phone's own backup finishes"
expect "0 days of screen time added" 3 "days already on this phone are not added twice"
expect "0 app limits added" 3 "limits already on this phone are not added twice"
shot e2e-29-restore-own
tap_text "OK"; sleep 2

# c) A prepared backup from "another phone".
NOW=$(adb shell date +%s | tr -d '\r')
OLD=$((NOW - 3 * 86400))
OLDDAY=$(adb shell date -d "@$OLD" +%Y-%m-%d | tr -d '\r')
cat > "$OUT/clocked-backup-old-phone.json" <<JSON
{"app":"clocked","format":1,"exportedAt":"2026-01-01T09:00:00.000","appVersion":"2.3.0",
 "settings":{"goalMinutes":150,"weeklySummary":true,"themeMode":"system","downtime":{"enabled":false,"start":1380,"end":420,"apps":[]}},
 "limits":[{"package":"dev.basalt.e2e.oldphone","minutes":30,"enabled":true}],
 "apps":[{"package":"dev.basalt.e2e.oldphone","name":"Old Phone App","category":-1,"system":false}],
 "days":[{"day":"$OLDDAY","unlocks":9,"sessions":[["dev.basalt.e2e.oldphone",${OLD}000,$((OLD + 1800))000]]}],
 "focus":[]}
JSON
adb push "$OUT/clocked-backup-old-phone.json" /sdcard/Download/clocked-backup-old-phone.json >/dev/null
adb shell content call --uri content://media --method scan_volume --arg external_primary >/dev/null 2>&1
reach "Restore from a backup"
tap_text "Restore from a backup"
pick_file "clocked-backup-old-phone.json"
expect "Restore this backup?" 20 "an unprotected backup opens without a password"
tap_text "Restore"; sleep 6
expect "1 day of screen time added" 30 "the older day from the other phone is restored"
expect "1 app limit added" 3 "the other phone's limit is restored"
shot e2e-30-restore-old-phone
tap_text "OK"; sleep 2
scroll_top
tap_text "App limits"; sleep 4
expect_row "Old Phone App" "30m" "the restored limit is listed under its app name"
shot e2e-31-restored-limit
back
reach "Restore from a backup"
tap_text "Restore from a backup"
pick_file "clocked-backup-old-phone.json"
tap_text "Restore"; sleep 6
expect "0 days of screen time added" 30 "restoring the same backup again adds nothing"
tap_text "OK"; sleep 2
alive || fail "app is not running at the end of the backup checks"

# --- Appearance: draft preview, Apply, persistence after restart, reset -----------------------
scroll_tap() {
  for i in $(seq 1 10); do
    dump; xy=$(_find exact "$1")
    if [ -n "$xy" ] && [ "${xy#* }" -lt $((SH*65/100)) ]; then adb shell input tap $xy; echo "tapped '$1' at $xy"; return 0; fi
    swipe_up
  done
  return 1
}
is_selected() { dump; python3 - "$1" <<'PY'
import re, sys, html
xml = open('/tmp/ui.xml', encoding='utf-8', errors='ignore').read()
for m in re.finditer(r'<node [^>]*>', xml):
    n = m.group(0)
    vals = [html.unescape(v) for v in re.findall(r' (?:text|content-desc)="([^"]*)"', n)]
    if any(v == sys.argv[1] or sys.argv[1] in v.split('\n') for v in vals):
        sys.exit(0 if ('selected="true"' in n or 'checked="true"' in n) else 1)
sys.exit(1)
PY
}
adb shell am force-stop "$PKG"; sleep 2
launch; sleep 6
tab "Settings"
scroll_tap "Appearance"; sleep 3
expect "Clocked, your way" 10 "Appearance screen opens with a live preview"
shot e2e-appearance
scroll_tap "Rose accent"; sleep 1
scroll_tap "Space Grotesk font"; sleep 1
scroll_tap "Pure black background"; sleep 1
scroll_tap "Icons only"; sleep 1
shot e2e-appearance-draft
expect "Apply" 5 "changes wait for Apply"
tap_text "Apply"; sleep 2
expect_not "Discard" 2 "Apply saves the draft"
back
adb shell am force-stop "$PKG"; sleep 2
launch; sleep 6
shot e2e-appearance-after-restart
tab "Settings"
scroll_tap "Appearance"; sleep 3
for i in 1 2 3; do has_text "Rose accent" && break; swipe_up; done
if is_selected "Rose accent"; then pass "accent choice survives a restart"; else fail "accent choice survives a restart"; fi
scroll_to "Space Grotesk font" >/dev/null
if is_selected "Space Grotesk font"; then pass "font choice survives a restart"; else fail "font choice survives a restart"; fi
scroll_to "Reset to default" >/dev/null; tap_text "Reset to default"; sleep 1
tap_text "Apply"; sleep 2
scroll_top
for i in 1 2 3; do has_text "Clocked accent" && break; swipe_up; done
if is_selected "Clocked accent"; then pass "Reset to default returns to the app colour"; else fail "Reset to default returns to the app colour"; fi
back
alive || fail "app died during the appearance checks"
