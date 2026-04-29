-- Lock down anon access to public schema. Every legitimate flow runs after
-- OTP verification, so the client always has an authenticated session by the
-- time it reaches the database. Also revoke TRUNCATE from authenticated, since
-- TRUNCATE bypasses RLS.

revoke all on table
    public.users,
    public.households,
    public.household_invites,
    public.categories,
    public.expenses,
    public.user_expenses,
    public.exceptions
  from anon;

revoke truncate on table
    public.users,
    public.households,
    public.household_invites,
    public.categories,
    public.expenses,
    public.user_expenses,
    public.exceptions
  from authenticated;


-- A naive policy on public.users that joins back to public.users would recurse.
-- Wrap the lookup in a SECURITY DEFINER helper so the inner read runs as the
-- function owner and skips RLS.

create or replace function public.current_user_household_id()
returns integer
language sql
security definer
stable
set search_path = public
as $$
  select household_id from public.users where auth_user_id = auth.uid() limit 1
$$;

create or replace function public.current_user_phone_e164()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select phone from auth.users where id = auth.uid() limit 1
$$;

revoke all on function public.current_user_household_id() from public;
grant execute on function public.current_user_household_id() to authenticated;

revoke all on function public.current_user_phone_e164() from public;
grant execute on function public.current_user_phone_e164() to authenticated;


alter table public.users             enable row level security;
alter table public.households        enable row level security;
alter table public.household_invites enable row level security;
alter table public.categories        enable row level security;
alter table public.expenses          enable row level security;
alter table public.user_expenses     enable row level security;
alter table public.exceptions        enable row level security;


-- public.users

create policy "users_select_self" on public.users
  for select to authenticated
  using (auth_user_id = auth.uid());

create policy "users_select_by_phone" on public.users
  for select to authenticated
  using (
    phone_e164 is not null
    and phone_e164 = public.current_user_phone_e164()
  );

create policy "users_select_household_members" on public.users
  for select to authenticated
  using (
    household_id is not null
    and household_id = public.current_user_household_id()
  );

-- An invitee who has not joined yet still needs to render inviter names from
-- the pending invite they received.
create policy "users_select_via_pending_invite" on public.users
  for select to authenticated
  using (
    exists (
      select 1
      from public.household_invites hi
      where hi.status = 'pending'
        and hi.invited_phone_e164 = public.current_user_phone_e164()
        and public.users.id = any(hi.inviter_user_ids)
    )
  );

create policy "users_insert_self" on public.users
  for insert to authenticated
  with check (auth_user_id = auth.uid());

create policy "users_update_self" on public.users
  for update to authenticated
  using (auth_user_id = auth.uid())
  with check (auth_user_id = auth.uid());

-- Pre-seeded user rows (created before OTP, e.g. via an out-of-band import)
-- get linked to their auth.users row on first sign-in.
create policy "users_update_link_phone" on public.users
  for update to authenticated
  using (
    auth_user_id is null
    and phone_e164 is not null
    and phone_e164 = public.current_user_phone_e164()
  )
  with check (
    auth_user_id = auth.uid()
    and phone_e164 = public.current_user_phone_e164()
  );


-- public.households

create policy "households_select_member" on public.households
  for select to authenticated
  using (id = public.current_user_household_id());

create policy "households_select_via_invite" on public.households
  for select to authenticated
  using (
    exists (
      select 1
      from public.household_invites hi
      where hi.status = 'pending'
        and hi.invited_phone_e164 = public.current_user_phone_e164()
        and hi.household_id = public.households.id
    )
  );

create policy "households_insert_authed" on public.households
  for insert to authenticated
  with check (auth.uid() is not null);


-- public.household_invites

create policy "invites_select_invitee" on public.household_invites
  for select to authenticated
  using (invited_phone_e164 = public.current_user_phone_e164());

create policy "invites_select_household" on public.household_invites
  for select to authenticated
  using (household_id = public.current_user_household_id());

create policy "invites_insert_member" on public.household_invites
  for insert to authenticated
  with check (
    household_id = public.current_user_household_id()
    and (
      select id from public.users where auth_user_id = auth.uid() limit 1
    ) = any(inviter_user_ids)
  );

create policy "invites_update_invitee" on public.household_invites
  for update to authenticated
  using (invited_phone_e164 = public.current_user_phone_e164())
  with check (invited_phone_e164 = public.current_user_phone_e164());

create policy "invites_update_member" on public.household_invites
  for update to authenticated
  using (household_id = public.current_user_household_id())
  with check (household_id = public.current_user_household_id());


-- public.categories, public.expenses, public.exceptions: scope to the
-- caller's household.

create policy "categories_household_rw" on public.categories
  for all to authenticated
  using (household_id = public.current_user_household_id())
  with check (household_id = public.current_user_household_id());

create policy "expenses_household_rw" on public.expenses
  for all to authenticated
  using (household_id = public.current_user_household_id())
  with check (household_id = public.current_user_household_id());

create policy "exceptions_household_rw" on public.exceptions
  for all to authenticated
  using (
    household_id is not null
    and household_id = public.current_user_household_id()
  )
  with check (
    household_id is not null
    and household_id = public.current_user_household_id()
  );


-- public.user_expenses has no household_id column; gate via the parent expense.

create policy "user_expenses_household_rw" on public.user_expenses
  for all to authenticated
  using (
    exists (
      select 1
      from public.expenses e
      where e.id = public.user_expenses.expense_id
        and e.household_id = public.current_user_household_id()
    )
  )
  with check (
    exists (
      select 1
      from public.expenses e
      where e.id = public.user_expenses.expense_id
        and e.household_id = public.current_user_household_id()
    )
  );
