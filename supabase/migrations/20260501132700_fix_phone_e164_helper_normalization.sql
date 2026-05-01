-- GoTrue stores auth.users.phone without the leading '+', even when the
-- client sends an E.164-formatted number. The previous helper returned the
-- raw value, so a comparison like
--   public.users.phone_e164 = current_user_phone_e164()
-- would compare e.g. '+16025459712' to '16025459712' and always be false.
-- That breaks the post-OTP RLS lookup that lets a freshly-signed-in user
-- discover their pre-seeded public.users row by phone.
--
-- Re-create the helper to always return E.164 (prepending '+' when missing)
-- so callers can rely on the format implied by its name.

create or replace function public.current_user_phone_e164()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select case
    when phone is null or phone = '' then null
    when phone like '+%' then phone
    else '+' || phone
  end
  from auth.users where id = auth.uid() limit 1
$$;
