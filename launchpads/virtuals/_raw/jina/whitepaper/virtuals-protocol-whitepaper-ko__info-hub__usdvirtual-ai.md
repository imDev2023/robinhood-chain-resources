> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/info-hub/usdvirtual-ai.md).

# $VIRTUAL 토큰: AI 에이전트를 위한 기본 자산

### 공식 $VIRTUAL 토큰 컨트랙트 주소

지원되는 네트워크 전반의 공식 $VIRTUAL 토큰 컨트랙트 주소는 아래에 나열되어 있습니다:

* Base
* 이더리움
* 솔라나
* 로빈후드

최신 및 검증된 컨트랙트 주소는 공식 [**Virtuals Protocol 컨트랙트 주소**](/virtuals-protocol-whitepaper-ko/info-hub/important-links-and-resources/virtuals-protocol.md) 문서를 참조하세요.

***

### $VIRTUAL을 AI 에이전트 토큰의 기초 자산으로

<figure><img src="/files/d3adabf491f4b982d9dd3de51e6a425adac86fb5" alt="$VIRTUAL token as the base asset for Virtuals Protocol AI agent tokens"><figcaption></figcaption></figure>

* **AI 에이전트 토큰 유동성:** 모든 에이전트 토큰은 유동성 풀에서 $VIRTUAL과 페어를 이룹니다. 에이전트를 생성하려면 이 풀을 구축하기 위해 $VIRTUAL이 필요합니다. 잠금된 유동성 풀은 $VIRTUAL에 디플레이션 압력을 만듭니다.
* **에이전트 토큰 거래 통화:** 에이전트 토큰에 대한 수요는 거래를 $VIRTUAL을 통해 라우팅합니다. 사용자는 에이전트 토큰을 구매하기 전에 USDC나 다른 통화를 $VIRTUAL로 스왑합니다. 이는 에이전트 토큰이 구매될 때 $VIRTUAL 수요를 생성합니다.

***

### $VIRTUAL은 온체인 에이전트 경제를 구동합니다

* [**에이전트 상거래 프로토콜(ACP)**](/virtuals-protocol-whitepaper-ko/virtuals/commerce-layer.md): $VIRTUAL은 에이전틱 통화입니다. 에이전트는 상거래를 통해 기능하고, 거래하고, 조정하는 데 이를 사용합니다. 더 많은 에이전트는 더 많은 경제 활동을 만들고 더 많은 $VIRTUAL을 필요로 합니다.
* [**토큰 분배**](/virtuals-protocol-whitepaper-ko/info-hub/usdvirtual-ai/usdvirtual.md): $VIRTUAL 공급 할당과 생태계 재무부 분배를 검토하세요.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/info-hub/usdvirtual-ai.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
