# Wonten Teka - Architecture & Business Rules

This workspace contains the "Wonten Teka" HR & Attendance platform. Always strictly adhere to these architectural constraints, UI guidelines, and business rules when writing or modifying code.

## 1. Technology Stack
- **Backend:** Laravel 11, Filament Admin Panel, Sanctum (API Auth), Reverb (WebSockets).
- **Mobile:** Flutter 3.44+ (Dart 3.12+), BLoC/Cubit for state management, `go_router` for navigation, Clean Architecture.
- **Database:** PostgreSQL. Redis for queues/cache. S3-compatible storage.

## 2. Structural Conventions (Flutter)
- Maintain a feature-first Clean Architecture approach in `lib/features/`.
- Every feature folder must isolate `data/`, `domain/`, and `presentation/` layers.
- Do not mix state management patterns; stick to `flutter_bloc`.

## 3. UI/UX Consistency & Interactivity
- **UI Consistency:** Ensure a highly consistent UI experience across all screens. Follow a unified design system (e.g., standard padding, typography, color tokens like the "coral/sunrise" primary palette, and rounded "Teka" mascot aesthetics).
- **Complete Interactions:** Before marking a UI feature as "done", ensure all interactive states are fully implemented and match the original plan. This includes proper loading states, empty states, error handling visuals, micro-animations, and descriptive feedback for the user (e.g., specific warning texts when face match fails or GPS is out of range).

## 4. Core Business & Security Constraints
- **Multi-Tenancy:** The system is a SaaS. Every tenant-scoped entity MUST have a `company_id` column and be globally scoped.
- **Device Binding (Fraud Control):** Enforce strict 1 Employee = 1 Device rule. Binding changes MUST require Admin approval via the Filament dashboard. Do not allow self-service device resets.
- **Biometrics (Fraud Control):** Face enrollment requires extracting embeddings from multiple poses (3-5) using Google ML Kit / TFLite. Store ONLY embeddings long-term, not raw photos. Face matching must include liveness detection.
- **Anti-Fake GPS (Fraud Control):** Check-ins must layer GPS mock-detection, root/jailbreak checks, and server-side radius validation. Do not blindly trust client booleans. Always provide transparent error messages (showing reverse-geocoded addresses).
- **Approval Engine:** Use the generic, multi-level `ApprovalFlow` / `ApprovalInstance` tables for ALL request types (Leaves, Claims, Overtime). Do not build separate approval logic per module.

## 5. Indonesia Market Compliance (Payroll & Tax)
- **Do NOT hardcode rates.** BPJS rates (Kesehatan, JHT, JP, JKK, JKM) and PPh 21 TER categories / PTKP thresholds MUST be configurable database settings.
- Version rate tables by effective date to prevent historical payroll corruption.
- Encrypt sensitive fields at rest (salary figures, NIK/NPWP).
