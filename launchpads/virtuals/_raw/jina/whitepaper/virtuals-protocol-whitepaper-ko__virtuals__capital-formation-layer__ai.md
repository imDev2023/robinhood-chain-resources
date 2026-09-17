> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/ai.md).

# AI 에이전트 토큰 출시를 위한 수수료 위임

### 수수료 위임이란 무엇인가요?

수수료 위임은 허가 없이 AI 에이전트 토큰을 출시할 수 있는 लॉन्च 모듈입니다. 토큰 생성자와 지정된 생성자 수수료 수령자를 분리합니다.

커뮤니티 구성원, 지지자, 협업자가 토큰 출시를 할 수 있도록 지원합니다. 지정된 빌더가 생성자 수수료 몫을 받습니다.

### 수수료 위임은 어떻게 작동하나요?

토큰 생성 중에 생성자는 수수료 위임을 활성화합니다. 그런 다음 빌더의 수수료 수령자 신원을 선택합니다:

* **X 계정** — 빌더의 `@사용자명`.
* **지갑 주소** — 빌더의 온체인 주소입니다.

그다음 토큰이 거래를 시작할 수 있습니다. 거래에는 1% 거래 수수료가 적용됩니다. 수수료 위임은 생성자의 70% 몫을 지정된 신원에 대해 예약합니다. 나머지 30%는 Virtuals Treasury를 지원합니다.

예약된 잔액은 토큰이 거래되는 동안 누적됩니다. 지정된 빌더는 프로필 인증 후 이를 청구할 수 있습니다.

### 커뮤니티 구성원이 제 프로젝트를 위해 AI 에이전트 토큰을 출시할 수 있나요?

네. 수수료 위임을 사용하면 커뮤니티 구성원이 AI 에이전트 토큰을 출시하면서 생성자 수수료 몫은 귀하에게 예약할 수 있습니다.

이는 사전 조율 없이도 가능합니다. 생성자는 귀하를 X 계정 또는 지갑 주소로 식별합니다. 귀하의 신원에 대해 예약된 수수료는 귀하가 청구할 수 있습니다.

### 위임된 거래 수수료는 어떻게 청구하나요?

1. Virtuals Protocol에 로그인하세요.
2. 위임된 X 계정 또는 지갑 주소와 연결된 프로필을 인증하세요.
3. 누적된 잔액을 청구하세요.

인증 후에는 향후 생성자 수수료가 귀하에게 직접 지급됩니다.

### 자주 묻는 질문

<details>

<summary>토큰 생성자가 저에게 위임된 수수료를 청구할 수 있나요?</summary>

아니요. 토큰 생성 시 식별된 빌더만 예약된 생성자 수수료 몫을 청구할 수 있습니다.

</details>

<details>

<summary>프로필을 청구하기 전에 수수료를 받을 수 있나요?</summary>

네. 수수료는 귀하의 X 계정 또는 지갑 주소에 연결된 예약 잔액으로 누적됩니다. 이를 청구하려면 연결된 프로필을 인증하세요.

</details>

<details>

<summary>수수료 위임은 빌더에게 어떤 수수료 몫을 예약하나요?</summary>

수수료 위임은 1% 거래 수수료 중 생성자의 70% 몫을 예약합니다. 나머지 30%는 Virtuals Treasury가 받습니다.

</details>

출시 수명 주기와 거래 수수료에 대한 자세한 내용은 다음을 참조하세요. [Virtuals 출시 메커니즘](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/virtuals.md).


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/ai.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
