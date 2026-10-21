# Ama’s Fashion — GitHub & Vercel source package

Premium fashion storefront, self-service administration and Paystack-ready commerce backend. This package preserves local development and includes a serverless-compatible cloud implementation.

**Status:** cloud preparation, syntax checks and 36 local tests pass. It has not been deployed or verified against real Turso, Vercel Blob or Paystack accounts in this packaging pass. Live selling remains disabled by default. Connecting services and completing launch verification are required.

## Upload to GitHub

1. Extract the ZIP. Upload the **contents** of the `amas-fashion` folder into your repository root, including `api/`, `cloud/`, `dist/`, `server/`, `scripts/`, `tests/`, `package.json`, `package-lock.json`, `vercel.json` and the ignore files.
2. Upload extracted source files, not the ZIP itself and not just `dist/`.
3. Do not upload `.env`, `.env.vercel`, `.vercel/`, `data/` or `node_modules/`. These are excluded from this archive and ignored by Git. Your existing owner credentials and customer database are intentionally absent.

## Import the repository in Vercel

Use **Add New → Project → Import Git Repository** and select this repository. Use the repository root (where `package.json` is located), not `dist/`.

| Setting | Value |
| --- | --- |
| Framework preset | Other |
| Node.js | 22.x |
| Install command | `npm ci --include=dev` |
| Build command | `npm run build:vercel` |
| Output directory | `dist` |

These build settings and API/admin rewrites are included in `vercel.json`. If Vercel creates an initial deployment before storage is connected, the static pages can appear but the backend will report setup incomplete. Finish the storage/schema steps and redeploy before accepting the site as working.

## Required persistent storage

Connect a **Turso/libSQL-compatible database** and a **public Vercel Blob store** to the intended Vercel project. Set server-side variables for the Production environment:

| Variable | Purpose |
| --- | --- |
| `TURSO_DATABASE_URL` | Remote libSQL database URL |
| `TURSO_AUTH_TOKEN` | Database access credential |
| `BLOB_READ_WRITE_TOKEN` | Public Blob upload credential; a supported `BLOB_STORE_ID`/OIDC connection may be used on hosted Functions instead |
| `CHECKOUT_ENABLED` | `false` for hosting review |
| `CATALOGUE_APPROVED` | `false` until actual content is approved |
| `LIVE_SALES_APPROVED` | `false` until launch approval |

Do not set cloud `PUBLIC_ORIGIN` to localhost. The default Vercel host is detected automatically; set the exact HTTPS origin when adding a custom domain. Keep preview data and credentials separate from Production.

The local SQLite database and uploads folder cannot be used as permanent Vercel storage. The included cloud API uses the remote database and Blob instead.

## Initialize and transfer your store yourself

Follow **[VERCEL-DEPLOY.md](VERCEL-DEPLOY.md)** in order. It includes:

- Linking the intended project with Vercel CLI.
- Pulling secrets into ignored `.env.vercel`.
- `npm run cloud:init` to create the database schema.
- `npm run cloud:import-local` to transfer an existing local store, photos and owner login without exposing them in GitHub.
- `npm run cloud:setup-admin` if no owner was imported.
- Deployment and hosted verification.

If you extracted this clean package into a new directory, your old database was **not copied into it**. Point `LOCAL_DATABASE_PATH` in your private `.env.vercel` to the original `data/store.sqlite` to import your existing store. The importer will transfer referenced local photos from that database’s uploads folder, and refuses to overwrite a populated target.

For a brand-new store with no existing data, first run `npm run seed:draft` locally, then import that new local database into the empty cloud database. This creates sample stock only. Create the cloud owner after import. Alternatively, initialize the cloud schema, create the cloud owner, and add products directly through `/admin` without importing samples. Do not create the cloud owner before a planned import.

## Validate locally

```bash
npm ci
npm run build:vercel
npm run check
npm test
```

These commands do not deploy, provision resources, migrate customer data or initiate payments. Database initialization and transfer are explicit setup steps, not build-time operations.

## Before live trading

Complete actual catalogue/inventory and policy approval, notifications, backups, hosted-browser checks and Paystack test-mode verification. Set Paystack secrets only through private environment settings. Register `/api/payments/paystack/webhook` on the real store origin and verify incoming webhooks can reach it. See [LOCAL-DEVELOPMENT.md](LOCAL-DEVELOPMENT.md) for capabilities and remaining operational limits.

This package is prepared for deployment configuration, not a claim that live production services have already been connected or verified.
