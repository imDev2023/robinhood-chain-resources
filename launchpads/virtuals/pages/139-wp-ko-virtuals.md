# Virtuals Protocol - Virtuals 출시 메커니즘

> Source: https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/virtuals
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Virtuals 출시 메커니즘

### 작동 방식

### 1. [생성](https://app.virtuals.io/create) 단계

창립자들은 Virtuals 플랫폼에서 자신의 에이전트를 무료로 생성하여 출시를 시작합니다. 일부 모듈에는 활성화 수수료가 부과됩니다: Launch Radar(100 $VIRTUAL), Capital Formation(10 $VIRTUAL), SOL Launch(10 $VIRTUAL). 그 외 모든 모듈은 무료입니다.

생성 과정에서 창립자들은 모듈을 켜거나 꺼서 출시 구성을 설정합니다. 각 모듈은 독립적입니다. 어떤 모듈도 작동하기 위해 다른 모듈을 필요로 하지 않습니다.

일단 생성되면, 에이전트 런치 페이지가 Virtuals Protocol 플랫폼에 즉시 게시되며, 다음을 표시합니다:

* 토큰 공급량 및 분배 파라미터
* 활성화된 모듈과 그 설정
* 창립 팀 세부 정보
* 제품 세부 정보 및 에이전트 정보

***

### 2. 출시 및 초기 거래

에이전트가 생성되면 거래가 자동으로 시작됩니다.

누구나 Virtuals Protocol 플랫폼을 통해 직접 거래할 수 있습니다. 사전 판매, 화이트리스트, 또는 제한된 할당은 없습니다.

#### **스나이퍼 세금 메커니즘**&#x20;

**안티 스나이퍼 보호가 활성화된 경우:**

세율은 99%에서 시작하여 창립자가 선택한 보호 기간 동안 1%의 기본 거래 세율까지 점차 감소합니다. 창립자는 생성 시 미리 설정된 기간을 선택합니다: 0초, 60초, 10분, 또는 98분.

* 창립자는 또한 보호가 거래의 어느 쪽에 적용될지 선택합니다: 매수 전용, 매도 전용, 또는 매수와 매도 모두. 기본적으로 보호는 매수 측 거래에만 적용되며, 매도 측 및 매수-매도 결합 보호는 선택 사항입니다.
* 보호 기간 동안 징수된 모든 스나이퍼 세금은 온체인에서 에이전트 토큰을 재매수하는 데 자동으로 사용됩니다.
* 재매수된 토큰은 3개월 클리프와 9개월 선형 베스팅 일정에 따라 팀 지갑으로 분배됩니다.
* 이 구조는 봇과 기회주의적 스나이퍼로부터 초기 유동성을 보호하는 동시에, 초기 변동성을 프로젝트 창립자에게 장기적인 정렬로 전환합니다.

안티 스나이퍼 보호가 활성화되지 않으면 거래 세율은 출시 시점부터 1%로 고정됩니다.

{% hint style="info" %}

#### **스나이퍼 세금 메커니즘 일반 FAQ**

참조할 수 있습니다 [안티 스나이퍼 보호 FAQ](/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches.md#anti-sniper-protection-faq)
{% endhint %}

***

### 3. 출시 생애주기

생성자가 에이전트를 배포하고 본딩 커브를 초기화합니다. 토큰은 Virtuals 플랫폼에서 즉시 거래 가능해집니다. 첫날부터 1% 거래 수수료가 적용됩니다:

* 70%는 에이전트 생성자에게 분배
* 30%는 Virtuals Treasury로

60일 모듈을 사용하는 출시의 경우, 창립자의 70% 지분은 시험 기간 동안 잠기며 약속 후에만 해제됩니다. 창립자가 약속하지 않으면 이 할당은 환불 풀로 재배정됩니다.

생성자의 70% 지분은 Fee Delegation 모듈을 통해 청구 전에 재지정할 수 있습니다: \[토큰 출시를 위한 수수료 위임] 참조.

***

### 4. 유동성 모델

거래가 계속되면 본딩 커브가 자동으로 $VIRTUAL 유동성을 축적합니다.

총 유동성이 42,000 $VIRTUAL에 도달하면, 유동성 풀이 자동으로 생성되고 Uniswap V2에서 에이전트 토큰과 페어링됩니다.

풀이 설정된 후 사용자는 Virtuals 플랫폼에서 직접 토큰을 거래하거나, 프로토콜에 통합된 지원 DEX, 애그리게이터, 또는 트레이딩 봇을 통해 거래할 수 있습니다.

이는 다음을 보장합니다:

* 지속적이고 검증 가능한 온체인 유동성 성장
* 본딩 커브에서 공개 시장으로의 원활한 전환
* 모든 지원 거래 환경 전반의 완전한 호환성

{% hint style="success" %}
에이전트 졸업 중 생성된 모든 유동성 풀(LP) 토큰은 10년(10년) 장기 잠금 하에 자동으로 스테이킹됩니다. 이 메커니즘의 목적은 유동성의 영속성을 보장하고, 출시 후 유동성 통제에 대한 모호성을 제거하며, Virtuals를 통해 출시된 모든 에이전트가 장기적이고 추출 불가능한 유동성 보장을 바탕으로 운영되도록 하는 것입니다.
{% endhint %}

***

### **5. 하이퍼부스트**

하이퍼부스트는 Virtuals에서 본딩되는 모든 토큰에 자동으로 적용되는 졸업 후 보상 메커니즘입니다. 모듈 활성화나 창립자 설정은 필요하지 않습니다.

**메커니즘**

과거에는 토큰 공급의 일부가 공개 시장 거래로의 일관된 전환을 유지하기 위해 졸업 시점에 비활성 상태로 남아 있었습니다. 하이퍼부스트는 이 공급을 졸업 후 시장 참여자를 위한 시간 분할 보상으로 배포합니다.

졸업 시 보상 할당은 14일 분배 일정에 들어갑니다:

* 총 보상 할당의 1/14이 14일 동안 매일 해제됩니다
* 일일 보상은 두 가지 범주로 분배됩니다: 거래, 그리고 해당 날짜의 거래량에서 각 지갑이 차지하는 비율에 따라 배분된 거래량, 그리고 토큰에 대해 게시된 콘텐츠.&#x20;
* 보상은 배포된 후 언제든지 청구할 수 있으며, 베스팅이나 잠금은 없습니다

할당 규모 및 콘텐츠 평가 기준을 포함한 보상 파라미터는 프로토콜에 의해 설정되며 분배의 무결성을 유지하기 위해 조정될 수 있습니다.

**목적**

75% 이상의 토큰은 졸업 시 가장 높은 거래량을 기록하는 24시간을 가집니다. 하이퍼부스트는 거래자에게 제공한 거래량에 대한 보상을 제공하고, 보유자는 졸업 후 지속적인 유동성의 혜택을 받으며, 창립자는 졸업 후 확장된 가시성 기간을 얻도록 하는 두 번째 인센티브 창을 도입하여 이 피크를 넘어 시장 참여를 확장합니다.

**자격**

7월 27일 오후 4시 UTC 이후 졸업하는 모든 토큰은 자동으로 하이퍼부스트에 들어갑니다.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/capital-formation-layer/virtuals.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
