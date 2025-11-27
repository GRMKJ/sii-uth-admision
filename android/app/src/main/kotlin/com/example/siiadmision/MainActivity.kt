package com.example.siiadmision

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		createDefaultNotificationChannel()
	}

	private fun createDefaultNotificationChannel() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			val channelId = getString(R.string.default_notification_channel_id)
			val channelName = getString(R.string.default_notification_channel_name)
			val channelDesc = getString(R.string.default_notification_channel_desc)

			val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT).apply {
				description = channelDesc
			}

			val manager: NotificationManager? = getSystemService(NotificationManager::class.java)
			manager?.createNotificationChannel(channel)
		}
	}
}
