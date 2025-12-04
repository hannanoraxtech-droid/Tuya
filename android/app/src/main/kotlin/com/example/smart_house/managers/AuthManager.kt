package com.example.smart_house.managers

import android.content.Context
import android.util.Log
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.android.user.api.IRegisterCallback
import com.thingclips.smart.android.user.api.IResetPasswordCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.sdk.api.IResultCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AuthManager(private val context: Context) {

    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendEmailCode" -> {
                val email = call.argument<String>("email") ?: ""
                val type = call.argument<Int>("type") ?: 1
                sendEmailCode(email, type, result)
            }
            "registerEmail" -> {
                val email = call.argument<String>("email") ?: ""
                val code = call.argument<String>("code") ?: ""
                val password = call.argument<String>("password") ?: ""
                registerEmail(email, code, password, result)
            }
            "loginEmail" -> {
                val email = call.argument<String>("email") ?: ""
                val password = call.argument<String>("password") ?: ""
                loginEmail(email, password, result)
            }
            "resetEmailPassword" -> {
                val email = call.argument<String>("email") ?: ""
                val code = call.argument<String>("code") ?: ""
                val newPassword = call.argument<String>("password") ?: ""
                resetEmailPassword(email, code, newPassword, result)
            }
            "testNetwork" -> testNetwork(result)
            "isLogin" -> isLogin(result)
            "logout" -> logout(result)
            else -> result.notImplemented()
        }
    }

    /** Test network connectivity */
    private fun testNetwork(result: MethodChannel.Result) {
        Thread {
                    try {
                        val google = java.net.InetAddress.getByName("google.com")
                        val tuya = java.net.InetAddress.getByName("a1.tuyaus.com")
                        result.success(
                                "Network OK: Google=${google.hostAddress}, Tuya=${tuya.hostAddress}"
                        )
                    } catch (e: Exception) {
                        result.error("network_error", e.message ?: "Unknown network error", null)
                    }
                }
                .start()
    }

    /** Send verification code (registration or reset password) */
    private fun sendEmailCode(email: String, type: Int, result: MethodChannel.Result) {
        try {
            val countryCode = "1"
            when (type) {
                1 -> { // Registration
                    ThingHomeSdk.getUserInstance()
                            .sendVerifyCodeWithUserName(
                                    email,
                                    "",
                                    countryCode,
                                    1,
                                    object : IResultCallback {
                                        override fun onSuccess() {
                                            Log.d(
                                                    "TuyaSDK",
                                                    "Verification code sent for registration"
                                            )
                                            result.success("success")
                                        }

                                        override fun onError(code: String?, error: String?) {
                                            Log.e("TuyaSDK", "Send code failed: $code - $error")
                                            result.error(
                                                    code ?: "unknown",
                                                    error ?: "Send code failed",
                                                    null
                                            )
                                        }
                                    }
                            )
                }
                3 -> { // Reset password
                    ThingHomeSdk.getUserInstance()
                            .sendVerifyCodeWithUserName(
                                    email,
                                    "",
                                    countryCode,
                                    3,
                                    object : IResultCallback {
                                        override fun onSuccess() {
                                            Log.d(
                                                    "TuyaSDK",
                                                    "Verification code sent for password reset"
                                            )
                                            result.success("success")
                                        }

                                        override fun onError(code: String?, error: String?) {
                                            Log.e(
                                                    "TuyaSDK",
                                                    "Send reset code failed: $code - $error"
                                            )
                                            result.error(
                                                    code ?: "unknown",
                                                    error ?: "Send reset code failed",
                                                    null
                                            )
                                        }
                                    }
                            )
                }
                else -> result.error("unknown_type", "Unknown type: $type", null)
            }
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception sending code: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Register account using email + code + password */
    private fun registerEmail(
            email: String,
            code: String,
            password: String,
            result: MethodChannel.Result
    ) {
        try {
            val countryCode = "1"
            ThingHomeSdk.getUserInstance()
                    .registerAccountWithEmail(
                            countryCode,
                            email,
                            password,
                            code,
                            object : IRegisterCallback {
                                override fun onSuccess(user: User) {
                                    Log.d(
                                            "TuyaSDK",
                                            "User registration successful: ${user.username}"
                                    )
                                    result.success("registered")
                                }

                                override fun onError(code: String?, error: String?) {
                                    Log.e("TuyaSDK", "Registration failed: $code - $error")
                                    result.error(
                                            code ?: "unknown",
                                            error ?: "Registration failed",
                                            null
                                    )
                                }
                            }
                    )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception during registration: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Login using email + password */
    private fun loginEmail(email: String, password: String, result: MethodChannel.Result) {
        try {
            val countryCode = "1"
            ThingHomeSdk.getUserInstance()
                    .loginWithEmail(
                            countryCode,
                            email,
                            password,
                            object : ILoginCallback {
                                override fun onSuccess(user: User) {
                                    Log.d("TuyaSDK", "Login successful: ${user.username}")
                                    result.success(user.uid)
                                }

                                override fun onError(code: String?, error: String?) {
                                    Log.e("TuyaSDK", "Login failed: $code - $error")
                                    result.error(code ?: "unknown", error ?: "Login failed", null)
                                }
                            }
                    )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception during login: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Reset password using email + verification code + new password */
    private fun resetEmailPassword(
            email: String,
            code: String,
            newPassword: String,
            result: MethodChannel.Result
    ) {
        if (code.isEmpty() || newPassword.isEmpty()) {
            result.error("missing_fields", "Verification code and new password are required", null)
            return
        }

        val countryCode = "1"
        ThingHomeSdk.getUserInstance()
                .resetEmailPassword(
                        countryCode,
                        email,
                        code,
                        newPassword,
                        object : IResetPasswordCallback {
                            override fun onSuccess() {
                                Log.d("TuyaSDK", "Password reset successfully")
                                result.success("success")
                            }

                            override fun onError(code: String?, error: String?) {
                                Log.e("TuyaSDK", "Password reset failed: $code - $error")
                                result.error(
                                        code ?: "unknown",
                                        error ?: "Password reset failed",
                                        null
                                )
                            }
                        }
                )
    }

    /** Check if user is currently logged in */
    private fun isLogin(result: MethodChannel.Result) {
        try {
            val isLoggedIn = ThingHomeSdk.getUserInstance().isLogin
            Log.d("TuyaSDK", "Login status check: $isLoggedIn")
            result.success(isLoggedIn)
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception checking login status: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Logout current user */
    private fun logout(result: MethodChannel.Result) {
        try {
            ThingHomeSdk.getUserInstance()
                    .logout(
                            object : ILogoutCallback {
                                override fun onSuccess() {
                                    Log.d("TuyaSDK", "Logout successful")
                                    result.success("success")
                                }

                                override fun onError(code: String?, error: String?) {
                                    Log.e("TuyaSDK", "Logout failed: $code - $error")
                                    result.error(code ?: "unknown", error ?: "Logout failed", null)
                                }
                            }
                    )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception during logout: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }
}
