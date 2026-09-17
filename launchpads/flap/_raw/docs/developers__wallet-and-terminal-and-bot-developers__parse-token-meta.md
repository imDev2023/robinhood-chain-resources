> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/parse-token-meta.md).

# Parse Token Meta

Whenever a token is launched, a `TokenCreated` event will be emitted:

```solidity
/// @notice emitted when a new token is created
///
/// @param ts The timestamp of the event
/// @param creator The address of the creator
/// @param nonce The nonce of the token
/// @param token  The address of the token
/// @param name  The name of the token
/// @param symbol  The symbol of the token
/// @param meta The meta URI of the token
event TokenCreated(
  uint256 ts, address creator, uint256 nonce, address token, string name, string symbol, string meta
);
```

The `TokenCreated` event contains the IPFS CID of the token’s metadata, which can be used to retrieve the metadata from IPFS.

Alternatively, you can also get the metadata through the token’s contract by calling the `metaURI` method of the token contract. The `meta` method returns the IPFS CID of the token’s metadata.

```solidity
interface IFlapToken {
    function metaURI() external view returns (string memory);
}
```

Let’s take the JACK token as an example to illustrate how to get the image:

If you call the `metaURI` method of the 0x4122a43daecd13cfb2543ad339470fd87bc11111 [token](https://x.flap.sh/0x4122a43daecd13cfb2543ad339470fd87bc11111), you will get the following cid: `bafkreieepx7lh6zcpqsneo2jdeqmcgxjg7facam34w5ezh4myajjauuc24`.

You can get the meta json from any ipfs gateway. However, it would be fast to use our ipfs gateway. Our gateway is located at <https://flap.mypinata.cloud/> . Such that, you can get the meta json here: `https://flap.mypinata.cloud/ipfs/bafkreieepx7lh6zcpqsneo2jdeqmcgxjg7facam34w5ezh4myajjauuc24`.

The meta json is as follows:

```json
{
    "buy": null,
    "creator": "0x7F403F924dDE32bFd4D4432E3996291aeFCe2f89",
    "description": "OKIE,OKIE",
    "image": "bafkreibwjuzzns6yf4wytfr5nk6vujb4yja4iejff2k76nshn2z5jkmiy4",
    "sell": null,
    "telegram": null,
    "twitter": null,
    "website": null
}
```

Note that the image field is also a cid, which is the cid of the image. Similarly, we can get the image here: `https://flap.mypinata.cloud/ipfs/bafkreibwjuzzns6yf4wytfr5nk6vujb4yja4iejff2k76nshn2z5jkmiy4`.
