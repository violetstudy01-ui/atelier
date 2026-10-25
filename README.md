# Studio Atelier 🎨

Studio Atelier is a full-stack art studio website where customers can explore and purchase paintings, book wall-painting services, and request custom pottery. It also includes a **“See It on Your Wall”** feature to preview artwork in a room setting.

## 🌐 Live Demo

**Website:** https://atelier-mu-beige.vercel.app

## ✨ Features

- **Painting Gallery:** Browse available paintings from the studio.
- **See It on Your Wall:** Preview how artwork could look in a room setting.
- **User Authentication:** Sign up and sign in using email and password.
- **Painting Orders:** Place orders for available paintings.
- **Wall Painting Bookings:** Request a booking by selecting a date, wall size, and address.
- **Custom Pottery Requests:** Select a pottery item, glaze, quantity, and required date.
- **Customer Dashboard:** View your own orders, bookings, and pottery requests.
- **Studio Administration:** Manage paintings and review wall bookings and pottery requests.

*Note: This is a demonstration project and does not process real payments.*

## 🛠️ Tech Stack

- **Frontend:** React, JavaScript, Vite, CSS
- **Authentication:** Supabase Auth
- **Database:** Supabase PostgreSQL
- **Database Security:** Row Level Security (RLS)
- **Deployment:** Vercel
- **Additional Backend:** Express.js health-check endpoint

The React frontend uses the Supabase JavaScript client for authentication and database operations. The Express service provides a health-check endpoint.

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

- Node.js 18 or newer
- npm
- A Supabase account and project

### 1. Clone the Repository

```bash
git clone https://github.com/violetstudy01-ui/atelier.git
cd atelier
```

If the project is inside a subdirectory, navigate to the directory containing `package.json`.

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Add your Supabase project details:

```env
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-supabase-publishable-or-anon-key
```

Replace the placeholder values with the Project URL and publishable key from your Supabase dashboard. You can also use the legacy `anon public` key.

The frontend expects the API key in the `VITE_SUPABASE_ANON_KEY` variable.

**Security:** Never put your Supabase `service_role` or secret key in frontend code or commit your `.env` file to GitHub.

### 4. Set Up the Database

1. Open your Supabase project.
2. Navigate to **SQL Editor**.
3. Apply the required database schema, seed data, and Row Level Security policies.
4. Verify that the required tables and policies exist before running the application.

If the database has already been configured, do not rerun the SQL scripts blindly.

### 5. Run the Development Server

```bash
npm run dev
```

Open the local URL displayed in your terminal.

### Useful Commands

```bash
npm run build
npm run preview
npm run lint
```

Run only commands that are defined in the project's `package.json`.

## ☁️ Deployment

The project is deployed using Vercel.

To deploy your own copy:

1. Import the GitHub repository into Vercel.
2. Select **Vite** as the framework preset.
3. Set the Root Directory to the directory containing `package.json`.
4. Configure the build command as `npm run build`.
5. Set the output directory to `dist`.
6. Add the following environment variables in **Settings → Environment Variables**:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
7. Deploy the project and verify the application.

Ensure that the environment variables point to the same Supabase project where the database schema and authentication are configured.

## 👥 User Roles

### Customer
- Browse available paintings.
- Place painting orders.
- Request wall-painting bookings.
- Submit custom pottery requests.
- View and manage their own orders and requests.

### Studio Admin
- Browse paintings.
- Add or edit available paintings.
- View customer orders, bookings, and pottery requests.
- Confirm or decline wall bookings.
- Accept or decline pottery requests.

Access permissions should be enforced through database policies and appropriate application logic. Admin access should not be available through public sign-up.

## 📌 Scope and Limitations

The project focuses on the core art studio workflow. The following features are outside the current project scope:

- Real payment processing
- Password reset and email verification
- Social login
- Public studio-admin registration
- Artwork image uploads
- Reviews and coupons
- Delivery tracking
- Email and SMS notifications

## ✅ Testing Checklist

Before submitting the project, verify:

- User registration and login
- Painting availability and order creation
- Wall booking date and wall-size validation
- Custom pottery request creation
- Customer cancellation and ownership restrictions
- Studio-admin approval and rejection workflows
- Correct database access permissions
- Environment variables and deployment configuration

## 🔮 Future Improvements

- Add automated tests for important user workflows.
- Improve accessibility and responsive design.
- Add artwork image uploads.
- Introduce email notifications for booking updates.
- Improve error handling and user feedback.

---

**Studio Atelier** — Bringing art into everyday spaces.
