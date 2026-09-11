begin;

alter table club.users rename column firebase_uid to auth_user_id;

comment on column club.users.auth_user_id is
  'Neon Auth user ID from the neon_auth schema; never trusted without a verified Neon Auth session.';

commit;
