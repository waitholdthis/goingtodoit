# GoingToDoIt — Mobile App

A high-accountability task manager for Android and iOS.

## Setup

```bash
cd goingtodoit_app
flutter pub get
flutter run
```

## Project Structure

- `lib/main.dart` — App entry + Task list UI.
- `lib/core/task_model.dart` — Task data model.
- `lib/core/force_engine.dart` — Deadline evaluation logic.
- `lib/core/escalation_rules.dart` — Snooze credits + escalation levels.
- `lib/data/task_repository.dart` — Local JSON persistence.
- `lib/features/task_creation/task_creation_screen.dart` — New task form.
- `lib/features/deep_links/deep_link_handler.dart` — `tel:`, `mailto:`, `sms:` launcher.
- `lib/features/deadline/deadline_handler.dart` — Notification scheduling stub.

## Permissions

See `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.
