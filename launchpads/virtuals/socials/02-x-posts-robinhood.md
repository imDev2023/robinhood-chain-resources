# Virtuals Protocol - X posts about Robinhood Chain

> Source: https://x.com/virtuals_io/status/2072660137794564521
> Retrieved: 2026-09-02 (Bright Data x_posts pipeline, JSON in _raw/socials/x-posts-robinhood.json)

---


Six post URLs were submitted (the two Robinhood Chain posts linked from the whitepaper, plus four found with `bdata search "virtuals_io Robinhood Chain site:x.com"`, raw in `_raw/socials/search-x-virtuals-robinhood.json`).

The pipeline returned one record; the other five were not returned by Bright Data (no error, no data).

The returned post is an X Article, so its body is not in the JSON, only the metrics.


## https://x.com/virtuals_io/status/2072660137794564521

- user_posted: virtuals_io
- name: Virtuals Protocol
- date_posted: 2026-07-02T12:34:19.000Z
- replies: 47
- reposts: 67
- likes: 534
- views: 177683
- quotes: 39
- bookmarks: 93
- external_url: http://x.com/i/article/2062796916375904257
- followers: 294525
- posts_count: 6300
- biography: Society of AI Agents
- is_verified: True
- verification_type: gold
- context: linked from whitepaper page "Builders Resources for AI Agents" as "Agent tokenization on Robinhood Chain guide" (pages/ file wp-about-virtuals-builders-resources-for-ai-agents), posted 2026-07-02, the day the first Robinhood Chain agent launched.

## Other post URLs submitted (not returned)

- https://x.com/celesteanglm/status/2073189495173001452 (Robinhood Chain use cases with the ACP CLI, linked from the whitepaper)
- https://x.com/virtuals_io/status/2073165193040048451
- https://x.com/virtuals_io/status/2073299312751284569
- https://x.com/virtuals_io/status/2082496431404028383
- https://x.com/virtuals_io/status/2094074417660010638

An earlier attempt to pull the whole timeline with `bdata pipelines x_posts https://x.com/virtuals_io` failed with a validation error because that pipeline only accepts status URLs (`_raw/socials/x-virtuals_io-posts.err`).
