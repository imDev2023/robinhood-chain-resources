> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Metadata Service

> Blockscout Metadata service turns raw addresses into human-readable name tags, protocols, categories, risk flags, and ecosystem labels.

Turn raw addresses into meaningful, human-readable information

* human-readable labels
* compliance signals
* protocol grouping
* enriched analytics

<Check>
  Rather than

  `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`

  You get:

  * **name tag:** USD Coin
  * **protocol:** Circle
  * **category:** stablecoin
  * **risk flags** (if any)
  * **ecosystem tags** (CEX, DeFi, grants, etc.)
</Check>

## Handles

| Handle                                                                   | Why                                                            |
| ------------------------------------------------------------------------ | -------------------------------------------------------------- |
| `GET https://api.blockscout.com/metadata/api/v1/tags`                    | Get all available tag types (OFAC, CEX, protocol, hacks, etc.) |
| `GET https://api.blockscout.com/metadata/api/v1/addresses/{address}`     | Get all metadata for a specific address                        |
| `GET https://api.blockscout.com/metadata/api/v1/addresses?addresses=...` | Batch enrich multiple addresses                                |
| `GET https://api.blockscout.com/metadata/api/v1/search?q=...`            | Search metadata (protocols, entities, labels)                  |

## Examples

### Wallet / explorer UX (name tags)

```shellscript theme={null}
curl "https://api.blockscout.com/metadata/api/v1/addresses/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48?apikey=YOUR_KEY"
```

### Compliance (OFAC / sanctions)

```shellscript theme={null}
curl "https://api.blockscout.com/metadata/api/v1/search?q=ofac&apikey=YOUR_KEY"
```

### Exchange detection (CEX)

```shellscript theme={null}
curl "https://api.blockscout.com/metadata/api/v1/search?q=binance&apikey=YOUR_KEY"
```

### Hack / exploit detection

```shellscript theme={null}
curl "https://api.blockscout.com/metadata/api/v1/addresses/0x...&apikey=YOUR_KEY"
```

### Protocol discovery

```shellscript theme={null}
curl "https://api.blockscout.com/metadata/api/v1/search?q=uniswap&apikey=YOUR_KEY"
```

## TypeScript example

```ts theme={null}
const API_KEY = process.env.API_KEY!;
const ADDRESSES = [
  "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
];

async function getJson(url: string) {
  const res = await fetch(url);
  return res.json();
}

async function main() {
  const url =
    `https://api.blockscout.com/metadata/api/v1/addresses?` +
    `addresses=${ADDRESSES.join(",")}&apikey=${API_KEY}`;

  const data = await getJson(url);

  for (const item of data.items ?? []) {
    console.log(item.address);
    console.log("name:", item.name);
    console.log("tags:", item.tags?.map((t: any) => t.name).join(", "));
    console.log("");
  }
}

main();
```

***
