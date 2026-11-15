# NexusHome Autonomous Engineering Sprint Rules

## Core Operational Protocol: "run daily sprint"

When the user gives the instruction **"run daily sprint"** (or any variation like "execute next sprint", "run sprint", etc.), the autonomous agent MUST execute the following strict 6-phase engineering workflow from start to finish without pausing:

---

### Phase 1: Pre-Flight Integrity Check
1. Run `git status` to verify working directory is clean.
2. Confirm git remote `origin` is authenticated and tracking `main`.
3. Verify that `flutter --version` and dependencies are resolved.

### Phase 2: Autonomous Sprint Selection
1. Open and parse `docs/AUTONOMOUS_BACKLOG.md`.
2. Locate the **first unchecked item** (marked with `[ ] Sprint XX`).
3. Extract the User Story, Technical Scope, and Acceptance Criteria for this sprint.

### Phase 3: Architectural Implementation
1. Follow Feature-First Clean Architecture + MVVM strictly:
   - Domain: Entities & use-case contracts.
   - Data: SQLite schema updates (`AppDatabase`), models, repository implementations.
   - Core / Platform: Native bridges (`MethodChannel`, `EventChannel`) if hardware/protocol-level.
   - Presentation: Riverpod Notifiers, UI widgets, responsive adaptive layouts.
2. Comply with all Anti-AI Hygiene Rules:
   - ZERO hardcoded colors (dynamic `Theme.of(context).colorScheme`).
   - ZERO emojis in source, comments, UI, logs, or commit messages.
   - Explicit unique `heroTag` on any `FloatingActionButton`.
   - 800x360 landscape viewport safe (independent scroll controllers, explicit `mainAxisExtent: 145` on grids, no RenderFlex overflows).
   - Keyboard safety (translucent tap-outside unfocus, no double-applied `viewInsets`).

### Phase 4: Sprint Gatekeeper Verification
1. Run `dart run tool/sprint_gate.dart`.
2. Verify all 5 internal phases pass with exit code 0:
   - `flutter pub get`
   - `dart format lib test tool`
   - `flutter analyze --no-fatal-infos --no-pub`
   - `flutter test --no-pub`
   - Logcat audit (if device attached).

### Phase 5: Backlog & Documentation Update
1. Update `docs/AUTONOMOUS_BACKLOG.md`:
   - Change `[ ] Sprint XX: <Name>` to `[x] Sprint XX: <Name>`.
   - Add completion timestamp and verification notes.

### Phase 6: Conventional Commit & Remote Sync
1. Stage all changes: `git add .`
2. Commit using Conventional Commits format:
   `feat(sprint-XX): implement <sprint-title>`
3. Push directly to remote: `git push origin main`
4. Confirm verification: `git log origin/main..HEAD` MUST be completely empty.
