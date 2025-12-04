package com.example.smart_house

import com.example.smart_house.managers.AuthManager
import com.example.smart_house.managers.HomeManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val AUTH_CHANNEL = "tuya_auth"
    private val HOME_CHANNEL = "tuya_home"

    private lateinit var authManager: AuthManager
    private lateinit var homeManager: HomeManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize managers
        authManager = AuthManager(this)
        homeManager = HomeManager(this)

        // Setup Auth Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTH_CHANNEL)
                .setMethodCallHandler { call, result -> authManager.handleMethodCall(call, result) }

        // Setup Home Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HOME_CHANNEL)
                .setMethodCallHandler { call, result -> homeManager.handleMethodCall(call, result) }
    }
}
