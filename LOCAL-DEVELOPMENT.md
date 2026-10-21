# Ama’s Fashion — storefront and management backend

**Hosting on Vercel:** use [VERCEL-DEPLOY.md](VERCEL-DEPLOY.md). Version 0.4 adds a remote libSQL database adapter and Vercel Blob uploads while retaining local SQLite development. You run the deployment and one-time data transfer yourself.

The premium ivory-and-espresso storefront now has a persistent server-owned catalogue, inventory by size, secure checkout preparation, Paystack hosted payments, signed-webhook handling, private order lookup, and an administrator screen. This is prepared for review, not cleared for live trading.

## Run locally yourself

Requires Node.js 22.13 or later (verified with 22.23.1). Run `npm ci` to install the pinned cloud/build dependencies. The built-in SQLite API is still marked experimental in this Node release; pin and validate the runtime before hosting.

From this project directory:

```bash
cp .env.example .env
npm run seed:draft
npm start
```

Open `http://127.0.0.1:8000`. Open `/admin` for store management. The seed command refuses to replace a populated catalogue. Its stock values are samples, not physical inventory. Keep checkout closed for this preview.

Create your owner login once:

```bash
npm run setup:admin
```

The setup command asks for your email and a password (12–128 characters). Password entry is hidden, and the server stores a salted scrypt hash rather than the password. Then start the server and sign in at `/admin`. No default login exists, and there is no publicly accessible registration endpoint. To recover access locally, stop the server and run `npm run reset:admin`; this explicitly resets owner credentials and revokes existing sessions.

Existing installations may still use the old `ADMIN_TOKEN` until an owner account is created. Creating an owner disables token sign-in. This remains a single-owner management system; staff roles, MFA and email-based password recovery are not included.

The old Python static-server command still provides a clearly labelled **demo** only. Use `npm start` for catalogue persistence, order management and Paystack integration.

## Paystack test setup

1. Use your Paystack **test** secret key in `PAYSTACK_SECRET_KEY` in `.env`.
2. Configure delivery areas in the Website & delivery editor (or use `SHIPPING_ZONES` as initial defaults). The editor takes GHS fees; stored values use integer pesewas. Example only (not an approved business rate):
   `[{"id":"accra","name":"Accra — TEST RATE","fee_minor":2500}]`
3. Set `CATALOGUE_APPROVED=true` only in an isolated test environment for testing the sample catalogue, and set `CHECKOUT_ENABLED=true`. Keep `LIVE_SALES_APPROVED=false`.
4. Restart the server and test checkout with Paystack test payment details.
5. For provider callbacks/webhooks, the server must be available at an HTTPS test origin. Set `PUBLIC_ORIGIN` to that exact origin. Register `/api/payments/paystack/webhook` in Paystack. A localhost address is not reachable by Paystack.
6. Verify successful, failed, delayed mobile-money and repeated payments against Paystack itself. Provider behavior has been tested with stubs, not with an actual Paystack account.

Orders reserve stock in an atomic database transaction. Repeated checkout requests with the same key do not reserve again. Prices, delivery fees and totals come from the server, not the browser. The payment callback alone does not confirm an order: the server verifies Paystack status, amount, currency and reference. Webhooks require a valid HMAC-SHA512 signature and also trigger independent transaction verification.

**Pending payments:** stock reservations expire after 30 minutes and are released once. An expired checkout cannot be reused to initialize a new payment. If a delayed payment succeeds, the server reacquires stock transactionally; if stock is no longer available, the order enters `payment_review` and cannot be fulfilled automatically. The operator must arrange a refund or resolve availability. Refunds are initiated in the Paystack dashboard; the management screen independently verifies completed full refunds. Partial refunds and automated dispute handling are not implemented.


## Management

- Sign in with your owner email and password.
- View store metrics and the latest management activity.
- View, add, edit, show or hide products.
- Upload JPEG, PNG or WebP photos up to 2 MB, or use HTTPS photo URLs.
- Edit homepage headings, story text, campaign photo, contact information and policy wording.
- Manage delivery-area names, codes and fees without editing code.
- Update size-specific available stock and prices in GHS.
- Search and filter orders by reference/customer and status, with 25 orders per page.
- Reconcile pending or expired payments with Paystack.
- Verify completed full refunds from Paystack without falsely restocking returned goods.
- Move verified paid orders through processing → shipped → completed.
- Payment status cannot be manually changed to paid.

Available stock is the number left after pending-order reservations. Avoid overwriting it with physical stock counts without accounting for reservations. Shipping labels, courier APIs, tracking links, partial refunds, promotions, customer accounts, transactional email/SMS are outside this review build. Full refunds are initiated in Paystack and reconciled in the management screen.

## Verification

```bash
npm run check
npm test
```

The included tests cover authoritative totals, invalid shipping zones, duplicate cart lines, insufficient stock, atomic orders, idempotency, payment amount/currency checks, fulfillment transitions, launch gates, origin checks, admin authentication and session expiry, body limits, denied sensitive files, signed webhooks, payment verification, initialization retry, reservation expiry, late-payment stock conflicts and full-refund reconciliation. Thirty-five automated checks currently pass across local and cloud drivers, including owner password authentication, settings persistence, conflict detection, delivery fee propagation, order pagination and photo-upload restrictions.

Tests run without opening a listening server and without sending external payments. The revised backend/admin/payment UI has not been browser-tested end to end. No server was started on your behalf in this pass.

## Hosting and launch requirements

The original `npm start` backend needs a **single Node process with a persistent local disk**. For Vercel, use the separate cloud entry point and storage configuration in VERCEL-DEPLOY.md; do not deploy the local SQLite process there. `Dockerfile` is provided for review; the image has not been built in this environment. Mount `/app/data` as a durable volume, terminate HTTPS at a reverse proxy, set `PUBLIC_ORIGIN` through hosting configuration and create your owner account on that persistent database, and use external rate limiting. Do not trust unfiltered forwarding headers. Horizontal scaling requires a shared transactional database and shared rate limiting rather than separate SQLite files.

The retained `.openai/hosting.json` belongs to the earlier static Sites prototype. It does **not** deploy this Node backend. No deployment or audience change has been made. Select and configure backend hosting before publication; migrating this server to Sites requires a Worker-compatible database/runtime implementation.

Before live launch:

- Replace or explicitly approve actual products, stock, prices and owned/licensed photography.
- Supply business name/contact details, delivery zones and charges, tax treatment, delivery promises and returns/privacy terms. These are not invented here; tax calculation is not implemented.
- Configure Paystack, complete real test-mode end-to-end verification and verify account eligibility.
- Verify reservation expiry, late-payment conflict handling and full-refund reconciliation with Paystack test mode. Establish a manual dispute-handling process and connect customer order notifications and recovery procedures.
- Perform browser/accessibility checks of the full storefront and admin experience on mobile and desktop.
- Configure domain, HTTPS, health monitoring, off-host encrypted backups and a tested restore procedure. Use SQLite’s online backup mechanism or stop the server before copying all database files; do not copy only the main database while WAL writes continue.
- Add appropriate retention/deletion controls for customer data, rotate administrator secrets and restrict management access.
- Finalize SEO, product detail URLs, sitemap/canonical metadata and owned social preview assets. `robots.txt` blocks indexing during review.
- Only after those steps, set `CATALOGUE_APPROVED=true`, `CHECKOUT_ENABLED=true`, `LIVE_SALES_APPROVED=true` and the live Paystack secret in the hosting secret store.

Reference documentation: [Paystack payments](https://paystack.com/docs/payments/accept-payments/), [Paystack webhooks](https://paystack.com/docs/payments/webhooks/), [Node SQLite](https://nodejs.org/docs/latest-v22.x/api/sqlite.html).

## Self-service store management

See **MANAGE-YOUR-STORE.md** for the complete first-time setup and everyday editing guide. Website changes are stored in the same database as catalogue and order information. Uploaded photos are stored in `uploads/` beside the configured database; include both the database and this folder in backups and durable hosting volumes. Uploaded photos are public, so upload only store media intended for customers. Unused uploaded files are retained; automatic media cleanup is not implemented.

The settings editor never exposes payment secrets and cannot enable live checkout. Existing pending orders keep their original prices and delivery charges. New checkouts use the latest saved delivery fees. Simultaneous settings edits use a revision check so an old browser window cannot silently replace newer settings.

Cloud build generation is deterministic and does not read local `.env` values or the store database. Migration and owner account commands are separate, explicit operations. The prepared Vercel deployment has not been provisioned or exercised against a real cloud database.
