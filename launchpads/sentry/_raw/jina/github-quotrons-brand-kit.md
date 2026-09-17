Title: GitHub - mavrkofficial/quotrons-brand-kit: Quotrons Brand Kit

URL Source: https://github.com/mavrkofficial/quotrons-brand-kit

Markdown Content:
Fine quotation machinery, in every size you'll ever need.

The official brand assets for [Quotrons](https://quotrons.cash/) — 4444 machines, every price ever asked, on Robinhood Chain. The whole kit follows the house style: 8-bit voxel machines on old-brochure paper. Crisp pixels, never mushy ones.

The mark is the **Quotron 800** terminal (cream shell, green CRT, salmon keys). The wordmark is QUOTRONS in the house pixel lettering. Everything here is derived from the original brochure art, so colors and pixels match everywhere.

```
01-logo/          the terminal mark — transparent, circle, square
02-wordmark/      QUOTRONS lettering, lockups
03-icons/         favicons + app icons, every platform slot
04-banners/       X header, square, DEX and OpenSea sets
05-cards/         rounded paper cards
06-announcements/ ready-to-post announcement art
07-pwa/           in-app brochure and hero banners
08-animated/      typing banner + boot-up logo GIFs
```

## 01 — Logo

[](https://github.com/mavrkofficial/quotrons-brand-kit#01--logo)
| Folder | What it is | Use it for |
| --- | --- | --- |
| `primary-transparent/` | The terminal alone, transparent | Default. Anywhere you control the background |
| `circle-paper/` | Terminal on a paper disc, transparent corners | Avatars, token icons, round crops |
| `square-paper/` | Terminal on full-bleed paper | DEX and wallet listings, tiles |

Sizes: 4096 (primary only), 2048, 1024, 512, 256, 128, 64.

`quotrons-logo.svg` is a true pixel-rect vector (3,199 rects on a 174x163 grid, `shape-rendering: crispEdges`). It scales to any size with hard pixel edges — use it wherever vectors are accepted. The PNGs are built so the pixels stay square at every size: nearest-neighbor above the master resolution, area-downsampled below it.

## 02 — Wordmark

[](https://github.com/mavrkofficial/quotrons-brand-kit#02--wordmark)
| Folder | What it is |
| --- | --- |
| `transparent/` | Ink lettering, transparent. `-white-` variants for dark surfaces |
| `on-paper/` | Same, on brochure paper |
| `lockup/` | Terminal + wordmark side by side, transparent |

Widths: 3000, 2000, 1200, 600 (transparent); lockups at heights 1200, 600, 300.

The lettering sits on an exact 16px grid, so the SVG and every PNG reproduce it pixel-perfectly. `quotrons-wordmark.svg` is the ink version; `quotrons-wordmark-monochrome.svg` inherits `currentColor` from your page — drop it inline and it takes your text color.

## 03 — Icons

[](https://github.com/mavrkofficial/quotrons-brand-kit#03--icons)
No drawn frame, no card border. Platforms apply their own masks; the art stays clean.

| File | Use it for |
| --- | --- |
| `favicon.ico` | Browser favicon, 16-256 in one file, terminal on transparent |
| `icon-16/32/48/64.png` | Individual browser-tab sizes, transparent |
| `icon-180.png` | Apple touch icon — full-bleed paper (iOS blackens transparency; never ship it transparent) |
| `icon-192.png`, `icon-512.png` | PWA / Android "any" icons, full-bleed paper, mark at 80% |
| `icon-maskable-512/1024.png` | PWA / Android `purpose: maskable` — mark at 62%, inside the safe zone |
| `icon-circle-1024.png` | Round desktop and community slots, transparent corners |

These are the same files quotrons.cash ships.

## 04 — Banners

[](https://github.com/mavrkofficial/quotrons-brand-kit#04--banners)
| File | Slot |
| --- | --- |
| `quotrons-banner-1500x500.png` | X / Twitter header |
| `quotrons-banner-3000x1000.png` | 2x master of the same |
| `quotrons-banner-600x200.png` | Small horizontal slots |
| `quotrons-banner-1500x1500.png` | Square 1:1 slots |
| `dexscreener/`, `dextools/` | DEX listing banners |
| `opensea/` | OpenSea logo, banners (desktop + mobile), background |

Composed from the real brochure elements: paper, double ink rule, wordmark, orange headline, the machine lineup (adding machine, desk unit, Quotron 800, NASDANK), halftone dots, orange footer.

## 05 — Cards

[](https://github.com/mavrkofficial/quotrons-brand-kit#05--cards)
Rounded rectangles (25px radius at 1x, doubled at 2x so they match when scaled), paper background with a thin ink inset rule, transparent outside the corners.

| File | Size |
| --- | --- |
| `quotrons-logo-card-1024/2048.png` | square |
| `quotrons-wordmark-card-1600x800 / 3200x1600.png` | 2:1 |

## 06 — Announcements & 07 — PWA

[](https://github.com/mavrkofficial/quotrons-brand-kit#06--announcements--07--pwa)
Ready-to-post announcement art, and the in-app brochure/hero banners used on quotrons.cash — kept here so the kit is the one folder you grab and send.

## 08 — Animated

[](https://github.com/mavrkofficial/quotrons-brand-kit#08--animated)
| File | What it does |
| --- | --- |
| `quotrons-banner-typing-1500x500.gif` | The X banner, animated: the hero CRT boots (dark tube → angled `start` → live screen), then QUOTRONS types itself out with a blinking `_` cursor, holds 5s, loops. ~3.7 MB |
| `quotrons-logo-square-boot-1024/512/100.gif` | The square logo booting: dark tube → `start` in green terminal type, angled to the screen's tilt → the live screen, glowing. Loops like a reboot. 100 fits the OpenSea logo slot |

## 09 — Machines

[](https://github.com/mavrkofficial/quotrons-brand-kit#09--machines)
Solo pixel-rect SVGs of the rest of the lineup, built the same way as the primary logo — every pixel a rectangle, `crispEdges`, infinite scale:

| File | Machine |
| --- | --- |
| `quotron-i-keypad.svg` | Quotron I Keypad (the adding machine) |
| `quotron-ii-desk-unit.svg` | Quotron II Desk Unit |
| `nasdank-terminal.svg` | NASDANK Terminal (the rival machine) |

## Colour

[](https://github.com/mavrkofficial/quotrons-brand-kit#colour)
Sampled from the artwork itself, not guessed:

| Swatch | Hex | Where |
| --- | --- | --- |
| Paper | `#F1EADA` | brochure ground, icon tiles |
| Ink | `#3A2A1C` | wordmark, rules, frames |
| Cream light | `#E5DDB8` | terminal shell, lit face |
| Cream shade | `#B4B181` | terminal shell, shadow face |
| CRT green | `#43E858` | the screen |
| Bezel ink | `#27282A` | screen bezel |
| Key salmon | `#FBB7B1` | keyboard |
| Accent red | `#DD0104` | the one red key |
| Brochure orange | `#CE5810` | headlines, footer bar |
| NASDANK teal | `#2EBCAE` | the rival machine |

## Usage

[](https://github.com/mavrkofficial/quotrons-brand-kit#usage)
Use these files as they are, anywhere you're talking about Quotrons — listings, articles, community art, embeds. Please don't use them to impersonate the project or imply endorsement.

*   Don't put the mark back in a bordered square. Cards get frames; icons don't.
*   Don't smooth-scale the pixels. Upscale nearest-neighbor, or use the SVGs.
*   Don't recolor the CRT. The screen glows green; that's the whole product.
*   Don't set the ink wordmark on dark ground — use the `-white-` variants.
*   Don't redraw, stretch, or rotate the machines.

[quotrons.cash](https://quotrons.cash/)

Links/Buttons:
- [Skip to content](https://github.com/mavrkofficial/quotrons-brand-kit#start-of-content)
- [](https://github.com/claude)
- [Sign in](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fmavrkofficial%2Fquotrons-brand-kit)
- [GitHub CopilotWrite better code with AI](https://github.com/features/copilot)
- [GitHub Copilot appDirect agents from issue to merge](https://github.com/features/ai/github-app)
- [MCP RegistryIntegrate external tools](https://github.com/mcp)
- [ActionsAutomate any workflow](https://github.com/features/actions)
- [CodespacesInstant dev environments](https://github.com/features/codespaces)
- [IssuesPlan and track work](https://github.com/features/issues)
- [Code ReviewManage code changes](https://github.com/features/code-review)
- [Code QualityEnforce quality at merge](https://github.com/features/code-quality)
- [GitHub Advanced SecurityFind and fix vulnerabilities](https://github.com/security/advanced-security)
- [Code securitySecure your code as you build](https://github.com/security/advanced-security/code-security)
- [Secret protectionStop leaks before they start](https://github.com/security/advanced-security/secret-protection)
- [Why GitHub](https://github.com/why-github)
- [Documentation](https://docs.github.com/)
- [Blog](https://github.blog/)
- [Changelog](https://github.blog/changelog)
- [Marketplace](https://github.com/marketplace)
- [View all features](https://github.com/features)
- [Enterprises](https://github.com/enterprise)
- [Small and medium teams](https://github.com/team)
- [Startups](https://github.com/enterprise/startups)
- [Nonprofits](https://github.com/solutions/industry/nonprofits)
- [App Modernization](https://github.com/solutions/use-case/app-modernization)
- [DevSecOps](https://github.com/solutions/use-case/devsecops)
- [DevOps](https://github.com/resources/articles?topic=devops)
- [CI/CD](https://github.com/solutions/use-case/ci-cd)
- [View all use cases](https://github.com/solutions/use-case)
- [Healthcare](https://github.com/solutions/industry/healthcare)
- [Financial services](https://github.com/solutions/industry/financial-services)
- [Manufacturing](https://github.com/solutions/industry/manufacturing)
- [Government](https://github.com/solutions/industry/government)
- [View all industries](https://github.com/solutions/industry)
- [View all solutions](https://github.com/solutions)
- [AI](https://github.com/resources/articles?topic=ai)
- [Software Development](https://github.com/resources/articles?topic=software-development)
- [Security](https://github.com/security)
- [View all topics](https://github.com/resources/articles)
- [Customer stories](https://github.com/customer-stories)
- [Events & webinars](https://github.com/resources/events)
- [Ebooks & reports](https://github.com/resources/whitepapers)
- [Business insights](https://github.com/solutions/executive-insights)
- [GitHub Skills](https://skills.github.com/)
- [Customer support](https://support.github.com/)
- [Community forum](https://github.com/orgs/community/discussions)
- [Trust center](https://github.com/trust-center)
- [Partners](https://github.com/partners)
- [View all resources](https://github.com/resources)
- [GitHub SponsorsFund open source developers](https://github.com/open-source/sponsors)
- [Security Lab](https://securitylab.github.com/)
- [Maintainer Community](https://maintainers.github.com/)
- [GitHub Stars](https://stars.github.com/)
- [Archive Program](https://archiveprogram.github.com/)
- [Topics](https://github.com/topics)
- [Trending](https://github.com/trending)
- [Collections](https://github.com/collections)
- [Copilot for BusinessEnterprise-grade AI features](https://github.com/features/copilot/copilot-business)
- [Premium SupportEnterprise-grade 24/7 support](https://github.com/enterprise/premium-support)
- [Pricing](https://github.com/pricing)
- [Sign up](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo&source_repo=mavrkofficial%2Fquotrons-brand-kit)
- [mavrkofficial](https://github.com/mavrkofficial/quotrons-brand-kit/commits?author=mavrkofficial)
- [quotrons-brand-kit](https://github.com/mavrkofficial/quotrons-brand-kit)
- [Notifications](https://github.com/login?return_to=%2Fmavrkofficial%2Fquotrons-brand-kit)
- [Issues 0](https://github.com/mavrkofficial/quotrons-brand-kit/issues)
- [Pull requests 0](https://github.com/mavrkofficial/quotrons-brand-kit/pulls)
- [Actions](https://github.com/mavrkofficial/quotrons-brand-kit/actions)
- [Projects](https://github.com/mavrkofficial/quotrons-brand-kit/projects)
- [Security and quality 0](https://github.com/mavrkofficial/quotrons-brand-kit/security)
- [Insights](https://github.com/mavrkofficial/quotrons-brand-kit/pulse)
- [1 Branch](https://github.com/mavrkofficial/quotrons-brand-kit/branches)
- [0 Tags](https://github.com/mavrkofficial/quotrons-brand-kit/tags)
- [claude](https://github.com/mavrkofficial/quotrons-brand-kit/commits?author=claude)
- [Add 09-machines: solo pixel-rect SVGs for Keypad, Desk Unit, NASDANK](https://github.com/mavrkofficial/quotrons-brand-kit/commit/bf34cf76fbe0574b4c3f7b485aae1eb5e0194794)
- [2 Commits](https://github.com/mavrkofficial/quotrons-brand-kit/commits/main/)
- [01-logo](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/01-logo)
- [QUOTRONS brand kit: logos, wordmark, icons, banners, cards, animated](https://github.com/mavrkofficial/quotrons-brand-kit/commit/88a689cf9aeed2e3972b9a87ee98d230642b981e)
- [02-wordmark](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/02-wordmark)
- [03-icons](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/03-icons)
- [04-banners](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/04-banners)
- [05-cards](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/05-cards)
- [06-announcements](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/06-announcements)
- [07-pwa](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/07-pwa)
- [08-animated](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/08-animated)
- [09-machines](https://github.com/mavrkofficial/quotrons-brand-kit/tree/main/09-machines)
- [README.md](https://github.com/mavrkofficial/quotrons-brand-kit/blob/main/README.md)
- [README](https://github.com/mavrkofficial/quotrons-brand-kit#)
- [Quotrons](https://quotrons.cash/)
- [Readme](https://github.com/mavrkofficial/quotrons-brand-kit#readme-ov-file)
- [Activity](https://github.com/mavrkofficial/quotrons-brand-kit/activity)
- [1 fork](https://github.com/mavrkofficial/quotrons-brand-kit/forks)
- [Report repository](https://github.com/contact/report-content?content_url=https%3A%2F%2Fgithub.com%2Fmavrkofficial%2Fquotrons-brand-kit&report=mavrkofficial+%28user%29)
- [Releases](https://github.com/mavrkofficial/quotrons-brand-kit/releases)
- [Contributors](https://github.com/mavrkofficial/quotrons-brand-kit/graphs/contributors)
- [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
- [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
- [Status](https://www.githubstatus.com/)
- [Community](https://github.community/)
- [Contact](https://support.github.com/?tags=dotcom-footer)
