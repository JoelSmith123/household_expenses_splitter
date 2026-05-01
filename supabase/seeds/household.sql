-- ============================================================
-- Mock Household Seed Data
-- Populates a realistic two-person household for core feature dev.
-- Usage: npm run db:reset:household
-- ============================================================

-- Drop any prior auth.users row for the test phone so re-seeding is deterministic.
-- supabase db reset does not always wipe the auth schema; an orphaned auth row
-- with a non-E.164 phone would prevent the new OTP login from matching the
-- seeded public.users.phone_e164. GoTrue stores phone as '16025459712' (no '+'
-- prefix) regardless of how the client sends it, so cover both forms.
DELETE FROM auth.users WHERE phone IN ('+16025459712', '16025459712', '6025459712');

-- Household
INSERT INTO public.households (id, name) VALUES (1, 'The Test House');
SELECT setval('public.households_id_seq', 1);

-- Users: Joel + Alex
-- auth_user_id is NULL for Joel on first seed. On first OTP login, GoTrue creates an auth
-- user and ensureUserProfile() finds Joel via phone_e164 fallback, then writes the real
-- auth UUID back. Subsequent logins match via existingByAuth directly.
-- NOTE: do not seed auth.users directly — GoTrue rejects manually-inserted rows during OTP.
INSERT INTO public.users (id, household_id, display_name, phone_e164, auth_user_id, monthly_income, country_code) VALUES
  (1, 1, 'Joel', '+16025459712', NULL, 5000.00, 'US'),
  (2, 1, 'Alex', NULL,           NULL, 4000.00, 'US');
SELECT setval('public.users_id_seq', 2);

-- Categories (name is globally unique per schema constraint)
INSERT INTO public.categories (id, name, household_id) VALUES
  (1, 'Rent',       1),
  (2, 'Groceries',  1),
  (3, 'Utilities',  1),
  (4, 'Dining Out', 1),
  (5, 'Transport',  1);
SELECT setval('public.categories_id_seq', 5);

-- Expenses spread over the last ~3 weeks
INSERT INTO public.expenses (id, household_id, category_id, description, total_amount, expense_date) VALUES
  (1, 1, 1, 'March rent',         2400.00, CURRENT_DATE - 20),
  (2, 1, 2, 'Trader Joe''s run',    87.43, CURRENT_DATE - 18),
  (3, 1, 3, 'Electric bill',        94.12, CURRENT_DATE - 15),
  (4, 1, 2, 'Costco trip',         134.67, CURRENT_DATE - 12),
  (5, 1, 4, 'Dinner at Nobu',      112.00, CURRENT_DATE - 9),
  (6, 1, 3, 'Internet bill',        79.99, CURRENT_DATE - 7),
  (7, 1, 5, 'Uber to airport',      38.50, CURRENT_DATE - 4),
  (8, 1, 2, 'Corner store',         22.15, CURRENT_DATE - 1);
SELECT setval('public.expenses_id_seq', 8);

-- Splits (user_expenses)
INSERT INTO public.user_expenses (expense_id, user_id, amount_paid) VALUES
  -- Rent: ~55/45 split
  (1, 1, 1320.00),
  (1, 2, 1080.00),
  -- Trader Joe's: 50/50
  (2, 1,   43.72),
  (2, 2,   43.71),
  -- Electric bill: 50/50
  (3, 1,   47.06),
  (3, 2,   47.06),
  -- Costco: 50/50
  (4, 1,   67.34),
  (4, 2,   67.33),
  -- Dinner: 50/50
  (5, 1,   56.00),
  (5, 2,   56.00),
  -- Internet: 50/50
  (6, 1,   40.00),
  (6, 2,   39.99),
  -- Uber: Joel solo
  (7, 1,   38.50),
  -- Corner store: 50/50
  (8, 1,   11.08),
  (8, 2,   11.07);
SELECT setval('public.user_expenses_id_seq', 15);

-- Exceptions: Alex pays reduced 75% of their share on Rent
INSERT INTO public.exceptions (id, user_id, category_id, exception_type, percent, household_id)
VALUES (1, 2, 1, 'REDUCED', 75.00, 1);
SELECT setval('public.exceptions_id_seq', 1);
