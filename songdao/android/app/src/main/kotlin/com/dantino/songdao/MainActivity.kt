package com.dantino.songdao

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app.songdao/app_info",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVersionInfo" -> {
                    val packageInfo = packageManager.getPackageInfo(packageName, 0)
                    result.success(
                        mapOf(
                            "version" to packageInfo.versionName,
                            "buildNumber" to packageInfo.longVersionCode.toString(),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }
}
