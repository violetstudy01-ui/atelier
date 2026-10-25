# Design Document — Studio Atelier

## 1. How do login and the two roles work?

The application uses Supabase Authentication for email-and-password sign-up and sign-in. It is designed around two roles: **Customer** and **Studio Admin**. Customers can browse paintings, place orders, book wall painting services, and request custom pottery, while the admin manages paintings and reviews bookings and pottery requests. Access to protected data is intended to be controlled using Supabase Row Level Security (RLS) policies.

## 2. Which database did you choose, and why?

I chose **Supabase PostgreSQL** because it provides a cloud-hosted relational database and integrates with Supabase Authentication. The relational structure suits the application's data, including paintings, customer orders, wall bookings, and pottery requests. Supabase also provides Row Level Security to help control access to customer and studio data.

## 3. How do you stop two people from taking the same painting or date?

The application uses database-backed records to track painting orders and wall bookings. To reliably prevent duplicate purchases or bookings, the database must enforce uniqueness or use an atomic transaction when an order or booking is created. These constraints must be verified in the deployed database; frontend checks alone are not sufficient to prevent simultaneous requests from creating duplicates.

## 4. What did you finish, what did you leave out, and what would you do next?

I built and deployed the Studio Atelier website using React, Vite, Supabase, and Vercel. The project includes authentication and an interface for the art studio's painting, wall-booking, and custom-pottery workflows, along with a “See It on Your Wall” preview feature. Real payment processing and other optional features such as email notifications and delivery tracking are outside the current scope. Next, I would thoroughly test customer and admin permissions, verify database constraints for concurrent orders and bookings, and improve automated testing and error handling.
# Design answers

## 1. How do login and the two roles work?

Customers create accounts with email and password. Each new profile starts as a customer. An existing profile can be promoted to the studio admin role by an operator in Supabase; there is no public admin signup. The database checks the role on every protected read and change.

## 2. Which database did you choose, and why?

I chose Supabase because it provides hosted Postgres, email/password authentication, and row-level security in one simple service. It also makes unique painting orders and unique booking dates database rules rather than frontend assumptions.

## 3. How do you stop two people taking the same painting or date?

Orders have a unique partial index for active orders on a painting. Wall bookings have a unique constraint on the booking date. Both rules run in the database, so simultaneous requests cannot create duplicate active records.

## 4. What did you finish, leave out, and do next?

Finished: browsing, painting detail pages, the room preview, authentication, orders, wall bookings, pottery requests, customer records, admin decisions, validation, and database policies. Left out: real payments, uploads, email notifications, delivery tracking, and a full Express API because they are outside the assignment scope. Next I would import the exact supplied seed archive, add a small automated API test suite, and deploy the static frontend with the Supabase project.
