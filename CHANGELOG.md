# Changelog

All notable changes to the NexusHome project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-11-18

### Added
- **Emergency Priority Pipeline**: Sub-50ms automated emergency override for critical smoke, water leak, and carbon monoxide alarms.
- **Hardware Emergency Overrides**: Immediate egress unlocking of all perimeter deadbolts upon alarm detection.
- **Flood Mitigation**: Automatic closure and isolation of main water shutoff valves upon conductive sub-floor leak detection.
- **Evacuation Strobe**: High-visibility 2700K amber strobe (100% brightness) across all interior luminaires.
- **Persistent Audit Logging**: SQLite `emergency_events` table tracking timestamps, event severity, source beacons, and executed mitigation actions.
- **Emergency Alert UI Banner**: Non-blocking real-time alert container with instant dismiss and action status readouts.
- **Recruiter Debug Simulation**: Dedicated buttons to inject simulated smoke and water leak alarms directly from the debug drawer.
- **GitHub Actions Release Workflow**: Automated release workflow building `app-release.apk` and publishing assets to GitHub Releases.

## [1.0.0] - 2026-11-16

### Added
- Initial production release of NexusHome IoT Automation Ecosystem.
- Clean Architecture + MVVM foundation with Riverpod and GetIt.
- Native Android (Kotlin) & iOS (Swift) Matter / Thread mesh bridge and smart-meter telemetry EventChannel.
- Floorplan Hub, Matter Mesh Canvas, Real-Time Solar & Energy Analytics with `fl_chart`.
- Autonomous 25-sprint backlog and gatekeeper verification protocol.
- Sprint 01: EV Charger Smart Off-Peak Scheduler with 6A-32A dynamic current modulation.
- Sprint 02: Circadian Adaptive Lighting Curve Engine with astronomical solar angle solver.
