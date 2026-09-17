> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/info-hub/important-links-and-resources/virtuals-protocol-contract-addresses.md).

# Virtuals Protocol Contract Addresses

### Official $VIRTUAL Token Contract Addresses

<table><thead><tr><th width="231.5546875">Chain</th><th>$VIRTUAL Token Contract Address</th></tr></thead><tbody><tr><td><strong>Base Chain</strong></td><td><code>0x0b3e328455c4059EEb9e3f84b5543F74E24e7E1b</code></td></tr><tr><td><strong>Ethereum Chain</strong></td><td><code>0x44ff8620b8cA30902395A7bD3F2407e1A091BF73</code></td></tr><tr><td><strong>Robinhood Chain</strong></td><td><code>0xc6911796042b15d7Fa4F6CDe69e245DdCd3d9c31</code></td></tr><tr><td><strong>Solana Chain</strong></td><td><code>3iQL8BFS2vE7mww4ehAqQHAsbmRNCrPxizWAT2Zfyr9y</code></td></tr></tbody></table>

### Virtuals Protocol Core Smart Contract Addresses

| Contract             | Description                            | Address                                      |
| -------------------- | -------------------------------------- | -------------------------------------------- |
| **Creator vault**    | Locks pre-bonding tokens for creators. | `0xdAd686299FB562f89e55DA05F1D96FaBEb2A2E32` |
| **Sell wall wallet** | Disburses tokens for sell orders.      | `0xe2890629EF31b32132003C02B29a50A025dEeE8a` |
| **Sell order**       | Executes sell orders.                  | `0xF8DD39c71A278FE9F4377D009D7627EF140f809e` |

### Virtuals Protocol Launchpad Bonding Curve Contract Addresses

<table><thead><tr><th width="257.515625">Chain</th><th>Bonding Curve Contract Address</th></tr></thead><tbody><tr><td><strong>Base Chain</strong></td><td><code>0x1A540088125d00dD3990f9dA45CA0859af4d3B01</code></td></tr><tr><td><strong>Robinhood Chain</strong></td><td><code>0xd4cCBFA37e2f35611b3042e4096Ad7a3459Bd007</code></td></tr></tbody></table>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/info-hub/important-links-and-resources/virtuals-protocol-contract-addresses.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
