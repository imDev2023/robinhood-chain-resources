> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Multisend

> Use the Blockscout Multisend Essential Dapp to batch-send ERC-20 tokens to many addresses from a CSV list for airdrops and payroll.

Multisend lets you send ERC20 tokens to multiple addresses at once rather than sending transactions one by one. With just a few clicks, you can create and send bulk transactions automatically, saving significant time and automating the process. Private keys and account information stay secure.

Multisend is useful when distributing tokens to many addresses, for example in an airdrop to a lot of recipients or payroll where you are sending many of the same ERC20 tokens to different addresses.

## Get Started

1. **Connect your wallet** to Blockscout (if needed)

<img src="https://mintcdn.com/blockscout/gvfoGxvUZ8kwePUt/images/login-1.jpg?fit=max&auto=format&n=gvfoGxvUZ8kwePUt&q=85&s=b6b16aed1d1c06c8403b0f483edd7ccb" alt="DAppscout blockchain explorer interface showing login button and essential dApps including token swap and multisend features" width="1828" height="1300" data-path="images/login-1.jpg" />

2. **Find the Multisend app** in the Essential Dapps Menu

<img src="https://mintcdn.com/blockscout/1uOrIN3i7xMS2PB5/images/mutlsend-dapp-2.jpg?fit=max&auto=format&n=1uOrIN3i7xMS2PB5&q=85&s=e5c72493a2ad393f32900ffb4d301b12" alt="DAppscout tutorial showing how to access Multisend dApp: step 1 click DApps menu, step 2 select Multisend to send tokens to multiple addresses" width="2010" height="1104" data-path="images/mutlsend-dapp-2.jpg" />

3. Click on the token field and **select the token** you want to send.

<img src="https://mintcdn.com/blockscout/1uOrIN3i7xMS2PB5/images/token-field-1.jpg?fit=max&auto=format&n=1uOrIN3i7xMS2PB5&q=85&s=fa3d4c8d367f13fc5144cfcbb5ae67ea" alt="Multisend dApp tutorial step 1: select token address to send tokens to multiple wallet addresses via CSV upload" width="1948" height="1268" data-path="images/token-field-1.jpg" />

<img src="https://mintcdn.com/blockscout/1uOrIN3i7xMS2PB5/images/token-field-3.jpg?fit=max&auto=format&n=1uOrIN3i7xMS2PB5&q=85&s=a34e08d7a040da6110383eb6df03b931" alt="Token search modal in Multisend dApp showing CV token selection on Optimism network for bulk token transfers" width="1074" height="1326" data-path="images/token-field-3.jpg" />

4. **Specify a list of addresses and amounts in CSV format** (for example `0x5c36bd76a6c138187c43da92f66f37e23b4017fa,12`) with 1 address and amount per line. You can upload a .csv file and the box will auto-populate. *Click the 'Show Sample CSV' button to see the formatted example.*

<Warning>
  .eth names are not currently supported, please use full 0x addresses.
</Warning>

<img src="https://mintcdn.com/blockscout/oi2GyiQE9nfe5-pB/images/address-field-1.jpg?fit=max&auto=format&n=oi2GyiQE9nfe5-pB&q=85&s=b79909242906a55bbb8fd535e4db985e" alt="Multisend dApp CSV upload field for entering multiple recipient wallet addresses to batch send CV tokens" width="1884" height="1270" data-path="images/address-field-1.jpg" />

<img src="https://mintcdn.com/blockscout/oi2GyiQE9nfe5-pB/images/address-2.jpg?fit=max&auto=format&n=oi2GyiQE9nfe5-pB&q=85&s=3324c45636ac6063e305dc378755a1d9" alt="Multisend dApp with CSV recipient list populated showing wallet addresses and token amounts for batch CV token distribution" width="1306" height="1162" data-path="images/address-2.jpg" />

5. **Click Proceed** to go to the next step, Validation.

<img src="https://mintcdn.com/blockscout/1uOrIN3i7xMS2PB5/images/token-and-addresses-populated-4.jpg?fit=max&auto=format&n=1uOrIN3i7xMS2PB5&q=85&s=5115c6b3cc1d94729a79f8c199d4675f" alt="Multisend dApp with recipient CSV populated and arrow pointing to Proceed button to validate batch token transfer" width="2292" height="1348" data-path="images/token-and-addresses-populated-4.jpg" />

6. In the **Validation** step you will see the amount approved (0 at the moment), the total tokens to be sent, the total number of tokens in the wallet, and the total amount of ETH in the wallet. You will also see the list of recipients and allocations for each address.

<img src="https://mintcdn.com/blockscout/1uOrIN3i7xMS2PB5/images/validation-1.jpg?fit=max&auto=format&n=1uOrIN3i7xMS2PB5&q=85&s=f3a9c0bea06e7a007f5fd80e0e776b7f" alt="Multisend validation screen showing transaction summary: 15.4991 CV tokens to be sent to 4 recipients with wallet balances displayed" width="1734" height="1174" data-path="images/validation-1.jpg" />

Scroll down to see the approval options. You can either approve the exact token amount for this multisend (recommended) or click unlimited approval. With unlimited you will not need to approve sending for future transactions *(this grants unlimited privileges to the app, which can be a security risk).*

Click **Approve** and confirm in your wallet.

<img src="https://mintcdn.com/blockscout/GSXNATzbO2vbpPFZ/images/approve-1.jpg?fit=max&auto=format&n=GSXNATzbO2vbpPFZ&q=85&s=aadff8bbc56f14d0e738b807105f7495" alt="Multisend validation showing recipient list with arrow pointing to Approve button to authorize batch token transfer" width="2124" height="1342" data-path="images/approve-1.jpg" />

7. Once you have approved the app to send tokens, you will see the approval transaction in the app. Click **Continue** to go to the third step where you will complete the transaction(s).

<img src="https://mintcdn.com/blockscout/GSXNATzbO2vbpPFZ/images/continue.jpg?fit=max&auto=format&n=GSXNATzbO2vbpPFZ&q=85&s=7669f857636dae60a16d4495b851d0a1" alt="Multisend validation complete with arrow pointing to Continue button after approving 15.4991 CV token batch transfer to 4 recipients" width="1856" height="1378" data-path="images/continue.jpg" />

8. **View the total estimate**. You will see an overview along with the cost estimate. You can change the value of gas price with the gear icon, but this can cause issues and is not generally recommended. If everything looks good, click Proceed and sign the transaction(s) in your wallet. There may be multiple transactions to sign depending on the number of recipients.

<img src="https://mintcdn.com/blockscout/1uOrIN3i7xMS2PB5/images/multisend.jpg?fit=max&auto=format&n=1uOrIN3i7xMS2PB5&q=85&s=ee1afc7e3d10766cf963ddd23de3fdc5" alt="Multisend final step showing transaction summary: 15.4991 CV tokens to 4 recipients with gas cost 0.00134026 ETH and arrow pointing to Proceed button" width="1658" height="1386" data-path="images/multisend.jpg" />

That's it! If you'd like to learn more about Multisender, see the video walkthrough below which goes into more details on the standalone application.

### Multisender video walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/rSJedr32XA4?si=4qyFLJ0F7bmFmfxp" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen />
