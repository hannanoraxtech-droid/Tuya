package com.example.smart_house.managers

import android.content.Context
import android.util.Log
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
import com.thingclips.smart.sdk.api.IResultCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class HomeManager(private val context: Context) {

    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getHomeList" -> {
                getHomeList(result)
            }
            "createHome" -> {
                val name = call.argument<String>("name") ?: ""
                val geoName = call.argument<String>("geoName") ?: ""
                val latitude = call.argument<Double>("latitude") ?: 0.0
                val longitude = call.argument<Double>("longitude") ?: 0.0
                val rooms = call.argument<List<String>>("rooms") ?: emptyList()
                createHome(name, longitude, latitude, geoName, rooms, result)
            }
            "deleteHome" -> {
                val homeId = (call.argument<Any>("homeId") as? Number)?.toLong() ?: 0L
                deleteHome(homeId, result)
            }
            "updateHomeName" -> {
                val homeId = (call.argument<Any>("homeId") as? Number)?.toLong() ?: 0L
                val name = call.argument<String>("name") ?: ""
                val geoName = call.argument<String>("geoName") ?: ""
                val latitude = call.argument<Double>("latitude") ?: 0.0
                val longitude = call.argument<Double>("longitude") ?: 0.0
                updateHomeName(homeId, name, longitude, latitude, geoName, result)
            }
            "getHomeDetail" -> {
                val homeId = (call.argument<Any>("homeId") as? Number)?.toLong() ?: 0L
                getHomeDetail(homeId, result)
            }
            else -> result.notImplemented()
        }
    }

    /** Get list of all homes */
    private fun getHomeList(result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "Getting home list")

            ThingHomeSdk.getHomeManagerInstance()
                    .queryHomeList(
                            object : IThingGetHomeListCallback {
                                override fun onSuccess(homeBeans: List<HomeBean>?) {
                                    if (homeBeans != null) {
                                        val homeList =
                                                homeBeans.map { home ->
                                                    mapOf(
                                                            "homeId" to home.homeId,
                                                            "name" to home.name,
                                                            "geoName" to (home.geoName ?: ""),
                                                            "latitude" to home.lat,
                                                            "longitude" to home.lon,
                                                            "admin" to home.isAdmin,
                                                            "roomCount" to (home.rooms?.size ?: 0),
                                                            "deviceCount" to
                                                                    (home.deviceList?.size ?: 0)
                                                    )
                                                }
                                        Log.d(
                                                "TuyaSDK",
                                                "Home list retrieved: ${homeList.size} homes"
                                        )
                                        result.success(homeList)
                                    } else {
                                        result.success(emptyList<Map<String, Any>>())
                                    }
                                }

                                override fun onError(errorCode: String?, error: String?) {
                                    Log.e("TuyaSDK", "Get home list failed: $errorCode - $error")
                                    result.error(
                                            errorCode ?: "unknown",
                                            error ?: "Failed to get home list",
                                            null
                                    )
                                }
                            }
                    )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception getting home list: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Create a new home */
    private fun createHome(
            name: String,
            lon: Double,
            lat: Double,
            geoName: String,
            rooms: List<String>,
            result: MethodChannel.Result
    ) {
        if (name.isEmpty()) {
            result.error("invalid_name", "Home name cannot be empty", null)
            return
        }

        if (name.length > 25) {
            result.error("invalid_name", "Home name must be 25 characters or less", null)
            return
        }

        try {
            Log.d("TuyaSDK", "Creating home: $name at ($lat, $lon)")

            ThingHomeSdk.getHomeManagerInstance()
                    .createHome(
                            name,
                            lon,
                            lat,
                            geoName,
                            rooms,
                            object : IThingHomeResultCallback {
                                override fun onSuccess(homeBean: HomeBean?) {
                                    if (homeBean != null) {
                                        Log.d(
                                                "TuyaSDK",
                                                "Home created successfully: ${homeBean.homeId}"
                                        )
                                        result.success(homeBean.homeId.toInt())
                                    } else {
                                        result.error(
                                                "creation_failed",
                                                "Home created but no data returned",
                                                null
                                        )
                                    }
                                }

                                override fun onError(errorCode: String?, errorMsg: String?) {
                                    Log.e("TuyaSDK", "Create home failed: $errorCode - $errorMsg")
                                    result.error(
                                            errorCode ?: "unknown",
                                            errorMsg ?: "Failed to create home",
                                            null
                                    )
                                }
                            }
                    )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception creating home: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Delete a home */
    private fun deleteHome(homeId: Long, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "Deleting home: $homeId")

            val home = ThingHomeSdk.newHomeInstance(homeId)
            home.dismissHome(
                    object : IResultCallback {
                        override fun onSuccess() {
                            Log.d("TuyaSDK", "Home deleted successfully")
                            result.success("success")
                        }

                        override fun onError(code: String?, error: String?) {
                            Log.e("TuyaSDK", "Delete home failed: $code - $error")
                            result.error(code ?: "unknown", error ?: "Failed to delete home", null)
                        }
                    }
            )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception deleting home: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Update home information */
    private fun updateHomeName(
            homeId: Long,
            name: String,
            lon: Double,
            lat: Double,
            geoName: String,
            result: MethodChannel.Result
    ) {
        if (name.isEmpty()) {
            result.error("invalid_name", "Home name cannot be empty", null)
            return
        }

        if (name.length > 25) {
            result.error("invalid_name", "Home name must be 25 characters or less", null)
            return
        }

        try {
            Log.d("TuyaSDK", "Updating home: $homeId -> $name")

            val home = ThingHomeSdk.newHomeInstance(homeId)
            home.updateHome(
                    name,
                    lon,
                    lat,
                    geoName,
                    object : IResultCallback {
                        override fun onSuccess() {
                            Log.d("TuyaSDK", "Home updated successfully")
                            result.success("success")
                        }

                        override fun onError(code: String?, error: String?) {
                            Log.e("TuyaSDK", "Update home failed: $code - $error")
                            result.error(code ?: "unknown", error ?: "Failed to update home", null)
                        }
                    }
            )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception updating home: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }

    /** Get home details */
    private fun getHomeDetail(homeId: Long, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "Getting home detail: $homeId")

            val home = ThingHomeSdk.newHomeInstance(homeId)
            home.getHomeDetail(
                    object : IThingHomeResultCallback {
                        override fun onSuccess(homeBean: HomeBean?) {
                            if (homeBean != null) {
                                val homeDetail =
                                        mapOf(
                                                "homeId" to homeBean.homeId,
                                                "name" to homeBean.name,
                                                "geoName" to (homeBean.geoName ?: ""),
                                                "latitude" to homeBean.lat,
                                                "longitude" to homeBean.lon,
                                                "admin" to homeBean.isAdmin,
                                                "roomCount" to (homeBean.rooms?.size ?: 0),
                                                "deviceCount" to (homeBean.deviceList?.size ?: 0),
                                                "groupCount" to (homeBean.groupList?.size ?: 0)
                                        )
                                Log.d("TuyaSDK", "Home detail retrieved successfully")
                                result.success(homeDetail)
                            } else {
                                result.error("not_found", "Home not found", null)
                            }
                        }

                        override fun onError(errorCode: String?, errorMsg: String?) {
                            Log.e("TuyaSDK", "Get home detail failed: $errorCode - $errorMsg")
                            result.error(
                                    errorCode ?: "unknown",
                                    errorMsg ?: "Failed to get home detail",
                                    null
                            )
                        }
                    }
            )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception getting home detail: ${e.message}")
            result.error("exception", e.message ?: "Unknown error", null)
        }
    }
}
