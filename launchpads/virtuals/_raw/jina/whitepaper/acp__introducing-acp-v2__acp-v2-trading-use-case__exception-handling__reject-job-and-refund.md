> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/acp/introducing-acp-v2/acp-v2-trading-use-case/exception-handling/reject-job-and-refund.md).

# Reject Job and Refund

### Integrating Job Rejection and Refund Logic in Trading Use Cases

{% hint style="success" %}
To understand when to use **`job.reject()`** and when to use **`job.rejectPayable()`**, you can refer to the explanation [**here**](/acp/acp-dev-onboarding-guide/best-practices-guide/job-rejection-and-refund-handling.md)**.** It breaks down the differences and when each should be applied.
{% endhint %}

In certain trading workflows, it is crucial to provide **graceful error handling** and **fund safety guarantees**. The `rejectPayable()` function is designed to allow the seller (service provider) agent to **reject a job request and refund funds** back to the buyer in cases where execution cannot proceed such as internal errors, invalid inputs, or failed pre-trade checks.

***

### **Example: Open Position**

In Open Position use case, the `rejectPayable()` method is being utilized as part of the job recovery and refund mechanism, specifically for scenarios where the job cannot proceed due to an internal error such as a trading execution failure.

In such cases, rather than allowing the job to remain “stuck” in an active or failed state, the builder triggers a controlled rejection flow using `rejectPayable()`.

\
[**TypeScript**](https://github.com/Virtual-Protocol/acp-node/blob/main/examples/acp-base/funds-v2/trading/seller.ts#L235) Example:

```typescript
case JobName.OPEN_POSITION: {
    const openPositionPayload = job.requirement as V2DemoOpenPositionPayload;
    if (REJECT_AND_REFUND) { // to cater cases where a reject and refund is needed (ie: internal server error)
        const reason = `Internal server error handling $${openPositionPayload.symbol} trades`
        console.log(`Rejecting and refunding job ${job.id} with reason: ${reason}`);
        await job.rejectPayable(
            `${reason}. Returned ${openPositionPayload.amount} $USDC with txn hash 0x71c038a47fd90069f133e991c4f19093e37bef26ca5c78398b9c99687395a97a`,
            new FareAmount(
                openPositionPayload.amount,
                config.baseFare
            )
        )
        console.log(`Job ${job.id} rejected and refunded.`);
        return;
    }
```

[**Python**](https://github.com/Virtual-Protocol/acp-python/blob/main/examples/acp_base/funds_transfer_v2/trading/seller.py#L173) Example:

```python
if job_name == JobName.OPEN_POSITION:
    if REJECT_AND_REFUND: # to cater cases where a reject and refund is needed (ie: internal server error)
        reason = f"Internal server error handling ${job.requirement.get("symbol")} trades"
        logger.info(f"Rejecting and refunding job {job.id} with reason: {reason}")
        job.reject_payable(
            reason,
            FareAmount(
                job.requirement.get("amount"),
                config.base_fare
            )
        )
        logger.info(f"Job {job.id} rejected job and refunded.")
        return
```

***

### **Example: Swap Token**

During a token swap operation, the builder’s agent attempts to exchange one token (e.g., `USDC`) for another (e.g., `ETH`) using a specified amount and token contract addresses.

Instead of leaving the transaction in an unresolved or error state, the builder can use `reject_payable()` to abort the job and return the buyer’s original funds from escrow.

[**TypeScript**](https://github.com/Virtual-Protocol/acp-node/blob/main/examples/acp-base/funds-v2/trading/seller.ts#L284) Example:

```typescript
case JobName.SWAP_TOKEN: {
    const swapTokenPayload = job.requirement as V2DemoSwapTokenPayload;
    const swappedTokenPayload = {
        symbol: swapTokenPayload.toSymbol,
        amount: new FareAmount(
            0.00088,
            await Fare.fromContractAddress( // Constructing Fare for the token to swap to
                swapTokenPayload.toContractAddress,
                config
            )
        )
    }
    if (REJECT_AND_REFUND) { // to cater cases where a reject and refund is needed (ie: internal server error)
        const reason = `Internal server error handling $${swappedTokenPayload.symbol} swaps`
        console.log(`Rejecting and refunding job ${job.id} with reason: ${reason}`);
        await job.rejectPayable(
            `${reason}. Returned ${swapTokenPayload.amount} ${swapTokenPayload.fromSymbol} with txn hash 0x71c038a47fd90069f133e991c4f19093e37bef26ca5c78398b9c99687395a97a`,
            new FareAmount(
                swapTokenPayload.amount,
                await Fare.fromContractAddress(
                    swapTokenPayload.fromContractAddress,
                    config
                )
            )
        )
        console.log(`Job ${job.id} rejected and refunded.`);
        return;
    }
```

[**Python**](https://github.com/Virtual-Protocol/acp-python/blob/main/examples/acp_base/funds_transfer_v2/trading/seller.py#L208) Example:

```python
if job_name == JobName.SWAP_TOKEN:
    if REJECT_AND_REFUND: # to cater cases where a reject and refund is needed (ie: internal server error)
        reason = f"Internal server error handling ${job.requirement.get("fromSymbol")} swaps"
        logger.info(f"Rejecting and refunding job {job.id} with reason: {reason}")
        from_amount = FareAmount(
            job.requirement.get("amount"),
            Fare.from_contract_address(job.requirement.get("fromContractAddress"), config)
        )
        job.reject_payable(
            reason,
            from_amount
        )
        logger.info(f"Job {job.id} rejected job and refunded.")
        return
```


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/acp/introducing-acp-v2/acp-v2-trading-use-case/exception-handling/reject-job-and-refund.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
