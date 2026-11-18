import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var telemetryTimer: Timer?
  private var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let registrar = engineBridge.pluginRegistry
    guard let binaryMessenger = registrar.value(forKey: "binaryMessenger") as? FlutterBinaryMessenger ??
            (UIApplication.shared.delegate as? FlutterAppDelegate)?.window?.rootViewController as? FlutterBinaryMessenger else {
      return
    }

    setupMatterBridge(messenger: binaryMessenger)
    setupEnergyTelemetry(messenger: binaryMessenger)
  }

  private func setupMatterBridge(messenger: FlutterBinaryMessenger) {
    let matterChannel = FlutterMethodChannel(name: "com.safeer.nexushome/matter_bridge", binaryMessenger: messenger)
    matterChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "commissionMatterDevice":
        let args = call.arguments as? [String: Any]
        let pairingCode = args?["pairingCode"] as? String ?? "UNKNOWN"
        let deviceType = args?["deviceType"] as? String ?? "Generic"
        let room = args?["room"] as? String ?? "Living Room"
        let response: [String: Any] = [
          "status": "SUCCESS",
          "nodeId": String(format: "0x%04X", arc4random_uniform(0xFFFF)),
          "pairingCode": pairingCode,
          "deviceType": deviceType,
          "room": room,
          "protocol": "Thread 1.3",
          "rssi": -45 - Int(arc4random_uniform(20)),
          "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]
        result(response)
      case "toggleDevicePower":
        let args = call.arguments as? [String: Any]
        let deviceId = args?["deviceId"] as? String ?? ""
        let isPowered = args?["isPowered"] as? Bool ?? false
        result([
          "status": "OK",
          "deviceId": deviceId,
          "isPowered": isPowered,
          "latencyMs": 14 + Int(arc4random_uniform(10))
        ])
      case "setDeviceAttribute":
        let args = call.arguments as? [String: Any]
        result([
          "status": "UPDATED",
          "deviceId": args?["deviceId"] ?? "",
          "attribute": args?["attribute"] ?? "",
          "value": args?["value"] ?? ""
        ])
      case "batchSetDeviceAttribute":
        let args = call.arguments as? [String: Any]
        let deviceIds = args?["deviceIds"] as? [String] ?? []
        result([
          "status": "BATCH_DISPATCHED",
          "affectedDevices": deviceIds.count,
          "attribute": args?["attribute"] ?? "",
          "value": args?["value"] ?? "",
          "latencyMs": 11 + Int(arc4random_uniform(8))
        ])
      case "triggerAutomationScene":
        let args = call.arguments as? [String: Any]
        result([
          "status": "EXECUTED",
          "sceneId": args?["sceneId"] ?? "",
          "affectedDevices": args?["deviceCount"] ?? 4,
          "meshTransitTimeMs": 20 + Int(arc4random_uniform(15))
        ])
      case "triggerEmergencyOverride":
        let args = call.arguments as? [String: Any]
        result([
          "status": "EMERGENCY_OVERRIDE_ENGAGED",
          "eventType": args?["eventType"] ?? "UNKNOWN",
          "sourceDevice": args?["sourceDevice"] ?? "Sensor",
          "doorsUnlocked": true,
          "executionLatencyMs": 9 + Int(arc4random_uniform(10))
        ])
      case "runMeshDiagnostics":
        result([
          "status": "HEALTHY",
          "activeThreadRouters": 4,
          "activeEndDevices": 12,
          "meshPartitionId": 1,
          "averageHopLatencyMs": 15.0,
          "borderRouterReachability": "99.98%",
          "packetLossRate": "0.01%"
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setupEnergyTelemetry(messenger: FlutterBinaryMessenger) {
    let telemetryChannel = FlutterEventChannel(name: "com.safeer.nexushome/energy_telemetry", binaryMessenger: messenger)
    telemetryChannel.setStreamHandler(EnergyTelemetryStreamHandler())
  }
}

class EnergyTelemetryStreamHandler: NSObject, FlutterStreamHandler {
  private var timer: Timer?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
      let baseSolar = 4.2 + (Double.random(in: 0.0...1.6))
      let baseHomeLoad = 2.4 + (Double.random(in: 0.0...1.8))
      let batterySoc = min(100.0, max(10.0, 82.0 + Double.random(in: -3.0...3.0)))
      let gridFlow = baseHomeLoad - baseSolar
      let voltage = 230.0 + Double.random(in: -2.0...2.0)

      let packet: [String: Any] = [
        "timestamp": Int(Date().timeIntervalSince1970 * 1000),
        "homeLoadWatts": Int(baseHomeLoad * 1000.0),
        "solarGenerationWatts": Int(baseSolar * 1000.0),
        "batterySocPercent": Double(round(batterySoc * 10) / 10),
        "gridImportExportKw": Double(round(gridFlow * 100) / 100),
        "lineVoltageV": Double(round(voltage * 10) / 10),
        "threadMeshLatencyMs": Int.random(in: 12...22)
      ]
      events(packet)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    timer?.invalidate()
    timer = nil
    return nil
  }
}
