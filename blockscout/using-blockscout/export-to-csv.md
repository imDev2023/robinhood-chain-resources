> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# CSV Exports

> Download address-level transactions, internal transactions, token transfers, and logs from a Blockscout explorer as CSV files for analysis.

Export to CSV gives users a way to easily download and analyze blockchain data. It is available for tabs on the address page including transactions, internal transactions, tokens, and logs.

<Info>
  Note: simplified CSV exports (transactions and transfers only, with no ability to define time periods) exist in Blockscout releases up to 3.5.1. Enhanced CSV export is available from v3.5.2+
</Info>

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/31170481-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=8d5e56148e6e1c503c521f05b0c8d52c" width="1008" height="220" data-path="images/31170481-image.jpeg" />
</Frame>

You will find the *Download CSV* button under the list of entities related to the tab.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/96f561dc-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=bcb9a9bfb7686283e1c0c0481807307e" width="522" height="282" data-path="images/96f561dc-image.jpeg" />
</Frame>

<Info>
  *Note:* under the *Tokens* tab, the list of token transfers will be exported.
</Info>

After clicking the button you will be forwarded to a */csv-export* page for a given address and given type of export (transactions, internal-transactions, token-transfers, logs).

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/1a7283db-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=9cd419f2039272ffc0a6d2ca1a1c33f2" width="1422" height="756" data-path="images/1a7283db-image.jpeg" />
</Frame>

It is possible to specify an arbitrary period for the data export. By default, the current period is the previous month. After completing the reCaptcha, the data for the chosen period should be exported.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/214e0caa-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=97fcfbe088329b3fa278189e7c1bf070" width="1360" height="608" data-path="images/214e0caa-image.jpeg" />
</Frame>

<Info>
  *Tip*: In order to prevent hitting a 30 secs loading timeout, choose the smallest time period possible for your data needs.
</Info>
