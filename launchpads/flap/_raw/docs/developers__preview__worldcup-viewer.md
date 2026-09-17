> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/preview/worldcup-viewer.md).

# World Cup Viewer

## Overview

`WorldCupViewer` is a read-only smart contract deployed on BSC mainnet that provides a clean, high-level view of **2026 FIFA World Cup** match results.

Users and integrators can query `WorldCupViewer` to find out the winner of the entire tournament or the winner of any specific group, without needing to understand the underlying oracle structure.

{% hint style="info" %}
`WorldCupViewer` is a read-only contract. All state — including match results and team names — is either stored in the contract or read live from the oracle. No transactions are required to query match results.
{% endhint %}

***

## Deployed address

| Network     | Address                                      |
| ----------- | -------------------------------------------- |
| BSC mainnet | `0x00036192958C2aaAF9F445d3Cdc2979995EA333e` |

***

## Methods

All query methods return a `MatchViewResult` struct:

```solidity
struct MatchViewResult {
    uint256 matchId;   // the match ID queried
    string matchName;  // human-readable name of the match
    bool isResolved;   // true if the oracle has settled this match
    uint256 teamId;    // ID of the winning team (0 if not yet resolved; 50 = draw/tie; 49 = others)
    string teamName;   // name of the winning team ("" if not yet resolved; "draw" for ties; "others" for unlisted teams)
}
```

{% hint style="info" %}
`teamId` uses two reserved values: `49` (`others`) for any team not individually tracked by the oracle, and `50` (`draw`) when a match ends in a tie.
{% endhint %}

### `getWorldCupWinner()`

```solidity
function getWorldCupWinner() external view returns (MatchViewResult memory);
```

Returns the winner of the 2026 FIFA World Cup (match ID `1`).

* If `isResolved = false`, the tournament winner has not yet been determined.
* If `isResolved = true`, `teamId` and `teamName` identify the champion.

{% hint style="info" %}
If the champion is a team not individually tracked by the oracle (i.e., grouped under "Others"), the contract resolves the winner using the separately configured `othersWinner` field, which is set by the contract owner.
{% endhint %}

***

### `getGroupMatchWinners(uint256 matchId)`

```solidity
function getGroupMatchWinners(uint256 matchId) external view returns (MatchViewResult memory);
```

Returns the winner of a group stage match. Pass the match ID for the group you want to query (e.g., `2` for Group A, `3` for Group B, and so on up to `13` for Group L).

* If `isResolved = false`, the group winner has not yet been determined.
* If `isResolved = true`, `teamId` and `teamName` identify the group winner.

***

### `getMatchResult(uint256 matchId)`

```solidity
function getMatchResult(uint256 matchId) external view returns (MatchViewResult memory);
```

Returns the resolved result for any match ID directly from the underlying oracle mapping.

* If `isResolved = false`, the match is not settled yet and the result remains pending.
* If `isResolved = true`, `teamId` identifies the winning outcome mapped from oracle request IDs.
* For a draw outcome (`teamId = 50`), `teamName` is returned as a tie message in the format `TeamA(teamIdA) and TeamB(teamIdB) are tied`.
* For non-draw outcomes, `teamName` is the mapped team name for that `teamId`.

***

### `getTeamName(uint256 teamId)`

```solidity
function getTeamName(uint256 teamId) external view returns (string memory);
```

Looks up the name for a given `teamId`. The standard query range is `1`-`48` (listed teams). If `teamId = 49`, it represents `"others"`; if `teamId = 50`, it represents `"draw"`. Unknown IDs return an empty string.

***

## Reference data

### Team ID mapping

| teamId | Team                       |
| ------ | -------------------------- |
| 1      | Mexico                     |
| 2      | South Africa               |
| 3      | South Korea                |
| 4      | Czechia                    |
| 5      | Canada                     |
| 6      | Bosnia and Herzegovina     |
| 7      | Qatar                      |
| 8      | Switzerland                |
| 9      | Brazil                     |
| 10     | Morocco                    |
| 11     | Haiti                      |
| 12     | Scotland                   |
| 13     | USA                        |
| 14     | Paraguay                   |
| 15     | Australia                  |
| 16     | Türkiye                    |
| 17     | Germany                    |
| 18     | Curaçao                    |
| 19     | Ivory Coast                |
| 20     | Ecuador                    |
| 21     | Netherlands                |
| 22     | Japan                      |
| 23     | Sweden                     |
| 24     | Tunisia                    |
| 25     | Belgium                    |
| 26     | Egypt                      |
| 27     | Iran                       |
| 28     | New Zealand                |
| 29     | Spain                      |
| 30     | Cape Verde                 |
| 31     | Saudi Arabia               |
| 32     | Uruguay                    |
| 33     | France                     |
| 34     | Senegal                    |
| 35     | Iraq                       |
| 36     | Norway                     |
| 37     | Argentina                  |
| 38     | Algeria                    |
| 39     | Austria                    |
| 40     | Jordan                     |
| 41     | Portugal                   |
| 42     | DR Congo                   |
| 43     | Uzbekistan                 |
| 44     | Colombia                   |
| 45     | England                    |
| 46     | Croatia                    |
| 47     | Ghana                      |
| 48     | Panama                     |
| 49     | Others (any unlisted team) |
| 50     | Draw                       |

***

### Match ID reference

{% hint style="info" %}
More matches will be added to this document as the tournament progresses.
{% endhint %}

#### Chapter 1: winner (Match 1)

#### Match 1 — 2026 FIFA World Cup Winner

{% hint style="warning" %}
Do **not** use `getMatchResult(1)` to determine the 2026 FIFA World Cup champion.\
Instead, always use `getWorldCupWinner()`, which fully resolves the tournament winner even if the oracle data merges several teams under "Others".\
Using `getMatchResult(1)` returns the raw oracle grouping and may not identify the actual team; `getWorldCupWinner()` always provides the true winner team ID and name.
{% endhint %}

Resolves to the team that wins the entire 2026 FIFA World Cup. This match tracks all individually listed teams plus an "Others" catch-all for any team not given their own oracle question.

| teamId | Team         | Oracle question title                                      |
| ------ | ------------ | ---------------------------------------------------------- |
| 29     | Spain        | Will Spain win the 2026 FIFA World Cup?                    |
| 33     | France       | Will France win the 2026 FIFA World Cup?                   |
| 45     | England      | Will England win the 2026 FIFA World Cup?                  |
| 37     | Argentina    | Will Argentina win the 2026 FIFA World Cup?                |
| 9      | Brazil       | Will Brazil win the 2026 FIFA World Cup?                   |
| 41     | Portugal     | Will Portugal win the 2026 FIFA World Cup?                 |
| 17     | Germany      | Will Germany win the 2026 FIFA World Cup?                  |
| 21     | Netherlands  | Will Netherlands win the 2026 FIFA World Cup?              |
| 36     | Norway       | Will Norway win the 2026 FIFA World Cup?                   |
| 25     | Belgium      | Will Belgium win the 2026 FIFA World Cup?                  |
| 13     | USA          | Will USA win the 2026 FIFA World Cup?                      |
| 10     | Morocco      | Will Morocco win the 2026 FIFA World Cup?                  |
| 44     | Colombia     | Will Colombia win the 2026 FIFA World Cup?                 |
| 22     | Japan        | Will Japan win the 2026 FIFA World Cup?                    |
| 32     | Uruguay      | Will Uruguay win the 2026 FIFA World Cup?                  |
| 46     | Croatia      | Will Croatia win the 2026 FIFA World Cup?                  |
| 1      | Mexico       | Will Mexico win the 2026 FIFA World Cup?                   |
| 8      | Switzerland  | Will Switzerland win the 2026 FIFA World Cup?              |
| 20     | Ecuador      | Will Ecuador win the 2026 FIFA World Cup?                  |
| 34     | Senegal      | Will Senegal win the 2026 FIFA World Cup?                  |
| 15     | Australia    | Will Australia win the 2026 FIFA World Cup?                |
| 5      | Canada       | Will Canada win the 2026 FIFA World Cup?                   |
| 12     | Scotland     | Will Scotland win the 2026 FIFA World Cup?                 |
| 3      | South Korea  | Will South Korea win the 2026 FIFA World Cup?              |
| 14     | Paraguay     | Will Paraguay win the 2026 FIFA World Cup?                 |
| 19     | Ivory Coast  | Will Ivory Coast win the 2026 FIFA World Cup?              |
| 26     | Egypt        | Will Egypt win the 2026 FIFA World Cup?                    |
| 27     | Iran         | Will Iran win the 2026 FIFA World Cup?                     |
| 47     | Ghana        | Will Ghana win the 2026 FIFA World Cup?                    |
| 38     | Algeria      | Will Algeria win the 2026 FIFA World Cup?                  |
| 24     | Tunisia      | Will Tunisia win the 2026 FIFA World Cup?                  |
| 39     | Austria      | Will Austria win the 2026 FIFA World Cup?                  |
| 28     | New Zealand  | Will New Zealand win the 2026 FIFA World Cup?              |
| 11     | Haiti        | Will Haiti win the 2026 FIFA World Cup?                    |
| 40     | Jordan       | Will Jordan win the 2026 FIFA World Cup?                   |
| 18     | Curaçao      | Will Curaçao win the 2026 FIFA World Cup?                  |
| 43     | Uzbekistan   | Will Uzbekistan win the 2026 FIFA World Cup?               |
| 2      | South Africa | Will South Africa win the 2026 FIFA World Cup?             |
| 30     | Cape Verde   | Will Cape Verde win the 2026 FIFA World Cup?               |
| 7      | Qatar        | Will Qatar win the 2026 FIFA World Cup?                    |
| 31     | Saudi Arabia | Will Saudi Arabia win the 2026 FIFA World Cup?             |
| —      | Others       | Will none of the listed teams win the 2026 FIFA World Cup? |

***

{% hint style="info" %}
For all group winner matches (Match 2–Match 13), you can use either `getMatchResult(matchId)` or `getGroupMatchWinners(matchId)`. Both will return the same result.
{% endhint %}

#### Chapter 2: group match winners (Match 2-13)

#### Match 2 — Group A Winner

Resolves to the team that wins Group A in the 2026 FIFA World Cup group stage.

| teamId | Team         | Oracle question title                                                                                                      |
| ------ | ------------ | -------------------------------------------------------------------------------------------------------------------------- |
| 1      | Mexico       | Will Mexico win Group A in the 2026 FIFA World Cup?                                                                        |
| 2      | South Africa | Will South Africa win Group A in the 2026 FIFA World Cup?                                                                  |
| 3      | South Korea  | Will South Korea win Group A in the 2026 FIFA World Cup?                                                                   |
| 4      | Czechia      | Will the winner of the Czechia/Denmark/North Macedonia/Republic of Ireland playoff win Group A in the 2026 FIFA World Cup? |

***

#### Match 3 — Group B Winner

Resolves to the team that wins Group B in the 2026 FIFA World Cup group stage.

| teamId | Team                   | Oracle question title                                                                                                 |
| ------ | ---------------------- | --------------------------------------------------------------------------------------------------------------------- |
| 5      | Canada                 | Will Canada win Group B in the 2026 World Cup?                                                                        |
| 6      | Bosnia and Herzegovina | Will the winner of the Bosnia and Herzegovina/Italy/Northern Ireland/Wales playoff win Group B in the 2026 World Cup? |
| 7      | Qatar                  | Will Qatar win Group B in the 2026 World Cup?                                                                         |
| 8      | Switzerland            | Will Switzerland win Group B in the 2026 World Cup?                                                                   |

***

#### Match 4 — Group C Winner

Resolves to the team that wins Group C in the 2026 FIFA World Cup group stage.

| teamId | Team     | Oracle question title                            |
| ------ | -------- | ------------------------------------------------ |
| 9      | Brazil   | Will Brazil win Group C in the 2026 World Cup?   |
| 10     | Morocco  | Will Morocco win Group C in the 2026 World Cup?  |
| 11     | Haiti    | Will Haiti win Group C in the 2026 World Cup?    |
| 12     | Scotland | Will Scotland win Group C in the 2026 World Cup? |

***

#### Match 5 — Group D Winner

Resolves to the team that wins Group D in the 2026 FIFA World Cup group stage.

| teamId | Team      | Oracle question title                                                                             |
| ------ | --------- | ------------------------------------------------------------------------------------------------- |
| 13     | USA       | Will USA win Group D in the 2026 World Cup?                                                       |
| 14     | Paraguay  | Will Paraguay win Group D in the 2026 World Cup?                                                  |
| 15     | Australia | Will Australia win Group D in the 2026 World Cup?                                                 |
| 16     | Türkiye   | Will the winner of the Kosovo/Romania/Slovakia/Türkiye playoff win Group D in the 2026 World Cup? |

***

#### Match 6 — Group E Winner

Resolves to the team that wins Group E in the 2026 FIFA World Cup group stage.

| teamId | Team        | Oracle question title                               |
| ------ | ----------- | --------------------------------------------------- |
| 17     | Germany     | Will Germany win Group E in the 2026 World Cup?     |
| 18     | Curaçao     | Will Curaçao win Group E in the 2026 World Cup?     |
| 19     | Ivory Coast | Will Ivory Coast win Group E in the 2026 World Cup? |
| 20     | Ecuador     | Will Ecuador win Group E in the 2026 World Cup?     |

***

#### Match 7 — Group F Winner

Resolves to the team that wins Group F in the 2026 FIFA World Cup group stage.

| teamId | Team        | Oracle question title                                                                           |
| ------ | ----------- | ----------------------------------------------------------------------------------------------- |
| 21     | Netherlands | Will Netherlands win Group F in the 2026 World Cup?                                             |
| 22     | Japan       | Will Japan win Group F in the 2026 World Cup?                                                   |
| 23     | Sweden      | Will the winner of the Albania/Poland/Sweden/Ukraine playoff win Group F in the 2026 World Cup? |
| 24     | Tunisia     | Will Tunisia win Group F in the 2026 World Cup?                                                 |

***

#### Match 8 — Group G Winner

Resolves to the team that wins Group G in the 2026 FIFA World Cup group stage.

| teamId | Team        | Oracle question title                               |
| ------ | ----------- | --------------------------------------------------- |
| 25     | Belgium     | Will Belgium win Group G in the 2026 World Cup?     |
| 26     | Egypt       | Will Egypt win Group G in the 2026 World Cup?       |
| 27     | Iran        | Will Iran win Group G in the 2026 World Cup?        |
| 28     | New Zealand | Will New Zealand win Group G in the 2026 World Cup? |

***

#### Match 9 — Group H Winner

Resolves to the team that wins Group H in the 2026 FIFA World Cup group stage.

| teamId | Team         | Oracle question title                                |
| ------ | ------------ | ---------------------------------------------------- |
| 29     | Spain        | Will Spain win Group H in the 2026 World Cup?        |
| 30     | Cape Verde   | Will Cape Verde win Group H in the 2026 World Cup?   |
| 31     | Saudi Arabia | Will Saudi Arabia win Group H in the 2026 World Cup? |
| 32     | Uruguay      | Will Uruguay win Group H in the 2026 World Cup?      |

***

#### Match 10 — Group I Winner

Resolves to the team that wins Group I in the 2026 FIFA World Cup group stage.

| teamId | Team    | Oracle question title                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------- |
| 33     | France  | Will France win Group I in the 2026 World Cup?                                          |
| 34     | Senegal | Will Senegal win Group I in the 2026 World Cup?                                         |
| 35     | Iraq    | Will the winner of the Bolivia/Iraq/Suriname playoff win Group I in the 2026 World Cup? |
| 36     | Norway  | Will Norway win Group I in the 2026 World Cup?                                          |

***

#### Match 11 — Group J Winner

Resolves to the team that wins Group J in the 2026 FIFA World Cup group stage.

| teamId | Team      | Oracle question title                             |
| ------ | --------- | ------------------------------------------------- |
| 37     | Argentina | Will Argentina win Group J in the 2026 World Cup? |
| 38     | Algeria   | Will Algeria win Group J in the 2026 World Cup?   |
| 39     | Austria   | Will Austria win Group J in the 2026 World Cup?   |
| 40     | Jordan    | Will Jordan win Group J in the 2026 World Cup?    |

***

#### Match 12 — Group K Winner

Resolves to the team that wins Group K in the 2026 FIFA World Cup group stage.

| teamId | Team       | Oracle question title                                                                                                |
| ------ | ---------- | -------------------------------------------------------------------------------------------------------------------- |
| 41     | Portugal   | Will Portugal win Group K in the 2026 World Cup?                                                                     |
| 42     | DR Congo   | Will the winner of the Democratic Republic of Congo/Jamaica/New Caledonia playoff win Group K in the 2026 World Cup? |
| 43     | Uzbekistan | Will Uzbekistan win Group K in the 2026 World Cup?                                                                   |
| 44     | Colombia   | Will Colombia win Group K in the 2026 World Cup?                                                                     |

***

#### Match 13 — Group L Winner

Resolves to the team that wins Group L in the 2026 FIFA World Cup group stage.

| teamId | Team    | Oracle question title                           |
| ------ | ------- | ----------------------------------------------- |
| 45     | England | Will England win Group L in the 2026 World Cup? |
| 46     | Croatia | Will Croatia win Group L in the 2026 World Cup? |
| 47     | Ghana   | Will Ghana win Group L in the 2026 World Cup?   |
| 48     | Panama  | Will Panama win Group L in the 2026 World Cup?  |

***

#### Chapter 3: group matches (Match 14-85)

#### Match 14 — Mexico vs. South Africa

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team         | Oracle question title                                                                         |
| ------ | ------------ | --------------------------------------------------------------------------------------------- |
| 1      | Mexico       | Will Mexico win on 2026-06-11 in Group A of the 2026 FIFA World Cup group stage?              |
| 50     | draw         | Will Mexico vs. South Africa end in a draw in Group A of the 2026 FIFA World Cup group stage? |
| 2      | South Africa | Will South Africa win on 2026-06-11 in Group A of the 2026 FIFA World Cup group stage?        |

***

#### Match 15 — South Korea vs. Czechia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                            |
| ------ | ----------- | ------------------------------------------------------------------------------------------------ |
| 3      | South Korea | Will Korea Republic win on 2026-06-11 in Group A of the 2026 FIFA World Cup group stage?         |
| 50     | draw        | Will Korea Republic vs. Czechia end in a draw in Group A of the 2026 FIFA World Cup group stage? |
| 4      | Czechia     | Will Czechia win on 2026-06-11 in Group A of the 2026 FIFA World Cup group stage?                |

***

#### Match 16 — Canada vs. Bosnia and Herzegovina

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team                   | Oracle question title                                                                                   |
| ------ | ---------------------- | ------------------------------------------------------------------------------------------------------- |
| 5      | Canada                 | Will Canada win on 2026-06-12 in Group B of the 2026 FIFA World Cup group stage?                        |
| 50     | draw                   | Will Canada vs. Bosnia and Herzegovina end in a draw in Group B of the 2026 FIFA World Cup group stage? |
| 6      | Bosnia and Herzegovina | Will Bosnia and Herzegovina win on 2026-06-12 in Group B of the 2026 FIFA World Cup group stage?        |

***

#### Match 17 — USA vs. Paraguay

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                            |
| ------ | -------- | ------------------------------------------------------------------------------------------------ |
| 13     | USA      | Will United States win on 2026-06-12 in Group D of the 2026 FIFA World Cup group stage?          |
| 50     | draw     | Will United States vs. Paraguay end in a draw in Group D of the 2026 FIFA World Cup group stage? |
| 14     | Paraguay | Will Paraguay win on 2026-06-12 in Group D of the 2026 FIFA World Cup group stage?               |

***

#### Match 18 — Qatar vs. Switzerland

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                       |
| ------ | ----------- | ------------------------------------------------------------------------------------------- |
| 7      | Qatar       | Will Qatar win on 2026-06-13 in Group B of the 2026 FIFA World Cup group stage?             |
| 50     | draw        | Will Qatar vs. Switzerland end in a draw in Group B of the 2026 FIFA World Cup group stage? |
| 8      | Switzerland | Will Switzerland win on 2026-06-13 in Group B of the 2026 FIFA World Cup group stage?       |

***

#### Match 19 — Brazil vs. Morocco

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 9      | Brazil  | Will Brazil win on 2026-06-13 in Group C of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Brazil vs. Morocco end in a draw in Group C of the 2026 FIFA World Cup group stage? |
| 10     | Morocco | Will Morocco win on 2026-06-13 in Group C of the 2026 FIFA World Cup group stage?        |

***

#### Match 20 — Haiti vs. Scotland

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                    |
| ------ | -------- | ---------------------------------------------------------------------------------------- |
| 11     | Haiti    | Will Haiti win on 2026-06-13 in Group C of the 2026 FIFA World Cup group stage?          |
| 50     | draw     | Will Haiti vs. Scotland end in a draw in Group C of the 2026 FIFA World Cup group stage? |
| 12     | Scotland | Will Scotland win on 2026-06-13 in Group C of the 2026 FIFA World Cup group stage?       |

***

#### Match 21 — Australia vs. Türkiye

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team      | Oracle question title                                                                       |
| ------ | --------- | ------------------------------------------------------------------------------------------- |
| 15     | Australia | Will Australia win on 2026-06-14 in Group D of the 2026 FIFA World Cup group stage?         |
| 50     | draw      | Will Australia vs. Türkiye end in a draw in Group D of the 2026 FIFA World Cup group stage? |
| 16     | Türkiye   | Will Türkiye win on 2026-06-14 in Group D of the 2026 FIFA World Cup group stage?           |

***

#### Match 22 — Germany vs. Curaçao

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                     |
| ------ | ------- | ----------------------------------------------------------------------------------------- |
| 17     | Germany | Will Germany win on 2026-06-14 in Group E of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Germany vs. Curaçao end in a draw in Group E of the 2026 FIFA World Cup group stage? |
| 18     | Curaçao | Will Curaçao win on 2026-06-14 in Group E of the 2026 FIFA World Cup group stage?         |

***

#### Match 23 — Netherlands vs. Japan

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                       |
| ------ | ----------- | ------------------------------------------------------------------------------------------- |
| 21     | Netherlands | Will Netherlands win on 2026-06-14 in Group F of the 2026 FIFA World Cup group stage?       |
| 50     | draw        | Will Netherlands vs. Japan end in a draw in Group F of the 2026 FIFA World Cup group stage? |
| 22     | Japan       | Will Japan win on 2026-06-14 in Group F of the 2026 FIFA World Cup group stage?             |

***

#### Match 24 — Ivory Coast vs. Ecuador

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                           |
| ------ | ----------- | ----------------------------------------------------------------------------------------------- |
| 19     | Ivory Coast | Will Côte d'Ivoire win on 2026-06-14 in Group E of the 2026 FIFA World Cup group stage?         |
| 50     | draw        | Will Côte d'Ivoire vs. Ecuador end in a draw in Group E of the 2026 FIFA World Cup group stage? |
| 20     | Ecuador     | Will Ecuador win on 2026-06-14 in Group E of the 2026 FIFA World Cup group stage?               |

***

#### Match 25 — Sweden vs. Tunisia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 23     | Sweden  | Will Sweden win on 2026-06-14 in Group F of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Sweden vs. Tunisia end in a draw in Group F of the 2026 FIFA World Cup group stage? |
| 24     | Tunisia | Will Tunisia win on 2026-06-14 in Group F of the 2026 FIFA World Cup group stage?        |

***

#### Match 26 — Spain vs. Cape Verde

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team       | Oracle question title                                                                      |
| ------ | ---------- | ------------------------------------------------------------------------------------------ |
| 29     | Spain      | Will Spain win on 2026-06-15 in Group H of the 2026 FIFA World Cup group stage?            |
| 50     | draw       | Will Spain vs. Cabo Verde end in a draw in Group H of the 2026 FIFA World Cup group stage? |
| 30     | Cape Verde | Will Cabo Verde win on 2026-06-15 in Group H of the 2026 FIFA World Cup group stage?       |

***

#### Match 27 — Belgium vs. Egypt

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------- |
| 25     | Belgium | Will Belgium win on 2026-06-15 in Group G of the 2026 FIFA World Cup group stage?       |
| 50     | draw    | Will Belgium vs. Egypt end in a draw in Group G of the 2026 FIFA World Cup group stage? |
| 26     | Egypt   | Will Egypt win on 2026-06-15 in Group G of the 2026 FIFA World Cup group stage?         |

***

#### Match 28 — Saudi Arabia vs. Uruguay

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team         | Oracle question title                                                                          |
| ------ | ------------ | ---------------------------------------------------------------------------------------------- |
| 31     | Saudi Arabia | Will Saudi Arabia win on 2026-06-15 in Group H of the 2026 FIFA World Cup group stage?         |
| 50     | draw         | Will Saudi Arabia vs. Uruguay end in a draw in Group H of the 2026 FIFA World Cup group stage? |
| 32     | Uruguay      | Will Uruguay win on 2026-06-15 in Group H of the 2026 FIFA World Cup group stage?              |

***

#### Match 29 — Iran vs. New Zealand

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                         |
| ------ | ----------- | --------------------------------------------------------------------------------------------- |
| 27     | Iran        | Will IR Iran win on 2026-06-15 in Group G of the 2026 FIFA World Cup group stage?             |
| 50     | draw        | Will IR Iran vs. New Zealand end in a draw in Group G of the 2026 FIFA World Cup group stage? |
| 28     | New Zealand | Will New Zealand win on 2026-06-15 in Group G of the 2026 FIFA World Cup group stage?         |

***

#### Match 30 — France vs. Senegal

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 33     | France  | Will France win on 2026-06-16 in Group I of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will France vs. Senegal end in a draw in Group I of the 2026 FIFA World Cup group stage? |
| 34     | Senegal | Will Senegal win on 2026-06-16 in Group I of the 2026 FIFA World Cup group stage?        |

***

#### Match 31 — Iraq vs. Norway

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team   | Oracle question title                                                                 |
| ------ | ------ | ------------------------------------------------------------------------------------- |
| 35     | Iraq   | Will Iraq win on 2026-06-16 in Group I of the 2026 FIFA World Cup group stage?        |
| 50     | draw   | Will Iraq vs. Norway end in a draw in Group I of the 2026 FIFA World Cup group stage? |
| 36     | Norway | Will Norway win on 2026-06-16 in Group I of the 2026 FIFA World Cup group stage?      |

***

#### Match 32 — Argentina vs. Algeria

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team      | Oracle question title                                                                       |
| ------ | --------- | ------------------------------------------------------------------------------------------- |
| 37     | Argentina | Will Argentina win on 2026-06-16 in Group J of the 2026 FIFA World Cup group stage?         |
| 50     | draw      | Will Argentina vs. Algeria end in a draw in Group J of the 2026 FIFA World Cup group stage? |
| 38     | Algeria   | Will Algeria win on 2026-06-16 in Group J of the 2026 FIFA World Cup group stage?           |

***

#### Match 33 — Austria vs. Jordan

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 39     | Austria | Will Austria win on 2026-06-17 in Group J of the 2026 FIFA World Cup group stage?        |
| 50     | draw    | Will Austria vs. Jordan end in a draw in Group J of the 2026 FIFA World Cup group stage? |
| 40     | Jordan  | Will Jordan win on 2026-06-17 in Group J of the 2026 FIFA World Cup group stage?         |

***

#### Match 34 — Portugal vs. DR Congo

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                       |
| ------ | -------- | ------------------------------------------------------------------------------------------- |
| 41     | Portugal | Will Portugal win on 2026-06-17 in Group K of the 2026 FIFA World Cup group stage?          |
| 50     | draw     | Will Portugal vs. DR Congo end in a draw in Group K of the 2026 FIFA World Cup group stage? |
| 42     | DR Congo | Will DR Congo win on 2026-06-17 in Group K of the 2026 FIFA World Cup group stage?          |

***

#### Match 35 — England vs. Croatia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                     |
| ------ | ------- | ----------------------------------------------------------------------------------------- |
| 45     | England | Will England win on 2026-06-17 in Group L of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will England vs. Croatia end in a draw in Group L of the 2026 FIFA World Cup group stage? |
| 46     | Croatia | Will Croatia win on 2026-06-17 in Group L of the 2026 FIFA World Cup group stage?         |

***

#### Match 36 — Ghana vs. Panama

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team   | Oracle question title                                                                  |
| ------ | ------ | -------------------------------------------------------------------------------------- |
| 47     | Ghana  | Will Ghana win on 2026-06-17 in Group L of the 2026 FIFA World Cup group stage?        |
| 50     | draw   | Will Ghana vs. Panama end in a draw in Group L of the 2026 FIFA World Cup group stage? |
| 48     | Panama | Will Panama win on 2026-06-17 in Group L of the 2026 FIFA World Cup group stage?       |

***

#### Match 37 — Uzbekistan vs. Colombia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team       | Oracle question title                                                                         |
| ------ | ---------- | --------------------------------------------------------------------------------------------- |
| 43     | Uzbekistan | Will Uzbekistan win on 2026-06-17 in Group K of the 2026 FIFA World Cup group stage?          |
| 50     | draw       | Will Uzbekistan vs. Colombia end in a draw in Group K of the 2026 FIFA World Cup group stage? |
| 44     | Colombia   | Will Colombia win on 2026-06-17 in Group K of the 2026 FIFA World Cup group stage?            |

***

#### Match 38 — Czechia vs. South Africa

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team         | Oracle question title                                                                          |
| ------ | ------------ | ---------------------------------------------------------------------------------------------- |
| 4      | Czechia      | Will Czechia win on 2026-06-18 in Group A of the 2026 FIFA World Cup group stage?              |
| 50     | draw         | Will Czechia vs. South Africa end in a draw in Group A of the 2026 FIFA World Cup group stage? |
| 2      | South Africa | Will South Africa win on 2026-06-18 in Group A of the 2026 FIFA World Cup group stage?         |

***

#### Match 39 — Switzerland vs. Bosnia and Herzegovina

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team                   | Oracle question title                                                                                        |
| ------ | ---------------------- | ------------------------------------------------------------------------------------------------------------ |
| 8      | Switzerland            | Will Switzerland win on 2026-06-18 in Group B of the 2026 FIFA World Cup group stage?                        |
| 50     | draw                   | Will Switzerland vs. Bosnia and Herzegovina end in a draw in Group B of the 2026 FIFA World Cup group stage? |
| 6      | Bosnia and Herzegovina | Will Bosnia and Herzegovina win on 2026-06-18 in Group B of the 2026 FIFA World Cup group stage?             |

***

#### Match 40 — Canada vs. Qatar

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team   | Oracle question title                                                                  |
| ------ | ------ | -------------------------------------------------------------------------------------- |
| 5      | Canada | Will Canada win on 2026-06-18 in Group B of the 2026 FIFA World Cup group stage?       |
| 50     | draw   | Will Canada vs. Qatar end in a draw in Group B of the 2026 FIFA World Cup group stage? |
| 7      | Qatar  | Will Qatar win on 2026-06-18 in Group B of the 2026 FIFA World Cup group stage?        |

***

#### Match 41 — Mexico vs. South Korea

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                           |
| ------ | ----------- | ----------------------------------------------------------------------------------------------- |
| 1      | Mexico      | Will Mexico win on 2026-06-18 in Group A of the 2026 FIFA World Cup group stage?                |
| 50     | draw        | Will Mexico vs. Korea Republic end in a draw in Group A of the 2026 FIFA World Cup group stage? |
| 3      | South Korea | Will Korea Republic win on 2026-06-18 in Group A of the 2026 FIFA World Cup group stage?        |

***

#### Match 42 — USA vs. Australia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team      | Oracle question title                                                                             |
| ------ | --------- | ------------------------------------------------------------------------------------------------- |
| 13     | USA       | Will United States win on 2026-06-19 in Group D of the 2026 FIFA World Cup group stage?           |
| 50     | draw      | Will United States vs. Australia end in a draw in Group D of the 2026 FIFA World Cup group stage? |
| 15     | Australia | Will Australia win on 2026-06-19 in Group D of the 2026 FIFA World Cup group stage?               |

***

#### Match 43 — Scotland vs. Morocco

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                      |
| ------ | -------- | ------------------------------------------------------------------------------------------ |
| 12     | Scotland | Will Scotland win on 2026-06-19 in Group C of the 2026 FIFA World Cup group stage?         |
| 50     | draw     | Will Scotland vs. Morocco end in a draw in Group C of the 2026 FIFA World Cup group stage? |
| 10     | Morocco  | Will Morocco win on 2026-06-19 in Group C of the 2026 FIFA World Cup group stage?          |

***

#### Match 44 — Brazil vs. Haiti

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team   | Oracle question title                                                                  |
| ------ | ------ | -------------------------------------------------------------------------------------- |
| 9      | Brazil | Will Brazil win on 2026-06-19 in Group C of the 2026 FIFA World Cup group stage?       |
| 50     | draw   | Will Brazil vs. Haiti end in a draw in Group C of the 2026 FIFA World Cup group stage? |
| 11     | Haiti  | Will Haiti win on 2026-06-19 in Group C of the 2026 FIFA World Cup group stage?        |

***

#### Match 45 — Türkiye vs. Paraguay

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                      |
| ------ | -------- | ------------------------------------------------------------------------------------------ |
| 16     | Türkiye  | Will Türkiye win on 2026-06-19 in Group D of the 2026 FIFA World Cup group stage?          |
| 50     | draw     | Will Türkiye vs. Paraguay end in a draw in Group D of the 2026 FIFA World Cup group stage? |
| 14     | Paraguay | Will Paraguay win on 2026-06-19 in Group D of the 2026 FIFA World Cup group stage?         |

***

#### Match 46 — Netherlands vs. Sweden

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                        |
| ------ | ----------- | -------------------------------------------------------------------------------------------- |
| 21     | Netherlands | Will Netherlands win on 2026-06-20 in Group F of the 2026 FIFA World Cup group stage?        |
| 50     | draw        | Will Netherlands vs. Sweden end in a draw in Group F of the 2026 FIFA World Cup group stage? |
| 23     | Sweden      | Will Sweden win on 2026-06-20 in Group F of the 2026 FIFA World Cup group stage?             |

***

#### Match 47 — Germany vs. Ivory Coast

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                           |
| ------ | ----------- | ----------------------------------------------------------------------------------------------- |
| 17     | Germany     | Will Germany win on 2026-06-20 in Group E of the 2026 FIFA World Cup group stage?               |
| 50     | draw        | Will Germany vs. Côte d'Ivoire end in a draw in Group E of the 2026 FIFA World Cup group stage? |
| 19     | Ivory Coast | Will Côte d'Ivoire win on 2026-06-20 in Group E of the 2026 FIFA World Cup group stage?         |

***

#### Match 48 — Ecuador vs. Curaçao

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                     |
| ------ | ------- | ----------------------------------------------------------------------------------------- |
| 20     | Ecuador | Will Ecuador win on 2026-06-20 in Group E of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Ecuador vs. Curaçao end in a draw in Group E of the 2026 FIFA World Cup group stage? |
| 18     | Curaçao | Will Curaçao win on 2026-06-20 in Group E of the 2026 FIFA World Cup group stage?         |

***

#### Match 49 — Tunisia vs. Japan

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------- |
| 24     | Tunisia | Will Tunisia win on 2026-06-21 in Group F of the 2026 FIFA World Cup group stage?       |
| 50     | draw    | Will Tunisia vs. Japan end in a draw in Group F of the 2026 FIFA World Cup group stage? |
| 22     | Japan   | Will Japan win on 2026-06-21 in Group F of the 2026 FIFA World Cup group stage?         |

***

#### Match 50 — Spain vs. Saudi Arabia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team         | Oracle question title                                                                        |
| ------ | ------------ | -------------------------------------------------------------------------------------------- |
| 29     | Spain        | Will Spain win on 2026-06-21 in Group H of the 2026 FIFA World Cup group stage?              |
| 50     | draw         | Will Spain vs. Saudi Arabia end in a draw in Group H of the 2026 FIFA World Cup group stage? |
| 31     | Saudi Arabia | Will Saudi Arabia win on 2026-06-21 in Group H of the 2026 FIFA World Cup group stage?       |

***

#### Match 51 — Belgium vs. Iran

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                     |
| ------ | ------- | ----------------------------------------------------------------------------------------- |
| 25     | Belgium | Will Belgium win on 2026-06-21 in Group G of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Belgium vs. IR Iran end in a draw in Group G of the 2026 FIFA World Cup group stage? |
| 27     | Iran    | Will IR Iran win on 2026-06-21 in Group G of the 2026 FIFA World Cup group stage?         |

***

#### Match 52 — Uruguay vs. Cape Verde

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team       | Oracle question title                                                                        |
| ------ | ---------- | -------------------------------------------------------------------------------------------- |
| 32     | Uruguay    | Will Uruguay win on 2026-06-21 in Group H of the 2026 FIFA World Cup group stage?            |
| 50     | draw       | Will Uruguay vs. Cabo Verde end in a draw in Group H of the 2026 FIFA World Cup group stage? |
| 30     | Cape Verde | Will Cabo Verde win on 2026-06-21 in Group H of the 2026 FIFA World Cup group stage?         |

***

#### Match 53 — New Zealand vs. Egypt

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                       |
| ------ | ----------- | ------------------------------------------------------------------------------------------- |
| 28     | New Zealand | Will New Zealand win on 2026-06-21 in Group G of the 2026 FIFA World Cup group stage?       |
| 50     | draw        | Will New Zealand vs. Egypt end in a draw in Group G of the 2026 FIFA World Cup group stage? |
| 26     | Egypt       | Will Egypt win on 2026-06-21 in Group G of the 2026 FIFA World Cup group stage?             |

***

#### Match 54 — Argentina vs. Austria

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team      | Oracle question title                                                                       |
| ------ | --------- | ------------------------------------------------------------------------------------------- |
| 37     | Argentina | Will Argentina win on 2026-06-22 in Group J of the 2026 FIFA World Cup group stage?         |
| 50     | draw      | Will Argentina vs. Austria end in a draw in Group J of the 2026 FIFA World Cup group stage? |
| 39     | Austria   | Will Austria win on 2026-06-22 in Group J of the 2026 FIFA World Cup group stage?           |

***

#### Match 55 — France vs. Iraq

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team   | Oracle question title                                                                 |
| ------ | ------ | ------------------------------------------------------------------------------------- |
| 33     | France | Will France win on 2026-06-22 in Group I of the 2026 FIFA World Cup group stage?      |
| 50     | draw   | Will France vs. Iraq end in a draw in Group I of the 2026 FIFA World Cup group stage? |
| 35     | Iraq   | Will Iraq win on 2026-06-22 in Group I of the 2026 FIFA World Cup group stage?        |

***

#### Match 56 — Norway vs. Senegal

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 36     | Norway  | Will Norway win on 2026-06-22 in Group I of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Norway vs. Senegal end in a draw in Group I of the 2026 FIFA World Cup group stage? |
| 34     | Senegal | Will Senegal win on 2026-06-22 in Group I of the 2026 FIFA World Cup group stage?        |

***

#### Match 57 — Jordan vs. Algeria

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 40     | Jordan  | Will Jordan win on 2026-06-22 in Group J of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Jordan vs. Algeria end in a draw in Group J of the 2026 FIFA World Cup group stage? |
| 38     | Algeria | Will Algeria win on 2026-06-22 in Group J of the 2026 FIFA World Cup group stage?        |

***

#### Match 58 — Portugal vs. Uzbekistan

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team       | Oracle question title                                                                         |
| ------ | ---------- | --------------------------------------------------------------------------------------------- |
| 41     | Portugal   | Will Portugal win on 2026-06-23 in Group K of the 2026 FIFA World Cup group stage?            |
| 50     | draw       | Will Portugal vs. Uzbekistan end in a draw in Group K of the 2026 FIFA World Cup group stage? |
| 43     | Uzbekistan | Will Uzbekistan win on 2026-06-23 in Group K of the 2026 FIFA World Cup group stage?          |

***

#### Match 59 — England vs. Ghana

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------- |
| 45     | England | Will England win on 2026-06-23 in Group L of the 2026 FIFA World Cup group stage?       |
| 50     | draw    | Will England vs. Ghana end in a draw in Group L of the 2026 FIFA World Cup group stage? |
| 47     | Ghana   | Will Ghana win on 2026-06-23 in Group L of the 2026 FIFA World Cup group stage?         |

***

#### Match 60 — Panama vs. Croatia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 48     | Panama  | Will Panama win on 2026-06-23 in Group L of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Panama vs. Croatia end in a draw in Group L of the 2026 FIFA World Cup group stage? |
| 46     | Croatia | Will Croatia win on 2026-06-23 in Group L of the 2026 FIFA World Cup group stage?        |

***

#### Match 61 — Colombia vs. DR Congo

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                       |
| ------ | -------- | ------------------------------------------------------------------------------------------- |
| 44     | Colombia | Will Colombia win on 2026-06-23 in Group K of the 2026 FIFA World Cup group stage?          |
| 50     | draw     | Will Colombia vs. DR Congo end in a draw in Group K of the 2026 FIFA World Cup group stage? |
| 42     | DR Congo | Will DR Congo win on 2026-06-23 in Group K of the 2026 FIFA World Cup group stage?          |

***

#### Match 62 — Bosnia and Herzegovina vs. Qatar

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team                   | Oracle question title                                                                                  |
| ------ | ---------------------- | ------------------------------------------------------------------------------------------------------ |
| 6      | Bosnia and Herzegovina | Will Bosnia and Herzegovina win on 2026-06-24 in Group B of the 2026 FIFA World Cup group stage?       |
| 50     | draw                   | Will Bosnia and Herzegovina vs. Qatar end in a draw in Group B of the 2026 FIFA World Cup group stage? |
| 7      | Qatar                  | Will Qatar win on 2026-06-24 in Group B of the 2026 FIFA World Cup group stage?                        |

***

#### Match 63 — Switzerland vs. Canada

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                        |
| ------ | ----------- | -------------------------------------------------------------------------------------------- |
| 8      | Switzerland | Will Switzerland win on 2026-06-24 in Group B of the 2026 FIFA World Cup group stage?        |
| 50     | draw        | Will Switzerland vs. Canada end in a draw in Group B of the 2026 FIFA World Cup group stage? |
| 5      | Canada      | Will Canada win on 2026-06-24 in Group B of the 2026 FIFA World Cup group stage?             |

***

#### Match 64 — Morocco vs. Haiti

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------- |
| 10     | Morocco | Will Morocco win on 2026-06-24 in Group C of the 2026 FIFA World Cup group stage?       |
| 50     | draw    | Will Morocco vs. Haiti end in a draw in Group C of the 2026 FIFA World Cup group stage? |
| 11     | Haiti   | Will Haiti win on 2026-06-24 in Group C of the 2026 FIFA World Cup group stage?         |

***

#### Match 65 — Scotland vs. Brazil

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                     |
| ------ | -------- | ----------------------------------------------------------------------------------------- |
| 12     | Scotland | Will Scotland win on 2026-06-24 in Group C of the 2026 FIFA World Cup group stage?        |
| 50     | draw     | Will Scotland vs. Brazil end in a draw in Group C of the 2026 FIFA World Cup group stage? |
| 9      | Brazil   | Will Brazil win on 2026-06-24 in Group C of the 2026 FIFA World Cup group stage?          |

***

#### Match 66 — Czechia vs. Mexico

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 4      | Czechia | Will Czechia win on 2026-06-24 in Group A of the 2026 FIFA World Cup group stage?        |
| 50     | draw    | Will Czechia vs. Mexico end in a draw in Group A of the 2026 FIFA World Cup group stage? |
| 1      | Mexico  | Will Mexico win on 2026-06-24 in Group A of the 2026 FIFA World Cup group stage?         |

***

#### Match 67 — South Africa vs. South Korea

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team         | Oracle question title                                                                                 |
| ------ | ------------ | ----------------------------------------------------------------------------------------------------- |
| 2      | South Africa | Will South Africa win on 2026-06-24 in Group A of the 2026 FIFA World Cup group stage?                |
| 50     | draw         | Will South Africa vs. Korea Republic end in a draw in Group A of the 2026 FIFA World Cup group stage? |
| 3      | South Korea  | Will Korea Republic win on 2026-06-24 in Group A of the 2026 FIFA World Cup group stage?              |

***

#### Match 68 — Curaçao vs. Ivory Coast

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                           |
| ------ | ----------- | ----------------------------------------------------------------------------------------------- |
| 18     | Curaçao     | Will Curaçao win on 2026-06-25 in Group E of the 2026 FIFA World Cup group stage?               |
| 50     | draw        | Will Curaçao vs. Côte d'Ivoire end in a draw in Group E of the 2026 FIFA World Cup group stage? |
| 19     | Ivory Coast | Will Côte d'Ivoire win on 2026-06-25 in Group E of the 2026 FIFA World Cup group stage?         |

***

#### Match 69 — Ecuador vs. Germany

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                     |
| ------ | ------- | ----------------------------------------------------------------------------------------- |
| 20     | Ecuador | Will Ecuador win on 2026-06-25 in Group E of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Ecuador vs. Germany end in a draw in Group E of the 2026 FIFA World Cup group stage? |
| 17     | Germany | Will Germany win on 2026-06-25 in Group E of the 2026 FIFA World Cup group stage?         |

***

#### Match 70 — Japan vs. Sweden

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team   | Oracle question title                                                                  |
| ------ | ------ | -------------------------------------------------------------------------------------- |
| 22     | Japan  | Will Japan win on 2026-06-25 in Group F of the 2026 FIFA World Cup group stage?        |
| 50     | draw   | Will Japan vs. Sweden end in a draw in Group F of the 2026 FIFA World Cup group stage? |
| 23     | Sweden | Will Sweden win on 2026-06-25 in Group F of the 2026 FIFA World Cup group stage?       |

***

#### Match 71 — Tunisia vs. Netherlands

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                         |
| ------ | ----------- | --------------------------------------------------------------------------------------------- |
| 24     | Tunisia     | Will Tunisia win on 2026-06-25 in Group F of the 2026 FIFA World Cup group stage?             |
| 50     | draw        | Will Tunisia vs. Netherlands end in a draw in Group F of the 2026 FIFA World Cup group stage? |
| 21     | Netherlands | Will Netherlands win on 2026-06-25 in Group F of the 2026 FIFA World Cup group stage?         |

***

#### Match 72 — Türkiye vs. USA

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                           |
| ------ | ------- | ----------------------------------------------------------------------------------------------- |
| 16     | Türkiye | Will Türkiye win on 2026-06-25 in Group D of the 2026 FIFA World Cup group stage?               |
| 50     | draw    | Will Türkiye vs. United States end in a draw in Group D of the 2026 FIFA World Cup group stage? |
| 13     | USA     | Will United States win on 2026-06-25 in Group D of the 2026 FIFA World Cup group stage?         |

***

#### Match 73 — Paraguay vs. Australia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team      | Oracle question title                                                                        |
| ------ | --------- | -------------------------------------------------------------------------------------------- |
| 14     | Paraguay  | Will Paraguay win on 2026-06-25 in Group D of the 2026 FIFA World Cup group stage?           |
| 50     | draw      | Will Paraguay vs. Australia end in a draw in Group D of the 2026 FIFA World Cup group stage? |
| 15     | Australia | Will Australia win on 2026-06-25 in Group D of the 2026 FIFA World Cup group stage?          |

***

#### Match 74 — Senegal vs. Iraq

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                  |
| ------ | ------- | -------------------------------------------------------------------------------------- |
| 34     | Senegal | Will Senegal win on 2026-06-26 in Group I of the 2026 FIFA World Cup group stage?      |
| 50     | draw    | Will Senegal vs. Iraq end in a draw in Group I of the 2026 FIFA World Cup group stage? |
| 35     | Iraq    | Will Iraq win on 2026-06-26 in Group I of the 2026 FIFA World Cup group stage?         |

***

#### Match 75 — Norway vs. France

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team   | Oracle question title                                                                   |
| ------ | ------ | --------------------------------------------------------------------------------------- |
| 36     | Norway | Will Norway win on 2026-06-26 in Group I of the 2026 FIFA World Cup group stage?        |
| 50     | draw   | Will Norway vs. France end in a draw in Group I of the 2026 FIFA World Cup group stage? |
| 33     | France | Will France win on 2026-06-26 in Group I of the 2026 FIFA World Cup group stage?        |

***

#### Match 76 — Cape Verde vs. Saudi Arabia

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team         | Oracle question title                                                                             |
| ------ | ------------ | ------------------------------------------------------------------------------------------------- |
| 30     | Cape Verde   | Will Cabo Verde win on 2026-06-26 in Group H of the 2026 FIFA World Cup group stage?              |
| 50     | draw         | Will Cabo Verde vs. Saudi Arabia end in a draw in Group H of the 2026 FIFA World Cup group stage? |
| 31     | Saudi Arabia | Will Saudi Arabia win on 2026-06-26 in Group H of the 2026 FIFA World Cup group stage?            |

***

#### Match 77 — Uruguay vs. Spain

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------- |
| 32     | Uruguay | Will Uruguay win on 2026-06-26 in Group H of the 2026 FIFA World Cup group stage?       |
| 50     | draw    | Will Uruguay vs. Spain end in a draw in Group H of the 2026 FIFA World Cup group stage? |
| 29     | Spain   | Will Spain win on 2026-06-26 in Group H of the 2026 FIFA World Cup group stage?         |

***

#### Match 78 — Egypt vs. Iran

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team  | Oracle question title                                                                   |
| ------ | ----- | --------------------------------------------------------------------------------------- |
| 26     | Egypt | Will Egypt win on 2026-06-26 in Group G of the 2026 FIFA World Cup group stage?         |
| 50     | draw  | Will Egypt vs. IR Iran end in a draw in Group G of the 2026 FIFA World Cup group stage? |
| 27     | Iran  | Will IR Iran win on 2026-06-26 in Group G of the 2026 FIFA World Cup group stage?       |

***

#### Match 79 — New Zealand vs. Belgium

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team        | Oracle question title                                                                         |
| ------ | ----------- | --------------------------------------------------------------------------------------------- |
| 28     | New Zealand | Will New Zealand win on 2026-06-26 in Group G of the 2026 FIFA World Cup group stage?         |
| 50     | draw        | Will New Zealand vs. Belgium end in a draw in Group G of the 2026 FIFA World Cup group stage? |
| 25     | Belgium     | Will Belgium win on 2026-06-26 in Group G of the 2026 FIFA World Cup group stage?             |

***

#### Match 80 — Croatia vs. Ghana

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------- |
| 46     | Croatia | Will Croatia win on 2026-06-27 in Group L of the 2026 FIFA World Cup group stage?       |
| 50     | draw    | Will Croatia vs. Ghana end in a draw in Group L of the 2026 FIFA World Cup group stage? |
| 47     | Ghana   | Will Ghana win on 2026-06-27 in Group L of the 2026 FIFA World Cup group stage?         |

***

#### Match 81 — Panama vs. England

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------- |
| 48     | Panama  | Will Panama win on 2026-06-27 in Group L of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Panama vs. England end in a draw in Group L of the 2026 FIFA World Cup group stage? |
| 45     | England | Will England win on 2026-06-27 in Group L of the 2026 FIFA World Cup group stage?        |

***

#### Match 82 — Colombia vs. Portugal

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team     | Oracle question title                                                                       |
| ------ | -------- | ------------------------------------------------------------------------------------------- |
| 44     | Colombia | Will Colombia win on 2026-06-27 in Group K of the 2026 FIFA World Cup group stage?          |
| 50     | draw     | Will Colombia vs. Portugal end in a draw in Group K of the 2026 FIFA World Cup group stage? |
| 41     | Portugal | Will Portugal win on 2026-06-27 in Group K of the 2026 FIFA World Cup group stage?          |

***

#### Match 83 — DR Congo vs. Uzbekistan

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team       | Oracle question title                                                                         |
| ------ | ---------- | --------------------------------------------------------------------------------------------- |
| 42     | DR Congo   | Will DR Congo win on 2026-06-27 in Group K of the 2026 FIFA World Cup group stage?            |
| 50     | draw       | Will DR Congo vs. Uzbekistan end in a draw in Group K of the 2026 FIFA World Cup group stage? |
| 43     | Uzbekistan | Will Uzbekistan win on 2026-06-27 in Group K of the 2026 FIFA World Cup group stage?          |

***

#### Match 84 — Jordan vs. Argentina

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team      | Oracle question title                                                                      |
| ------ | --------- | ------------------------------------------------------------------------------------------ |
| 40     | Jordan    | Will Jordan win on 2026-06-27 in Group J of the 2026 FIFA World Cup group stage?           |
| 50     | draw      | Will Jordan vs. Argentina end in a draw in Group J of the 2026 FIFA World Cup group stage? |
| 37     | Argentina | Will Argentina win on 2026-06-27 in Group J of the 2026 FIFA World Cup group stage?        |

***

#### Match 85 — Algeria vs. Austria

Resolves to the winner of this match in the 2026 FIFA World Cup.

| teamId | Team    | Oracle question title                                                                     |
| ------ | ------- | ----------------------------------------------------------------------------------------- |
| 38     | Algeria | Will Algeria win on 2026-06-27 in Group J of the 2026 FIFA World Cup group stage?         |
| 50     | draw    | Will Algeria vs. Austria end in a draw in Group J of the 2026 FIFA World Cup group stage? |
| 39     | Austria | Will Austria win on 2026-06-27 in Group J of the 2026 FIFA World Cup group stage?         |

***
