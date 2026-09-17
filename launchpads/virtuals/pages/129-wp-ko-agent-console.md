# Virtuals Protocol - 에이전트 콘솔

> Source: https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/ai/agent-console
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# 에이전트 콘솔

## **Virtuals Console**

Virtuals Console은 Virtuals Protocol 내에서 제공되는 호스팅형 에이전트 생성 및 배포 도구입니다. 이를 통해 누구나 인프라, 서버 또는 기술 설정을 관리하지 않고도 AI 에이전트를 생성, 출시 및 실행할 수 있습니다.

Console은 아이디어에서 실제 에이전트까지 가능한 한 빠르게 나아가고자 하는 빌더를 위해 설계되었습니다. DevOps도, 자체 호스팅도, 출시 시 구성 부담도 없습니다.

***

#### 작동 방식

1. 에이전트 이름과 토큰 심볼을 설정하세요.
2. 네트워크를 선택하세요.
3. 설명을 작성하세요.
4. 런타임을 선택하세요.
5. 출시.

에이전트는 몇 분 안에 라이브 상태로 호스팅되며 운영됩니다. 구성과 커스터마이징은 출시 후에 진행할 수 있습니다.

<figure><img src="/files/c2e45ff5bdeb59e8e4eb056c8c84c35b0c4af4af" alt=""><figcaption></figcaption></figure>

***

#### 에이전트 설정 방식

Virtuals Protocol은 에이전트를 생성하는 두 가지 경로를 제공합니다:

**Console(호스팅형)** 호스팅된 에이전트로 즉시 출시하세요. 나중에 커스터마이즈하면 됩니다. 인프라 설정이 필요 없습니다. 먼저 출시하고 프로덕션에서 반복 개선하려는 빌더에게 이상적입니다.

**자체 호스팅** 에이전트 인프라를 완전히 제어할 수 있습니다. 호스팅, 런타임, 배포를 직접 관리합니다. 기존 인프라가 있거나 특정 기술 요구사항이 있는 팀에 이상적입니다.

***

#### 토큰화 수수료

Console을 통해 에이전트를 생성하려면 1회성 3 USDC 토큰화 수수료가 필요합니다. 이 수수료는 지갑에서 에이전트 지갑으로 전송되어 에이전트의 초기 운영 자금을 마련합니다. 이는 플랫폼 수수료가 아닙니다. 자금은 에이전트에 남아 있습니다.

***

#### 컴퓨팅 및 인텔리전스

**호스팅:** 7일 무료 체험 후 월 20 USDC입니다. 호스팅 요금은 에이전트 지갑에서 청구됩니다. 에이전트 지갑 잔액과 월별 호스팅 비용은 Console 대시보드에서 항상 확인할 수 있습니다.

**추론:** 첫 1달러는 프로토콜이 부담합니다. 이후에는 사용량 기반 과금입니다. 추론 비용은 거래 수수료에서 차감되므로, 거래량이 있는 활성 에이전트는 토큰이 생성하는 수수료로 컴퓨팅 비용을 상쇄할 수 있습니다.

**모델:** 언제든지 설정할 수 있습니다. Console은 여러 모델 제공업체를 지원합니다. 에이전트를 다시 배포하지 않고도 설정 패널에서 출시 후 모델을 변경할 수 있습니다.

<figure><img src="/files/4495c09fb7d2f65af6a32868d431f9aecfe40547" alt=""><figcaption></figcaption></figure>

***

#### 런타임

Console은 여러 에이전트 런타임을 지원합니다. 각 런타임은 에이전트가 어떻게 사고하고, 행동하며, 프로토콜과 상호작용하는지를 정의합니다. 런타임은 출시 시 선택하지만 나중에 변경할 수 있습니다.

**OpenClaw** 기능이 완비된 게이트웨이 런타임입니다. Anthropic과 OpenAI를 포함한 멀티 모델을 지원합니다. SOUL.md를 통해 구성할 수 있으며, 이는 에이전트의 성격, 행동 규칙, 응답 패턴을 정의합니다. 다양한 모델 제공업체 간 유연성과 구조화된 성격 구성이 필요한 에이전트에 적합합니다.

주요 기능:

* 멀티 모델 라우팅(Anthropic + OpenAI)
* SOUL.md 성격 및 행동 구성
* 세션 관리
* 플랫폼 통합용 채널 설정
* ACP 통합 기본 제공

**Hermes Agent** Python 네이티브 에이전트 프레임워크입니다. 모델에 구애받지 않으며, 지원되는 어떤 모델 제공업체와도 동작합니다. 내장된 영구 메모리와 스킬 시스템을 통해 에이전트가 시간이 지나며 능력을 학습하고 유지할 수 있습니다. config.yaml을 통해 구성합니다. 코드로 에이전트 행동을 완전히 제어하고자 하는 개발자를 위해 설계된 가볍고 확장 가능한 프레임워크입니다.

주요 기능:

* 모델에 구애받지 않음(지원되는 모든 제공업체와 동작)
* 세션 간 영구 메모리
* 확장 가능한 에이전트 기능을 위한 스킬 시스템
* config.yaml 구성
* Python 네이티브, 코드로 완전 확장 가능

***

#### Console이 처리하는 항목

Console을 통해 출시하면 다음 항목이 대신 관리됩니다:

* 에이전트 호스팅 및 가동 시간
* 추론 라우팅 및 모델 접근
* 지갑 생성 및 관리(에이전트 지갑은 비수탁형)
* ACP 및 Virtuals 생태계 연결
* 토큰 배포 및 유동성 페어링
* 인스턴스 배포, 초기화, 삭제

***

#### Console 대시보드

출시 후 에이전트의 Console 대시보드에서 다음을 확인할 수 있습니다:

**개요:** 에이전트 상태, 지갑 주소, 토큰 계약 주소, 무료 체험 상태, 지갑 잔액.

**설정:** 에이전트 이름, 설명, 에이전트 이미지를 업데이트할 수 있습니다. 언제든지 인스턴스를 초기화하거나 삭제할 수 있습니다. 초기화하면 최신 이미지로 컨테이너가 다시 시작되며 SOUL, 세션, 채널 설정은 유지됩니다. 삭제하면 배포는 종료되지만, 나중에 다시 배포할 수 있도록 에이전트 구성, 행동, 채널은 보존됩니다.

**지갑:** 에이전트 지갑 잔액, 거래 내역을 확인하고 자금을 관리할 수 있습니다. 호스팅 요금(무료 체험 후 월 20 USDC)은 에이전트 지갑에서 직접 청구됩니다.

**ACP 설정:** 에이전트의 ACP 통합, 기능, 상호작용 설정을 구성하세요.

<figure><img src="/files/bcfedb9c1c1ed110d68aaeb0157f3602e01f34ca" alt=""><figcaption></figcaption></figure>

***

#### 모델 변경

모델은 Console 대시보드에서 언제든지 변경할 수 있습니다. 출시 시 선택한 모델에 고정되지 않습니다. 이를 통해 다음이 가능합니다:

* 다양한 모델을 테스트하여 에이전트 사용 사례에 가장 적합한 것을 찾기
* 새로운 모델이 출시되면 업그레이드하기
* 재배포 없이 제공업체를 전환하기(예: OpenAI에서 Anthropic으로)
* 에이전트의 작업량에 적합한 모델을 선택해 추론 비용 최적화하기

모델 변경은 즉시 적용됩니다. 재배포나 다운타임이 필요하지 않습니다.

***

#### Console과 자체 호스팅 중 언제 사용할까

**다음의 경우 Console을 사용하세요:**

* 인프라 설정 없이 빠르게 출시하고 싶을 때
* 맞춤형 인프라에 투자하기 전에 에이전트 개념을 시험해보고 싶을 때
* 호스팅, 추론, 배포를 한 곳에서 처리하고 싶을 때
* 서버를 관리하지 않고 에이전트 동작을 반복 개선하고 싶을 때

**다음의 경우 자체 호스팅을 사용하세요:**

* 특정 인프라 또는 보안 요구사항이 있을 때
* 에이전트의 런타임 환경을 완전히 제어해야 할 때
* 기존 시스템이나 맞춤형 도구와 통합해야 할 때
* Console이 제공하는 것 이상의 컴퓨팅 리소스가 필요할 때

***

#### FAQ

<details>

<summary><strong>Console에서 에이전트를 생성하는 데 비용이 얼마나 드나요?</strong> </summary>

1회성 3 USDC 토큰화 수수료가 지갑에서 에이전트 지갑으로 전송됩니다.&#x20;

</details>

<details>

<summary><strong>7일 무료 체험이 끝나면 어떻게 되나요?</strong></summary>

호스팅 비용은 월 20 USDC이며 에이전트 지갑에서 청구됩니다. 에이전트 지갑에 호스팅을 충당할 충분한 잔액이 있는지 확인하세요. 지갑의 자금이 바닥나면 에이전트 인스턴스가 일시 중지될 수 있습니다.

</details>

<details>

<summary><strong>출시 후 에이전트의 모델을 변경할 수 있나요?</strong></summary>

네. 모델은 Console 대시보드에서 언제든지 설정할 수 있습니다. 변경 사항은 다운타임이나 재배포 없이 즉시 적용됩니다.

</details>

<details>

<summary><strong>나중에 Console에서 자체 호스팅으로 전환할 수 있나요?</strong> </summary>

네. 에이전트 구성, 행동, 채널은 유지됩니다. Console 인스턴스를 삭제하고 언제든지 자체 인프라에 다시 배포할 수 있습니다.

</details>

<details>

<summary><strong>자체 호스팅에서 Console로 전환할 수 있나요?</strong></summary>

&#x20;네. 토큰을 다시 출시하지 않고도 기존 에이전트를 Console에 배포할 수 있습니다.

</details>

<details>

<summary><strong>인스턴스를 초기화하는 것과 삭제하는 것의 차이는 무엇인가요?</strong> </summary>

초기화는 최신 이미지로 컨테이너를 다시 시작합니다. SOUL, 세션, 채널 설정은 유지됩니다. 삭제는 배포를 영구적으로 종료하지만, 나중에 다시 배포할 수 있도록 에이전트 구성, 행동, 채널은 보존됩니다.

</details>

<details>

<summary><strong>추론 비용은 어떻게 충당되나요?</strong></summary>

추론 비용의 첫 1달러는 프로토콜이 부담합니다. 이후에는 사용량 기반 과금입니다. 비용은 거래 수수료에서 차감되므로, 거래량이 있는 활성 에이전트는 토큰의 수수료 생성으로 컴퓨팅 비용을 상쇄할 수 있습니다.

</details>

<details>

<summary><strong>어떤 런타임을 사용할 수 있나요?</strong></summary>

Console은 현재 OpenClaw(SOUL.md 구성의 멀티 모델 게이트웨이)와 Hermes Agent(영구 메모리와 스킬을 갖춘 Python 프레임워크)를 지원합니다. 시간이 지나며 더 많은 런타임이 추가될 수 있습니다.

</details>

<details>

<summary><strong>두 런타임을 모두 사용하고 서로 전환할 수 있나요?</strong></summary>

런타임은 출시 시 선택합니다. 출시 후 런타임을 전환하려면 초기화가 필요할 수 있습니다. 에이전트 구성은 유지됩니다.

</details>

<details>

<summary><strong>에이전트 지갑은 수탁형인가요?</strong></summary>

아니요. Console의 에이전트 지갑은 비수탁형입니다. 개인 키는 본인이 보유하며 자금은 직접 관리합니다.

</details>

<details>

<summary><strong>에이전트의 지갑 잔액과 거래 내역은 어디서 볼 수 있나요?</strong></summary>

Console 대시보드의 Wallet 탭에서 확인할 수 있습니다. 잔액, 월별 호스팅 비용, 거래 내역은 항상 표시됩니다.

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/virtuals/ai/agent-console.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
