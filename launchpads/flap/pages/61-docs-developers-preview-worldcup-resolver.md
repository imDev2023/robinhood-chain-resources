# Flap - World Cup Resolver

> Source: https://docs.flap.sh/flap/developers/preview/worldcup-resolver
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/preview/worldcup-resolver.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/preview/worldcup-resolver.md).

# World Cup Resolver

{% hint style="warning" %}
This is an older solution and can still be used. For new integrations, prefer [worldcup-viewer.md](/flap/developers/preview/worldcup-viewer.md).
{% endhint %}

## Overview

`WorldCupResolver` is a read-only smart contract deployed on BSC mainnet that reads **2026 FIFA World Cup** match outcomes from the on-chain oracle system and exposes the results to downstream consumers.

**Deployed address (BSC mainnet):** `0x134C6b9562E226096947e018ddEe4804c9146921`

The contract covers 43 entries: the 32 tournament teams, a selection of additional national teams with odds, and an "Other" catch-all. Each team maps to a unique oracle question: *"Will \[Team] win the 2026 FIFA World Cup?"* The underlying oracle resolves each question as YES or NO on-chain.

{% hint style="info" %}
No result state is stored inside `WorldCupResolver`. Every call to `resolveWinner()` reads the oracle live, so the returned snapshot always reflects the latest state.
{% endhint %}

***

## How It Works

### Oracle questions and team resolution

For every team, there is exactly one oracle question: *"Will this team win the World Cup?"*

| Oracle field       | Meaning                                                       |
| ------------------ | ------------------------------------------------------------- |
| `reportedAt > 0`   | The oracle has published a result for this team               |
| `results == true`  | The result is **YES** - this team won                         |
| `results == false` | The result is **NO** - this team did **not** win (eliminated) |
| `flaggedAt > 0`    | The result is currently under dispute; treat as unresolved    |

A team is confirmed as the **final winner** only when all three conditions hold simultaneously:

1. `reportedAt > 0` - oracle has reported.
2. `results == true` - result is YES.
3. `flaggedAt == 0` - result is **not** flagged/disputed.

### Resolving the final winner

Call `resolveWinner()`. It scans all 43 entries and returns a `WinnerResult` struct:

* `isResolved = true` → a confirmed winning team was found; read `winnerIndex` and `winnerName`.
* `isResolved = false` → no confirmed winner yet; inspect `statuses[]` for per-team progress.

### Resolving a single match (team elimination)

{% hint style="warning" %}
**Limitation - teams grouped under "Other" (index 42):**

`WorldCupResolver` does not run its own oracle. It reads data from an external UMA-based oracle, and the resolution data provided by that oracle only covers 42 individually named teams. All remaining qualified national teams that were not given their own oracle question are grouped into a single `Other` entry (index 42).

As a result, if one of those unlisted teams is eliminated in a match, their elimination **cannot** be detected individually - the `Other` question stays unresolved until one of those teams wins the entire World Cup (at which point `Other` resolves YES). Per-team match resolution is only supported for the 42 named teams.
{% endhint %}

Because every oracle question is about the **overall World Cup winner**, an answer of NO for a team means that team has been **definitively eliminated** - they can never win the tournament.

This makes it possible to infer match outcomes incrementally, well before the final is played:

**Example - Group stage match: Team A vs Team B**

1. Call `resolveWinner()` and read `statuses[]`.
2. Check Team A's status: `isReported = true`, `result = false`, `isFlagged = false` → **Team A is eliminated** (they lost and are out of the tournament).
3. Check Team B's status: `isReported = false` → **Team B is still in contention** (their question has not yet been resolved).

In this scenario Team A's result is fully settled - it can be used to pay out prediction positions - while Team B remains pending until a later match resolves their fate.

{% hint style="warning" %}
Only treat `isReported = true` **and** `isFlagged = false` as a settled result. A flagged result is under oracle dispute and must not be acted upon.
{% endhint %}

***

## Interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @notice Per-team oracle status, returned by read-only query methods.
struct TeamStatus {
    uint8 index;       // 0-based team index (same order as getSupportedTeams())
    string name;       // human-readable team name
    bool isReported;   // true when reportedAt > 0 on the oracle
    bool result;       // true = YES (winner), false = NO or not yet reported
    bool isFlagged;    // true when flaggedAt > 0 - result is disputed
}

/// @notice Return value of resolveWinner().
struct WinnerResult {
    bool isResolved;       // true if a definitive YES answer was found
    uint8 winnerIndex;     // set only when isResolved = true
    string winnerName;     // set only when isResolved = true
    TeamStatus[] statuses; // full per-team snapshot at time of call
}

interface IWorldCupResolver {
    /// @notice Returns the full list of 43 supported team names in index order.
    ///         names[0] = "Spain", names[42] = "Other".
    ///         Safe to call at any time, including while the contract is paused.
    function getSupportedTeams() external view returns (string[] memory names);

    /// @notice Reads the oracle live and computes the World Cup winner.
    ///
    ///         - isResolved = true  → winnerIndex / winnerName identify the champion.
    ///         - isResolved = false → no winner yet; inspect statuses[] for per-team progress.
    ///
    ///         A team counts as winner only when:
    ///           1. reportedAt > 0  (oracle has reported)
    ///           2. results == true (oracle result is YES)
    ///           3. flaggedAt == 0  (result is not disputed)
    function resolveWinner() external view returns (WinnerResult memory result);
}
```

***

## Supported Teams

`getSupportedTeams()` returns 43 entries. The index is stable and matches the `TeamStatus.index` field returned by `resolveWinner()`.

| Index | Team        | Index | Team         |
| ----- | ----------- | ----- | ------------ |
| 0     | Spain       | 22    | Canada       |
| 1     | France      | 23    | Scotland     |
| 2     | England     | 24    | South Korea  |
| 3     | Argentina   | 25    | Paraguay     |
| 4     | Brazil      | 26    | Ivory Coast  |
| 5     | Portugal    | 27    | Egypt        |
| 6     | Germany     | 28    | Iran         |
| 7     | Netherlands | 29    | Ghana        |
| 8     | Norway      | 30    | Algeria      |
| 9     | Italy       | 31    | Tunisia      |
| 10    | Belgium     | 32    | Austria      |
| 11    | USA         | 33    | New Zealand  |
| 12    | Morocco     | 34    | Haiti        |
| 13    | Colombia    | 35    | Jordan       |
| 14    | Japan       | 36    | Curacao      |
| 15    | Uruguay     | 37    | Uzbekistan   |
| 16    | Croatia     | 38    | South Africa |
| 17    | Mexico      | 39    | Cape Verde   |
| 18    | Switzerland | 40    | Qatar        |
| 19    | Ecuador     | 41    | Saudi Arabia |
| 20    | Senegal     | 42    | Other        |
| 21    | Australia   |       |              |

***

## Integration Examples

### Check for the final winner (Solidity)

```solidity
IWorldCupResolver resolver = IWorldCupResolver(0x134C6b9562E226096947e018ddEe4804c9146921);

WinnerResult memory r = resolver.resolveWinner();
if (r.isResolved) {
    // r.winnerName  → e.g. "Brazil"
    // r.winnerIndex → e.g. 4
}
```

### Check whether a specific team has been eliminated (Solidity)

```solidity
WinnerResult memory r = resolver.resolveWinner();

// Example: check if Spain (index 0) is eliminated
TeamStatus memory spain = r.statuses[0];
if (spain.isReported && !spain.result && !spain.isFlagged) {
    // Spain has been definitively eliminated - safe to settle Spain positions
}
```

### Read all statuses off-chain (ethers.js)

```js
const resolver = new ethers.Contract(
    "0x134C6b9562E226096947e018ddEe4804c9146921",
    IWorldCupResolverABI,
    provider
);

const result = await resolver.resolveWinner();

console.log("Is resolved:", result.isResolved);
if (result.isResolved) {
    console.log("Winner:", result.winnerName, "(index", result.winnerIndex, ")");
}

for (const status of result.statuses) {
    if (status.isReported && !status.isFlagged) {
        const outcome = status.result ? "WINNER" : "ELIMINATED";
        console.log(`${status.name}: ${outcome}`);
    } else {
        console.log(`${status.name}: pending`);
    }
}
```

***

## Deployment Details

| Field            | Value                                        |
| ---------------- | -------------------------------------------- |
| Network          | BSC Mainnet                                  |
| Contract address | `0x134C6b9562E226096947e018ddEe4804c9146921` |
