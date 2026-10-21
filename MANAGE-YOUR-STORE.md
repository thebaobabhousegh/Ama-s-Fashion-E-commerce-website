# Manage Ama’s Fashion yourself

Your private management screen is at **http://127.0.0.1:8000/admin** when you run the Node server locally.

## First-time setup

Requires Node.js 22.13 or later. Run `npm ci` to install the pinned dependencies.

Open Terminal and enter:

```bash
cd "amas-fashion"
```

If `.env` does not exist yet, copy the example:

```bash
cp -n .env.example .env
```

Create your owner login:

```bash
npm run setup:admin
```

Enter your own email and choose a password of 12–128 characters. Password entry is hidden. Keep these credentials private; there is no default account.

For a completely empty store, import the sample collection once:

```bash
npm run seed:draft
```

Skip this if products already exist. The command refuses to overwrite existing data. The imported inventory is sample stock for review, not your actual stock count.

Start your store:

```bash
npm start
```

Open:

- Storefront: **http://127.0.0.1:8000**
- Management: **http://127.0.0.1:8000/admin**

Sign in using the email and password you created. Keep Terminal open while using the store. Press **Ctrl+C** to stop it. Use Node for the full backend; the old Python server only serves the static demo.

## What you can manage

### Overview

See visible products, low-stock sizes, pending payments, orders ready to process, payments needing review, and verified order value. Verified order value is the sum of paid/processing/shipped/completed orders, not net accounting revenue. The activity list records catalogue, order and settings changes.

### Products & stock

- Add a new piece or search for an existing one.
- Change its name, category, colour, description and price.
- Upload a JPEG, PNG or WebP image up to 2 MB, or enter an HTTPS photo URL.
- Set available quantities for XS, S, M, L and XL.
- Show or hide the product.
- Click **Save piece**, then refresh the storefront.

Hiding a piece removes it from browsing without destroying historical orders. Use photos you own or have permission to use. Uploaded photos are publicly accessible store assets.

Available stock already excludes units reserved for pending payments. Count those reservations when reconciling the physical stock in your shop.

### Orders

Search by order reference, customer name or email. Filter by status and move between pages. Verified paid orders move through:

**Paid → Processing → Shipped → Completed**

Use **Check payment with Paystack** to reconcile a pending or expired payment. You cannot manually label an unpaid order paid. Payments arriving after reservations expire are checked against stock availability; conflicts are flagged for review.

Initiate refunds through Paystack. After a full refund finishes, enter the order reference and Paystack refund ID in **Reconcile a refund**. The server checks it independently. Returned goods are not restocked automatically.

Paystack credentials are required for real payment checks. They stay in the server environment, outside the management editor. Checkout remains closed by default.

### Website & delivery

Edit the announcement bar, main headings, homepage description, campaign photo, story text, contact details, returns/delivery policy and privacy wording.

Add delivery areas using a unique code (for example, `accra`), a customer-facing name, and a fee in GHS. Zero is valid for free delivery. Existing pending orders retain their original fees; new checkouts use the saved rates.

Click **Save website & delivery settings**, then refresh the storefront. These edits persist across server restarts. Policy links appear only after you enter policy text. Settings revisions protect against overwriting newer changes from another browser window; refresh and reapply your changes if a conflict is reported.

## Password recovery

If you forget your owner password, stop the server and run this locally:

```bash
npm run reset:admin
```

Confirm the reset and enter your replacement credentials. Existing management sessions are revoked. This requires access to the server’s Terminal; there is no public registration or email reset link.

## Keep your data

By default, your database is `data/store.sqlite` and uploaded photos are in `data/uploads/`. Keep this directory when moving or hosting the project. Back it up securely, including SQLite WAL files if copying a stopped database. Prefer SQLite’s online backup mechanism for a running database. Do not include customer data or credentials in tutorial recordings or public archives.

The management system currently has one owner account. Separate staff permissions, MFA and automated email recovery are not implemented. This version is still for review; real sales require the launch setup listed in README.md.
