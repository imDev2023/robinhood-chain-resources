> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# My Account Settings for Blockscout Personalization

> Configure Blockscout My Account with Ueberauth, Auth0, Sendgrid, and Airtable to enable user login, watchlist alerts, and public tag requests.

[My Account](/using-blockscout/my-account) is now available for chains that would like to incorporate personalization into their explorer. You will need to configure several 3rd party accounts to fully interact with the My Account feature. These include:

* [Ueberauth](https://hexdocs.pm/ueberauth/readme.html): User authentication & login
* [Sendgrid](https://sendgrid.com/): Watchlist notifications
* [Airtable](https://www.airtable.com/): Public Tag requests via API

Once these are set up, [update your Blockscout instance](/setup/deployment/manual-old-ui) and add the [My Account ENV variables](/setup/env-variables#account-related-env-variables). Below are examples from the [Gnosis Chain instance](https://gnosis.blockscout.com/) with some private info redacted.

```txt theme={null}
ACCOUNT_ENABLED=true
ACCOUNT_AUTH0_DOMAIN=login.blockscout.com
ACCOUNT_AUTH0_CLIENT_ID=...
ACCOUNT_AUTH0_CLIENT_SECRET=...
ACCOUNT_SENDGRID_API_KEY=...
ACCOUNT_SENDGRID_SENDER=noreply@blockscout.com
ACCOUNT_SENDGRID_TEMPLATE=d-...
ACCOUNT_PUBLIC_TAGS_AIRTABLE_URL=https://api.airtable.com/v0/.../Public%20Tags
ACCOUNT_PUBLIC_TAGS_AIRTABLE_API_KEY=key...
ACCOUNT_CLOAK_KEY=...
ACCOUNT_REDIS_URL=redis://redis_db:6379
ACCOUNT_DATABASE_URL=postgresql://user:pass@host:port/db
```

## Airtable Schema

Add `request_type` and `request_id` variables to the airtable when configuring for your My Account settings.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/392c1207-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=9f5f6d151ab09bb2560cf1e4f07f743c" width="565" height="561" data-path="images/392c1207-image.jpeg" />
</Frame>

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/2af5a6c8-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=a63fe59786e708ac799a46323e79ae9a" width="617" height="370" data-path="images/2af5a6c8-image.jpeg" />
</Frame>

## List of required variables

The following variables are needed for your airtable.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/77b246a5-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=e1632246b7bce91ee86167d776100728" width="2304" height="784" data-path="images/77b246a5-image.jpeg" />
</Frame>
