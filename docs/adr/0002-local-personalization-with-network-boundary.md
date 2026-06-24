# ADR-0002: Local personalization with hard network boundary

## Status
Accepted

## Context
Cotypist stores typing history in an encrypted SQLite database for personalization, but the encryption makes it impossible for users to audit what's stored. It also bundles Sentry (crash reporting) and RepliesSDK (support), both of which make network calls that could theoretically include user context.

Scribe Bar wants personalization (learning writing style over time) but with zero risk of data exfiltration.

## Decision
Implement **local personalization** with two hard constraints:

### 1. Plaintext, auditable storage
- Writing Profile is stored as **plaintext JSON** files the user can open, inspect, and delete
- No opaque encrypted databases — if a user runs `cat` on any file in Scribe Bar's data directory, they should be able to read it
- Storage location: `~/Library/Application Support/app.scribebar.ScribeBar/Profiles/`

### 2. Hard Network Boundary
- Scribe Bar makes network calls for **exactly two purposes**: model downloads and app update checks
- **Never** for: user data, typing context, personalization data, crash reports, analytics, telemetry
- No Sentry, no third-party analytics SDK, no crash reporting SDK
- This is enforced architecturally — the personalization subsystem has no access to `URLSession` or `Network.framework`

### What gets stored for personalization
- Frequently used phrases and word patterns (statistical, not raw text)
- Per-app writing style signals (formal vs. casual)
- Accepted/rejected completion patterns
- Language detection history (which languages the user types in which apps)

### What never gets stored
- Raw typed text verbatim
- Screenshot images or raw OCR output
- Clipboard contents
- Passwords, secrets, private keys (SecretSanitizer filters these before any processing)

## Consequences
- **Good**: Users can fully audit their data with `cat` or any text editor
- **Good**: Zero exfiltration risk — personalization module has no network access
- **Good**: Still learns writing style, so completions improve over time
- **Trade-off**: Plaintext storage means another app with disk access could read it (mitigated by macOS sandboxing)
- **Trade-off**: No crash reporting means bugs are harder to diagnose — rely on user-submitted logs instead
