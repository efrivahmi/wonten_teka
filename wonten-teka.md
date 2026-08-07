# Wonten Teka — complete build plan

A Flutter attendance & HR platform: face recognition + anti-spoof GPS check-in, shift scheduling, multilevel leave/claim approvals, payroll with BPJS/PPh 21, a company calendar, and a personal habit-style planner — with a realtime SaaS dashboard for HR/admins.

---

## 1. Overview & assumptions

Before anything else, three assumptions are baked into this plan. If any is wrong, tell me and the shape of the system changes:

1. **Multi-tenant SaaS** — many companies will use one platform (not just your own company). The architecture below supports this; if it's actually just for your own company, you can simplify the tenancy layer.
2. **Indonesia is the primary market** — BPJS, PPh 21, and "bos"-style approval language all point here, so the compliance sections assume Indonesian labor and tax regulation.
3. **Small-to-mid team building this** — stack choices favor speed of delivery and a large local hiring pool over hyperscale-from-day-one architecture.

---

## 2. High-level architecture

```
Flutter mobile app  +  Admin web dashboard
            |                  |
            v                  v
        API gateway (REST + WebSocket)
                    |
                    v
        Backend application
   Auth · Attendance · Approvals · Payroll · Calendar
                    |
      -----------------------------
      |             |             |
  PostgreSQL       Redis     Object storage
 (system of      (cache,     (face photos,
   record)      queue, pub/     slips,
                   sub)        receipts)
```

**Outbound integrations from the backend application layer:**
- On-device face match (+ optional cloud liveness re-check)
- FCM push notifications
- WhatsApp/SMS gateway for notification delivery (very commonly used alongside push in Indonesia — consider Fonnte, Qontak, or the official WhatsApp Business API)
- Bank/disbursement API for payroll transfer (phase 2+, optional)

**Multi-tenancy approach:** single database, shared schema, a `company_id` column on every tenant-scoped table plus enforced query scoping (Laravel global scopes or NestJS interceptors). This is the simplest model to operate at your likely scale. Move to schema-per-tenant or database-per-tenant later only if a specific client contractually requires physical data isolation.

---

## 3. Mobile tech stack (Flutter)

### 3.1 Core

- **Flutter 3.44+ / Dart 3.12+** (stable channel)
- **Architecture:** Clean Architecture, feature-first folders (see section 10)
- **State management:** `flutter_bloc` — Cubit for simple screens, Bloc for multi-step flows like face capture + GPS validation. Riverpod is an equally valid alternative with less boilerplate if your team prefers it.
- **Navigation:** `go_router` — supports role-based redirects (employee vs. approver home) and deep links from push notifications straight into an approval screen
- **Dependency injection:** `get_it` + `injectable`

### 3.2 Package map by feature

| Domain | Packages | Purpose |
|---|---|---|
| Networking | `dio`, `pretty_dio_logger` | HTTP client, interceptors for JWT refresh, retry, logging |
| Offline data | `drift` | Local SQLite — queue check-ins offline, sync when back online |
| Secure storage | `flutter_secure_storage` | Tokens, device keys |
| Face detection | `google_mlkit_face_detection` | On-device face landmarks, alignment, blink/head-pose cues |
| Face matching | `tflite_flutter` + a MobileFaceNet/FaceNet `.tflite` model | On-device 1:1 embedding comparison for verification |
| Liveness/anti-spoof | `flutter_face_liveness` (or `flutter_liveness_detection`) | Bundles ML Kit + TFLite liveness/replay-attack detection so you don't hand-roll it |
| Camera | `camera` | Selfie capture for enrollment and check-in |
| Location | `geolocator` | GPS; exposes a mock-provider flag on Android for spoofing detection |
| Root/jailbreak detection | `safe_device` or `flutter_jailbreak_detection` | Flags devices more capable of GPS/identity spoofing |
| Device fingerprint | `device_info_plus` | Powers the one-employee-one-device binding |
| Realtime | `web_socket_channel` or `socket_io_client` | Live dashboard/notification updates |
| Push notifications | `firebase_messaging` + `flutter_local_notifications` | Remote + local notifications |
| Calendar UI | `table_calendar` or `syncfusion_flutter_calendar` | Company calendar and shift views |
| Charts | `fl_chart` | Attendance trend on the mobile "my attendance" screen |
| PDF viewing | `printing` + `pdf` | View/share server-generated salary slip PDFs |
| Forms | `flutter_form_builder` | Leave/claim request forms with validation |
| Animation | `lottie`, `rive` | Onboarding, mascot micro-interactions |
| Localization | `easy_localization` | Bahasa Indonesia + English |
| Responsive sizing | `flutter_screenutil` | Consistent sizing across the wide range of Android device sizes in market |
| Icons/splash | `flutter_launcher_icons`, `flutter_native_splash` | Branded app icon and splash screen |

---

## 4. Backend tech stack

### 4.1 Recommended: Laravel + Filament

- **Laravel 11 (PHP)** — mature, and this is exactly the ecosystem most Indonesian payroll/HRIS shops already build on, which matters for hiring
- **Filament** — an admin panel builder on top of Laravel. It can generate most of the "realtime SaaS dashboard" requirement (tables, stat widgets, charts, relation managers, approval queues) in a fraction of the time a custom React admin panel would take. This is the single biggest time-saver in this stack.
- **Laravel Sanctum** — token auth for the Flutter app
- **Laravel Reverb** — first-party WebSocket server for realtime dashboard updates and notifications (no separate Node service needed)
- **Laravel Queues (Redis-backed)** — payroll batch runs, PDF generation, notification fan-out
- **Laravel Scheduler** — recurring jobs: monthly payroll close, leave balance accrual, holiday reminders
- **Maatwebsite/Excel** — attendance and payroll exports

### 4.2 Alternative: NestJS + Prisma

If your team is JS/TS-native, or you expect to split into microservices as you scale: NestJS (Node.js/TypeScript) + Prisma ORM + Socket.io + BullMQ. More boilerplate up front; pays off if you need heavily custom realtime logic or a larger engineering org later.

### 4.3 Data layer

- **PostgreSQL** — primary database (MySQL/MariaDB also fully fine with Laravel, if your team already knows it)
- **Redis** — cache, queues, pub/sub for realtime
- **S3-compatible object storage** — AWS S3, MinIO (self-hosted), or Cloudflare R2, for face photos, salary slip PDFs, receipt uploads
- **Hosting region** — AWS `ap-southeast-3` (Jakarta) or GCP `asia-southeast2` (Jakarta) for latency and a local presence; local providers (Biznet Gio, IDCloudHost) are viable alternatives if data-residency preference outweighs hyperscaler features

---

## 5. Admin web dashboard

Built directly in **Filament** (fastest path, matches the Laravel recommendation). If you'd rather build a fully custom web app instead: Next.js + Tailwind CSS + shadcn/ui + Recharts.

**Realtime widgets to build:**
- Today's attendance snapshot (present / late / absent / on leave) — live via WebSocket
- Attendance trend chart, filterable by department, daily/weekly/monthly
- Pending approvals queue (leave, claims, overtime)
- Payroll run status
- Upcoming calendar events and holidays

---

## 6. Feature-by-feature build guide

### 6.1 Device binding (one employee = one device)

- On first login, register a `device_id` (via `device_info_plus` fingerprint) plus push token against the employee record
- Block login and check-in attempts from any other device for that employee; a new device requires **admin approval** to re-bind (phone lost or replaced) — never let the employee self-approve a new device, that defeats the control
- Validate the binding server-side on *every* attendance submission, not just at login

### 6.2 Face recognition attendance

- **Enrollment:** capture 3–5 reference selfies during onboarding, generate a face embedding, store the embedding encrypted — not the raw photos long-term
- **Verification flow:** ML Kit detects and aligns the face → a randomized liveness challenge (blink or head-turn) → generate embedding → compare cosine similarity against the stored enrollment embedding → pass/fail threshold
- Do the match on-device for speed and privacy, but also send the embedding (or photo) for a server-side re-score — a modified client shouldn't be able to just fake a "pass" response
- Route low-confidence matches to an HR review queue rather than hard-blocking, so lighting or camera-angle issues don't lock out legitimate employees

### 6.3 Anti-fake GPS

Layer several checks — any single one alone is beatable:
- `geolocator`'s mock-location flag (Android)
- Root/jailbreak detection
- WiFi network cross-check against known office networks, where available
- Server-side impossible-travel check (distance/time between consecutive check-ins)
- Server-side geofence re-validation — never trust a client-reported "inside geofence" boolean alone
- **Flag, don't always hard-block.** Suspicious attempts should route to a flagged-attendance review queue for HR, since GPS/network issues also produce false positives

### 6.4 Attendance & realtime reports

- Every check-in/out writes an immutable `attendance_logs` row (timestamp, GPS, face-match score, device ID, flags)
- Daily/weekly/monthly views are aggregation queries (scheduled aggregation jobs or materialized views for performance at scale), feeding both the mobile "my attendance" screen and the admin dashboard
- Push realtime updates to the admin dashboard over WebSocket on every new check-in

### 6.5 Shift scheduling

- `shift_templates` (name, start/end time, grace period) → `shift_assignments` (employee, date, template)
- Manager-facing schedule builder (calendar/grid) in the admin dashboard; employees see their own shift in the app
- Attendance validation compares check-in time against the *assigned* shift, not a single global company time

### 6.6 Urgent task / broadcast

- `announcements` table (title, body, target: company-wide / department / individual, priority)
- Push via FCM plus an in-app feed; track `acknowledged_by` so managers can see who has and hasn't seen an urgent notice

### 6.7 Leave management

- `leave_types` (annual, sick, unpaid…) with a configurable monthly/annual quota per type
- `leave_requests` (employee, type, date range, reason, attachment, status)
- A scheduled balance-calculation job handles accrual and carry-over rules

### 6.8 Multilevel approval engine (build once, reuse everywhere)

This is the one piece of infrastructure worth over-investing in, because leave, claims, and overtime all need it:
- `approval_flows` — per company + request type, an ordered list of steps (role-based or specific-person), with optional conditions (e.g. "claims over Rp 1,000,000 require Finance as step 2")
- `approval_instances` — one per actual request, tracking current step and overall status
- `approval_actions` — the audit trail: who, when, decision, comment, per step
- Design this **one** engine, reuse it for leave, claims, and overtime — don't build separate approval logic per module

### 6.9 Company calendar

- `calendar_events` (type: holiday / meeting / association event; scope: company-wide / department; date/time; description)
- Seed national holidays annually; meetings and association events are created by HR or managers

### 6.10 Personal habit / self-schedule

- Separate from the company calendar — `personal_tasks` (employee, title, recurrence rule, reminder time, streak count)
- Local notifications for reminders; simple streak tracking that doesn't need a server round-trip beyond sync

### 6.11 Payroll & salary slip

- `payroll_components` — basic salary, allowances, deductions, configurable per employee/company
- `payroll_runs` — monthly batch (draft / processing / finalized / paid)
- `payslips` — one PDF per employee per run, stored in object storage, viewable and downloadable in-app
- Generate PDFs **server-side** (Laravel: `dompdf` or `snappy`) — keeps calculation and formatting logic in one trusted place, not on-device

### 6.12 BPJS & PPh 21 compliance engine

This is the module with real regulatory exposure, so the architectural principle matters more than any specific number: **build it as a configurable rules/rates table, not hardcoded logic.**

**PPh 21 (income tax withholding), current mechanics:**
- Since January 2024 (PMK 168/2023), monthly withholding uses the **TER method** (Tarif Efektif Rata-rata / average effective rate) for January–November, then a full reconciliation in December against the progressive 5–35% annual scale — December's deduction is often larger because of this true-up
- Employees are placed into **TER category A, B, or C** based on PTKP (non-taxable income) status
- PTKP reference thresholds: single (TK/0) ≈ Rp 54,000,000/year; married (K/0) ≈ Rp 58,500,000/year; +Rp 4,500,000 per dependent, up to 3 dependents
- Employees without an NPWP (tax ID) on file are subject to a surcharge
- CoreTax (DJP's tax administration system) is the current reporting integration point to plan for

**BPJS, current structure:**
- **BPJS Kesehatan** (health): 5% of salary, split 4% employer / 1% employee, salary basis capped (~Rp 12,000,000)
- **BPJS Ketenagakerjaan** (employment) is four separate programs, each with its own rate and basis:
  - JHT (old age savings): 5.7% total (3.7% employer / 2% employee), **no salary cap**
  - JP (pension): 3% total (2% employer / 1% employee), capped around Rp 11,000,000 and **adjusted periodically** — this cap has moved more than once within 2026 alone
  - JKK (work accident): 0.24%–1.74%, employer-only, varies by industry risk classification
  - JKM (death benefit): 0.3%, employer-only
  - JKP (job loss): a small employer-funded rate, not deducted from the employee
- **Tapera** (housing savings) became mandatory for private-sector employees during 2026: 3% total (0.5% employer / 2.5% employee) — a good example of why this whole module needs to be configuration-driven, not hardcoded

**Build recommendation:**
- Store PTKP status, TER category tables, BPJS rates, and salary caps as database-backed settings editable by a super-admin — never as constants in code
- **Version every rate table by effective date**, so a rate change doesn't silently corrupt historical payroll runs when recalculated or audited
- Get an actual Indonesian tax/payroll consultant or accountant to validate the calculation engine before go-live — this module carries real compliance liability beyond software correctness, and the figures above should be verified against current BPJS/DJP sources at build time, not taken as final

### 6.13 Claims & reimbursement

- `claim_categories` (transport, medical, meals…) with optional per-category limits
- `claims` (employee, category, amount, receipt image, status) — routes through the same approval engine from 6.8
- Approved reimbursements can feed automatically into the next `payroll_run`

### 6.14 Realtime SaaS dashboard

Covered in section 5 — built on Filament's widget system, fed by the WebSocket layer from section 2.

---

## 7. Core database entities (overview)

| Entity | Key fields | Notes |
|---|---|---|
| `companies` | name, tenant settings | Tenant root |
| `employees` | company_id, role, PTKP status | |
| `devices` | employee_id, device_fingerprint, status | One active device per employee |
| `roles` / `permissions` | | RBAC |
| `shift_templates` / `shift_assignments` | | |
| `attendance_logs` | employee_id, timestamp, gps, face_score, device_id, flags | Immutable |
| `leave_types` / `leave_requests` | | |
| `approval_flows` / `approval_instances` / `approval_actions` | | Generic engine (6.8) |
| `claim_categories` / `claims` | | |
| `payroll_components` / `payroll_runs` / `payslips` | | |
| `calendar_events` | | |
| `personal_tasks` | | |
| `announcements` | | Urgent broadcasts |
| `notifications` | | |
| `audit_logs` | actor, action, before/after | Immutable, covers approvals + payroll edits |

---

## 8. Security architecture

- **Transport:** TLS everywhere; certificate pinning in the Flutter app for the API domain
- **Auth:** short-lived JWT access tokens with refresh-token rotation (Sanctum)
- **RBAC:** employee / supervisor / HR admin / finance admin / super admin, enforced **server-side on every endpoint** — never trust a client-side role check alone
- **Sensitive-field encryption at rest:** salary figures, NIK/NPWP (tax ID), BPJS numbers, face embeddings
- **Fraud controls:** device binding (6.1) and anti-GPS-spoof layering (6.3) — treat these as security controls, not just UX
- **Audit log:** every approval action, payroll edit, and role change recorded immutably
- **Rate limiting** and brute-force lockout on auth endpoints
- **Secrets management:** environment-based secrets manager (AWS Secrets Manager, Doppler, or Vault) — never committed to the repo
- **Compliance:** design biometric and payroll/tax data handling around Indonesia's UU PDP (Personal Data Protection Law) — explicit consent for biometric enrollment, a defined retention/deletion policy, and support for data-subject access requests
- **Ongoing:** dependency scanning and a third-party penetration test before major releases

---

## 9. UI/UX & branding direction

The mockup shown above reflects this direction:

- **Palette rationale:** a coral/sunrise primary rather than the generic blue-purple most HR SaaS defaults to — it plays off "Teka" (arrival), so each check-in reads as a small "new day" moment rather than a sterile transaction
- **Mascot ("Teka"):** a simple, rounded, friendly character appearing at check-in moments — home screen, face-scan screen, success/empty states. Keep the personality warm and reassuring, not cutesy-childish, since this is a workplace tool used by all levels of staff
- **Design tokens:** define color, type scale, spacing, and radius once in Figma; mirror as a Dart `ThemeData` + constants file so the mobile app stays pixel-consistent with the design source of truth
- **On illustration:** what's shown in the mockup is a vector concept to establish direction and personality — not final production art. Hand this brief (palette, personality, where the mascot appears) to an illustrator or an AI image tool for polished final character art
- **Performance & accessibility:** target low-end Android devices, which make up a large share of the Indonesian market — keep image assets light, avoid heavy shader-based animation, support system text scaling, and maintain WCAG AA contrast throughout

---

## 10. Suggested Flutter folder structure

```
lib/
  core/
    theme/
    network/
    storage/
    di/
    widgets/
  features/
    auth/
    attendance/
    leave/
    approval/
    payroll/
    calendar/
    schedule_habit/
    claims/
    dashboard/
    profile/
  l10n/
  main.dart
```

Each feature folder follows `data / domain / presentation` per Clean Architecture.

---

## 11. Development roadmap (phased)

| Phase | Scope | Rough duration | Status |
|---|---|---|---|
| 0 — Foundation | Project setup, design system, auth, multi-tenant data model, CI/CD | 2–3 weeks | ✅ **DONE (Backend)** |
| 1 — Attendance MVP | Device binding, face enrollment/verification, anti-fake GPS check-in, basic attendance history, push notifications | 4–6 weeks | ✅ **DONE (Backend API)** |
| 2 — Workforce management | Shift scheduling, leave + multilevel approval, company calendar, urgent broadcast | 4–5 weeks | ✅ **DONE (Backend API & Admin Models)** |
| 3 — Payroll & finance | Payroll engine, BPJS/PPh 21 engine, salary slip PDFs, claims/reimbursement | 5–6 weeks | ✅ **COMPLETED** |
| 4 — Dashboard & personal scheduler | Realtime admin dashboard widgets, personal habit scheduler, exports/reporting | 3–4 weeks | ✅ **COMPLETED** |
| 5 — Hardening & launch | Security audit/pentest, low-end device performance pass, UAT, store submission | 2–3 weeks | ⏳ Pending |

Total: roughly **5–6 months** for a small dedicated team. We have successfully completed the Backend for Phase 1 and most of Phase 2! The next step is either finishing the Backend API for Phase 3 (Payroll, Claims, PDFs) and creating the remaining Filament Admin pages, or starting the Flutter mobile app for Phase 1 & 2.

**Baseline team:** 1–2 Flutter developers, 1–2 backend developers, 1 UI/UX designer, 1 QA/PM (roles can overlap on a small team).

---

## 12. Next steps

1. Confirm or correct the assumptions in section 1 — they shape the tenancy and compliance design
2. Pick a backend track: Laravel + Filament (faster, larger local hiring pool) vs. NestJS + Prisma (TS-unified, better fit if you're scaling into microservices)
3. From here, I can scaffold the actual Flutter project structure and starter code, or build out the Laravel models/migrations for the schema in section 7 — just say which.
