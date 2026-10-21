# Ama’s Fashion: review handoff

The premium storefront has been preserved. This pass adds a persistent catalogue and order database, stock by size, server-calculated delivery/totals, Paystack hosted checkout, verified payment webhooks, a protected administrator screen, reservation expiry, late-payment safeguards, and full-refund reconciliation.

**Status:** prepared for review; not deployed or cleared for live selling. Checkout defaults closed. Current merchandise, prices, photos and stock are sample content. No payment-provider credentials were entered or customer messages sent.

## Run it yourself

In Terminal:

```bash
cd "amas-fashion"
cp .env.example .env
npm run seed:draft
npm start
```

Open `http://127.0.0.1:8000`. The seed step is only needed once and refuses to overwrite a populated catalogue. The full backend uses Node, so the earlier Python static-server command will only show the demo.

For `/admin`, run `npm run setup:admin` once and choose your own email and password. Password entry is hidden. Start the server, then sign in through the management screen. See MANAGE-YOUR-STORE.md for the complete guide.

## Review now

1. Browse categories, search, save pieces, select a size and adjust your bag.
2. Open checkout and confirm that live sales are closed during review.
3. Sign into `/admin`, upload a photo, edit a draft product, adjust size stock and refresh the storefront. Use Website & delivery to update homepage content and delivery fees.
4. Follow the Paystack test setup in README.md to exercise an actual hosted test checkout. No card or mobile-money data is entered into the store itself.
5. Review orders and test the paid → processing → shipped → completed progression. Pending orders cannot be marked paid manually.

## Verification completed

Thirty-five automated tests pass using in-memory databases and simulated Paystack responses. They check pricing tampering, stock constraints, idempotency, authentication, origin restrictions, payload limits, signature verification, exact payment amounts/currency, reservation expiry, late payments and refund reconciliation. Existing static-storefront behavior checks pass too.

The server has not been started for you. The new checkout/admin screens still need browser testing with your Paystack test account. Docker packaging is supplied but has not been built or deployed.

## Needed before launch

- Real catalogue, licensed photos, inventory, delivery fees, contact information and approved store/privacy/returns terms.
- Paystack credentials and end-to-end test-mode verification.
- Transactional notifications, courier/fulfillment process and a clear dispute/refund procedure.
- Hosting with a persistent disk, domain, HTTPS, monitoring, backup and recovery verification.
- Mobile/accessibility checks and finalized search metadata/product URLs.

Guest checkout is supported; customer accounts and staff roles are not included. Order searching and pagination, owner login and website settings are included. Inventory and orders use a single-node SQLite backend. Vercel hosting is now prepared through the separate cloud API, remote libSQL database and Vercel Blob; follow VERCEL-DEPLOY.md. The original static Sites configuration remains separate.
