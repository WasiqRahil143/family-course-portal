# Train With Rahil Portal — Project Context

Last updated: 12 September 2026

## How to use this file

This is the project’s source of truth. Read it before making a change, then inspect only the files relevant to that change. Update this document in the same commit whenever a meaningful feature, decision, integration, limitation, or plan changes.

The code remains the authority for implementation details. This file is the authority for product intent, architecture, status, and next priorities.

## Product goal

Build a very simple, phone-friendly portal for Train With Rahil that reduces administration for families and course managers.

The first production version is only for Rahil’s own school courses. Its architecture should later support multiple schools, independent course managers, and school administrators without requiring a complete rewrite.

## Users and responsibilities

| Role | Primary tasks | Permissions |
|---|---|---|
| Family | Manage children, see approved courses, report absence, choose cash-payment plan, provide health information and consent | Only its own family and children |
| Course manager | Manage assigned courses, attendance, progress and cash-payment confirmation | Only assigned schools and courses |
| Company manager | Configure courses, users, access and reporting | Full Train With Rahil access |
| School manager, later | Review applications, accept or reject children and resolve schedule conflicts | Only its own school |

One child must never be accepted into two courses that occur at the same time. Families may later submit ranked preferences such as priority 1 and priority 2.

## Current courses represented

| Course | School level | Current day | Annual price | Progress system |
|---|---|---|---:|---|
| Jungle Gymnastics | GS | Tuesday | €420 | Jungle Passport |
| Superhero Training | CE1 to CM1 | Thursday | €450 according to the school course sheet; verify before production billing | Superhero Pass, planned |

Displayed family and student names are fictional examples. Production student lists must come only from school-approved registrations.

## Current product state

### Working in the frontend

- Neon Auth sign-in, sign-up, email verification, password recovery and account/session UI
- Authenticated portal gate; course data is not rendered before sign-in
- Responsive family portal and phone-friendly navigation
- Family overview with next course, absence shortcut, payment warning and progress summary
- Child/family, health, emergency-contact and consent interfaces
- Course schedule and quick absence reporting
- Cash plan choice: one payment or four instalments
- Manager cash-confirmation interaction
- Jungle Passport progress categories
- Manager views for attendance, courses, cash payments and access roles
- Five-language selector: German, French, English, Spanish and Chinese
- Main navigation, overview and payment warning translate across the five enabled languages
- Manager identities open directly in the manager portal; the family view remains available from its navigation
- A direct sign-out control closes the Neon Auth session and returns to the sign-in page
- Manager family-account screen with Neon Auth admin actions for creating accounts, resetting passwords, disabling/reactivating accounts and removing accounts
- Manager family records include a configurable access-until date; enforcement of that date is still pending the shared database connection
- Full course configuration interface for adding, editing and removing courses; fields include image, tagline, description, schedule, level, price, capacity, lead and preregistration state
- Course-lead directory and course assignment fields
- Editable seven-stage progress/pass framework per course
- One-click switch from the manager portal to the family-view preview
- Clean custom monkey artwork for Jungle Gymnastics

### Not production-ready yet

- Authentication is connected, but approved-family onboarding and backend authorization are not yet connected
- No real persistent family, health, consent, attendance or payment records
- New manager course, lead, family-metadata and passport configuration is stored only in the current browser for this preview; it is not yet shared across devices
- Neon Auth admin account actions are implemented but require live end-to-end verification before family invitations begin
- Access-until dates are displayed but do not yet automatically block an expired user
- No real student, health, consent, attendance or payment records
- No password recovery or multi-device session handling
- Detailed forms still need complete translation
- No invitation or account-activation flow
- No automatic payment due-date calculation or reminders
- No audit trail or backend-enforced permissions
- No finalized privacy, retention or production consent wording
- No school approval workflow or scheduling-conflict protection
- Superhero Pass is not implemented
- Manager screens still use fictional preview records until the secure role and data APIs are connected

The public site is a functional frontend preview with real authentication administration, but it is not yet an operational family-data portal.

## Technical map

| Part | Service or location | Status |
|---|---|---|
| Source code | GitHub: `WasiqRahil143/family-course-portal` | Connected; only this repository may be changed |
| Public preview | Netlify: `family-course-portal-demo.netlify.app` | Connected; manually deployed |
| Frontend | Next.js 16, React 19, TypeScript, static export | Working |
| Styling | `app/globals.css` | Working |
| Main interface | `app/page.tsx` | Family preview; frontend state only |
| Manager configuration | `app/manager-portal.tsx` | UI complete; Neon Auth account actions connected; configuration currently browser-local |
| Portal metadata | `app/layout.tsx` | Working |
| Jungle artwork | `public/jungle-monkey.png` | Working |
| Relational database | Neon `lively-dawn-61650044` — Train With Rahil – School Club Platform | Created; PostgreSQL 17 in Frankfurt; initial 20-table schema and Neon Auth identity migration verified |
| Authentication | Neon Auth | Enabled and connected to the frontend; verified email required; production redirect domain trusted |
| Data API | Neon Data API | Enabled with Neon Auth; automatic public-schema grants were deliberately disabled; `club` access policies are pending |
| Supabase | Friending Around organization | Not used for this portal; isolated creation was blocked by its free-project limit |
| Email | Hostinger Mail via Neon Auth custom SMTP | Connected; verification, password-reset and SMTP test delivery confirmed on 12 September 2026 |
| School working list | Shared spreadsheet workflow | Separate; future import or migration needed |

Never modify Rahil’s other GitHub, Netlify, or Supabase projects. Any database must be a new project dedicated to this portal, preferably in an EU region.

## Intended production architecture

1. Next.js frontend on Netlify.
2. A dedicated Neon PostgreSQL database in Frankfurt for relational application data.
3. Neon Auth for family and manager identities, email verification, password recovery and sessions.
4. The frontend uses Neon Auth directly. Server-side endpoints validate Neon Auth identity before privileged database access.
5. Families can sign in on several devices using one account. Password reset must work.
6. A family account may contain multiple guardians and children.
7. The server enforces roles and school/course assignments on every request; the browser never receives database credentials.
8. Health and child data are minimized, restricted and covered by retention/deletion rules.
9. Public photo/video consent is optional, granular, revocable and never required for participation.
10. Cash is not processed online. Families choose a plan; only an authorized manager confirms receipt.
11. Sensitive status changes retain a timestamp and responsible user.

## Planned core data model

- organizations, schools, profiles and role assignments
- families, family members and children
- courses, sessions, applications, ranked preferences and enrollments
- attendance
- health notes and emergency contacts
- consent records and consent history
- payment plans, instalments and cash confirmations
- progress frameworks, skills and awarded stamps
- audit events

## Product rules already decided

- Company name for now: Train With Rahil.
- First release supports Rahil’s courses only.
- Playful for children, serious and trustworthy for parents and schools.
- Simpler than the school portal and excellent on mobile.
- Payment is cash only: one annual payment or instalments.
- Payment becomes green only after manager confirmation.
- A real overdue amount creates a persistent, noticeable reminder.
- Jungle progress uses sustainable categories rather than recording every movement after every class.
- Final Jungle achievement: lion / Dschungel-Champion.
- Superhero Pass should cover strength, agility, coordination, endurance, mobility and teamwork.
- Digital progress should use batch updates so it does not interrupt teaching.
- Future applications support ranked choices and prevent conflicting acceptances.
- Five family languages are planned: German, French, English, Spanish and Chinese. Arabic was removed after mobile usability problems.
- Neon Auth currently cannot restrict who creates an account. An account alone grants no course access; every family or manager must also be linked to an approved `club.users` record and role on the server.
- Never connect or alter unrelated projects.

## Two-week production plan

Target: a genuinely useful pilot by 25 September 2026. This means a small, secure operational version for approved families, not the complete future multi-school platform.

### Days 1–2: secure foundation

- Use the dedicated Frankfurt Neon project and the versioned initial schema.
- Configure Neon Auth and require verified email addresses.
- Add environment configuration without committing secrets.
- Enforce family, course-manager and company-manager roles in the server API.
- Implement email login plus password recovery and multi-device sessions.

Done when a test family and Rahil can sign in and see only permitted test records.

### Days 3–4: family onboarding

- Invitation and activation flow
- Multiple guardians/devices per family
- Child profile, emergency contact and minimum necessary health information
- Validation, loading, error, empty and success states

Done when Rahil can invite a test family and it can complete the profile on a phone.

### Days 5–6: courses and attendance

- Import only school-approved children
- Connect courses and sessions
- Show only the family’s enrollments
- Persist quick absence reporting
- Connect the live mobile attendance list

Done when a family reports an absence and Rahil immediately sees it in the correct session.

### Days 7–8: cash payments

- Store one-payment or instalment selection
- Generate due dates from course settings
- Add due, overdue, received and waived states
- Restrict cash confirmation to authorized managers
- Show reminders only for genuinely overdue payments

Done when family and manager see the same accurate status.

### Days 9–10: consent, privacy and security

- Finalize German consent/privacy wording, then translate it
- Store consent version, timestamp and withdrawal history
- Restrict health details to necessary staff
- Audit payments, attendance, consent and sensitive profile changes
- Test boundaries between two families and all roles

Done when accounts cannot access another family’s data and consent is revocable.

### Days 11–12: languages and quality

- Move every interface string into one translation system
- Finish DE, FR and EN first; review ES and ZH before production activation
- Check mobile screens, keyboard use and readable sizes
- Remove fictional data and preview-only controls from production mode

Done when every enabled production language is consistent on every screen.

### Days 13–14: pilot

- Test complete journeys as Rahil and as two families
- Test invitation, login, profile, absence, attendance, payments and consent
- Add backups, error monitoring and support contact
- Connect a production domain and invite a few approved families first
- Fix pilot blockers before inviting everyone

Done when the portal can safely support the first real course week.

## After the pilot

1. Jungle and Superhero digital passes with batch progress updates.
2. Ranked family applications.
3. School approval/rejection portal.
4. Automatic same-time conflict prevention.
5. Multiple schools and external course managers.
6. Exports, school reports and analytics.

## Immediate next action

Persist manager-created family metadata, course leads, courses and progress frameworks in Neon with server-enforced manager/family policies. Enforce account expiry, then connect one test family to an empty family profile and verify isolation with a second account. Do not enter real child or health data until those access boundaries pass.

## Change log

### 11 September 2026

- Created this source-of-truth file.
- Added repository instructions requiring this file to be read and updated with every meaningful change.
- Recorded the frontend, integrations, limitations, decisions and architecture.
- Defined the two-week path from preview to secure pilot.
- Previous portal update: replaced the monkey artwork, made the main family interface multilingual and removed prominent demo labels.
- Attempted to create an isolated Frankfurt Supabase project at €0/month; Supabase rejected it because the organization has reached its two-active-free-project limit. No existing project was changed.
- Selected Neon PostgreSQL plus Firebase Authentication as the free pilot architecture.
- Created the isolated Neon project `lively-dawn-61650044`, named “Train With Rahil – School Club Platform”, using PostgreSQL 17 in Frankfurt. Neon Auth remains disabled.
- Applied and verified `db/migrations/0001_initial_schema.sql`; Neon reports all 20 planned `club` tables.
- Replaced the planned Firebase dependency with Neon Auth to keep authentication and relational data in one isolated project.
- Enabled Neon Auth and the Data API, required email verification, and trusted only localhost plus `family-course-portal-demo.netlify.app` for redirects.
- Deliberately disabled automatic public-schema grants when enabling the Data API. No `club` data is exposed through the API yet.
- Added the frontend authentication gate and account/session UI, plus `0002_neon_auth_identity.sql`; the production build succeeds.
- Fixed the Neon verification-code route to use `/auth/email-verification` and allowed the complete set of supported authentication routes. New users now see the six-digit code entry screen instead of being returned to sign-in.
- Explicitly enabled OTP email verification in `NeonAuthUIProvider`, so both sign-up and an `EMAIL_NOT_VERIFIED` sign-in response navigate to the six-digit verification form.

### 12 September 2026

- Added a required confirmation-password field to account creation so families must enter the same password twice before signing up.
- Replaced Neon Auth's shared sender with the dedicated Hostinger mailbox `info@trainwithrahil.com` through custom SMTP.
- Confirmed delivery of Neon Auth's SMTP test, password-reset email and a newly resent six-digit email-verification code to the Hostinger inbox.
- Made manager accounts open directly in the manager portal and added Neon Auth's admin role as a manager identity signal.
- Fixed the Arabic phone layout, including header spacing, right-to-left controls and hero artwork overlap.
- Removed Arabic from the portal after continued mobile usability problems.
- Replaced the account-menu sign-out action with a direct Neon Auth sign-out button that returns to the sign-in page.
- Added the first manager configuration layer: family account administration, access dates, course-lead records, full course CRUD, preregistration switches, image fields, and editable seven-stage course passports.
- Added direct switching between manager and family views. Neon Auth account actions are wired to real admin endpoints; configuration records remain browser-local until the next database-policy step.
