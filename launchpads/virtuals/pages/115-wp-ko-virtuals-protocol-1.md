# Virtuals Protocol - Virtuals Protocol 보안 정책 및 취약점 공개

> Source: https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/info-hub/security/virtuals-protocol-1
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Virtuals Protocol 보안 정책 및 취약점 공개

### 책임 있는 공개 및 버그 바운티 프로그램

Virtuals Protocol은 다음과 협력하고 있습니다 [Immunefi](https://immunefi.com/) 종합적인 버그 바운티 프로그램에 대해.

### 보안 취약점 신고하기

보안은 [Virtuals Protocol](https://app.virtuals.io/)에서 최우선 과제입니다. 2025년 8월 5일 기준으로 바운티로 30,000달러 이상을 지급했습니다. 취약점을 책임 있게 신고해 주시는 보안 연구자분들께 감사드립니다.

보안 취약점을 발견하셨다면 다음으로 이메일을 보내주세요 <security@virtuals.io> 다음 내용을 포함해:

* 취약점에 대한 자세한 설명
* 재현 절차
* 취약점의 잠재적 영향
* 파악하신 완화 방법이 있다면 그 방법

### 취약점 신고 응답 일정

* 초기 응답은 **24시간 이내** 에 귀하의 신고를 접수했음을 확인하기 위해
* 진행 상황에 대한 업데이트는 영업일 기준 3일마다 제공됩니다
* 중대한 문제는 15일 이내에 해결
* 공개 시점은 귀하와 조율하겠습니다

문제가 해결될 때까지 블로그, X 또는 다른 곳에 게시하지 마십시오. 공개는 귀하와 조율하겠습니다.

### 취약점 공개 범위

Virtuals Protocol이 관여하는 모든 것이 범위에 포함됩니다. 여기에는 다음이 포함됩니다:

* 스마트 계약
* SDK
* 프로덕션용 저장소 코드, 다음을 포함하여 [Virtuals Protocol](https://github.com/Virtual-Protocol) 및 [G.A.M.E](https://github.com/game-by-virtuals)

### 보안 연구자 표창 및 바운티 보상

중요 인프라 보안을 강화하는 보안 연구자를 인정합니다. 기여자는 다음과 같습니다:

* 보안 감사 표기에 이름이 올라갑니다
* 보안 문제 발견에 대해 바운티가 지급됩니다

#### 버그 바운티 보상이 결정되는 방식

* **설명 품질:** 잘 작성된 제출물을 제공하세요.
* **재현 가능성:** 개념 증명(POC)을 포함하세요. 코드, 스크립트, 세부 사항은 재현 가능성과 보상을 높입니다.
* **수정 품질:** 더 높은 보상을 받으려면 수정안을 포함하세요.

우리는 [CVSS 점수](https://nvd.nist.gov/vuln-metrics/cvss) 를 사용해 공정한 지급액을 결정합니다.

### 보안 문의

보안 문제는 다음으로 신고하세요 <security@virtuals.io>.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-protocol-whitepaper-ko/info-hub/security/virtuals-protocol-1.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
