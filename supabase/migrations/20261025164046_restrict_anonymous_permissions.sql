/*
# Restrict anonymous permissions

1. Change
- Anonymous visitors can browse paintings and catalog choices only.
- Customer records and order/booking/request writes are authenticated-only.

2. Security
- Revoke default anonymous CRUD privileges from protected tables.
- Keep authenticated grants required by the row-level security policies.
*/

REVOKE INSERT, UPDATE, DELETE ON public.paintings FROM anon;
REVOKE INSERT, UPDATE, DELETE ON public.pottery_items, public.glazes FROM anon;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.profiles FROM anon;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.orders FROM anon;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.wall_bookings FROM anon;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.pottery_requests FROM anon;
