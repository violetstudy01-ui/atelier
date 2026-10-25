/*
# Add the complete supplied gallery

1. Change
- Add all eleven local gallery photos from `public/p-002.jpg` through `public/p-012.jpg`.
- Keep the existing four records and avoid duplicate seed rows.
- Include the missing `Still Life No. 4` listing.

2. Notes
- Images are served from the website's public folder so the gallery remains available without third-party image hosting.
*/

INSERT INTO public.paintings (title, artist, description, image_url, price) VALUES
('Village Celebration', 'Studio Atelier', 'A vivid wall painting filled with movement, colour, and community.', '/p-002.jpg', 18500),
('Under the Flowering Tree', 'Studio Atelier', 'A quiet miniature-inspired scene of gardens, trees, and soft water.', '/p-003.jpg', 22000),
('Rhythm in Colour', 'Studio Atelier', 'A bold folk composition with expressive figures and joyful pattern.', '/p-004.jpg', 19500),
('Lilac Canopy', 'Studio Atelier', 'A delicate study of botanical pattern in a soft, pale palette.', '/p-005.jpg', 14500),
('Garden Conversation', 'Studio Atelier', 'A richly layered garden scene with figures beneath an old tree.', '/p-006.jpg', 23000),
('Kalamkari Stories', 'Studio Atelier', 'A detailed narrative work with hand-drawn line and saturated colour.', '/p-007.jpg', 20500),
('Puppets in Silk', 'Studio Atelier', 'A playful portrait of traditional puppets in jewel-toned costume.', '/p-008.jpg', 17500),
('The Garden Musicians', 'Studio Atelier', 'A lyrical landscape where small scenes unfold between trees and water.', '/p-009.jpg', 21500),
('Modern Folk No. 2', 'Studio Atelier', 'A geometric, colourful composition that brings energy to a room.', '/p-010.jpg', 24000),
('Night Performer', 'Studio Atelier', 'A dramatic portrait study shaped by shadow, costume, and light.', '/p-011.jpg', 19000),
('Still Life No. 4', 'Mira Sen', 'A considered composition of vessels, shadow, and morning colour.', '/p-012.jpg', 16500)
ON CONFLICT DO NOTHING;
