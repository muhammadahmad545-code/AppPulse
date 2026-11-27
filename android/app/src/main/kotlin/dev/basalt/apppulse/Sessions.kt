package dev.basalt.apppulse

/**
 * Rebuilds foreground sessions from usage events. A line-for-line port of `lib/data/reconstruct.dart`
 * (keep both in step), so the background limit check counts exactly what the app shows:
 * - One app is in the foreground at a time. A resume of another app (or the home screen) ends the
 *   current session even when Android never sent the matching pause.
 * - An app stays in front while any of its activities is resumed.
 * - Screen off, lock and shutdown end the current session. If that app is still on top after the screen
 *   comes back and Android only reports its pause, the time from wake-up to that pause is counted.
 * - Excluded packages (home screen, System UI, Clocked) never get sessions.
 * - Sessions of one app less than 2 s apart are joined; pieces shorter than 1 s are dropped.
 */
object Sessions {
    class Ev(val ts: Long, val type: Int, val pkg: String, val cls: String)

    class Session(val pkg: String, val start: Long, val end: Long)

    private const val MERGE_GAP = 2_000L
    private const val MIN_LENGTH = 1_000L

    /** Sessions plus the app still in front at [now]. Events must be in time order. */
    fun reconstruct(events: List<Ev>, now: Long, excluded: Set<String>): Pair<List<Session>, String?> {
        val sorted = events.withIndex().sortedWith(compareBy({ it.value.ts }, { it.index })).map { it.value }
        val out = ArrayList<Session>()
        var open: String? = null
        var since = 0L
        val activities = HashSet<String>()
        var interrupted: String? = null
        var wokeAt: Long? = null

        fun add(pkg: String, start: Long, end: Long) {
            if (end <= start) return
            val last = out.lastOrNull()
            if (last != null && last.pkg == pkg && start <= last.end + MERGE_GAP) {
                out[out.size - 1] = Session(pkg, last.start, maxOf(end, last.end))
                return
            }
            out.add(Session(pkg, start, end))
        }

        fun close(at: Long) {
            open?.let { add(it, since, at) }
            open = null
            activities.clear()
        }

        for (e in sorted) {
            when (e.type) {
                Usage.RESUMED -> {
                    interrupted = null
                    if (e.pkg.isEmpty() || e.pkg in excluded) {
                        close(e.ts)
                    } else {
                        if (open != e.pkg) {
                            close(e.ts)
                            open = e.pkg
                            since = e.ts
                        }
                        activities.add(e.cls)
                    }
                }
                Usage.PAUSED -> {
                    val woke = wokeAt
                    if (open == e.pkg) {
                        val known = activities.remove(e.cls)
                        if (!known || activities.isEmpty()) close(e.ts)
                    } else if (open == null && interrupted == e.pkg && woke != null && e.ts > woke) {
                        add(e.pkg, woke, e.ts)
                        interrupted = null
                    }
                }
                Usage.SCREEN_OFF, Usage.KEYGUARD_SHOWN, Usage.SHUTDOWN -> {
                    if (open != null) {
                        interrupted = open
                        wokeAt = null
                    }
                    close(e.ts)
                }
                Usage.SCREEN_ON, Usage.KEYGUARD_HIDDEN -> if (interrupted != null) wokeAt = e.ts
                Usage.STARTUP -> {
                    interrupted = null
                    close(e.ts)
                }
            }
        }
        val foreground = open
        close(now)
        return Pair(out.filter { it.end - it.start >= MIN_LENGTH }, foreground)
    }

    /** Foreground time per package inside [from, to), and the app in front at [to]. */
    fun totals(events: List<Ev>, from: Long, to: Long, excluded: Set<String>): Usage.Today {
        val (sessions, foreground) = reconstruct(events, to, excluded)
        val totals = HashMap<String, Long>()
        for (s in sessions) {
            val a = maxOf(s.start, from)
            val b = minOf(s.end, to)
            if (b > a) totals[s.pkg] = (totals[s.pkg] ?: 0L) + (b - a)
        }
        return Usage.Today(totals, foreground)
    }
}
