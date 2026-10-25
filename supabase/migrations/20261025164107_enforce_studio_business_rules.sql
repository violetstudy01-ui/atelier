/*
# Enforce studio business rules in the database

1. Rules
- Order prices must match the current painting price.
- Customers may cancel wall bookings only at least three days before the booking date.
- Pottery requests may only be edited or cancelled while requested.

2. Security
- These checks run in database triggers and cannot be bypassed by changing browser code.
*/

CREATE OR REPLACE FUNCTION public.validate_order()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE expected_price numeric;
BEGIN
  SELECT price INTO expected_price FROM public.paintings WHERE id = NEW.painting_id;
  IF expected_price IS NULL OR NEW.price <> expected_price THEN
    RAISE EXCEPTION 'Painting price is invalid';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS validate_order_before_write ON public.orders;
CREATE TRIGGER validate_order_before_write BEFORE INSERT OR UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.validate_order();

CREATE OR REPLACE FUNCTION public.validate_booking_update()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF OLD.status IN ('requested', 'confirmed') AND NEW.status = 'cancelled' AND NEW.booking_date < current_date + 3 THEN
    RAISE EXCEPTION 'Bookings can only be cancelled at least three days before the date';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS validate_booking_before_update ON public.wall_bookings;
CREATE TRIGGER validate_booking_before_update BEFORE UPDATE ON public.wall_bookings FOR EACH ROW EXECUTE FUNCTION public.validate_booking_update();

CREATE OR REPLACE FUNCTION public.validate_pottery_update()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF OLD.status <> 'requested' AND (NEW.quantity <> OLD.quantity OR NEW.needed_by <> OLD.needed_by OR NEW.item_id <> OLD.item_id OR NEW.glaze_id <> OLD.glaze_id) THEN
    RAISE EXCEPTION 'Only requested pottery can be edited';
  END IF;
  IF OLD.status <> 'requested' AND NEW.status = 'cancelled' THEN
    RAISE EXCEPTION 'Only requested pottery can be cancelled';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS validate_pottery_before_update ON public.pottery_requests;
CREATE TRIGGER validate_pottery_before_update BEFORE UPDATE ON public.pottery_requests FOR EACH ROW EXECUTE FUNCTION public.validate_pottery_update();

REVOKE EXECUTE ON FUNCTION public.validate_order() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.validate_booking_update() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.validate_pottery_update() FROM PUBLIC, anon, authenticated;
