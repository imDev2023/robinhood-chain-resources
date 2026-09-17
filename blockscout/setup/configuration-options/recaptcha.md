> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# reCAPTCHA Setup for Blockscout CSV and Account

> Enable Google reCAPTCHA v2 invisible on Blockscout to block bots on CSV exports and account features using site key and secret key ENV variables.

<Warning>
  Blockscout currently supports **reCAPTCHA v2 in invisible mode.** Previous frontend versions (**v1.36.x)** support v3, but moving forward we will only support v2.
</Warning>

reCAPTCHA from Google is a free service (with certain [usage limits](https://cloud.google.com/recaptcha/quotas)) designed to protect your site from spam and bots. It can be used in Blockscout to prevent bot activity related to CSV downloads and account validation. reCAPTCHA is turned on by default, but can be disabled by setting `RE_CAPTCHA_DISABLED` to true.

### Obtain your keys

1\) To use reCAPTCHA you will need a SITE KEY and SECRET KEY

1. Go to [https://www.google.com/recaptcha/admin/create](https://www.google.com/recaptcha/admin/create), login to Google with an existing account, and fill in the following info:

   a. **Label**: Private label to identify the instance in your reCAPTCHA admin dashboard.

   b. **reCAPTCHA type**: Select Challenge (v2) and Invisible reCAPTCHA badge

   c. **Domains**: Enter your primary Blockscout domain, all associated subdomains will be covered. You can enter multiple domains, and also localhost for testing if needed.

   d. **Submit**

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/7bfba9fb-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=8bd20c389093fdc1a6f88aebc4aa6919" width="1642" height="1062" data-path="images/7bfba9fb-image.jpeg" />
</Frame>

2\) Copy your keys and use them with the following ENV variables to enable reCAPTCHA.

| Backend ENV Variable    | Google reCAPTCHA key |
| ----------------------- | -------------------- |
| `RE_CAPTCHA_SECRET_KEY` | SECRET KEY           |

| Frontend ENV Variable                 | Google reCAPTCHA key |
| ------------------------------------- | -------------------- |
| `NEXT_PUBLIC_RE_CAPTCHA_APP_SITE_KEY` | SITE KEY             |

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/34a27edd-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=7ae0c437cd5d1aef7d634ee81cde10a6" width="1622" height="1068" data-path="images/34a27edd-image.jpeg" />
</Frame>

3\) Add the keys to ENV variables to your .env file or at runtime for the backend and frontend containers.

Backend container:

```javascript theme={null}
$ export RE_CAPTCHA_SECRET_KEY=6Le...Qdo
```

Frontend container:

```javascript theme={null}
$ export NEXT_PUBLIC_RE_CAPTCHA_APP_SITE_KEY=6L...IU
```

<Info>
  Once setup, you can view and update your reCAPTCHA settings on the Google admin dashboard at [https://www.google.com/recaptcha/admin](https://www.google.com/recaptcha/admin)
</Info>

### Additional reCAPTCHA ENV info

* Backend reCAPTCHA ENVs are located in the Backend ENVs: Common page in the [CSV exports section](/setup/env-variables/backend-env-variables#csv-export).
* Frontend reCAPTCHA ENVs are located on the Frontend ENVs: Common -> ENVs page in the [External Services section](/setup/env-variables/frontend-common-envs/envs#external-services-configuration).
* Disable reCAPTCHA by setting `RE_CAPTCHA_DISABLED` to true
* Disable checking reCAPTCHA domain names by setting `RE_CAPTCHA_CHECK_HOSTNAME` to false. This will bypass checking the hostname info added during reCAPTCHA setup in Google. [More info on domains.](https://developers.google.com/recaptcha/docs/domain_validation)
