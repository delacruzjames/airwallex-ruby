# Sandbox Integration Checklist

## Purpose

This document explains how to manually verify airwallex-ruby against the Airwallex sandbox/demo environment.

These checks are not part of the automated unit test suite.

## Safety Rules

- Use Airwallex sandbox/demo credentials only.
- Never use production credentials for this checklist.
- Never commit `.env`.
- Never print full API keys or webhook secrets in logs.
- Never paste real secrets into issues, pull requests, screenshots, or README examples.
- Keep automated specs mocked with WebMock.
- Manual sandbox scripts should be opt-in only.

## Required Environment Variables

AIRWALLEX_CLIENT_ID
AIRWALLEX_API_KEY
AIRWALLEX_LOGIN_AS
AIRWALLEX_WEBHOOK_SECRET

Notes:
- AIRWALLEX_LOGIN_AS is optional.
- AIRWALLEX_WEBHOOK_SECRET is only needed for webhook verification checks.

## Base URLs

Demo:
https://api-demo.airwallex.com/api/v1

Production:
https://api.airwallex.com/api/v1

The SDK should use `environment: :demo` for this checklist.

## Checklist

### 1. Install dependencies

```bash
bundle install
```

### 2. Copy environment template

```bash
cp .env.example .env
```

Then fill in sandbox credentials.

### 3. Run unit tests

```bash
bundle exec rspec
```

### 4. Run lint

```bash
bundle exec rubocop
```

### 5. Build gem

```bash
bundle exec rake build
```

### 6. Verify authentication

```bash
ruby scripts/sandbox/authenticate.rb
```

Expected:
- The script authenticates successfully.
- It prints a redacted token preview.
- It prints token expiry.
- It does not print the API key.

### 7. Verify PaymentIntent create

```bash
ruby scripts/sandbox/create_payment_intent.rb
```

Expected:
- The script creates a sandbox PaymentIntent.
- It prints the PaymentIntent id.
- It prints whether client_secret is present.
- It does not print sensitive credentials.

### 8. Verify PaymentIntent retrieve

```bash
ruby scripts/sandbox/retrieve_payment_intent.rb int_xxx
```

Expected:
- The script retrieves the PaymentIntent.
- It prints id and status if present.

### 9. Verify Refund create, optional

```bash
ruby scripts/sandbox/create_refund.rb int_xxx
```

Expected:
- The script attempts to create a sandbox refund.
- If the sandbox account/payment method does not support refunding this PaymentIntent, the script should show a clean Airwallex error.
- This should not be treated as SDK failure unless the request shape is wrong.

Note: Refund creation may fail depending on sandbox PaymentIntent status or account settings. That is expected and does not indicate an SDK problem unless the request payload is incorrect.

### 10. Verify webhook signature locally

```bash
ruby scripts/sandbox/verify_webhook_signature.rb
```

Expected:
- The script builds a fake webhook payload.
- It signs the payload using AIRWALLEX_WEBHOOK_SECRET.
- It verifies the payload using Airwallex::Webhook.construct_event.
- It prints event name.

### 11. Optional Rails sample check

```bash
cd examples/rails_app
bundle install
```

Review:
- config/initializers/airwallex.rb
- config/routes.rb
- app/controllers/airwallex_webhooks_controller.rb

This sample is illustrative and does not need to call real Airwallex APIs.

## Manual Test Result Template

Date:
Tester:
Gem version:
Ruby version:
Airwallex environment: demo

Authentication:
- [ ] Passed
- Notes:

PaymentIntent create:
- [ ] Passed
- PaymentIntent id:
- Notes:

PaymentIntent retrieve:
- [ ] Passed
- Notes:

Refund create:
- [ ] Passed
- [ ] Skipped
- Notes:

Webhook verification:
- [ ] Passed
- Notes:

Issues found:

## Troubleshooting

### Authentication failed

Check:
- AIRWALLEX_CLIENT_ID
- AIRWALLEX_API_KEY
- AIRWALLEX_LOGIN_AS, if your API key requires it
- environment is set to :demo

### Unauthorized request

Check:
- Token was generated from sandbox credentials
- SDK is using demo base URL
- The account has permissions for the requested API

### PaymentIntent create failed

Check:
- Required request fields
- Currency and amount
- Payment products enabled on sandbox account
- Whether your Airwallex account has payment acceptance enabled

### Refund failed

Possible causes:
- PaymentIntent is not refundable
- Payment was not completed
- Sandbox payment method does not support refund scenario
- Account permissions

### Webhook verification failed

Check:
- Use raw request body
- Use x-timestamp exactly as received
- Use correct webhook secret
- Payload was not parsed and re-serialized before verification
