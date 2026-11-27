package dev.basalt.apppulse

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/** Same scenarios as test/reconstruct_test.dart, so the limit checker and the app agree. */
class SessionsTest {
    private val base = 1_773_133_200_000L
    private fun t(min: Int, sec: Int = 0) = base + min * 60_000L + sec * 1_000L
    private fun resume(p: String, at: Long, c: String = "Main") = Sessions.Ev(at, Usage.RESUMED, p, c)
    private fun pause(p: String, at: Long, c: String = "Main") = Sessions.Ev(at, Usage.PAUSED, p, c)
    private fun sys(type: Int, at: Long) = Sessions.Ev(at, type, "android", "")
    private val launcher = "com.android.launcher3"
    private val excluded = setOf(launcher, "com.android.systemui", "android")

    private fun total(events: List<Sessions.Ev>, to: Long = t(600), from: Long = base) =
        Sessions.totals(events, from, to, excluded)

    @Test
    fun androidCodes() {
        assertEquals(15, Usage.SCREEN_ON)
        assertEquals(16, Usage.SCREEN_OFF)
    }

    @Test
    fun wakingStraightIntoAnAppKeepsItsSession() {
        val r = total(listOf(resume("insta", t(0)), sys(15, t(0)), sys(16, t(30)), pause("insta", t(30, 1))))
        assertEquals(t(30) - t(0), r.totals["insta"])
        assertNull(r.foreground)
    }

    @Test
    fun screenOffTimeIsNeverCounted() {
        val r = total(
            listOf(
                resume("insta", t(0)), sys(16, t(10)), sys(17, t(10)), sys(15, t(50)), sys(18, t(51)),
                resume("insta", t(51)), pause("insta", t(56)),
            ),
        )
        assertEquals(15 * 60_000L, r.totals["insta"])
    }

    @Test
    fun appLeftOnTopCountsFromUnlockToPause() {
        val r = total(listOf(resume("insta", t(0)), sys(16, t(10)), sys(17, t(10)), sys(15, t(20)), sys(18, t(21)), pause("insta", t(25))))
        assertEquals(14 * 60_000L, r.totals["insta"])
    }

    @Test
    fun openSessionEndsNowAndIsInFront() {
        val r = total(listOf(sys(15, t(0)), resume("insta", t(1))), to = t(46))
        assertEquals(45 * 60_000L, r.totals["insta"])
        assertEquals("insta", r.foreground)
    }

    @Test
    fun homeScreenEndsASessionAndIsNotCounted() {
        val r = total(listOf(resume("a", t(0)), resume(launcher, t(3)), pause(launcher, t(7)), resume("b", t(7)), pause("b", t(8))))
        assertEquals(3 * 60_000L, r.totals["a"])
        assertEquals(60_000L, r.totals["b"])
        assertNull(r.totals[launcher])
    }

    @Test
    fun movingBetweenScreensIsOneSession() {
        val events = listOf(resume("a", t(0), "Main"), pause("a", t(5), "Main"), resume("a", t(5, 1), "Detail"), pause("a", t(8), "Detail"))
        val (sessions, _) = Sessions.reconstruct(events, t(600), excluded)
        assertEquals(1, sessions.size)
        assertEquals(t(8) - t(0), sessions[0].end - sessions[0].start)
    }

    @Test
    fun onlyTimeInsideTheWindowCounts() {
        val r = total(listOf(resume("a", t(-30)), pause("a", t(15))), from = base, to = t(600))
        assertEquals(15 * 60_000L, r.totals["a"])
    }
}
