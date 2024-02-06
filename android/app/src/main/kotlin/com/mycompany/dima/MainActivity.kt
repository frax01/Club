package com.mycompany.dima

import android.util.Log
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    //val _firebaseMessaging: FirebaseMessaging = FirebaseMessaging.instance
    //FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
    //    if (!task.isSuccessful) {
    //        Log.w(TAG, "Fetching FCM registration token failed", task.exception)
    //        return@OnCompleteListener
    //    }
    //
    //    // Get new FCM registration token
    //    val token = task.result
    //
    //    // Log and toast
    //    val msg = getString(R.string.msg_token_fmt, token)
    //    Log.d(TAG, msg)
    //    Toast.makeText(baseContext, msg, Toast.LENGTH_SHORT).show()
  //  })
////
    //override fun onNewToken(token: String) {
    //    Log.d(TAG, "Refreshed token: $token")
    //
    //    // If you want to send messages to this application instance or
    //    // manage this apps subscriptions on the server side, send the
    //    // FCM registration token to your app server.
    //    sendRegistrationToServer(token)
    //}
    //// Declare the launcher at the top of your Activity/Fragment:
    //private val requestPermissionLauncher = registerForActivityResult(
    //    ActivityResultContracts.RequestPermission(),
    //) { isGranted: Boolean ->
    //    if (isGranted) {
    //        // FCM SDK (and your app) can post notifications.
    //    } else {
    //        // TODO: Inform user that that your app will not show notifications.
    //    }
  //  }
////
    //private fun askNotificationPermission() {
    //    // This is only necessary for API level >= 33 (TIRAMISU)
    //    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    //        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
    //            PackageManager.PERMISSION_GRANTED
    //        ) {
    //            // FCM SDK (and your app) can post notifications.
    //        } else if (shouldShowRequestPermissionRationale(Manifest.permission.POST_NOTIFICATIONS)) {
    //            // TODO: display an educational UI explaining to the user the features that will be enabled
    //            //       by them granting the POST_NOTIFICATION permission. This UI should provide the user
    //            //       "OK" and "No thanks" buttons. If the user selects "OK," directly request the permission.
    //            //       If the user selects "No thanks," allow the user to continue without notifications.
    //        } else {
    //            // Directly ask for the permission
    //            requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
    //        }
    //    }
    //}
}
