begin;

create schema if not exists club;

create table club.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table club.schools (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references club.organizations(id) on delete restrict,
  name text not null,
  timezone text not null default 'Europe/Berlin',
  created_at timestamptz not null default now(),
  unique (organization_id, name)
);

create table club.users (
  id uuid primary key default gen_random_uuid(),
  firebase_uid text not null unique,
  email text not null,
  display_name text,
  preferred_language text not null default 'de'
    check (preferred_language in ('de','fr','en','es','ar','zh')),
  disabled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index users_email_lower_idx on club.users (lower(email));

create table club.role_assignments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references club.users(id) on delete cascade,
  organization_id uuid references club.organizations(id) on delete cascade,
  school_id uuid references club.schools(id) on delete cascade,
  role text not null check (role in ('company_manager','school_manager','course_manager','guardian')),
  created_at timestamptz not null default now(),
  check (organization_id is not null or school_id is not null or role = 'guardian'),
  unique nulls not distinct (user_id, organization_id, school_id, role)
);

create table club.families (
  id uuid primary key default gen_random_uuid(),
  preferred_language text not null default 'de'
    check (preferred_language in ('de','fr','en','es','ar','zh')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table club.family_members (
  family_id uuid not null references club.families(id) on delete cascade,
  user_id uuid not null references club.users(id) on delete cascade,
  relationship_label text,
  is_primary_contact boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (family_id, user_id)
);

create table club.children (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references club.families(id) on delete restrict,
  first_name text not null,
  last_name text not null,
  date_of_birth date,
  school_class text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index children_family_idx on club.children(family_id);

create table club.courses (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references club.schools(id) on delete restrict,
  name text not null,
  school_level text,
  weekday smallint check (weekday between 1 and 7),
  start_time time,
  end_time time,
  annual_price_cents integer not null check (annual_price_cents >= 0),
  currency char(3) not null default 'EUR',
  capacity integer check (capacity > 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_time is null or end_time is null or start_time < end_time)
);

create table club.course_managers (
  course_id uuid not null references club.courses(id) on delete cascade,
  user_id uuid not null references club.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (course_id, user_id)
);

create table club.course_sessions (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references club.courses(id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  check (starts_at < ends_at),
  unique (course_id, starts_at)
);

create index course_sessions_course_time_idx on club.course_sessions(course_id, starts_at);

create table club.enrollments (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references club.children(id) on delete restrict,
  course_id uuid not null references club.courses(id) on delete restrict,
  status text not null default 'pending'
    check (status in ('pending','approved','rejected','waitlisted','withdrawn')),
  priority smallint check (priority between 1 and 9),
  decided_by uuid references club.users(id) on delete set null,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (child_id, course_id)
);

create index enrollments_course_status_idx on club.enrollments(course_id, status);

create table club.attendance (
  session_id uuid not null references club.course_sessions(id) on delete cascade,
  child_id uuid not null references club.children(id) on delete restrict,
  status text not null check (status in ('expected','present','absent_reported','absent_unreported')),
  family_note text,
  recorded_by uuid references club.users(id) on delete set null,
  recorded_at timestamptz not null default now(),
  primary key (session_id, child_id)
);

create table club.health_profiles (
  child_id uuid primary key references club.children(id) on delete cascade,
  health_notes text,
  emergency_contact_name text,
  emergency_contact_phone text,
  confirmed_by uuid references club.users(id) on delete set null,
  confirmed_at timestamptz,
  updated_at timestamptz not null default now()
);

create table club.consents (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references club.children(id) on delete cascade,
  consent_type text not null
    check (consent_type in ('internal_documentation','school_channels','public_promotion')),
  granted boolean not null,
  policy_version text not null,
  decided_by uuid not null references club.users(id) on delete restrict,
  decided_at timestamptz not null default now(),
  withdrawn_at timestamptz
);

create index consents_child_type_time_idx on club.consents(child_id, consent_type, decided_at desc);

create table club.payment_plans (
  id uuid primary key default gen_random_uuid(),
  enrollment_id uuid not null unique references club.enrollments(id) on delete restrict,
  plan_type text not null check (plan_type in ('single','instalments')),
  selected_by uuid not null references club.users(id) on delete restrict,
  selected_at timestamptz not null default now()
);

create table club.payment_instalments (
  id uuid primary key default gen_random_uuid(),
  payment_plan_id uuid not null references club.payment_plans(id) on delete cascade,
  sequence_number smallint not null check (sequence_number > 0),
  amount_cents integer not null check (amount_cents >= 0),
  due_date date not null,
  status text not null default 'due' check (status in ('due','received','waived')),
  received_at timestamptz,
  confirmed_by uuid references club.users(id) on delete set null,
  note text,
  unique (payment_plan_id, sequence_number)
);

create index payment_instalments_due_idx on club.payment_instalments(status, due_date);

create table club.progress_frameworks (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references club.courses(id) on delete cascade,
  name text not null,
  final_award_name text,
  active boolean not null default true,
  unique (course_id, name)
);

create table club.progress_skills (
  id uuid primary key default gen_random_uuid(),
  framework_id uuid not null references club.progress_frameworks(id) on delete cascade,
  name text not null,
  animal_or_symbol text,
  display_order smallint not null,
  stamp_target smallint not null default 3 check (stamp_target > 0),
  unique (framework_id, display_order)
);

create table club.progress_awards (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references club.children(id) on delete cascade,
  skill_id uuid not null references club.progress_skills(id) on delete cascade,
  awarded_by uuid not null references club.users(id) on delete restrict,
  awarded_at timestamptz not null default now(),
  note text
);

create index progress_awards_child_skill_idx on club.progress_awards(child_id, skill_id);

create table club.audit_events (
  id bigint generated always as identity primary key,
  actor_user_id uuid references club.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create index audit_events_entity_idx on club.audit_events(entity_type, entity_id, occurred_at desc);
create index audit_events_actor_idx on club.audit_events(actor_user_id, occurred_at desc);

create function club.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger users_touch_updated_at before update on club.users
for each row execute function club.touch_updated_at();
create trigger families_touch_updated_at before update on club.families
for each row execute function club.touch_updated_at();
create trigger children_touch_updated_at before update on club.children
for each row execute function club.touch_updated_at();
create trigger courses_touch_updated_at before update on club.courses
for each row execute function club.touch_updated_at();
create trigger enrollments_touch_updated_at before update on club.enrollments
for each row execute function club.touch_updated_at();

commit;
