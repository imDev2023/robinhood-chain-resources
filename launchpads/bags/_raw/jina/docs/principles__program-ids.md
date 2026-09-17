> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Program IDs

> Solana programs used by Bags and where to find their IDLs

This page lists the Solana programs actively used by Bags and shows where to find their Interface Definition Language (IDL) files.

<Note>
  All program IDs below refer to mainnet-beta deployments unless otherwise noted.
</Note>

## Active Programs

| Program           | Purpose                                                         | Program ID                                     |
| ----------------- | --------------------------------------------------------------- | ---------------------------------------------- |
| Bags Fee Share V1 | Custom fee splits and fee claiming (legacy)                     | `FEEhPbKVKnco9EXnaY3i4R5rQVUx91wgVfu8qokixywi` |
| Bags Fee Share V2 | Fee share configuration and claiming (current)                  | `FEE2tBhCKAt7shrod19QttSVREUYPiyMzoku1mL1gqVK` |
| Meteora DAMM v2   | Post-migration tokens (AMM/pool after bonding curve graduation) | `cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG`  |
| Meteora DBC       | Token creation and bonding curve management                     | `dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN`  |

## Program Overviews

### Bags Fee Share V1 (Legacy)

* **Purpose**: Legacy fee share program for custom fee splits and fee claiming.
* **Program ID**: `FEEhPbKVKnco9EXnaY3i4R5rQVUx91wgVfu8qokixywi`
* **Status**: Still supported for backward compatibility with existing positions

### Bags Fee Share V2 (Current)

* **Purpose**: Current fee share program for configuring fee splits and claiming fees. Used by Token Launch v2.
* **Program ID**: `FEE2tBhCKAt7shrod19QttSVREUYPiyMzoku1mL1gqVK`
* **Features**: Supports multiple fee claimers, partner configurations, and lookup tables for large configurations

### Meteora DAMM v2

* **Purpose**: AMM used by tokens after migrating from bonding curves; supports SPL and Token-2022 flows.
* **Program ID**: `cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG`
* **More info**: See the Meteora developer docs.

### Meteora DBC

* **Purpose**: Token creation and bonding curve lifecycle management prior to AMM migration.
* **Program ID**: `dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN`
* **More info**: See the Meteora developer docs.

## IDLs

* **All actively used IDLs (including Meteora and Bags)** are available in the Bags SDK repository:
  * `bags-sdk` IDLs: `https://github.com/bagsfm/bags-sdk/tree/main/src/idl`

<Tip>
  You can consume these IDLs directly in your build tooling or download them for offline use when generating clients.
</Tip>

## Address Lookup Table

* To save on transaction size when interacting with Bags programs and instructions, you can use our public Address Lookup Table (LUT).
* **LUT address**: `Eq1EVs15EAWww1YtPTtWPzJRLPJoS6VYP9oW9SbNr3yp`
* It includes the most commonly used accounts and will be extended over time.

## References

* Meteora Developer Guide: `https://docs.meteora.ag/developer-guide/home`
* Bags SDK IDLs: `https://github.com/bagsfm/bags-sdk/tree/main/src/idl`

## Verification Checklist

* **Network**: Ensure you are on mainnet-beta when interacting with the above program IDs.
