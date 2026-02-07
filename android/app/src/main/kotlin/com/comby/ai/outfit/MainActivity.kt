package com.comby.ai.outfit.generator.tryon.wardrobe.fitcheck.style

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.media.AudioManager

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 🔑 Telefon ses tuşlarıyla kontrol edilebilir hale getir
        volumeControlStream = AudioManager.STREAM_VOICE_CALL
    }
}
