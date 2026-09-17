# Sentry - Route map: what each path actually serves

> Source: https://www.sentry.trading/desktop/*
> Retrieved: 2026-09-02 (Jina Reader and agent-browser)
> Raw capture: `_raw/jina/sentry-desktop-*.md, _raw/ab/read-desktop-*.txt`

---

The app has fewer real routes than its paths suggest. Confirmed on 2026-09-02, logged out and then logged in:

| path | logged out | logged in |
| --- | --- | --- |
| `/` and `/desktop/tokens` | Discover list | Discover list |
| `/desktop/social` | feed, posting gated | feed with the account header |
| `/desktop/create` | redirects to `/desktop/tokens` | the launch form |
| `/desktop/portfolio` | shell with placeholders | full portfolio |
| `/desktop/tools` | shell | creator tools, allowlisted per account |
| `/desktop/guide` | full guide | full guide |
| `/desktop/leaderboard` | redirects to `/desktop/tokens` | redirects to `/desktop/tokens` |
| `/desktop/referrals` | redirects to `/desktop/tokens` | redirects to `/desktop/tokens`; the panel lives inside the Settings modal |
| `/desktop/settings` | redirects to `/desktop/tokens` | redirects to `/desktop/tokens`; Settings is the header gear, a modal |
| `/desktop/launch` | redirects to `/desktop/tokens` | not a route |
| `/swap`, `/lock` | standalone guest surfaces | same |

A headless fetch of a redirecting route returns whatever Discover had rendered by the time the reader gave up, which is why several of the captures below are copies of the token list rather than the page their URL names.

## /desktop/tokens

Capture size 1360 bytes.

0 Sentry markets · Robinhood 1h / 6h / 24h · Volume · Txns · Holders

| # | Token |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
| No Robinhood tokens found. Deploy one from the Create page! |

![Image 1: ETH](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/ethereum-eth-logo-colored%20(1).svg)ETH...

[Guide](https://www.sentry.trading/desktop/guide)·[Disclaimers](https://www.sentry.trading/desktop/guide#disclaimers)·[Terms](https://www.sentry.trading/desktop/guide#tos)·[Privacy](https://www.sentry.trading/desktop/guide#privacy)

Sentry is a product of Mavrk, Inc.

Links/Buttons:
- [Skip to tokens list](https://www.sentry.trading/desktop/tokens#tokens-list)
- [Discover](https://www.sentry.trading/desktop/tokens)
- [Social](https://www.sentry.trading/desktop/social)
- [Profile](https://www.sentry.trading/desktop/portfolio)
- [Tools](https://www.sentry.trading/desktop/tools)
- [](mailto:team@sentry.trading)
- [Guide](https://www.sentry.trading/desktop/guide)
- [Disclaimers](https://www.sentry.trading/desktop/guide#disclaimers)
- [Terms](https://www.sentry.trading/desktop/guide#tos)
- [Privacy](https://www.sentry.trading/desktop/guide#privacy)

## /desktop/create

Capture size 7797 bytes.

183 Sentry markets · Robinhood 1h / 6h / 24h · Volume · Txns · Holders

| # | Token |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ![Image 1: Quotrons](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/opensea-logo-240.png) ![Image 2: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) QUOTRON Quotrons 18d [](https://robinhoodchain.blockscout.com/address/0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F "Robinhood Explorer")[](https://quotrons.cash/ "Website")[](https://twitter.com/x.com/quotrons404 "Twitter") | — | $11.8M | $443.9K | $1.1M | 941 559/382 |
| 2 | ![Image 3: Netflix and Chill](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/chill-logo-gif.gif) ![Image 4: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) CHILL/NFLX Netflix and Chill 1mo [](https://robinhoodchain.blockscout.com/address/0xF699AEA8a333202A7Dc610aBc664c213c9dc4111 "Robinhood Explorer")[](https://nflxandchill.com/ "Website")[](https://x.com/nflxnchill "Twitter")[](https://t.me/chillportaltg "Telegram") |  | $74.4K | $16.8K | $47.2K | 235 123/112 |
| 3 | ![Image 5: Robin](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/ROBIN.png) ![Image 6: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) ROBIN Robin 2mo [](https://robinhoodchain.blockscout.com/address/0xF051ea98319b066eB493e191a0E37e24De514f14 "Robinhood Explorer")[](https://robinrhc.xyz/ "Website")[](https://x.com/RobinOnRHC "Twitter")[](https://t.me/RobinOnRHC "Telegram") |  | $51.2K | $14.7K | $37.9K | 302 168/134 |
| 4 | ![Image 7: Sentry](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/new-sentry-logo-512x512.gif) ![Image 8: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SENTRY Sentry 1mo [](https://robinhoodchain.blockscout.com/address/0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7 "Robinhood Explorer")[](https://sentry.trading/ "Website")[](https://x.com/sentrylauncher "Twitter")[](https://t.me/sentrylauncher "Telegram") | — | $4.1M | $109.0K | $32.0K | 47 25/22 |
| 5 | ![Image 9: RobinWifHat](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/logo-4-lol.png) ![Image 10: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) WIF RobinWifHat 2mo [](https://robinhoodchain.blockscout.com/address/0xE49A1C3033EcC6b804bc423021D3F71F1A3e0F9B "Robinhood Explorer")[](https://robinwifhat.com/ "Website")[](https://x.com/RobinWifHat "Twitter")[](https://t.me/robinwifhat "Telegram") |  | $3.4M | $131.9K | $11.7K | 75 33/42 |
| 6 | ![Image 11: Baby Sentry](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/98191e73-4613-4943-9bdd-3bd46089ebd2-logo.png) ![Image 12: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BSENTRY Baby Sentry 4d [](https://robinhoodchain.blockscout.com/address/0xEf3a80C82C1A5f12c3e16e79eAE47c364e4fe669 "Robinhood Explorer")[](https://x.com/bsentrylauncher?s=11 "Twitter") |  | $11.5K | $6.3K | $5.9K | 60 31/29 |
| 7 | ![Image 13: Sardines](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/7ea776b2-494b-49ae-86f8-377e26ff17a9-logo.png) ![Image 14: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SARD Sardines 7d [](https://robinhoodchain.blockscout.com/address/0xFAFF8708913483B5E61738Aa12f48703696c6744 "Robinhood Explorer")[](https://wearesardines.com/ "Website")[](https://x.com/sardonrobinhood "Twitter")[](https://t.me/sardonrobinhood "Telegram") |  | $40.9K | $13.1K | $5.4K | 35 23/12 |
| 8 | ![Image 15: Big Chungus](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/96ac8610-902a-4691-abc3-b58f470fd480-logo.png) ![Image 16: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BIGCHUNG Big Chungus 12d [](https://robinhoodchain.blockscout.com/address/0x01ed38Ba18A6e9EA04A23442852B5B0d800BfF2f "Robinhood Explorer") |  | $1.5K | $1.5K | $4.5K | 105 61/44 |
| 9 | ![Image 17: BOINK](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/9c342b99-c625-4ce2-9399-ebb763d60e2f-logo.png) ![Image 18: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BOINK BOINK 1mo [](https://robinhoodchain.blockscout.com/address/0x1172247d932f2c298E4D4777633F6B2265c1De18 "Robinhood Explorer")[](https://www.boink.club/ "Website")[](https://x.com/boinknfts "Twitter")[](https://t.me/boinkonrh "Telegram") |  | $10.9K | $6.3K | $2.7K | 37 20/17 |
| 10 | ![Image 19: RHC6900](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/rhc6900.jpg) ![Image 20: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) 6900 RHC6900 1mo [](https://robinhoodchain.blockscout.com/address/0xb76cDb47A0A13DE3229A051E8B1B52169BBaaeE4 "Robinhood Explorer")[](https://rhc6900.com/ "Website")[](https://x.com/spxonrhc "Twitter")[](https://t.me/telegram.me/spxonrhc "Telegram") |  | $31.1K | $11.3K | $1.7K | 29 18/11 |
| 11 | ![Image 21: Mira](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/ee9a942b-6d5c-4115-8cfb-d16b19bd9ad6-logo.png) ![Image 22: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) MIRA Mira 14d [](https://robinhoodchain.blockscout.com/address/0xf91EABEAcc55CA64F8C5Bf47e3AAb476A7868d64 "Robinhood Explorer") |  | $3.4K | $2.9K | $433 | 8 4/4 |
| 12 | ![Image 23: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) STEST Sentry Test 2mo [](https://robinhoodchain.blockscout.com/address/0xED350516129853FC58B9FfFc5d7C28460c4A7e95 "Robinhood Explorer") | — | $1.4K | $1.4K | $2 | 1 0/1 |
| 13 | ![Image 24: Hood Of Meme](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/5af177e1-69ef-4d77-91a0-4716f8439b43-logo.png) ![Image 25: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) HOME Hood Of Meme 1d [](https://robinhoodchain.blockscout.com/address/0x9b4434278976cCF6150A0Ff113AcC96d594CaBAC "Robinhood Explorer") | — | $1.4K | — | — | — |
| 14 | ![Image 26: Silver Inu](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/937dc0f5-69ba-4ad6-b775-4680fcd70847-logo.png) ![Image 27: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SILVER INU/SLV Silver Inu 3d [](https://robinhoodchain.blockscout.com/address/0xf668B7002810313fD676862a8EC57F0975038692 "Robinhood Explorer") | — | — | — | — | — |
| 15 | ![Image 28: Silver Inu](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/9be397bc-1cf8-4f83-b2e0-2b37194b556a-logo.png) ![Image 29: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SILVER INU/SLV Silver Inu 3d [](https://robinhoodchain.blockscout.com/address/0x54a39956A2eA5669049Af0fa54eB6C1ffEB4845a "Robinhood Explorer") | — | — | — | — | — |

Showing **1–15** of **183** tokens

![Image 30: kBTC](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/kBTC.png)kBTC$77,523.00

Sentry is a product of Mavrk, Inc.

Links/Buttons:
- [Skip to tokens list](https://www.sentry.trading/desktop/tokens#tokens-list)
- [Discover](https://www.sentry.trading/desktop/tokens)
- [Social](https://www.sentry.trading/desktop/social)
- [](mailto:team@sentry.trading)
- [Guide](https://www.sentry.trading/desktop/guide)
- [Disclaimers](https://www.sentry.trading/desktop/guide#disclaimers)
- [Terms](https://www.sentry.trading/desktop/guide#tos)
- [Privacy](https://www.sentry.trading/desktop/guide#privacy)

## /desktop/launch

Capture size 7797 bytes.

183 Sentry markets · Robinhood 1h / 6h / 24h · Volume · Txns · Holders

| # | Token |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ![Image 1: Quotrons](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/opensea-logo-240.png) ![Image 2: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) QUOTRON Quotrons 18d [](https://robinhoodchain.blockscout.com/address/0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F "Robinhood Explorer")[](https://quotrons.cash/ "Website")[](https://twitter.com/x.com/quotrons404 "Twitter") | — | $11.8M | $443.9K | $1.1M | 941 559/382 |
| 2 | ![Image 3: Netflix and Chill](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/chill-logo-gif.gif) ![Image 4: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) CHILL/NFLX Netflix and Chill 1mo [](https://robinhoodchain.blockscout.com/address/0xF699AEA8a333202A7Dc610aBc664c213c9dc4111 "Robinhood Explorer")[](https://nflxandchill.com/ "Website")[](https://x.com/nflxnchill "Twitter")[](https://t.me/chillportaltg "Telegram") |  | $74.4K | $16.8K | $47.2K | 235 123/112 |
| 3 | ![Image 5: Robin](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/ROBIN.png) ![Image 6: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) ROBIN Robin 2mo [](https://robinhoodchain.blockscout.com/address/0xF051ea98319b066eB493e191a0E37e24De514f14 "Robinhood Explorer")[](https://robinrhc.xyz/ "Website")[](https://x.com/RobinOnRHC "Twitter")[](https://t.me/RobinOnRHC "Telegram") |  | $51.2K | $14.7K | $37.9K | 302 168/134 |
| 4 | ![Image 7: Sentry](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/new-sentry-logo-512x512.gif) ![Image 8: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SENTRY Sentry 1mo [](https://robinhoodchain.blockscout.com/address/0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7 "Robinhood Explorer")[](https://sentry.trading/ "Website")[](https://x.com/sentrylauncher "Twitter")[](https://t.me/sentrylauncher "Telegram") | — | $4.1M | $109.0K | $32.0K | 47 25/22 |
| 5 | ![Image 9: RobinWifHat](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/logo-4-lol.png) ![Image 10: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) WIF RobinWifHat 2mo [](https://robinhoodchain.blockscout.com/address/0xE49A1C3033EcC6b804bc423021D3F71F1A3e0F9B "Robinhood Explorer")[](https://robinwifhat.com/ "Website")[](https://x.com/RobinWifHat "Twitter")[](https://t.me/robinwifhat "Telegram") |  | $3.4M | $131.9K | $11.7K | 75 33/42 |
| 6 | ![Image 11: Baby Sentry](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/98191e73-4613-4943-9bdd-3bd46089ebd2-logo.png) ![Image 12: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BSENTRY Baby Sentry 4d [](https://robinhoodchain.blockscout.com/address/0xEf3a80C82C1A5f12c3e16e79eAE47c364e4fe669 "Robinhood Explorer")[](https://x.com/bsentrylauncher?s=11 "Twitter") |  | $11.5K | $6.3K | $5.9K | 60 31/29 |
| 7 | ![Image 13: Sardines](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/7ea776b2-494b-49ae-86f8-377e26ff17a9-logo.png) ![Image 14: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SARD Sardines 7d [](https://robinhoodchain.blockscout.com/address/0xFAFF8708913483B5E61738Aa12f48703696c6744 "Robinhood Explorer")[](https://wearesardines.com/ "Website")[](https://x.com/sardonrobinhood "Twitter")[](https://t.me/sardonrobinhood "Telegram") |  | $40.9K | $13.1K | $5.4K | 35 23/12 |
| 8 | ![Image 15: Big Chungus](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/96ac8610-902a-4691-abc3-b58f470fd480-logo.png) ![Image 16: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BIGCHUNG Big Chungus 12d [](https://robinhoodchain.blockscout.com/address/0x01ed38Ba18A6e9EA04A23442852B5B0d800BfF2f "Robinhood Explorer") |  | $1.5K | $1.5K | $4.5K | 105 61/44 |
| 9 | ![Image 17: BOINK](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/9c342b99-c625-4ce2-9399-ebb763d60e2f-logo.png) ![Image 18: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BOINK BOINK 1mo [](https://robinhoodchain.blockscout.com/address/0x1172247d932f2c298E4D4777633F6B2265c1De18 "Robinhood Explorer")[](https://www.boink.club/ "Website")[](https://x.com/boinknfts "Twitter")[](https://t.me/boinkonrh "Telegram") |  | $10.9K | $6.3K | $2.7K | 37 20/17 |
| 10 | ![Image 19: RHC6900](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/rhc6900.jpg) ![Image 20: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) 6900 RHC6900 1mo [](https://robinhoodchain.blockscout.com/address/0xb76cDb47A0A13DE3229A051E8B1B52169BBaaeE4 "Robinhood Explorer")[](https://rhc6900.com/ "Website")[](https://x.com/spxonrhc "Twitter")[](https://t.me/telegram.me/spxonrhc "Telegram") |  | $31.1K | $11.3K | $1.7K | 29 18/11 |
| 11 | ![Image 21: Mira](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/ee9a942b-6d5c-4115-8cfb-d16b19bd9ad6-logo.png) ![Image 22: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) MIRA Mira 14d [](https://robinhoodchain.blockscout.com/address/0xf91EABEAcc55CA64F8C5Bf47e3AAb476A7868d64 "Robinhood Explorer") |  | $3.4K | $2.9K | $433 | 8 4/4 |
| 12 | ![Image 23: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) STEST Sentry Test 2mo [](https://robinhoodchain.blockscout.com/address/0xED350516129853FC58B9FfFc5d7C28460c4A7e95 "Robinhood Explorer") | — | $1.4K | $1.4K | $2 | 1 0/1 |
| 13 | ![Image 24: Hood Of Meme](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/5af177e1-69ef-4d77-91a0-4716f8439b43-logo.png) ![Image 25: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) HOME Hood Of Meme 1d [](https://robinhoodchain.blockscout.com/address/0x9b4434278976cCF6150A0Ff113AcC96d594CaBAC "Robinhood Explorer") | — | $1.4K | — | — | — |
| 14 | ![Image 26: Silver Inu](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/937dc0f5-69ba-4ad6-b775-4680fcd70847-logo.png) ![Image 27: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SILVER INU/SLV Silver Inu 3d [](https://robinhoodchain.blockscout.com/address/0xf668B7002810313fD676862a8EC57F0975038692 "Robinhood Explorer") | — | — | — | — | — |
| 15 | ![Image 28: Silver Inu](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/9be397bc-1cf8-4f83-b2e0-2b37194b556a-logo.png) ![Image 29: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SILVER INU/SLV Silver Inu 3d [](https://robinhoodchain.blockscout.com/address/0x54a39956A2eA5669049Af0fa54eB6C1ffEB4845a "Robinhood Explorer") | — | — | — | — | — |

Showing **1–15** of **183** tokens

![Image 30: kBTC](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/kBTC.png)kBTC$77,523.00

Sentry is a product of Mavrk, Inc.

Links/Buttons:
- [Skip to tokens list](https://www.sentry.trading/desktop/tokens#tokens-list)
- [Discover](https://www.sentry.trading/desktop/tokens)
- [Social](https://www.sentry.trading/desktop/social)
- [](mailto:team@sentry.trading)
- [Guide](https://www.sentry.trading/desktop/guide)
- [Disclaimers](https://www.sentry.trading/desktop/guide#disclaimers)
- [Terms](https://www.sentry.trading/desktop/guide#tos)
- [Privacy](https://www.sentry.trading/desktop/guide#privacy)

## /desktop/leaderboard

Capture size 7762 bytes.

183 Sentry markets · Robinhood 1h / 6h / 24h · Volume · Txns · Holders

| # | Token |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ![Image 1: Quotrons](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/opensea-logo-240.png) ![Image 2: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) QUOTRON Quotrons 18d [](https://robinhoodchain.blockscout.com/address/0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F "Robinhood Explorer")[](https://quotrons.cash/ "Website")[](https://twitter.com/x.com/quotrons404 "Twitter") | — | $11.8M | $443.9K | $1.1M | 941 559/382 |
| 2 | ![Image 3: Netflix and Chill](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/chill-logo-gif.gif) ![Image 4: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) CHILL/NFLX Netflix and Chill 1mo [](https://robinhoodchain.blockscout.com/address/0xF699AEA8a333202A7Dc610aBc664c213c9dc4111 "Robinhood Explorer")[](https://nflxandchill.com/ "Website")[](https://x.com/nflxnchill "Twitter")[](https://t.me/chillportaltg "Telegram") |  | $74.4K | $16.8K | $47.2K | 235 123/112 |
| 3 | ![Image 5: Robin](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/ROBIN.png) ![Image 6: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) ROBIN Robin 2mo [](https://robinhoodchain.blockscout.com/address/0xF051ea98319b066eB493e191a0E37e24De514f14 "Robinhood Explorer")[](https://robinrhc.xyz/ "Website")[](https://x.com/RobinOnRHC "Twitter")[](https://t.me/RobinOnRHC "Telegram") |  | $51.2K | $14.7K | $37.9K | 302 168/134 |
| 4 | ![Image 7: Sentry](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/new-sentry-logo-512x512.gif) ![Image 8: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SENTRY Sentry 1mo [](https://robinhoodchain.blockscout.com/address/0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7 "Robinhood Explorer")[](https://sentry.trading/ "Website")[](https://x.com/sentrylauncher "Twitter")[](https://t.me/sentrylauncher "Telegram") | — | $4.1M | $109.0K | $32.0K | 47 25/22 |
| 5 | ![Image 9: RobinWifHat](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/logo-4-lol.png) ![Image 10: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) WIF RobinWifHat 2mo [](https://robinhoodchain.blockscout.com/address/0xE49A1C3033EcC6b804bc423021D3F71F1A3e0F9B "Robinhood Explorer")[](https://robinwifhat.com/ "Website")[](https://x.com/RobinWifHat "Twitter")[](https://t.me/robinwifhat "Telegram") |  | $3.4M | $131.9K | $11.7K | 75 33/42 |
| 6 | ![Image 11: Baby Sentry](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/98191e73-4613-4943-9bdd-3bd46089ebd2-logo.png) ![Image 12: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BSENTRY Baby Sentry 4d [](https://robinhoodchain.blockscout.com/address/0xEf3a80C82C1A5f12c3e16e79eAE47c364e4fe669 "Robinhood Explorer")[](https://x.com/bsentrylauncher?s=11 "Twitter") |  | $11.5K | $6.3K | $5.9K | 60 31/29 |
| 7 | ![Image 13: Sardines](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/7ea776b2-494b-49ae-86f8-377e26ff17a9-logo.png) ![Image 14: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SARD Sardines 7d [](https://robinhoodchain.blockscout.com/address/0xFAFF8708913483B5E61738Aa12f48703696c6744 "Robinhood Explorer")[](https://wearesardines.com/ "Website")[](https://x.com/sardonrobinhood "Twitter")[](https://t.me/sardonrobinhood "Telegram") |  | $40.9K | $13.1K | $5.4K | 35 23/12 |
| 8 | ![Image 15: Big Chungus](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/96ac8610-902a-4691-abc3-b58f470fd480-logo.png) ![Image 16: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BIGCHUNG Big Chungus 12d [](https://robinhoodchain.blockscout.com/address/0x01ed38Ba18A6e9EA04A23442852B5B0d800BfF2f "Robinhood Explorer") |  | $1.5K | $1.5K | $4.5K | 105 61/44 |
| 9 | ![Image 17: BOINK](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/9c342b99-c625-4ce2-9399-ebb763d60e2f-logo.png) ![Image 18: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) BOINK BOINK 1mo [](https://robinhoodchain.blockscout.com/address/0x1172247d932f2c298E4D4777633F6B2265c1De18 "Robinhood Explorer")[](https://www.boink.club/ "Website")[](https://x.com/boinknfts "Twitter")[](https://t.me/boinkonrh "Telegram") |  | $10.9K | $6.3K | $2.7K | 37 20/17 |
| 10 | ![Image 19: RHC6900](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/web-images/Aa_RHC-logo-updates/rhc6900.jpg) ![Image 20: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) 6900 RHC6900 1mo [](https://robinhoodchain.blockscout.com/address/0xb76cDb47A0A13DE3229A051E8B1B52169BBaaeE4 "Robinhood Explorer")[](https://rhc6900.com/ "Website")[](https://x.com/spxonrhc "Twitter")[](https://t.me/telegram.me/spxonrhc "Telegram") |  | $31.1K | $11.3K | $1.7K | 29 18/11 |
| 11 | ![Image 21: Mira](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/ee9a942b-6d5c-4115-8cfb-d16b19bd9ad6-logo.png) ![Image 22: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) MIRA Mira 14d [](https://robinhoodchain.blockscout.com/address/0xf91EABEAcc55CA64F8C5Bf47e3AAb476A7868d64 "Robinhood Explorer") |  | $3.4K | $2.9K | $433 | 8 4/4 |
| 12 | ![Image 23: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) STEST Sentry Test 2mo [](https://robinhoodchain.blockscout.com/address/0xED350516129853FC58B9FfFc5d7C28460c4A7e95 "Robinhood Explorer") | — | $1.4K | $1.4K | $2 | 1 0/1 |
| 13 | ![Image 24: Hood Of Meme](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/5af177e1-69ef-4d77-91a0-4716f8439b43-logo.png) ![Image 25: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) HOME Hood Of Meme 1d [](https://robinhoodchain.blockscout.com/address/0x9b4434278976cCF6150A0Ff113AcC96d594CaBAC "Robinhood Explorer") | — | $1.4K | — | — | — |
| 14 | ![Image 26: Silver Inu](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/937dc0f5-69ba-4ad6-b775-4680fcd70847-logo.png) ![Image 27: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SILVER INU/SLV Silver Inu 3d [](https://robinhoodchain.blockscout.com/address/0xf668B7002810313fD676862a8EC57F0975038692 "Robinhood Explorer") | — | — | — | — | — |
| 15 | ![Image 28: Silver Inu](https://esjrycmiokijtxnbfyox.supabase.co/storage/v1/object/public/solana-logos/9be397bc-1cf8-4f83-b2e0-2b37194b556a-logo.png) ![Image 29: Robinhood](https://www.sentry.trading/robinhood-chain-logo.png) SILVER INU/SLV Silver Inu 3d [](https://robinhoodchain.blockscout.com/address/0x54a39956A2eA5669049Af0fa54eB6C1ffEB4845a "Robinhood Explorer") | — | — | — | — | — |

Showing **1–15** of **183** tokens

![Image 30: SENTRY](https://www.sentry.trading/icon-any-192.png)SENTRY$0.00409

Sentry is a product of Mavrk, Inc.

Links/Buttons:
- [Skip to tokens list](https://www.sentry.trading/desktop/tokens#tokens-list)
- [Discover](https://www.sentry.trading/desktop/tokens)
- [Social](https://www.sentry.trading/desktop/social)
- [](mailto:team@sentry.trading)
- [Guide](https://www.sentry.trading/desktop/guide)
- [Disclaimers](https://www.sentry.trading/desktop/guide#disclaimers)
- [Terms](https://www.sentry.trading/desktop/guide#tos)
- [Privacy](https://www.sentry.trading/desktop/guide#privacy)

## /desktop/referrals

Capture size 209 bytes.

Links/Buttons:
This page does not seem to contain any buttons/links.

## /desktop/settings

Capture size 208 bytes.

Links/Buttons:
This page does not seem to contain any buttons/links.
