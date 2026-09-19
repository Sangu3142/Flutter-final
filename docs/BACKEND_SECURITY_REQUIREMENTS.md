# Backend Security Requirements — ZamWealth Quest

**Status:** binding. These are ship-blocking requirements for the backend and cloud-sync work, not
recommendations.
**Applies to:** any server, API, database, or third-party integration added to ZamWealth Quest.
**Written:** 2026-09-17, alongside the offline security remediation pass.
**Related:** [docs/security.md](docs/security.md) (offline audit, 9 issues), [SECURITY_AUDIT.md](SECURITY_AUDIT.md)
(fuller 26-finding audit, mostly release-hardening).

---

## Why this document exists

ZamWealth Quest is offline-only today. Every security control in the app — password hashing, Hive
encryption, input validation, level entitlement — runs **on the player's device**, which means every
one of them is advisory. A determined user with a rooted phone can edit any of it.

That is an accepted trade for an offline educational app. It stops being acceptable the moment a
server holds other people's data or real money moves. The rules below are what the backend must
satisfy before it ships.

The single principle underneath all of them:

> **The client is not a security boundary.** Anything the app checks, the server must check again.
> Anything the app knows, an attacker knows. Anything the app is allowed to send, an attacker can
> forge.

Search the codebase for `// BACKEND:` to find the exact places that change when the server lands.

---

## 1. Secrets

**Requirement:** every API key, database credential, signing secret, and third-party token lives in
**server-side environment variables only**.

Non-negotiable:

- **Never in the Flutter client.** Not in Dart source, not in `pubspec.yaml`, not in
  `AndroidManifest.xml`, not in `strings.xml`, not in an asset file, not in a `.env` bundled with
  the app. Everything shipped in an APK is public — `jadx -d out/ app.apk` recovers it in minutes,
  and the release build is not currently obfuscated (SECURITY_AUDIT.md VUL-008).
- **Never committed.** `.env` files stay in `.gitignore`. A secret that reaches a git commit is
  burned and must be rotated, even if the commit is later removed — the history persists in clones
  and forks.
- **Never returned to the client.** No endpoint may echo a config object containing secrets, and no
  error message may include a connection string.
- **CI/CD** reads secrets from the platform's secret store (GitHub Actions secrets, or equivalent),
  never from a checked-in file.
- **Rotation:** document who rotates each secret and how. Rotate on staff change and on any
  suspected exposure.

**The one thing the client may hold** is a short-lived session token issued by your own server,
stored in `flutter_secure_storage` (already a dependency — see `lib/core/secure_hive.dart` for the
established pattern). Never a provider API key, never a database credential.

### Current audit result — clean baseline

A scan of `lib/`, `android/`, `ios/`, and `web/` on 2026-09-17 found **no hardcoded API keys,
tokens, passwords, or credentials**. The only matches for secret-like patterns were the `hint_token`
game power-up constant. Recorded here so a future regression is visible as a change from a known
state.

---

## 2. Server-side authorization on every route

**Requirement:** every endpoint independently verifies that the requesting user owns the record
being read or written. No exceptions for "internal" or "unlikely to be called" routes.

**Never trust a client-supplied user ID.** Not in the body, not in a query string, not in a URL
path, not in a custom header. The only trustworthy identity is the one the server derives from a
verified session token.

### Required pattern

```ts
// Every handler follows this shape. No shortcuts.
async function handler(req) {
  // 1. Identity comes from the verified token — never from the request payload.
  const session = await verifySessionToken(req.headers.authorization);
  if (!session) return respond(401, { error: 'Unauthorized' });
  const userId = session.userId;          // trusted
  // const userId = req.body.userId;      // NEVER — client-controlled

  // 2. Load the record, then prove ownership before doing anything with it.
  const record = await db.wallet.findById(req.params.walletId);
  if (!record) return respond(404, { error: 'Not found' });
  if (record.userId !== userId) {
    // Same generic response as "not found": a distinct 403 confirms the record
    // exists and belongs to someone else.
    return respond(404, { error: 'Not found' });
  }

  // 3. Only now act.
  return respond(200, serialize(record));
}
```

### Specifically

- **Reads and writes both.** Ownership checks on `GET` are as important as on `POST` — an IDOR that
  leaks another player's profile is a breach whether or not anything was modified.
- **Enumerable IDs are not access control.** Sequential or guessable IDs are fine *if* ownership is
  checked; UUIDs are not a substitute for checking.
- **Privilege checks server-side.** Admin, moderator, or dev capabilities are decided by a role on
  the server record, never by a client flag. (Compare: `sandboxMode` is now gated by build mode in
  `lib/core/app_flags.dart` precisely because a Hive-stored flag is client-controlled.)
- **No "the app won't send that".** The app is not the only client. `curl` is a client.

### Flutter-side counterpart

The app must never send its uid as an authorization claim. `uid` may accompany a request as *data*
(which record am I asking about) but the server decides whether that access is allowed. See the
`// BACKEND:` markers in `lib/features/auth/providers/auth_provider.dart`.

---

## 3. Database-level lockdown

**Requirement:** access control is enforced **at the database layer**, so that a client-side query
can never bypass application-level authorization. Mandatory regardless of which platform is chosen.

This is the layer that saves you when layer 2 has a bug — and layer 2 will eventually have a bug.

### If Supabase → Row Level Security

RLS **enabled on every table**, with deny-by-default policies. A table without RLS enabled is fully
readable by anyone holding the anon key, which ships inside the app.

```sql
alter table public.profiles enable row level security;

create policy "own profile: read"
  on public.profiles for select
  using (auth.uid() = user_id);

create policy "own profile: write"
  on public.profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);   -- with check stops re-assigning a row to someone else
```

- The `service_role` key bypasses RLS entirely. It is a **server-only** secret and must never reach
  the client (see §1).
- `with check` as well as `using` on every write policy.
- Test each policy from an unauthenticated client and from a *different* authenticated user — not
  just from the owner.

### If Firebase → Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Deny by default; grant narrowly.
    match /{document=**} { allow read, write: if false; }

    match /profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /payments/{paymentId} {
      // Readable by the owner; writable only by the server (Admin SDK bypasses
      // rules). Clients must never create their own payment records.
      allow read: if request.auth != null
                  && request.auth.uid == resource.data.userId;
      allow write: if false;
    }
  }
}
```

- Default-deny at the top, then narrow grants.
- Rules are code: keep them in the repo, review them in PRs, and cover them with the emulator's
  rules-testing suite.
- Never ship `allow read, write: if true`, not even briefly, not even in dev — dev databases leak.

### Both

- Financial and entitlement tables (payments, unlocked levels, balances) are **server-write-only**.
  The client may read its own rows; it may never insert or update them directly.
- Enforce the same ownership rule in the database that §2 enforces in the handler. Two independent
  layers, same answer.

---

## 4. Server-side input validation and sanitization

**Requirement:** every user submission is validated and sanitized **server-side**, on every request,
regardless of what the client already checked.

The app now has a full client-side validation layer in
[lib/core/validators.dart](lib/core/validators.dart) — username charset and length, display-name
charset, password bounds, free-text limits with control-character stripping, ZamCoin and ZMW ranges,
Zambian MSISDN format. **That layer is UX, not security.** It tells an honest player what went
wrong. It stops nothing. The server must re-implement every one of those rules.

Required:

- **Allowlist, don't blocklist.** Define what a field may contain and reject everything else.
  Blocklists of "dangerous characters" are always incomplete.
- **Type, length, and range on every field.** An unbounded string is a denial-of-service vector; an
  unbounded number is an overflow.
- **Parameterised queries only.** Never build SQL by string concatenation — no exceptions for
  "internal" queries or values that "can only come from a dropdown".
- **Output encoding at the point of rendering.** Anything a user authored (display names, business
  names, savings goal names, evening reflections — all currently free text) must be encoded for its
  destination context before rendering. This matters the moment any of it appears in a web
  dashboard, an email, or an admin panel.
- **Validate structure, not just fields.** Reject unknown keys; do not let a client add
  `{"role": "admin"}` or `{"walletBalance": 999999}` to a profile update and have it mass-assigned.
- **Re-validate on every request.** Not once at signup — every time.

Mirror the limits in `validators.dart` so client and server agree on what is acceptable, and treat
the server's copy as the authority.

---

## 5. Hardening

### 5.1 Rate limiting

Required on authentication and every sensitive endpoint:

| Endpoint | Limit |
|---|---|
| Login | 5 attempts per account per 15 min, plus a per-IP cap |
| Registration | 3 per IP per hour |
| Password reset request | 3 per account per hour |
| Payment initiation | 10 per account per hour |
| General API | a sane per-token ceiling |

- Limit **per account and per IP**. Per-IP alone is defeated by a botnet; per-account alone allows
  spraying one password across many accounts.
- Apply **exponential backoff or temporary lockout** after repeated failures, and notify the account
  owner.
- Return `429` with a `Retry-After` header.

The app has a local 5-attempt / 5-minute lockout in `AuthNotifier` (see
`lib/features/auth/providers/auth_provider.dart`). It lives in process memory and is trivially
bypassed by restarting the app. It deters a curious person holding the phone. **It is not
brute-force protection** — that is a server control, and it is required here.

### 5.2 Payment webhook signature verification

Every incoming payment webhook (MTN MoMo, Airtel Money, or any processor) **must** be verified
before it is trusted:

1. **Verify the signature on the raw request body**, using the shared secret from environment
   variables, before parsing. Parse-then-verify is a bug: it means acting on unverified structure.
2. **Reject unsigned or mis-signed requests** with a `400`. Do not log-and-continue.
3. **Use a constant-time comparison** for the signature (the same reason `_constantTimeEquals` exists
   in `lib/core/password_hasher.dart`).
4. **Idempotency:** store the provider's event ID and ignore duplicates. Webhooks retry, and a
   replayed "payment succeeded" must not unlock a level twice or credit a wallet twice.
5. **Never trust the amount, currency, or user in the payload alone** — reconcile against the
   payment record your server created when the transaction was initiated.
6. **Never grant entitlement from a client callback.** The app returning from a payment flow is a
   hint to refresh, never proof of payment. Only the verified webhook (or a server-side status
   query) grants access.

```ts
app.post('/webhooks/momo', rawBody(), async (req, res) => {
  const signature = req.headers['x-provider-signature'];
  const expected = hmacSha256(process.env.MOMO_WEBHOOK_SECRET, req.rawBody);
  if (!signature || !timingSafeEqual(signature, expected)) {
    logger.warn('rejected webhook: bad signature', { ip: req.ip });
    return res.status(400).json({ error: 'Invalid request' });
  }
  const event = JSON.parse(req.rawBody);
  if (await alreadyProcessed(event.id)) return res.status(200).end();  // idempotent
  await processPayment(event);
  await markProcessed(event.id);
  res.status(200).end();
});
```

### 5.3 Generic error messages

**Requirement:** clients receive generic, non-revealing errors. Full detail is logged server-side
only.

- **Never return** stack traces, file paths, SQL text, query fragments, ORM errors, library
  versions, or internal hostnames. Disable framework debug pages in production.
- **Identical responses for "no such account" and "wrong password"** — distinct messages let an
  attacker enumerate registered accounts. (Already applied client-side: login now returns a single
  `'Incorrect username or password.'`)
- **Identical responses for "not found" and "not yours"** — see the §2 pattern.
- **Log the full detail server-side** with a correlation ID, and return that ID to the client so a
  support conversation can find the real error without exposing it.

```ts
catch (err) {
  const correlationId = randomUUID();
  logger.error({ correlationId, err });            // everything, server-side
  return respond(500, {
    error: 'Something went wrong. Please try again.',
    correlationId,                                  // safe to show
  });
}
```

The Flutter side already follows this: `AuthNotifier` no longer interpolates `e.toString()` into
user-facing errors; detail goes to a `kDebugMode`-guarded `debugPrint`.

---

## 6. Migration checklist — what changes in this app

Each item has a matching `// BACKEND:` comment in the code.

| Area | Today (offline) | Required with a backend |
|---|---|---|
| **Credential check** | `verifyPassword()` against a local PBKDF2 hash in the `users` box — `auth_provider.dart` | Server verifies; client stores only a short-lived token |
| **Password storage** | PBKDF2-HMAC-SHA256, per-user salt, on-device | Server-side hash (Argon2id or bcrypt); the device stores no hash at all |
| **Session** | In-memory Riverpod state, nothing persisted; `kSessionBox` cleared at launch | Refresh token in `flutter_secure_storage`; server can revoke; sign-out revokes server-side |
| **Account uniqueness** | Local `containsKey` — two devices can both hold "chanda" | Database unique constraint |
| **Level entitlement** | `UserProfile.unlockedLevels` on-device — `level_provider.dart` | Server owns the entitlement; client asks, never decides |
| **Payments** | Simulated, `sandboxMode: true`, record written locally — `payment_provider.dart` | Real provider + signature-verified webhook; local record becomes a cache |
| **Leaderboard** | 9 fictional players seeded locally — `leaderboard_screen.dart` | Server-owned and server-sorted; client never submits its own rank |
| **Input validation** | `lib/core/validators.dart` on-device | Same rules re-implemented server-side; client copy is UX only |
| **Rate limiting** | In-memory 5-attempt lockout in `AuthNotifier` | Per-account and per-IP limits at the API |
| **Data at rest** | AES-256 Hive boxes, key in platform keystore — `secure_hive.dart` | Encrypted at rest server-side; device cache stays encrypted |
| **Transport** | No network traffic today | TLS only; `usesCleartextTraffic="false"`; consider certificate pinning for payment calls |

### Before the first backend release

- [ ] Every route verifies the session token and re-checks record ownership (§2)
- [ ] RLS / Firebase Rules enabled and deny-by-default on **every** table (§3)
- [ ] Policies tested as: owner, a different authenticated user, and unauthenticated (§3)
- [ ] All `validators.dart` rules re-implemented server-side (§4)
- [ ] Rate limits live on login, registration, password reset, and payment (§5.1)
- [ ] Webhook signature verification with idempotency keys (§5.2)
- [ ] Debug pages off; no stack trace or query text reaches a client (§5.3)
- [ ] No secret in the client bundle — re-run the §1 scan against the release APK, not just the source
- [ ] TLS enforced; `android:usesCleartextTraffic="false"` set in the manifest
- [ ] Penetration test of the auth and payment flows before real money moves

---

## Related work not covered here

Release hardening from [SECURITY_AUDIT.md](SECURITY_AUDIT.md) that remains open and blocks a Play
Store submission independently of the backend:

- `android:allowBackup="false"` and `dataExtractionRules` (VUL-006) — the Hive files are now
  ciphertext and the key is not backed up, so an `adb backup` yields nothing useful, but there is no
  reason to hand the files over
- A real release signing key — the release build is currently signed with the shared debug keystore
  (VUL-007)
- R8/ProGuard minification plus `--obfuscate --split-debug-info` (VUL-008)
- `applicationId` and `namespace` off the placeholder `com.example.zamwealth_quest` (VUL-015,
  VUL-025) — Google Play rejects `com.example.*`
