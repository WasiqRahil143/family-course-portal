# Train With Rahil Portal — Project Context

Last updated: 11 September 2026

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

- Responsive family portal and phone-friendly navigation
- Family overview with next course, absence shortcut, payment warning and progress summary
- Child/family, health, emergency-contact and consent interfaces
- Course schedule and quick absence reporting
- Cash plan choice: one payment or four instalments
- Manager cash-confirmation interaction
- Jungle Passport progress categories
- Manager views for attendance, courses, cash payments and access roles
- Six-language selector: German, French, English, Spanish, Arabic and Chinese
- Main navigation, overview and payment warning translate; Arabic supports right-to-left layout
- Clean custom monkey artwork for Jungle Gymnastics

### Not production-ready yet

- No authentication, family accounts or persistent database
- No real student, health, consent, attendance or payment records
- No password recovery or multi-device session handling
- Detailed forms still need complete translation
- No invitation or account-activation flow
- No automatic payment due-date calculation or reminders
- No audit trail or backend-enforced permissions
- No finalized privacy, retention or production consent wording
- No school approval workflow or scheduling-conflict protection
- Superhero Pass is not implemented

The public site is a functional frontend preview, not yet an operational portal.

## Technical map

| Part | Service or location | Status |
|---|---|---|
| Source code | GitHub: `WasiqRahil143/family-course-portal` | Connected; only this repository may be changed |
| Public preview | Netlify: `family-course-portal-demo.netlify.app` | Connected; manually deployed |
| Frontend | Next.js 16, React 19, TypeScript, static export | Working |
| Styling | `app/globals.css` | Working |
| Main interface | `app/page.tsx` | Frontend state only |
| Portal metadata | `app/layout.tsx` | Working |
| Jungle artwork | `public/jungle-monkey.png` | Working |
| Authentication/database | Supabase | Not connected; isolated project creation is blocked by the organization’s two-active-free-project limit |
| Email | Hostinger Mail | Separate mailbox; not connected to portal automation |
| School working list | Shared spreadsheet workflow | Separate; future import or migration needed |

Never modify Rahil’s other GitHub, Netlify, or Supabase projects. Any database must be a new project dedicated to this portal, preferably in an EU region.

## Intended production architecture

1. Next.js frontend on Netlify.
2. A dedicated Supabase project for authentication, Postgres data and secure access rules.
3. Families can sign in on several devices using one account. Password reset or passwordless email login must work.
4. A family account may contain multiple guardians and children.
5. Roles and school/course assignments control access. Row Level Security protects every exposed table.
6. Health and child data are minimized, restricted and covered by retention/deletion rules.
7. Public photo/video consent is optional, granular, revocable and never required for participation.
8. Cash is not processed online. Families choose a plan; only an authorized manager confirms receipt.
9. Sensitive status changes retain a timestamp and responsible user.

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
- Six family languages are planned.
- Never connect or alter unrelated projects.

## Two-week production plan

Target: a genuinely useful pilot by 25 September 2026. This means a small, secure operational version for approved families, not the complete future multi-school platform.

### Days 1–2: secure foundation

- Create a dedicated EU-hosted Supabase project.
- Add environment configuration without committing secrets.
- Create schema, migrations and Row Level Security.
- Add family, course-manager and company-manager roles.
- Implement passwordless email login plus recovery.

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
- Finish DE, FR and EN first; review ES, AR and ZH before production activation
- Check Arabic layout, mobile screens, keyboard use and readable sizes
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

Choose a safe Supabase capacity option, then create the isolated project and implement authentication plus the minimum secure schema. The Friending Around organization currently has two active free projects, so Supabase rejected creation of another free project. Do not pause, modify or reuse an existing project as a workaround. Do not enter real child or health data until access policies have been tested using two separate family accounts.

## Change log

### 11 September 2026

- Created this source-of-truth file.
- Added repository instructions requiring this file to be read and updated with every meaningful change.
- Recorded the frontend, integrations, limitations, decisions and architecture.
- Defined the two-week path from preview to secure pilot.
- Previous portal update: replaced the monkey artwork, made the main family interface multilingual and removed prominent demo labels.
- Attempted to create an isolated Frankfurt Supabase project at €0/month; Supabase rejected it because the organization has reached its two-active-free-project limit. No existing project was changed.
