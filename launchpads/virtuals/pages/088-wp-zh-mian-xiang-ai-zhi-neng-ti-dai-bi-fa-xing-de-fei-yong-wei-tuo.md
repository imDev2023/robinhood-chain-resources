# Virtuals Protocol - 面向 AI 智能体代币发行的费用委托

> Source: https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/mian-xiang-ai-zhi-neng-ti-dai-bi-fa-xing-de-fei-yong-wei-tuo
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# 面向 AI 智能体代币发行的费用委托

### 什么是费用委托？

费用委托是一种用于无需许可的 AI 代理代币发行的启动模块。它将代币创建者与指定的创作者费用接收方分离开来。

它支持由社区成员、支持者和协作者发起的发行。指定的构建者将获得创作者费用份额。

### 费用委托如何运作？

在创建代币时，创建者启用费用委托。他们选择构建者的费用接收身份：

* **X 账号** —— 构建者的 `@用户名`.
* **钱包地址** —— 构建者的链上地址。

随后，代币即可开始交易。交易需支付 1% 的交易费。费用委托会为指定身份保留创建者 70% 的份额。剩余的 30% 归 Virtuals Treasury。

在代币交易期间，保留余额会持续累积。指定的构建者在完成资料验证后即可领取。

### 社区成员可以为我的项目发起 AI 代理代币吗？

可以。费用委托允许社区成员发起 AI 代理代币，同时将其创作者费用份额保留给你。

这可以在没有事先协调的情况下发生。创建者会使用你的 X 账号或钱包地址来识别你。为你的身份保留的费用仍归你领取。

### 我如何领取委托的交易费用？

1. 登录 Virtuals Protocol。
2. 验证与已委托的 X 账号或钱包地址关联的资料。
3. 领取累计余额。

验证完成后，未来的创作者费用将直接流向你。

### 常见问题

<details>

<summary>代币创建者可以领取委托给我的费用吗？</summary>

不可以。只有在代币创建时被标识出的构建者才能领取保留的创作者费用份额。

</details>

<details>

<summary>在我领取资料之前，我可以收到费用吗？</summary>

可以。费用会累积到与你的 X 账号或钱包地址关联的保留余额中。验证关联资料后即可领取。

</details>

<details>

<summary>费用委托为构建者保留多少费用份额？</summary>

费用委托会保留 1% 交易费中的创建者 70% 份额。Virtuals Treasury 获得剩余的 30%。

</details>

有关发行生命周期和交易费用的详情，请参见 [Virtuals 发行机制](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/virtuals-qi-dong-ji-zhi.md).


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/mian-xiang-ai-zhi-neng-ti-dai-bi-fa-xing-de-fei-yong-wei-tuo.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
