/*
# Create Studio Atelier application schema

1. New tables
- `profiles`: signed-in user names and roles. Roles are `customer` or `admin`.
- `paintings`: unique artworks that can be purchased once.
- `orders`: customer painting orders, with cancellation support.
- `wall_bookings`: one booking per date, with size, address, rate, and status.
- `pottery_items`: available pottery choices.
- `glazes`: available glaze choices.
- `pottery_requests`: customer pottery requests with status and edit/cancel support.

2. Security
- Row-level security is enabled for every table.
- Customers can only read and change their own records.
- Admin access is controlled by the `is_admin()` function and never by client-side UI alone.
- Public visitors can browse paintings and catalog choices, but mutations require a signed-in account.

3. Integrity
- Painting order creation uses a unique partial index so an artwork cannot have two active orders.
- Wall bookings use a unique date constraint.
- Status and date constraints enforce assignment rules in the database.

4. Seed data
- Adds a small starter gallery, pottery catalog, and glaze catalog with remote image URLs.
- The admin role is intentionally not seeded; promote a signed-in profile to admin in the Supabase dashboard after registering.
*/

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL DEFAULT 'Studio guest',
  role text NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.paintings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  artist text NOT NULL,
  description text NOT NULL DEFAULT '',
  image_url text NOT NULL,
  price numeric(10,2) NOT NULL CHECK (price > 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  painting_id uuid NOT NULL REFERENCES public.paintings(id) ON DELETE RESTRICT,
  customer_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  price numeric(10,2) NOT NULL CHECK (price > 0),
  status text NOT NULL DEFAULT 'placed' CHECK (status IN ('placed', 'cancelled')),
  created_at timestamptz NOT NULL DEFAULT now(),
  cancelled_at timestamptz
);

CREATE UNIQUE INDEX IF NOT EXISTS one_active_order_per_painting ON public.orders (painting_id) WHERE status = 'placed';

CREATE TABLE IF NOT EXISTS public.wall_bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  booking_date date NOT NULL UNIQUE,
  wall_size_sqft integer NOT NULL CHECK (wall_size_sqft BETWEEN 10 AND 500),
  address text NOT NULL CHECK (char_length(address) >= 10),
  rate numeric(10,2) NOT NULL DEFAULT 150,
  total_price numeric(10,2) GENERATED ALWAYS AS (wall_size_sqft * rate) STORED,
  status text NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'confirmed', 'declined', 'cancelled')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.pottery_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.glazes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.pottery_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  item_id uuid NOT NULL REFERENCES public.pottery_items(id) ON DELETE RESTRICT,
  glaze_id uuid NOT NULL REFERENCES public.glazes(id) ON DELETE RESTRICT,
  quantity integer NOT NULL CHECK (quantity BETWEEN 1 AND 12),
  needed_by date NOT NULL,
  status text NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'accepted', 'declined', 'cancelled')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'); $$;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.paintings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wall_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pottery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.glazes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pottery_requests ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.paintings TO authenticated;
GRANT SELECT ON public.paintings TO anon;
GRANT SELECT, INSERT, UPDATE ON public.orders TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.wall_bookings TO authenticated;
GRANT SELECT ON public.pottery_items, public.glazes TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.pottery_items, public.glazes TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.pottery_requests TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

DROP POLICY IF EXISTS "profiles own read" ON public.profiles;
CREATE POLICY "profiles own read" ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid() OR public.is_admin());
DROP POLICY IF EXISTS "profiles own insert" ON public.profiles;
CREATE POLICY "profiles own insert" ON public.profiles FOR INSERT TO authenticated WITH CHECK (id = auth.uid() AND role = 'customer');
DROP POLICY IF EXISTS "profiles own update" ON public.profiles;
CREATE POLICY "profiles own update" ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid() OR public.is_admin()) WITH CHECK ((id = auth.uid() AND role = 'customer') OR public.is_admin());

DROP POLICY IF EXISTS "paintings public read" ON public.paintings;
CREATE POLICY "paintings public read" ON public.paintings FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "paintings admin insert" ON public.paintings;
CREATE POLICY "paintings admin insert" ON public.paintings FOR INSERT TO authenticated WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS "paintings admin update" ON public.paintings;
CREATE POLICY "paintings admin update" ON public.paintings FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS "paintings admin delete" ON public.paintings;
CREATE POLICY "paintings admin delete" ON public.paintings FOR DELETE TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "orders own or admin read" ON public.orders;
CREATE POLICY "orders own or admin read" ON public.orders FOR SELECT TO authenticated USING (customer_id = auth.uid() OR public.is_admin());
DROP POLICY IF EXISTS "orders customer insert" ON public.orders;
CREATE POLICY "orders customer insert" ON public.orders FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid() AND status = 'placed');
DROP POLICY IF EXISTS "orders own cancel" ON public.orders;
CREATE POLICY "orders own cancel" ON public.orders FOR UPDATE TO authenticated USING (customer_id = auth.uid() OR public.is_admin()) WITH CHECK ((customer_id = auth.uid() AND status = 'cancelled') OR public.is_admin());

DROP POLICY IF EXISTS "bookings own or admin read" ON public.wall_bookings;
CREATE POLICY "bookings own or admin read" ON public.wall_bookings FOR SELECT TO authenticated USING (customer_id = auth.uid() OR public.is_admin());
DROP POLICY IF EXISTS "bookings customer insert" ON public.wall_bookings;
CREATE POLICY "bookings customer insert" ON public.wall_bookings FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid() AND status = 'requested');
DROP POLICY IF EXISTS "bookings own cancel or admin update" ON public.wall_bookings;
CREATE POLICY "bookings own cancel or admin update" ON public.wall_bookings FOR UPDATE TO authenticated USING (customer_id = auth.uid() OR public.is_admin()) WITH CHECK ((customer_id = auth.uid() AND status = 'cancelled') OR public.is_admin());

DROP POLICY IF EXISTS "catalog public read items" ON public.pottery_items;
CREATE POLICY "catalog public read items" ON public.pottery_items FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "catalog admin manage items" ON public.pottery_items;
CREATE POLICY "catalog admin manage items" ON public.pottery_items FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS "catalog public read glazes" ON public.glazes;
CREATE POLICY "catalog public read glazes" ON public.glazes FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "catalog admin manage glazes" ON public.glazes;
CREATE POLICY "catalog admin manage glazes" ON public.glazes FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "pottery own or admin read" ON public.pottery_requests;
CREATE POLICY "pottery own or admin read" ON public.pottery_requests FOR SELECT TO authenticated USING (customer_id = auth.uid() OR public.is_admin());
DROP POLICY IF EXISTS "pottery customer insert" ON public.pottery_requests;
CREATE POLICY "pottery customer insert" ON public.pottery_requests FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid() AND status = 'requested');
DROP POLICY IF EXISTS "pottery own edit or admin update" ON public.pottery_requests;
CREATE POLICY "pottery own edit or admin update" ON public.pottery_requests FOR UPDATE TO authenticated USING (customer_id = auth.uid() OR public.is_admin()) WITH CHECK ((customer_id = auth.uid() AND status IN ('requested', 'cancelled')) OR public.is_admin());

INSERT INTO public.paintings (title, artist, description, image_url, price) VALUES
('Quiet Ochre', 'Mira Sen', 'A warm study in light, clay and late afternoon stillness.', 'https://images.pexels.com/photos/1183992/pexels-photo-1183992.jpeg?auto=compress&cs=tinysrgb&w=1200', 18500),
('Blue Hour', 'Arjun Rao', 'Layered blue pigments inspired by the last light over the city.', 'https://images.pexels.com/photos/1647962/pexels-photo-1647962.jpeg?auto=compress&cs=tinysrgb&w=1200', 24000),
('Garden Memory', 'Leela Kapoor', 'An expressive floral landscape with soft green and coral notes.', 'https://images.pexels.com/photos/1266808/pexels-photo-1266808.jpeg?auto=compress&cs=tinysrgb&w=1200', 21000),
('Still Life No. 4', 'Mira Sen', 'A considered composition of vessels, shadow and morning fruit.', 'https://images.pexels.com/photos/167404/pexels-photo-167404.jpeg?auto=compress&cs=tinysrgb&w=1200', 16500)
ON CONFLICT DO NOTHING;

INSERT INTO public.pottery_items (name) VALUES ('Tea set'), ('Serving bowl'), ('Planter'), ('Bud vase') ON CONFLICT DO NOTHING;
INSERT INTO public.glazes (name) VALUES ('Ivory matte'), ('Terracotta wash'), ('Deep ocean'), ('Sage satin') ON CONFLICT DO NOTHING;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon;
