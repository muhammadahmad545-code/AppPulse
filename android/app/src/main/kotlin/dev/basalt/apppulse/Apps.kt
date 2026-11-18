package dev.basalt.apppulse

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import java.io.ByteArrayOutputStream

/** Installed-app metadata from PackageManager. */
object Apps {
    private fun launcherIntent() = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
    private fun homeIntent() = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)

    /** Describes [packages], or every launchable app when [packages] is null. */
    @Suppress("DEPRECATION")
    fun describe(ctx: Context, packages: List<String>?): List<Map<String, Any?>> {
        val pm = ctx.packageManager
        val targets = packages ?: pm.queryIntentActivities(launcherIntent(), 0)
            .mapNotNull { it.activityInfo?.packageName }
            .distinct()
        val out = ArrayList<Map<String, Any?>>()
        for (p in targets) {
            try {
                val info = pm.getApplicationInfo(p, 0)
                out.add(
                    mapOf(
                        "package" to p,
                        "name" to pm.getApplicationLabel(info).toString(),
                        "system" to ((info.flags and ApplicationInfo.FLAG_SYSTEM) != 0 &&
                            (info.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) == 0),
                        "category" to info.category,
                        "launchable" to (pm.getLaunchIntentForPackage(p) != null),
                        "installed" to true,
                    ),
                )
            } catch (_: PackageManager.NameNotFoundException) {
                out.add(mapOf("package" to p, "installed" to false))
            }
        }
        return out
    }

    /**
     * Packages whose foreground time is not "app usage": the home screen app(s), System UI and AppPulse.
     * Settings registers a fallback HOME activity, so it is never treated as a launcher.
     */
    @Suppress("DEPRECATION")
    fun excludedPackages(ctx: Context): List<String> {
        val pm = ctx.packageManager
        val out = LinkedHashSet<String>()
        pm.resolveActivity(homeIntent(), PackageManager.MATCH_DEFAULT_ONLY)?.activityInfo?.packageName?.let { out.add(it) }
        for (r in pm.queryIntentActivities(homeIntent(), 0)) {
            r.activityInfo?.packageName?.let { out.add(it) }
        }
        out.remove("com.android.settings")
        out.add("android")
        out.add("com.android.systemui")
        out.add(ctx.packageName)
        return out.toList()
    }

    fun icon(ctx: Context, pkg: String, size: Int): ByteArray? {
        return try {
            val drawable = ctx.packageManager.getApplicationIcon(pkg)
            val px = size.coerceIn(24, 256)
            val bmp = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, px, px)
            drawable.draw(canvas)
            val stream = ByteArrayOutputStream()
            bmp.compress(Bitmap.CompressFormat.PNG, 100, stream)
            bmp.recycle()
            stream.toByteArray()
        } catch (_: Exception) {
            null
        }
    }
}
