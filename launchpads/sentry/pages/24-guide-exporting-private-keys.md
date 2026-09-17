# Sentry - Guide, Exporting Private Keys

> Source: https://www.sentry.trading/desktop/guide#exporting-keys
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Exporting Private Keys[](https://www.sentry.trading/desktop/guide#exporting-keys "Copy link to this section")

Move any wallet — generated or imported — to your own custody. The export shows the plaintext private key one time, after you re-confirm your password.

1.   Open `Settings`>`Export EVM Key`. The export modal shows which wallet you're about to reveal — label, address, source (generated vs imported).
2.   Re-enter your account password. The backend re-runs `bcrypt.compare` against your stored hash before it decrypts and returns anything.
3.   On success, the key is shown in a one-shot reveal panel. Tap the eye icon to toggle visibility, the copy icon to put it on the clipboard, or the “Done — close and forget” button to wipe it from React state.
