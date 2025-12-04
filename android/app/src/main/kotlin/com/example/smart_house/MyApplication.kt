package com.example.smart_house

import android.app.Application
import android.util.Log
import com.thingclips.smart.home.sdk.ThingHomeSdk

class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        val appKey = "m5axpc3xxeratt7tppx5"     // Access ID
        val appSecret = "fagcvvhy5kn4vtjkf7fm895vnfys594s"  // Access Secret

        // Your SDK version supports this init method
        ThingHomeSdk.init(this, appKey, appSecret)

        ThingHomeSdk.setDebugMode(BuildConfig.DEBUG)

        Log.d("TuyaSDK", "Tuya SDK Initialized ✔")
    }

    override fun onTerminate() {
        super.onTerminate()
        ThingHomeSdk.onDestroy()
        Log.d("TuyaSDK", "Tuya SDK Destroyed")
    }
}
