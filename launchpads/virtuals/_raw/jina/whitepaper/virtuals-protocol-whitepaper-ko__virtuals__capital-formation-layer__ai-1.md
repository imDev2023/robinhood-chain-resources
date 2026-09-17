> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/ai-1.md).

# AI 에이전트 출시용 사전 구매 토큰

### AI 에이전트 출시 전에 토큰을 사전 구매

무료 Pre-buy 모듈을 통해 창업자는 생성 시 총 토큰 공급량의 최대 100%까지 구매할 수 있습니다. 이를 통해 공개 거래가 시작되기 전에 창업자가 토큰을 구매할 수 있습니다.

***

### Pre-buy 토큰 모듈의 작동 방식

사전 구매된 토큰은 다음과 같습니다:

* Agent Launch Page의 토크노믹스 섹션에 투명하게 공개됨
* 기본적으로 1개월 클리프와 12개월 선형 베스팅 일정이 적용됨
* 토큰 거래가 시작되기 전에 커뮤니티에 표시됨

Pre-buy는 창업자가 초기 토큰 시장을 안정화하고, 스나이핑을 방지하며, 직접 참여를 통해 확신을 전달하는 데 도움이 될 수 있습니다.

***

### Pre-buy 토큰 베스팅

기본 베스팅 일정은 1개월 클리프와 12개월 선형 베스팅으로 구성됩니다.

창업자는 출시 전에 이러한 베스팅 매개변수를 조정할 수 있습니다. 토크노믹스는 참여자에게 투명하게 유지됩니다.

***

### Pre-buy와 자동 자본 형성

만약 [자동 자본 형성](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/automated-capital-formation.md) 이 활성화되어 있고 창업자가 TGE 시 FDV 200만 달러를 초과하여 자가 구매하면, 해당 ACF 토큰은 팀 할당으로 재분류됩니다. 이는 즉시 배분되지 않습니다.

이는 초기 창업자 토큰 구매가 자본 해제를 앞당기는 것을 방지합니다.

***

### Pre-buy 제한 및 토큰 출시 재개

Agent Card가 활성화된 이후에는 팀이 AI 에이전트를 다시 출시하지 않고는 Pre-buy를 사용할 수 없습니다.

Agent Card가 배포된 후 Pre-buy를 추가하려면, 팀은 기존 토큰 출시에 대한 취소를 하고 새로 생성해야 합니다. 이 취소 및 재출시는 예정된 출시일 하루 전까지 가능합니다. 모듈 수수료는 환불되지 않습니다.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/ai-1.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
