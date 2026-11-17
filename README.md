# NexusHome

[![NexusHome CI/CD Pipeline](https://github.com/Safeer-Hussain/nexushome/actions/workflows/ci.yml/badge.svg)](https://github.com/Safeer-Hussain/nexushome/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-emerald)](#system-architecture)
[![License](https://img.shields.io/badge/License-Proprietary-blue)](#confidentiality--clean-room-disclaimer)

NexusHome is an architectural Smart Home IoT Automation Ecosystem, Matter/Thread Mesh Network Controller, Real-Time Solar & Energy Grid Telemetry Platform, Native IoT Hardware Bridge, and On-Device AI Home Copilot engineered in Flutter.

Designed for high-performance zero-cloud residential sanctuaries, NexusHome operates completely offline via an edge-first SQLite database and native Android (Kotlin) and iOS (Swift) platform channels.

---

## System Architecture

NexusHome enforces a strict Feature-First Clean Architecture + MVVM design pattern:

```mermaid
graph TD
    subgraph Presentation Layer
        UI[AdaptiveScaffold & Multi-Screen Views]
        Notifiers[Riverpod State Notifiers]
        Theme[Dynamic Obsidian / Architectural Light Theme]
    end

    subgraph Domain Layer
        Entities[DeviceEntity, MeshNodeEntity, TelemetryEntity]
    end

    subgraph Data Layer
        Models[DeviceModel, MeshNodeModel, RuleModel]
        Repos[DeviceRepository, EnergyRepository, MeshRepository]
    end

    subgraph Infrastructure & Native Bridges
        DB[(Local SQLite AppDatabase)]
        Prefs[(SharedPreferences)]
        MatterBridge[MethodChannel: com.safeer.nexushome/matter_bridge]
        EnergyChannel[EventChannel: com.safeer.nexushome/energy_telemetry]
    end

    UI --> Notifiers
    Notifiers --> Repos
    Repos --> Models
    Models --> Entities
    Repos --> DB
    Repos --> Prefs
    Repos --> MatterBridge
    Repos --> EnergyChannel
```

---

## State Flow & Reactive Mutations

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as DeviceCard / ControlSheet
    participant Notifier as DeviceListNotifier (Riverpod)
    participant Repo as DeviceRepository
    participant DB as SQLite (AppDatabase)
    participant Native as MatterNativeBridge (Kotlin/Swift)

    User->>UI: Tap Power Toggle / Adjust Dimmer
    UI->>Notifier: togglePower(deviceId)
    Note over Notifier: Optimistic Immutable State Update (state = [...])
    Notifier-->>UI: Immediate Widget Rebuild (0ms lag)
    Notifier->>Repo: togglePower(id, isPowered)
    Repo->>DB: UPDATE devices SET is_powered = 1
    Repo->>Native: MethodChannel.invokeMethod('toggleDevicePower')
    Native-->>Repo: Status OK (14ms mesh latency)
```

---

## Native Matter / Thread Mesh Telemetry Flow

```mermaid
sequenceDiagram
    autonumber
    participant SmartMeter as Smart Meter & Inverter
    participant Native as Android / iOS EventChannel
    participant Bridge as MatterNativeBridge
    participant StreamProvider as energyTelemetryStreamProvider
    participant View as EnergyView & Flow Diagram

    SmartMeter->>Native: 2-Second Telemetry Pulse
    Native->>Bridge: EventSink.success(Packet)
    Bridge->>StreamProvider: Stream.map(EnergyTelemetryModel)
    StreamProvider->>View: Reactive UI Update (Solar kW, Load kW, Battery SoC %)
```

---

## Core Feature Matrix

| Feature Module | Technical Specification | Operational State |
| :--- | :--- | :--- |
| **Room Floorplan Hub** | Filterable by Living Room, Master Suite, Kitchen, Office, Garage with explicit `mainAxisExtent: 145` | Production Ready |
| **Device Control Studio** | Brightness (0-100%), Kelvin temperature (2700K-6500K), HVAC thermostat dial (16°C-30°C), PIN-protected deadbolt | Production Ready |
| **Thread Mesh Canvas** | CustomPainter topology graph, pulsing Border Router node, hop counts, dBm signal diagnostics | Production Ready |
| **Matter Commissioning** | 11-digit Matter pairing code validator, quick-discovery beacon shortcuts, instant node generation | Production Ready |
| **Solar & Grid Analytics** | Directional power bus, full-width `fl_chart` 24h diurnal dual-line chart, USD / PKR tariff calculator | Production Ready |
| **Automations & Scenes** | One-tap quick scenes ("Good Morning", "Cinema Mode", "Eco Saver"), IF-THEN rule builder | Production Ready |
| **Security Sentinel** | Armed Home / Armed Away / Disarmed states, live camera cards, PIR motion event stream | Production Ready |
| **On-Device AI Copilot** | Contextual power auditor, token streaming guarded in `try ... finally`, one-tap efficiency prompts | Production Ready |
| **EV Smart Charger (Level 2)** | Dynamic 6A-32A current slider, battery SoC gauge, off-peak tariff scheduler (23:00-06:00), fast-charge boost override | Production Ready |
| **Circadian Adaptive Engine** | Astronomical solar elevation angle solver, 2700K-5500K smooth cubic curve, 15-min periodic batch Thread node dispatch | Production Ready |
| **Recruiter Debug Drawer** | Latency simulator (100-1500ms), HTTP 503 cloud outage toggle, motion trigger injection | Production Ready |

---

## Quality Gate & Verification

The project includes a standalone gatekeeper script `tool/sprint_gate.dart`:

```bash
dart run tool/sprint_gate.dart
```

This sequentially enforces:
1. `flutter pub get`
2. `dart format lib test tool`
3. `flutter analyze --no-fatal-infos --no-pub`
4. `flutter test --no-pub`
5. Connected Android physical device runtime check (`adb logcat -d` for RenderFlex or duplicate Hero tags).

---

## Confidentiality & Clean-Room Disclaimer

This software and its documentation are developed under a clean-room protocol for Safeer Hussain. All architectural patterns, mock network interceptors, Matter platform bridges, and AI Copilot engines are original implementations utilizing open standards.
