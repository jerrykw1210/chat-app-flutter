package my.com.prochat.chat

import io.flutter.embedding.android.FlutterActivity
import io.getstream.video.flutter.stream_video_flutter.service.PictureInPictureHelper

class MainActivity: FlutterActivity() {
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        PictureInPictureHelper.enterPictureInPictureIfInCall(this)
    }
}
