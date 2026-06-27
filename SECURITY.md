# Security Policy

## Reporting a Vulnerability

Please do not open a public GitHub issue for security vulnerabilities.

Report security issues privately to the maintainer.

## Credential Safety

Never commit:

- AIRWALLEX_CLIENT_ID
- AIRWALLEX_API_KEY
- AIRWALLEX_LOGIN_AS
- AIRWALLEX_WEBHOOK_SECRET
- real webhook payloads containing sensitive data

Use environment variables or Rails credentials.
