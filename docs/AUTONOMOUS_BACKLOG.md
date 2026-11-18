# NexusHome Autonomous Engineering Sprint Backlog

This document defines the 25 daily engineering sprints for NexusHome. Each sprint is structured with granular user stories, technical tasks, and acceptance criteria. When executing the autonomous sprint protocol, the engine reads this file, selects the first uncompleted `[ ]` sprint, builds it, verifies via `tool/sprint_gate.dart`, checks off the box `[x]`, and commits.

---

### [x] Sprint 01: EV Charger Smart Off-Peak Scheduler
- **User Story**: As an electric vehicle owner, I want NexusHome to automatically defer EV charging to lowest-tariff midnight hours or solar peak windows so I minimize charging costs.
- **Technical Scope**: Add EV Charger device type, integrate charging current slider (6A - 32A), off-peak scheduling logic in SQLite, and dynamic tariff trigger.
- **Acceptance Criteria**: EV charging stops during peak tariff windows (17:00-21:00) and resumes automatically at off-peak. Passes all unit and widget tests.
- **Status**: COMPLETED (Automated Gatekeeper Verified, 26 Tests Passing, SQLite Seeding & UI Controls Active)

---

### [x] Sprint 02: Circadian Adaptive Lighting Curve Engine
- **User Story**: As a resident, I want interior luminaire color temperatures to smoothly transition from crisp 5500K daylight down to warm 2700K amber at sunset to protect natural circadian rhythms.
- **Technical Scope**: Add astronomical solar angle calculator in Dart, periodic curve evaluator, and batch attribute dispatch to Thread light nodes.
- **Acceptance Criteria**: Color temperature updates smoothly across active lights every 15 minutes based on local astronomical time.
- **Status**: COMPLETED (Automated Gatekeeper Verified, 36 Tests Passing, Astronomical Calculator & Periodic Batch Dispatch Active)

---

### [x] Sprint 03: Water Leak & Smoke Sensor Emergency Override
- **User Story**: As a homeowner, I want critical emergency alarms (water leak, smoke detection) to immediately cut main water valves, unlock exit deadbolts, and trigger audio-visual strobe alerts.
- **Technical Scope**: Implement emergency priority channel in `AppDatabase`, immediate non-blocking UI alert banner, and automated perimeter deadbolt unlocking.
- **Acceptance Criteria**: Simulated sensor event unlocks doors within 50ms and turns interior lights to high-visibility amber.
- **Status**: COMPLETED (Automated Gatekeeper Verified, 41 Tests Passing, Sub-50ms Lock/Valve/Amber Override Active)

---

### [ ] Sprint 04: Multi-Zone Audio Grouping Controller
- **User Story**: As a smart home user, I want to group smart speakers across Living Room, Kitchen, and Patio for synchronized whole-home audio playback.
- **Technical Scope**: Add media player entity, volume slider, group/ungroup toggle, and Matter Cast bridge method channel calls.
- **Acceptance Criteria**: Audio groups can be formed and volume adjusted uniformly or per-zone with zero latency drift.

---

### [ ] Sprint 05: Monthly Utility Bill Predictor & Carbon Offset Calculator
- **User Story**: As an eco-conscious resident, I want an accurate projection of monthly electric billing and net kg CO2 offset achieved by rooftop solar.
- **Technical Scope**: Integrate mathematical regression based on 24-hour telemetry history, historical billing tariffs, and EPA carbon factor (0.85 lbs CO2 / kWh).
- **Acceptance Criteria**: Displays real-time estimated monthly cost in USD/PKR alongside cumulative kg CO2 saved this billing cycle.

---

### [ ] Sprint 06: Matter Device Firmware OTA Update Manager
- **User Story**: As an IoT administrator, I want to audit Thread and Matter hardware firmware versions and trigger localized over-the-air firmware updates via the Border Router.
- **Technical Scope**: Add firmware metadata fields to `mesh_nodes` table, OTA progress bar widget, and method channel simulation.
- **Acceptance Criteria**: Device displays update available badge, and 1-tap update completes with simulated transfer progress.

---

### [ ] Sprint 07: Dynamic Smart Blinds Solar Heat Gain Mitigation
- **User Story**: As a homeowner, I want motorized blinds on south-facing windows to adjust tilt during peak solar irradiance to reduce air-conditioning load.
- **Technical Scope**: Add sun-azimuth calculation and automated blinds position rule triggered by solar generation > 4.5 kW.
- **Acceptance Criteria**: Blinds automatically angle to 35% when solar irradiance reaches peak threshold.

---

### [ ] Sprint 08: Geofencing Auto-Arming & Arrival Welcome Scene
- **User Story**: As a resident, I want NexusHome to arm security when all family members leave the geofence perimeter and execute the Welcome scene upon arrival.
- **Technical Scope**: Add simulated geofence radius trigger, distance evaluation in `AutomationRepository`, and perimeter state transitions.
- **Acceptance Criteria**: Simulated location exit arms all deadbolts and transitions HVAC to Eco mode.

---

### [ ] Sprint 09: Air Quality Index (AQI) Auto-Purifier Integration
- **User Story**: As an allergy sufferer, I want indoor air purifiers to spin up to maximum filtration whenever PM2.5 or VOC thresholds spike.
- **Technical Scope**: Add PM2.5 / VOC metrics to `EnvironmentBar`, create auto-purifier speed control entity, and IF-THEN rule.
- **Acceptance Criteria**: Simulated particulate spike triggers purifier from Low to Turbo within 1 frame.

---

### [ ] Sprint 10: Home Battery Wall Peak-Shaving Arbitrage Engine
- **User Story**: As a solar-battery owner, I want my battery to discharge into the home during peak grid tariff hours to avoid high utility charges.
- **Technical Scope**: Implement battery discharge scheduler comparing tariff cost vs. battery cycle wear cost.
- **Acceptance Criteria**: Grid import drops to 0 kW during peak tariff hours when battery SoC is > 30%.

---

### [ ] Sprint 11: Biometric Fingerprint & Face Unlock for Smart Deadbolts
- **User Story**: As a security-conscious resident, I want to authenticate via local biometric sensor (fingerprint/FaceID) to unlock perimeter deadbolts without manual PIN entry.
- **Technical Scope**: Add biometric authentication fallback handler and visual biometric unlock button in `DeviceControlSheet`.
- **Acceptance Criteria**: Valid biometric challenge immediately unlocks deadbolt without revealing PIN on screen.

---

### [ ] Sprint 12: Heat Pump Water Heater Eco Mode Optimization
- **User Story**: As an energy manager, I want my hybrid water heater to run in heat-pump-only mode during peak solar hours and hibernate during peak grid tariff.
- **Technical Scope**: Add water heater device type with temperature buffer slider (45°C - 60°C) and solar excess diversion logic.
- **Acceptance Criteria**: Water heater powers on only when rooftop solar surplus exceeds 1.5 kW.

---

### [ ] Sprint 13: Thread Mesh Signal Heatmap & Repeater Placement Advisor
- **User Story**: As a network integrator, I want visual recommendations on optimal Thread repeater placement based on low RSSI dead zones.
- **Technical Scope**: Add distance and signal attenuation heatmap overlay to `MeshCanvas` with color-coded signal contours.
- **Acceptance Criteria**: Nodes with RSSI < -60 dBm highlight yellow/amber and display recommended repeater positions.

---

### [ ] Sprint 14: Guest Access PIN Code Generator with Time Expiry
- **User Story**: As a host, I want to generate temporary 4-digit guest access PINs for the front deadbolt that automatically expire after a set duration.
- **Technical Scope**: Add `guest_pins` table in SQLite, duration selector (1 hour - 7 days), and auto-revocation logic.
- **Acceptance Criteria**: Expired PINs are rejected with inline error and logged to Security Sentinel timeline.

---

### [ ] Sprint 15: Refrigerator & Freezer Door Ajar Vigilance Sentinel
- **User Story**: As a homeowner, I want an alert if the kitchen refrigerator or freezer door remains open for more than 3 minutes to avoid food spoilage.
- **Technical Scope**: Add contact sensor timer evaluator in `AutomationRepository` and persistent notification banner.
- **Acceptance Criteria**: Contact sensor open for > 180 seconds raises warning notification in Security Sentinel feed.

---

### [ ] Sprint 16: Swimming Pool Pump Solar-Surplus Diverter
- **User Story**: As a pool owner, I want pool filtration pumps to run exclusively during peak solar over-generation periods.
- **Technical Scope**: Add pool pump wattage profile (1200W) and dynamic solar surplus diversion controller.
- **Acceptance Criteria**: Pump activates when solar generation exceeds home load by at least 1500W for 5 continuous minutes.

---

### [ ] Sprint 17: Local Offline Voice Command Intent Parser
- **User Story**: As a resident, I want to type or speak natural voice commands ("turn off living room lights", "set temperature to 21 degrees") and have them parsed locally.
- **Technical Scope**: Implement regex/token intent parser in `AiCopilotNotifier` mapping phrases to direct SQLite device mutations.
- **Acceptance Criteria**: Natural language command mutates target device state directly without external API calls.

---

### [ ] Sprint 18: Smart Irrigation Soil Moisture & Weather Forecast Engine
- **User Story**: As a gardener, I want smart sprinkler valves to skip scheduled watering if soil moisture is above 60% or rain is detected.
- **Technical Scope**: Add multi-zone sprinkler controller entity, moisture threshold rules, and rain sensor feed.
- **Acceptance Criteria**: Irrigation cycle suppresses with "Skipped - Soil Moisture Adequate (68%)" notification.

---

### [ ] Sprint 19: Real-Time Grid Frequency & Harmonic Health Monitor
- **User Story**: As a power quality enthusiast, I want to monitor utility grid frequency (50.0 Hz / 60.0 Hz) and line voltage fluctuations to protect sensitive electronics.
- **Technical Scope**: Add line frequency gauge and voltage fluctuation history graph in `EnergyView`.
- **Acceptance Criteria**: Line frequency outside 49.8 - 50.2 Hz triggers power quality warning banner.

---

### [ ] Sprint 20: Presence-Based HVAC Micro-Zoning
- **User Story**: As a homeowner, I want unoccupied rooms to drift into eco temperature bands and return to comfort mode upon occupancy detection.
- **Technical Scope**: Add room-level occupancy timers linked to PIR motion sensors, adjusting target temps by +/- 2.0°C.
- **Acceptance Criteria**: Room unoccupied for 45 minutes drifts temperature to 25.0°C; motion resets to 22.0°C immediately.

---

### [ ] Sprint 21: Generator & Microgrid Islanding Transfer Switch
- **User Story**: As a resilient homeowner, I want seamless monitoring of microgrid transfer switch state during utility grid blackouts.
- **Technical Scope**: Add Island Mode status badge, critical load shedding matrix, and emergency generator telemetry.
- **Acceptance Criteria**: Grid disconnection switches app to "Microgrid Island Mode" shedding non-critical HVAC zones.

---

### [ ] Sprint 22: Smart Window Contact & HVAC Lockout Interlock
- **User Story**: As an efficiency purist, I want HVAC in a room to shut off automatically if windows in that room are opened for more than 2 minutes.
- **Technical Scope**: Create window-to-HVAC interlock rule engine in `AutomationRepository`.
- **Acceptance Criteria**: Opening panoramic window pauses living room HVAC controller with "Paused: Window Open" status.

---

### [ ] Sprint 23: Child Lock & Hardware Touch-Panel Tamper Shield
- **User Story**: As a parent, I want to lock physical wall switches and thermostat dials so children cannot accidentally alter temperature or lights.
- **Technical Scope**: Add tamper child-lock toggle to device attributes and native platform method channel.
- **Acceptance Criteria**: Enabling child-lock reflects on device card and prevents touch alterations without biometric unlock.

---

### [ ] Sprint 24: Comprehensive Energy Telemetry CSV & Parquet Exporter
- **User Story**: As an energy analyst, I want to export full-year hourly telemetry into CSV and Parquet formats for custom analysis in Python/Pandas.
- **Technical Scope**: Implement streaming CSV generator with timestamps, kWh generation, load, battery SoC, and grid exchange.
- **Acceptance Criteria**: Export action generates formatted CSV file and triggers system share sheet.

---

### [ ] Sprint 25: 3D Isometric Home Floorplan Visualizer
- **User Story**: As a high-tech homeowner, I want an interactive 3D isometric representation of my home with glowing lights and live device statuses in real-time.
- **Technical Scope**: Custom isometric canvas renderer in Flutter using matrix transformations, interactive room selection, and live node states.
- **Acceptance Criteria**: Interactive 3D rooms reflect real-time on/off states and allow direct tap-to-toggle interaction.
