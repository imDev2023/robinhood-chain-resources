# Flap - Discord and Farcaster

> Source: https://discord.gg/flapdotsh and https://warpcast.com/flap
> Retrieved: 2026-09-02 (Jina Reader and Bright Data, both empty)

---

Both official community links published in the docs return an empty body through Jina Reader and through Bright Data's unlocker.

- `https://discord.gg/flapdotsh` returns a page whose only text is the word `Flap` (`_raw/socials/jina-discord_gg_flapdotsh.md`, `_raw/socials/bdata-discord-flapdotsh.md`).
The invite is a client-side redirect that a text extractor cannot follow, so the member count could not be captured.
CertiK Skynet links the same community as `https://discord.com/invite/Flap`.
- `https://warpcast.com/flap` returns only the word `Farcaster` (`_raw/socials/jina-warpcast_com_flap.md`, `_raw/socials/bdata-warpcast-flap.md`).
Warpcast has since been renamed to Farcaster and the `warpcast.com` profile route no longer server-renders.

Neither gap affects any number in `README.md`.
