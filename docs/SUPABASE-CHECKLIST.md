# Supabase connection checklist

1. Confirm the exact Supabase project and status.
2. Inspect existing public tables and migrations; do not create duplicates.
3. Review `supabase/migrations/202611220001_profile_foundation.sql`.
4. Apply only after the existing schema has been checked.
5. Configure Auth providers and redirect URLs.
6. Configure Flutter with the Project URL and Publishable key only.
7. Test signup/signin, own-profile read/insert/update and cross-user denial.
8. Never put service_role or secret keys in the Flutter app.
