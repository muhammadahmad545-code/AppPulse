package dev.basalt.apppulse

import android.graphics.drawable.Icon
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/** Quick Settings "Focus" tile: tap to start a 25-minute focus session, tap again to stop it. */
class FocusTileService : TileService() {
    private val handler = Handler(Looper.getMainLooper())
    private val tick = object : Runnable {
        override fun run() {
            render()
            if (Focus.active(applicationContext) != null) handler.postDelayed(this, 20_000L)
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        handler.removeCallbacks(tick)
        tick.run()
    }

    override fun onStopListening() {
        handler.removeCallbacks(tick)
        super.onStopListening()
    }

    override fun onClick() {
        super.onClick()
        val ctx = applicationContext
        if (Focus.active(ctx) != null) {
            Focus.stop(ctx, fromApp = false)
        } else {
            Focus.startFromTile(ctx)
        }
        handler.removeCallbacks(tick)
        tick.run()
    }

    private fun render() {
        val tile = qsTile ?: return
        val active = Focus.active(applicationContext)
        val now = System.currentTimeMillis()
        tile.icon = Icon.createWithResource(this, R.drawable.ic_tile_focus)
        tile.label = "Focus"
        if (active != null && active.end > now) {
            val left = ((active.end - now + 59_999L) / 60_000L).coerceAtLeast(1L)
            tile.state = Tile.STATE_ACTIVE
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) tile.subtitle = "$left min left"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) tile.stateDescription = "Focusing, $left minutes left"
        } else {
            tile.state = Tile.STATE_INACTIVE
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) tile.subtitle = "${Focus.TILE_MINUTES} min"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) tile.stateDescription = "Off"
        }
        tile.updateTile()
    }
}
