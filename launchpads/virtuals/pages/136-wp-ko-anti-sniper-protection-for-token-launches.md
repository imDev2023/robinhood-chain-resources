# Virtuals Protocol - 토큰 출시를 위한 안티 스나이퍼 보호

> Source: https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# 토큰 출시를 위한 안티 스나이퍼 보호

### 토큰 출시 안티-스나이퍼 보호

안티-스나이퍼 보호는 AI 에이전트 토큰 출시를 위한 무료 Virtuals Protocol 출시 모듈입니다. TGE에서 동적 매수 측 세금을 적용합니다. 이를 통해 초기 거래 중 봇 활동과 기회주의적인 토큰 스나이핑이 줄어듭니다.

이 모듈은 기본적으로 활성화되어 있으며 무료입니다.

<figure><img src="/files/a39b6e6bfed700986e18a8339355db2554755f64" alt=""><figcaption><p>TGE 보호 기간 동안 동적 매수세 세금이 점차 감소합니다.</p></figcaption></figure>

### 동적 스나이퍼 세금의 작동 방식

스나이퍼 세금은 TGE 시점에 99%에서 시작합니다.

* 이 세금은 창립자가 선택한 보호 기간 동안 1% 기준 거래세까지 점차 감소합니다.
* 창립자는 세금이 적용될 거래 측면을 선택합니다:
  * **매수:** 들어오는 방향에서 봇이 토큰을 스나이핑하는 것을 막습니다. 이것이 기본값입니다.
  * **매도:** 초기 보유자들이 낮은 유동성에 물량을 던지는 것을 억제합니다.
  * **매수 및 매도:** 감소하는 세금을 양쪽 모두에 동시에 적용합니다.
* 기간 동안 징수된 스나이퍼 세금은 온체인 자동 에이전트 토큰 바이백 자금을 조달합니다.
* 재매입된 토큰은 팀 지갑으로 이동합니다. 이 토큰은 3개월 클리프와 9개월 선형 베스팅 일정에 따릅니다.

이 토큰 출시 보호 기능은 봇과 스나이퍼로부터 초기 유동성을 방어하는 데 도움이 됩니다. 초기 거래세를 프로젝트 창립자와의 장기적 정렬로 전환합니다.

### TGE 보호 기간 설정

창립자는 생성 단계에서 네 가지 사전 설정 기간 중 하나를 선택해 보호 기간과 적용 측면(매수, 매도, 또는 매수 및 매도)을 설정합니다. 세금 감소율은 선택한 기간이 끝날 때 1% 기준값에 도달하도록 자동으로 조정됩니다.

사용 가능한 기간:

* **0초:** 안티-스나이퍼 보호가 적용되지 않습니다. 거래세는 출시 시점부터 1%로 유지됩니다.
* **60초:** 세금이 1분 동안 99%에서 1%로 감소합니다.
* **10분:** 세금이 10분 동안 99%에서 1%로 감소합니다.
* **98분:** 세금이 98분 동안 99%에서 1%로 감소하며, 대략 분당 1%씩 감소합니다.

60초 및 10분 사전 설정은 현재 매수 측 거래에만 적용됩니다. 98분 사전 설정은 매수 측, 매도 측 또는 양쪽 모두에 적용할 수 있어, 창립자가 출시 보호 프로필을 가장 세밀하게 제어할 수 있습니다.

### 안티-스나이퍼 보호 FAQ

<details>

<summary>스나이퍼 세금 바이백은 언제 시작되나요?</summary>

바이백은 설정된 보호 기간이 끝나고 보호 대상 측(매수 또는 매도)의 세금이 기준 1%에 도달하는 즉시 자동으로 시작됩니다.

</details>

<details>

<summary>징수된 스나이퍼 세금은 한 번의 바이백에 사용되나요?</summary>

아니요. 온체인 바이백은 24시간에 걸쳐 점진적으로 실행됩니다.

</details>

<details>

<summary>출시 후 안티-스나이퍼 보호 기간을 변경할 수 있나요?</summary>

아니요. 보호 기간은 생성 시 설정되며 에이전트 런치 페이지가 게시된 후에는 수정할 수 없습니다.

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
