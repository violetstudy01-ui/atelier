# Studio Atelier

A student art-studio website for browsing paintings, requesting wall painting, and ordering custom pottery.

## Features

- Painting gallery with local artwork images and search/sorting
- “See It on Your Wall” room preview
- Customer email/password sign-in
- Painting orders, wall bookings, and pottery requests
- Customer dashboard and admin decision screens
- Supabase database policies for record access and business rules

## Technology

- React + JavaScript + Vite
- Supabase Auth and PostgreSQL
- A small Express health endpoint in `server/index.js`

**Architecture note:** The current React application reads and writes its business data directly through the Supabase JavaScript client. The Express server currently provides only a `/health` endpoint; it is not the API handling orders or bookings. For the simplest deployment, host the React frontend and use Supabase for authentication/database. Deploy Express separately only if you need its health endpoint.

## 1. Local setup

Requirements: Node.js 18 or newer.

1. Copy `.env.example` to `.env`.
2. Fill in the Supabase project URL and publishable/anon key.
3. Install dependencies: `npm install`.
4. Start the frontend: `npm run dev`.
5. Open the local URL printed by Vite.

To run the optional Express health endpoint in another terminal:

```bash
node server/index.js
```

It responds at `/health` on port `3001` by default.

## 2. Supabase database setup

1. Create or open your Supabase project.
2. Open **SQL Editor** in the Supabase dashboard.
3. Apply every SQL file in `supabase/migrations/` in filename order, starting with the earliest timestamp.
4. Check that the tables and policies were created.
5. Register a normal customer account through the website.
6. In Supabase **Table Editor → profiles**, change that user's `role` from `customer` to `admin` to grant studio-admin access.

There is no public admin registration page. Never put an admin password or a service-role/secret key in frontend code or GitHub.

The seed migration adds the painting gallery and the pottery/glaze reference data. The image assets are in `public/`.

If the Supabase project already has these migrations applied, do not run them blindly again. Check the existing schema and migration history first.

## 3. Environment variables

`.env.example` lists the only frontend variables expected by this project:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

These values are used by the browser client. The anon/publishable key is designed for browser use only when database Row Level Security is correctly configured. Never expose a Supabase service-role key.

For Vercel, add the same `VITE_` variables in **Project Settings → Environment Variables**, then redeploy.

## 4. Deploy the website

### Frontend (recommended simple route: Vercel)

1. Push this project to GitHub.
2. Import the repository into Vercel.
3. Set the Root Directory to the folder containing this `package.json` (usually `project` if you keep the outer ZIP folder structure; preferably upload the contents of this folder as the repository root).
4. Build command: `npm run build`.
5. Output directory: `dist`.
6. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in Vercel Environment Variables.
7. Deploy and test sign-in, gallery, and a sample workflow.

This is a Vite single-page app. If refreshing a nested URL returns 404, configure SPA rewrites in the hosting provider.

### Optional Express health service

The app's business flows do not currently depend on Express. If you choose to deploy the health service, create a Node web service using this repository, set its service root to the directory containing `server/index.js` and `package.json`, and use `node server/index.js` as the start command. The service exposes `/health`.

## 5. Before submitting

- Verify login and logout.
- Verify customer and admin access separately.
- Verify painting orders and cancellation.
- Verify wall booking date and size validation.
- Verify pottery request status changes.
- Confirm records persist after a refresh.
- Never commit `.env`, passwords, or secret keys.
- Include the GitHub repository and deployed website URLs in your submission.

## Scope

Real payments, uploads, notifications, delivery tracking, and reviews are not implemented.
