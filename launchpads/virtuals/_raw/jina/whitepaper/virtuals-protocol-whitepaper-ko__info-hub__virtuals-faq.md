> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/info-hub/virtuals-faq.md).

# Virtuals 빌더 및 에이전트 토큰 출시 FAQ

{% hint style="info" %}
이 FAQ는 2026년 8월 14일 기준의 현재 시스템을 반영합니다. 프로토콜이 반복 개선됨에 따라 세부 내용은 시간이 지나며 변경될 수 있습니다.
{% endhint %}

{% hint style="info" %}

## 원하시는 내용을 찾지 못하셨나요?

다음을 통해 티켓을 제출하세요: [Discord 지원](https://discord.com/invite/virtualsio).
{% endhint %}

### Virtuals Protocol 빌더 및 에이전트 토큰 출시 FAQ

Virtuals Protocol에서 에이전트를 출시하고 토큰화하는 방법에 대한 답변을 확인하세요. 이 FAQ는 출시 지원, 거래세 분배, 베스팅된 토큰 청구를 다룹니다.

<details>

<summary>Virtuals Protocol에서 에이전트를 어떻게 출시/토큰화하나요?</summary>

다음에서 시작하세요 [Virtuals 출시 메커니즘](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/virtuals.md). 여기에는 생성, 거래, 유동성, 졸업이 포함됩니다.

</details>

<details>

<summary>내 에이전트 출시를 어떻게 지원받을 수 있나요?</summary>

다음을 참조하세요 [에이전트 출시 지원](/virtuals-protocol-whitepaper-ko/info-hub/builders-hub/agent-launch-support.md) 에서 마케팅 및 기술 지원 리소스를 확인하세요.

</details>

<details>

<summary>Base에서 거래세는 어떻게 추적 및 처리되나요?</summary>

Base에서 거래세 흐름을 추적하는 방법은 세 가지입니다:<br>

**옵션 1: Virtuals Tax Checker 대시보드에서 추적**\
\
에이전트의 거래 수수료 누적 및 분배 상태는 공식 [Virtuals Tax Checker 대시보드](https://dune.com/virtual_protocol/tax-checker).\
\
“프로젝트별 미분배 Virtual 내역”이라고 표시된 섹션으로 스크롤한 다음, 표를 정렬하여 보류 중인 분배를 확인하세요.

참고:

* 에이전트 토큰의 거래세가 1 $VIRTUAL 이상 누적되면 수수료 분배가 트리거됩니다. *(위 세부 내용 참고)*

**옵션 2: 계약을 통해 추적**

1. 토큰 스왑 → Tax Swapper\
   \
   세금이 부과되는 에이전트 토큰 거래는 Tax Swapper로 라우팅됩니다:\
   \
   0x8e0253dA409Faf5918FE2A15979fd878F4495D0E<br>
2. Swapper가 $VIRTUAL로 변환 → Tax Manager로 전송\
   \
   Tax Swapper는 세금이 부과된 토큰을 $VIRTUAL로 변환한 후, 결과를 Tax Manager로 보냅니다:\
   \
   0x7e26173192d72fd6d75a759f888d61c2cdbb64b1<br>
3. Tax Manager가 수수료를 $VIRTUAL로 분배\
   \
   Tax Manager는 수수료를 제작자와 플랫폼에 직접 $VIRTUAL로 분배합니다.

**옵션 3: Tax Manager 계약에서 읽기**

Tax Manager 프록시 계약에서 함수 5를 사용하세요:

[BaseScan - Tax Manager 계약](https://basescan.org/address/0x7e26173192d72fd6d75a759f888d61c2cdbb64b1#readProxyContract)

이 함수는 분배 잔액에 대한 현재 통계를 반환합니다.

</details>

<details>

<summary>Solana에서 에이전트 거래세는 어떻게 추적 및 처리되나요?</summary>

Solana에서는 세금 수익이 에이전트 지갑에서 창작자의 분배 지갑으로 직접 전송됩니다.

* 대상 지갑이 알려지지 않은 경우, 창작자는 확인을 위해 Virtuals 팀에 문의해야 합니다.
* 또는 LP 수수료 분배 지갑을 통해 분배를 모니터링할 수 있습니다:

  9WBoFXeAbskmi6aMK5jvyNgXVKeZrcVeFJtDBLikzdnm

</details>

<details>

<summary>거래세는 어떻게 처리 및 분배되나요?</summary>

각 에이전트 토큰에 대해 거래세가 누적됩니다. 에이전트 토큰의 거래세가 1 $VIRTUAL 이상에 도달하면 시스템이 이를 USDC로 교환한 후 토큰 소유자에게 분배합니다.

</details>

<details>

<summary>베스팅된 토큰은 어떻게 청구하나요?</summary>

베스팅된 토큰은 자동 분배되지 않습니다.

수령 지갑은 다음에 로그인해야 합니다 [app.virtuals.io](https://app.virtuals.io) 그리고 베스팅된 토큰을 수동으로 청구해야 합니다.

</details>

### 에이전트 토큰 출시 계획 및 설정

<details>

<summary>내 토큰은 출시에서 유동성 풀로 어떻게 이동하나요?</summary>

에이전트가 생성되면 거래가 시작됩니다. 본딩 커브는 42,000 $VIRTUAL에서 유동성 풀로 졸업합니다. 다음을 참조하세요 [Virtuals 출시 메커니즘](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/virtuals.md) 전체 수명 주기에 대해.

</details>

<details>

<summary>초기 스나이핑으로부터 출시를 어떻게 보호할 수 있나요?</summary>

생성 시 Anti-Sniper Protection을 활성화하세요. 선택한 보호 기간 동안 점진적으로 감소하는 세금이 적용됩니다. 다음을 검토하세요 [토큰 출시를 위한 Anti-Sniper Protection](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches.md) 를 설정하기 전에.

</details>

<details>

<summary>60 Days 모듈이란 무엇이며, 언제 사용해야 하나요?</summary>

60 Days는 선택 가능한 창업자 체험판입니다. 장기적으로 약속하기 전에 수요를 검증할 수 있습니다. 다음을 읽어보세요 [60 Days](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/60.md) 약정, 환불, 자금 조달 규칙을 확인하세요.

</details>

<details>

<summary>Fee Delegation은 내 프로젝트의 출시를 어떻게 지원하나요?</summary>

Fee Delegation을 사용하면 누구나 AI 에이전트 토큰을 출시할 수 있으며, 창작자 수수료 지분은 당신을 위해 예약됩니다.

런처는 X 핸들 또는 지갑 주소로 당신을 식별합니다. 창작자의 거래 수수료 70% 지분은 해당 신원에 연결된 잔액으로 적립됩니다. 런처는 이 잔액을 청구할 수 없습니다.

적립된 수수료를 청구하려면 Virtuals Protocol에서 연결된 프로필을 인증하세요. 이후 발생하는 수수료는 직접 귀하에게 전달됩니다. 다음을 참조하세요 [토큰 출시를 위한 Fee Delegation](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/ai.md).

</details>

<details>

<summary>유동성 풀이 생성되면 개발자 지갑은 왜 스테이킹된 토큰을 받나요?</summary>

Virtuals Protocol을 통해 유동성 풀이 출시되면 풀 생성자가 LP의 소유자가 됩니다. 영구성을 보장하고 유동성 유출을 방지하기 위해 모든 LP 토큰은 즉시 스테이킹되어 장기 잠금됩니다.

그 후 프로토콜은 스테이킹된 LP 포지션을 생성자의 지갑으로 다시 전송합니다. 이는 다음을 의미합니다:

* 소유권 → 생성자는 LP의 소유권을 유지합니다
* 잠긴 유동성 → LP 토큰은 수년간 스테이킹되며 인출할 수 없습니다
* 생태계 정렬 → 프로젝트는 소유권을 유지하는 동안 유동성은 영구적으로 보호됩니다

이 메커니즘은 Virtuals Protocol 전반에 걸쳐 표준화되어 있습니다. 모든 풀은 빌더에게는 소유권을, 프로토콜에는 보안을 부여하여 빌더와 참여자 모두를 보호하도록 설계되었습니다.

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/info-hub/virtuals-faq.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
