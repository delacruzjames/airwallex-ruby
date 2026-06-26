# Airwallex API Research

Notes for building the unofficial `airwallex-ruby` SDK. Phase 1 uses this document only — no live API calls yet.

## Official documentation

- API reference: https://www.airwallex.com/docs/api
- Authentication: https://www.airwallex.com/docs/api/authentication/api_access/login
- Developer tools: https://www.airwallex.com/docs/developer-tools/api/quickstart-with-postman
- Manage API keys: https://www.airwallex.com/docs/developer-tools/api/manage-api-keys

## Base URLs

| Environment | Base URL |
|-------------|----------|
| Sandbox (demo) | `https://api-demo.airwallex.com/api/v1` |
| Production | `https://api.airwallex.com/api/v1` |

## Authentication

**Endpoint:** `POST /authentication/login`

**Required headers:**

- `x-client-id` — Airwallex Client ID
- `x-api-key` — Airwallex API key

**Response:** JSON with `token` and `expires_at`. Use the token as `Authorization: Bearer <token>` on subsequent requests.

**Implementation notes:**

- Do not call the login endpoint before every request.
- Cache the token in memory and reuse it until `expires_at`.
- Refresh only when expired or after a 401 response.

Optional header for scoped keys:

- `x-login-as` — target account ID when the API key is scoped to multiple accounts

## Planned resources (initial scope)

| Resource | Purpose |
|----------|---------|
| Authentication | Obtain and manage access tokens |
| PaymentIntents | Payment acceptance — create, confirm, capture, cancel |
| Refunds | Refund captured payments |
| Webhooks | Verify webhook signatures and parse events |
| Balances | Query multi-currency account balances |
| Transfers | Payouts to beneficiaries |

## Phase roadmap

1. **Phase 1 (current)** — Gem skeleton, configuration, empty client/resources
2. **Phase 2** — HTTP client, authentication, token caching
3. **Phase 3+** — Individual API resources with tests (WebMock + optional sandbox integration)

## References

- Postman collection uses API version header `x-api-version` (e.g. `2025-11-11`)
- Write operations typically require a `request_id` (UUID) for idempotency
- Sandbox file uploads use `https://files-demo.airwallex.com`; production uses `https://files.airwallex.com`
