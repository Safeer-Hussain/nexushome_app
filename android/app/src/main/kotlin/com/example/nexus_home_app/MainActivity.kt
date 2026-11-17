package com.example.nexus_home_app

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random

class MainActivity : FlutterActivity() {
    private val matterChannelName = "com.safeer.nexushome/matter_bridge"
    private val energyTelemetryChannelName = "com.safeer.nexushome/energy_telemetry"

    private var telemetryHandler: Handler? = null
    private var telemetryRunnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Matter / Thread Mesh Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, matterChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "commissionMatterDevice" -> {
                    val pairingCode = call.argument<String>("pairingCode") ?: "UNKNOWN"
                    val deviceType = call.argument<String>("deviceType") ?: "Generic"
                    val room = call.argument<String>("room") ?: "Living Room"

                    val response = mapOf(
                        "status" to "SUCCESS",
                        "nodeId" to "0x" + System.currentTimeMillis().toString(16).takeLast(4).uppercase(),
                        "pairingCode" to pairingCode,
                        "deviceType" to deviceType,
                        "room" to room,
                        "protocol" to "Thread 1.3",
                        "rssi" to (-42 - Random.nextInt(25)),
                        "timestamp" to System.currentTimeMillis()
                    )
                    result.success(response)
                }
                "toggleDevicePower" -> {
                    val deviceId = call.argument<String>("deviceId") ?: ""
                    val isPowered = call.argument<Boolean>("isPowered") ?: false
                    result.success(
                        mapOf(
                            "status" to "OK",
                            "deviceId" to deviceId,
                            "isPowered" to isPowered,
                            "latencyMs" to (12 + Random.nextInt(15))
                        )
                    )
                }
                "setDeviceAttribute" -> {
                    val deviceId = call.argument<String>("deviceId") ?: ""
                    val attribute = call.argument<String>("attribute") ?: ""
                    val value = call.argument<Any>("value")
                    result.success(
                        mapOf(
                            "status" to "UPDATED",
                            "deviceId" to deviceId,
                            "attribute" to attribute,
                            "value" to value
                        )
                    )
                }
                "batchSetDeviceAttribute" -> {
                    val deviceIds = call.argument<List<String>>("deviceIds") ?: emptyList()
                    val attribute = call.argument<String>("attribute") ?: ""
                    val value = call.argument<Any>("value")
                    result.success(
                        mapOf(
                            "status" to "BATCH_DISPATCHED",
                            "affectedDevices" to deviceIds.size,
                            "attribute" to attribute,
                            "value" to value,
                            "latencyMs" to (10 + Random.nextInt(12))
                        )
                    )
                }
                "triggerAutomationScene" -> {
                    val sceneId = call.argument<String>("sceneId") ?: ""
                    val affectedCount = call.argument<Int>("deviceCount") ?: 4
                    result.success(
                        mapOf(
                            "status" to "EXECUTED",
                            "sceneId" to sceneId,
                            "affectedDevices" to affectedCount,
                            "meshTransitTimeMs" to (18 + Random.nextInt(20))
                        )
                    )
                }
                "runMeshDiagnostics" -> {
                    val diagnostics = mapOf(
                        "status" to "HEALTHY",
                        "activeThreadRouters" to 4,
                        "activeEndDevices" to 12,
                        "meshPartitionId" to 1,
                        "averageHopLatencyMs" to 14.2,
                        "borderRouterReachability" to "99.98%",
                        "packetLossRate" to "0.01%"
                    )
                    result.success(diagnostics)
                }
                else -> result.notImplemented()
            }
        }

        // Live Energy Smart-Meter & Telemetry Event Channel (Streams every 2 seconds)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, energyTelemetryChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    telemetryHandler = Handler(Looper.getMainLooper())
                    telemetryRunnable = object : Runnable {
                        override fun run() {
                            val baseSolar = 4.2 + (Random.nextDouble() * 1.6)
                            val baseHomeLoad = 2.4 + (Random.nextDouble() * 1.8)
                            val batterySoc = (82.0 + Random.nextDouble() * 6.0).coerceIn(10.0, 100.0)
                            val gridFlow = (baseHomeLoad - baseSolar) // negative means exporting
                            val voltage = 230.0 + (Random.nextDouble() * 3.5 - 1.7)
                            val meshLatency = 12 + Random.nextInt(10)

                            val packet = mapOf(
                                "timestamp" to System.currentTimeMillis(),
                                "homeLoadWatts" to (baseHomeLoad * 1000.0).toInt(),
                                "solarGenerationWatts" to (baseSolar * 1000.0).toInt(),
                                "batterySocPercent" to (batterySoc * 10.0).toInt() / 10.0,
                                "gridImportExportKw" to ((gridFlow * 100.0).toInt() / 100.0),
                                "lineVoltageV" to ((voltage * 10.0).toInt() / 10.0),
                                "threadMeshLatencyMs" to meshLatency
                            )
                            events?.success(packet)
                            telemetryHandler?.postDelayed(this, 2000)
                        }
                    }
                    telemetryHandler?.post(telemetryRunnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    telemetryRunnable?.let { telemetryHandler?.removeCallbacks(it) }
                    telemetryHandler = null
                    telemetryRunnable = null
                }
            }
        )
    }
}
