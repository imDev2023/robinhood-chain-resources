> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/automated-capital-formation.md).

# 자동화된 자본 형성

### 토큰 출시를 위한 자동 자본 조성(ACF)

자동 자본 조성 모듈을 활성화하려면 10 $VIRTUAL 수수료가 필요합니다.

활성화되면 토큰 공급량의 50%가 창립 팀을 위해 예약됩니다. 이 할당은 자동 자본 조성과 팀 할당으로 나뉩니다.

<figure><img src="/files/9f4b96b2f12b46ea6f9cfb1dd820ad56610f49dd" alt="Automated Capital Formation token allocation for Virtuals Protocol AI agent token launches"><figcaption></figcaption></figure>

***

### ACF 토큰 분배 및 창업자 자금 조달(25%)

프로젝트가 200만 달러 FDV에 도달하면 ACF가 자동 팀 분배를 시작합니다. 분배는 FDV가 추가로 10만 달러 증가할 때마다 연속적인 유동성 풀 생성을 사용합니다. 이는 1억 6,000만 달러 FDV까지 계속됩니다.

* ACF 수익금은 $USDC로 창업자에게 직접 지급됩니다.
* 분배는 자동적이며 투명합니다. 이는 시장 가치 평가에 엄격하게 연동됩니다.
* 창업자는 자신의 토큰이 시장 성장을 보일 때만 유동성을 받습니다.
* 주문은 자연스러운 가격 발견을 통해 체결됩니다.

### FDV 범위별 예상 자본 조성

| 가치 평가 범위($, USD)         | 판매 비율(%) | 평균 판매 가치 평가($, USD) | 조달액($, USD) | 누적 조달액($, USD) |
| ------------------------ | -------- | ------------------- | ----------- | -------------- |
| 2,000,000 - 10,000,000   | 5%       | 6,000,000           | 300,000     | 300,000        |
| 10,000,000 - 20,000,000  | 5%       | 15,000,000          | 750,000     | 1,050,000      |
| 20,000,000 - 40,000,000  | 5%       | 30,000,000          | 1,500,000   | 2,550,000      |
| 40,000,000 - 80,000,000  | 5%       | 60,000,000          | 3,000,000   | 5,550,000      |
| 80,000,000 - 160,000,000 | 5%       | 120,000,000         | 6,000,000   | 11,550,000     |

***

### 팀 토큰 할당 및 베스팅(25%)

팀 토큰 할당의 나머지 25%는 TGE 후 1년 동안 잠금됩니다. 이후 6개월간 선형 베스팅 일정이 적용됩니다.

프로젝트가 1년 전에 1억 6,000만 달러 FDV에 도달하면 베스팅은 즉시 시작됩니다. 이후에도 6개월 선형 일정이 적용됩니다.

이는 창업자의 책임성과 장기적인 AI 에이전트 개발을 지원합니다.

***

### Pre-buy 모듈을 통한 팀 초기 매수

그때 [사전 매수](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/ai-1.md) 모듈이 활성화되면 팀은 생성 과정에서 총 공급량의 최대 50%까지 구매할 수 있습니다. 이는 초기 토큰 시장을 안정화하고, 스나이핑을 방지하며, 창업자의 확신을 드러낼 수 있습니다.

사전 구매된 모든 토큰은 토크노믹스에 공개됩니다. 기본적으로 최소 1개월 클리프와 12개월 베스팅 일정이 적용됩니다. 팀은 출시 전에 이러한 매개변수를 조정할 수 있습니다.

창업자가 TGE 시점에 200만 달러 FDV를 초과하여 자체 매수하면, 해당 ACF 토큰 수량은 팀 할당으로 재분류됩니다. 이는 즉시 분배되지 않습니다.

이는 초기 창업자 참여가 자본 방출을 앞당기는 것을 방지합니다. 장기적인 성장 정렬과 책임성을 유지합니다.

### Pre-buy 제한 및 토큰 출시 재개

Agent Card가 활성화된 후에는 AI 에이전트를 다시 출시하지 않고는 팀이 Pre-buy를 실행할 수 없습니다.

Agent Card가 배포된 후 Pre-buy를 추가하려면, 팀은 기존 토큰 출시를 취소하고 새로 생성해야 합니다. 이 취소 및 재출시는 예정된 출시 하루 전까지 가능합니다. 모듈 수수료는 환불되지 않습니다.

이는 초기 팀 토큰 접근을 의도적이고 투명하며 공정하게 유지합니다. 참가자를 보호하고 시장의 건전성을 보존합니다.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/automated-capital-formation.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
