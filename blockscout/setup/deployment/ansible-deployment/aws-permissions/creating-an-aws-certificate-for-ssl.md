> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Creating An AWS Certificate For SSL

> Request and validate a public AWS ACM certificate for SSL on Blockscout, then set the ARN in terraform.tfvars via alb_certificate_arn.

<Warning>
  If you **do not want to use SSL**, you can disable by adding the `use_ssl = "false"` parameter to the `terraform.tfvars` file.
</Warning>

### To create:

1\) Go to [https://console.aws.amazon.com/acm/](https://console.aws.amazon.com/acm/). Select provision certificates and click on get started:

<Frame caption="Get Started">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/ac321ad7-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=3d3ff529165ffbbbcc012628b2280d70" width="2304" height="1378" data-path="images/ac321ad7-image.jpeg" />
</Frame>

2\) Request a Public Certificate.

<Frame caption="Request a certificate">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/d6d001c1-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=a2b127a0e8ea1a70b708cce52b29efef" width="2304" height="1378" data-path="images/d6d001c1-image.jpeg" />
</Frame>

3\) Add a domain you have access to and click **Next**.

<Info>
  This does not need to be the same domain for deployment - as long as it's a valid ARN on your account it will pass verification.
</Info>

<Frame caption="Add your Domain name">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/02c37a26-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=0577b3cd5d33146307f6344daf18144f" width="2304" height="1378" data-path="images/02c37a26-image.jpeg" />
</Frame>

4\) Choose your validation method (your preference) and click **Review**.

<Frame caption="Choose either method and click Review">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/0eae8e36-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=c29f3ae79c5cb1db2577f3f29c01142a" width="2304" height="1378" data-path="images/0eae8e36-image.jpeg" />
</Frame>

5\) Review your information and click **Confirm and request.**

<Frame caption="Click Confirm and request">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/c851895e-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=aae43fd798830a42fb818b0316f72c55" width="2304" height="1436" data-path="images/c851895e-image.jpeg" />
</Frame>

6\) Click **Continue** to begin validation.

<Frame caption="Continue to Validate your certificate">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/3fd60fe0-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=96779814d2b994c7dad2322ec9972cfd" width="2304" height="1378" data-path="images/3fd60fe0-image.jpeg" />
</Frame>

7\) Confirm the Domain:

* **DNS Validation:** Create a CNAME record in the DNS configuration for each of the domains listed below.
* **Email Validation:** Receive email and follow link

<Frame caption="Email Validation">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/30d7048f-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=702ef560e8028d2edcfd1bae7ce0a383" width="1208" height="1278" data-path="images/30d7048f-image.jpeg" />
</Frame>

8\) Approve the Certificate

<Frame caption="Click I Approve to complete the process">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/2d49bb16-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=8c2b92a00f1f1c98c1700e0388004d01" width="2304" height="1436" data-path="images/2d49bb16-image.jpeg" />
</Frame>

9\) In the AWS Certificate Manager, click on the domain name to view the certificate details. **Copy and paste your ARN** into the `alb_certificate_arn` field in the `terraform.tfvars` file

<Frame caption="Copy and Paste the full ARN into the alb_certificate_arn field in terraform.tfvars">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/e5b02517-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=5e6aa912f5eaf4cf68a6288a5f36681a" width="2304" height="1436" data-path="images/e5b02517-image.jpeg" />
</Frame>
