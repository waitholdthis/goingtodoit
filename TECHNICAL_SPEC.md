# GoingToDoIt — Technical Specification & Feature Roadmap

> **Document status:** v1.0 Draft — Product Concept + Architecture  
> **Repository:** https://github.com/waitholdthis/goingtodoit  

---

## 1. Product Concept Summary

GoingToDoIt is an accountability-first task manager that bridges the gap between "reminding" and "doing" by launching the correct system app at the right moment with the conversation pre-started — turning passive to-dos into executed actions. Moving beyond notifications, it uses platform deep links and user-defined escalation rules to guide the user to completion, while giving them a manual override path that respects real-world constraints like meetings.

---

## 2. Core Feature Architecture

| # | Feature | iOS Feasibility | Android Feasibility | Notes |
|---|---------|----------------|---------------------|-------|
| 1 | **Deep Link to Phone Dialer** | ✅ High — `tel:` URL scheme (opens Phone app with number pre-filled; user must tap Call). Direct `telprompt:` is public API but Apple discourages it; standard `tel:` is allowed. | ✅ High — `tel:` intent works the same way. Third-party dialer handling is allowed via `Intent.createChooser()`. | **Store policy:** Neither platform allows placing the call without an explicit user tap in the foreground. We design for that tap — the app's job is to present the dialer. |
| 2 | **Deep Link to Mail Client** | ✅ High — `mailto:` URL scheme with prefilled `to`, `subject`, `body`. Opens Mail.app or user's default mail client. | ✅ High — `mailto:` intent, same behavior. | **Privacy:** Body/subject are visible to the user before send; we never auto-send. |
| 3 | **SMS / iMessage Quick Launch** | ✅ Medium — `sms:` scheme opens Messages with recipient pre-filled. Apple restricts SMS automation; no auto-send. | ✅ High — `sms:` intent opens default SMS app; user must send. | **Edge case:** Group threads vs 1:1. App enforces 1:1 to reduce policy risk. |
| 4 | **Calendar Event Forcing** | ✅ High — EventKit read/write allows us to block a time slot by creating a busy event titled "GoingToDoIt Action Block" that other event invites treat as a conflict. | ✅ High — `CalendarContract`, `Intent.INSERT` with pre-filled event. | **UX:** User opts in; we don't silently block time. |
| 5 | **Escalation / Penalty Engine** | ✅ High — LocalNotifications + Critical Alerts mode (if user grants). Escalation can auto-repeat notifications at increasing volume/frequency. **No lockouts or forced actions.** | ✅ High — AlarmManager + foreground notification channel for critical tasks. | **Store policy:** Cannot force UI interactions or block other apps. Escalation is notification-only. |

---

## 3. The "Force" Logic — Decision Flow at Deadline

```
[Task Deadline Reached]
           |
           v
[Has user already marked complete?]
           |--- YES --> [Exit: show success toast / haptic]
           |--- NO ---> continue
           |
           v
[Is this a "Full Force" task?]
    (User set at task creation)
           |
           +--- YES --------> [Trigger OS Alarm / Critical Notification]
           |                    |
           |                    v
           |               [Foreground Activity Launched]
           |               (Deep link + confirmation UI)
           |                    |
           |                    v
           |               [User must TAP to Confirm Start]
           |               OR [Tap Snooze (1 of 3 credits/day)]
           |               OR [Tap Skip (logs failure)]
           |
           +--- NO ---------> [Soft notification only]
                                |
                                v
                           [Tap notification -> opens task detail]
                                |
                                v
                           [User manually launches deep link]
```

**Snooze & Escalation rules:**
- Each user day starts with **3 Snooze Credits**.
- Full Force tasks consume 1 credit on snooze; credits regenerate at midnight local time.
- After credits exhaust, snooze button hides; only "Do Now" and "Skip" remain.
- Skipping increments a **Missed Counter** visible on the task card.
- After 3 misses on the same task, app prompts: "Keep or archive?" — never auto-deletes.

---

## 4. Permission Strategy

### Mandatory Permissions

| Permission | iOS | Android | Why It's Needed | Presentation Copy |
|-----------|-----|---------|-----------------|-------------------|
| **Notifications** | `UNUserNotificationCenter` | `POST_NOTIFICATIONS` (API 33+) | Deadline alarms + escalation | "GoingToDoIt needs to reach you at the right moment. Notifications are the backbone of accountability." |
| **Critical Alerts** *(opt-in)* | Critical Alerts entitlement (Apple review required) | Foreground service + `USE_FULL_SCREEN_INTENT` | Bypass Do Not Disturb for time-critical items | "For emergency tasks only (e.g., medication window). You'll never get spam." |
| **Contacts (optional)** | `CNContactStore` read-only | `READ_CONTACTS` | Pre-fill phone/email deep links from address book | "Pick a contact when you build the task — we never upload or share contacts." |
| **Calendar (optional)** | EventKit write | `WRITE_CALENDAR` | Reserve a pre-event block so nothing else schedules over your commitment | "We create a private blocker labeled 'Action Block' — only you see it." |
| **Phone / SMS** *(not strictly requested)* | N/A — `tel:` / `sms:` need no permission | N/A — `tel:` / `sms:` need no runtime permission | Launching dialer / messenger | No permission prompt needed (URL-based). |
| **Location (optional)** | Standard or Precise | `ACCESS_FINE_LOCATION` | Timezone / location-based reminders | "Reminders follow your day — used only for on-device scheduling." |

### Permission UX Pattern
1. **Pre-permission education toast**: App shows rationale copy 3–5 seconds before the system dialog.
2. **Graceful degradation**: If denied, app falls back to in-app list only and disables deep link fields.
3. **Per-task opt-in**: Contacts/Calendar are requested only when the user attempts a deep link task type, not on first launch.

---

## 5. Monetization & Retention (Anti-Burnout)

### Secondary value pillars (beyond "force")
- **Streak Insurance (subscription $2.99/mo)**: Missed tasks don't break streaks if you use a makeup pass. Gives users a "breather" valve so the tool doesn't feel punitive.
- **Weekly Insight Reports**: Surfaces patterns like "You most often miss evening errands" and suggests smarter scheduling (not shame).
- **Team / Accountability Groups (upsell)**: A shared queue where friends can see that you executed (not that you missed). Social pressure is different from self-punishment; at scale it creates gentle accountability.

### Retention hooks
- **"Ready, Set, Go" 3-second handoff screen**: When deadline triggers, show a quick breathing / readiness graphic before the deep link — this micro-window reduces resistance and feels more supportive than jarring.
- **Completion ceremonies**: Small confetti + a written "What I just did" log line (never public unless user shares).
- **Variable escalation cadence**: Default is 3 escalating notifications, then It's done. No infinite alarms. Users set their max escalation in settings (1–5).

---

## 6. Initial Repo Scaffold

A minimal Flutter-based cross-platform scaffolding (iOS + Android from one codebase) with the architecture to support the above:

```
goingtodoit/
├── tech_spec/
│   └── TECHNICAL_SPEC.md          (this document)
├── goingtodoit_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── task_model.dart
│   │   │   └── force_engine.dart
│   │   │   └── escalation_rules.dart
│   │   ├── features/
│   │   │   ├── task_creation/
│   │   │   ├── deadline/
│   │   │   └── deep_links/
│   │   └── data/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── README.md
├── .gitignore
└── README.md
```

---

## 7. Next Steps

1. Validate Critical Alerts entitlement flow against Apple HIG + Google Play policy for your specific jurisdiction.
2. Flutter repo bootstrap + CI for iOS simulator + Android emulator.
3. Implement `force_engine` as a pure Dart class (testable without UI).
4. Add `DeepLinkHandler` abstraction so platform channels route `tel:`, `mailto:`, `sms:` uniformly.
5. Build first UI: Task creation with "Force at deadline?" toggle and permission flow.
