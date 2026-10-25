# Design answers

## 1. How do login and the two roles work?

Customers create accounts with email and password. Each new profile starts as a customer. An existing profile can be promoted to the studio admin role by an operator in Supabase; there is no public admin signup. The database checks the role on every protected read and change.

## 2. Which database did you choose, and why?

I chose Supabase because it provides hosted Postgres, email/password authentication, and row-level security in one simple service. It also makes unique painting orders and unique booking dates database rules rather than frontend assumptions.

## 3. How do you stop two people taking the same painting or date?

Orders have a unique partial index for active orders on a painting. Wall bookings have a unique constraint on the booking date. Both rules run in the database, so simultaneous requests cannot create duplicate active records.

## 4. What did you finish, leave out, and do next?

Finished: browsing, painting detail pages, the room preview, authentication, orders, wall bookings, pottery requests, customer records, admin decisions, validation, and database policies. Left out: real payments, uploads, email notifications, delivery tracking, and a full Express API because they are outside the assignment scope. Next I would import the exact supplied seed archive, add a small automated API test suite, and deploy the static frontend with the Supabase project.
