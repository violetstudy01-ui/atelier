/*
# Tighten catalog permissions

1. Change
- Replace broad catalog FOR ALL policies with four explicit CRUD policies for each catalog table.

2. Security
- Anonymous and authenticated users can still read pottery items and glazes.
- Only admins can insert, update, or delete catalog entries.
*/

DROP POLICY IF EXISTS "catalog admin manage items" ON public.pottery_items;
DROP POLICY IF EXISTS "catalog admin insert items" ON public.pottery_items;
CREATE POLICY "catalog admin insert items" ON public.pottery_items FOR INSERT TO authenticated WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS "catalog admin update items" ON public.pottery_items;
CREATE POLICY "catalog admin update items" ON public.pottery_items FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS "catalog admin delete items" ON public.pottery_items;
CREATE POLICY "catalog admin delete items" ON public.pottery_items FOR DELETE TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "catalog admin manage glazes" ON public.glazes;
DROP POLICY IF EXISTS "catalog admin insert glazes" ON public.glazes;
CREATE POLICY "catalog admin insert glazes" ON public.glazes FOR INSERT TO authenticated WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS "catalog admin update glazes" ON public.glazes;
CREATE POLICY "catalog admin update glazes" ON public.glazes FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS "catalog admin delete glazes" ON public.glazes;
CREATE POLICY "catalog admin delete glazes" ON public.glazes FOR DELETE TO authenticated USING (public.is_admin());
