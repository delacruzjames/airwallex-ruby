# Airwallex Ruby Rails Example

This is a lightweight sample Rails integration for airwallex-ruby.

It demonstrates:

- Initializer configuration
- Creating a PaymentIntent
- Creating a Refund
- Verifying webhooks
- Example routes

This sample does not use real credentials.

Environment variables:

- `AIRWALLEX_CLIENT_ID`
- `AIRWALLEX_API_KEY`
- `AIRWALLEX_LOGIN_AS`
- `AIRWALLEX_WEBHOOK_SECRET`

Run example in a real Rails app:

```bash
rails generate airwallex:install
```

Copy the files from this directory into your Rails application as needed.
