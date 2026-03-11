package com.enocderit.meditest.healthcare_homelab

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.enocderit.meditest/pdf_saver"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "savePdfToDownloads" -> {
                        val name = call.argument<String>("name")
                        val bytes = call.argument<ByteArray>("bytes")
                        val subDir = call.argument<String>("subDir")
                        if (name == null || bytes == null) {
                            result.error(
                                "INVALID_ARGS",
                                "name or bytes is null",
                                null
                            )
                            return@setMethodCallHandler
                        }
                        try {
                            val uri = savePdfToDownloads(name, bytes, subDir)
                            result.success(uri.toString())
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun savePdfToDownloads(
        name: String,
        bytes: ByteArray,
        subDir: String?
    ): android.net.Uri? {
        val resolver = contentResolver
        val fileName = if (name.endsWith(".pdf")) name else "$name.pdf"

        val contentValues = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val relativePath = if (!subDir.isNullOrEmpty()) {
                    Environment.DIRECTORY_DOWNLOADS + "/" + subDir
                } else {
                    Environment.DIRECTORY_DOWNLOADS
                }
                put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
        }

        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Downloads.EXTERNAL_CONTENT_URI
        }

        val uri = resolver.insert(collection, contentValues)
            ?: throw IllegalStateException("Failed to create new MediaStore record")

        resolver.openOutputStream(uri)?.use { out ->
            out.write(bytes)
            out.flush()
        } ?: throw IllegalStateException("Failed to open output stream")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            contentValues.clear()
            contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)
        }

        return uri
    }
}
