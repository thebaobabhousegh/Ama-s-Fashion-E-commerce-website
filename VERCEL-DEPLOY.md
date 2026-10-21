# Host Ama’s Fashion on Vercel

This guide is for you to perform the deployment yourself. Paste only command text into Terminal, not the Markdown fences. Do not record secret values while filming your tutorial.

## What this setup hosts

- Storefront and management dashboard: Vercel.
- Products, inventory, orders, owner login and website settings: a remote libSQL-compatible database from Turso.
- Product and campaign photo uploads: a **public** Vercel Blob store.

The existing local Node/SQLite server continues to work with `npm start`. The cloud version uses the same business rules with asynchronous database access, request-isolated transactions and persistent database-backed rate limits. It never uses `/tmp` as a permanent database. Cloud storage may involve provider terms, plan selection and charges; review these yourself during setup.

## 1. Enter the project folder

```bash
cd "amas-fashion"
```

Install the pinned project dependencies:

```bash
npm ci
```

Install Vercel CLI from the official npm package if it is not already available.

## 2. Sign in and link the correct project

```bash
vercel login
```

```bash
vercel link
```

Choose your Vercel account/team and create or select the **Ama’s Fashion** project. Confirm the project folder is this directory, containing `vercel.json` and `package.json`, rather than only `dist/`.

This creates `.vercel/project.json`. Cloud database scripts refuse to proceed until this project is linked. Do not deploy yet.

## 3. Connect persistent storage

For the database, use the Vercel Marketplace Turso integration. Inspect the integration’s current guide before installing:

```bash
vercel integration guide turso
```

```bash
vercel integration add turso
```

Select a **libSQL-compatible** database connection supported by `@libsql/client`, connect it to the linked project and ensure these secret environment variables are available for **Production**:

- `TURSO_DATABASE_URL`
- `TURSO_AUTH_TOKEN`

If the current Marketplace flow does not offer a libSQL-compatible connection, create one through Turso’s dashboard and add those variables in Vercel → Project Settings → Environment Variables. The code uses the libSQL client, not Turso’s newer native-engine SDK; select the matching database type rather than assuming every engine is interchangeable.

For photos, open your Vercel project → **Storage** → create a **Blob** store with **public** access, and connect it to this project. Product photos are public by design. Confirm one of these is connected:

- `BLOB_READ_WRITE_TOKEN`, or
- `BLOB_STORE_ID` with the supported Vercel Blob OIDC connection.

For the one-time local photo import, use a Blob read/write token in the pulled local environment if OIDC is not available outside a deployed function. Keep it secret. If there are no locally uploaded photos, the importer does not need to upload any existing HTTPS catalogue photos.

Keep production and preview databases separate if you later add preview deployments. Do not point untrusted preview code at the production database or give it production secrets.

## 4. Keep checkout closed during the hosting review

In Vercel → Project Settings → Environment Variables → Production, set:

| Name | Value |
| --- | --- |
| `CHECKOUT_ENABLED` | `false` |
| `CATALOGUE_APPROVED` | `false` |
| `LIVE_SALES_APPROVED` | `false` |

Do not add a Paystack live key yet. You do not need one to host the storefront and manage the catalogue.

For the initial `vercel.app` domain, the function derives its allowed host from Vercel’s deployment variables. When adding a custom domain later, set `PUBLIC_ORIGIN` to that exact HTTPS origin and redeploy. Do not use `http://127.0.0.1:8000` as the cloud origin.

## 5. Pull cloud credentials locally

```bash
vercel env pull .env.vercel --environment=production
```

This writes secrets to `.env.vercel`, which is ignored by Git, deployment uploads and project archives. Never paste its contents into chat or show it in your tutorial. It does not replace your existing `.env` file.

The cloud scripts read `.env.vercel`; `npm start` continues to read your local `.env`.

## 6. Initialize the empty cloud database

```bash
npm run cloud:init
```

This creates the cloud schema. It preserves existing records. It is a setup step you run yourself, not a public website endpoint and not an automatic build-time mutation.

## 7. Transfer your existing store

Stop your local server with **Control+C** before the final cutover so the local store stops changing.

To transfer the existing local database, catalogue, orders, settings, owner account and uploaded photos:

```bash
npm run cloud:import-local
```

The importer:

- Opens the local database read-only and keeps a consistent snapshot.
- Moves referenced local photo files to Vercel Blob and rewrites those photo URLs in the cloud copy.
- Preserves your existing owner email/password hash, so you can use the same login.
- Does not copy active admin sessions; you sign in again on the hosted site.
- Refuses to overwrite a cloud store that already contains data.
- Leaves your local files and database unchanged.

The default local source is `data/store.sqlite`. If you use a different database path, set `LOCAL_DATABASE_PATH` in `.env.vercel` before importing. Include both the SQLite database and its uploads folder in your backup before cutover. Order/customer data and salted password hashes will be transferred to your selected cloud database when you execute this command.

If the local store has no owner account, create a cloud owner after initializing/importing:

```bash
npm run cloud:setup-admin
```

Do **not** create the cloud owner before importing an existing store: the importer refuses a non-empty target. `npm run cloud:reset-admin` is the explicit owner-password recovery command for the cloud database.

Do not continue editing both local and cloud stores after cutover; they are separate databases and do not automatically synchronize. Previously initialized Paystack payment links retain their original callback URL; reconcile outstanding payments before moving real sales to a new origin.

## 8. Validate and deploy

```bash
npm run build:vercel
```

```bash
npm test
```

```bash
vercel --prod
```

Use the URL printed by Vercel after the deployment reports success. Your management dashboard is at that URL followed by `/admin`.

`vercel.json` configures the static storefront, the serverless API route and admin routing. No Docker server or persistent listening process is required on Vercel.

## 9. Verify the hosted site

- Open the storefront and `/admin`.
- Sign in with the imported owner login.
- Edit a product, save it and refresh the storefront.
- Upload a test product photo and confirm it persists after another deployment.
- Change a website setting and check the customer-facing page.
- Confirm checkout still says the store is preparing for launch.
- Check `/api/health` and Vercel runtime logs for errors.

No cloud resources were created or live deployment performed while preparing these files. The cloud code passed local libSQL-backed parity tests; actual Vercel routing, provider connectivity, OIDC permissions and hosted-browser behavior must be verified after you provision resources and deploy.

## Before taking real payments

Finish catalogue/policy approval, transactional notifications, backup/recovery and operational review. Configure Paystack test mode and verify hosted card/mobile-money checkout and webhook behavior before adding live credentials. Register your hosted `/api/payments/paystack/webhook` URL in Paystack and confirm Vercel protection settings permit provider delivery; private protected previews cannot receive arbitrary provider webhooks without an explicit supported access configuration.

Expired stock reservations are released on new catalogue/quote/order requests. This keeps availability correct for active shoppers without relying on a process-local timer; add a protected scheduled maintenance task if you need expiry to run while the site is idle. Rate-limit counters are shared in the database, rather than per-function memory. Long-term cleanup of old counter keys and a dedicated distributed limiter can be added as traffic grows.

## References

- [Vercel deployment CLI](https://vercel.com/docs/cli/deploy)
- [Vercel Marketplace](https://vercel.com/marketplace)
- [Vercel Blob](https://vercel.com/docs/vercel-blob)
- [Turso TypeScript/libSQL reference](https://docs.turso.tech/sdk/ts/reference)
