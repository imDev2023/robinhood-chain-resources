> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-bai-pi-shu/xin-xi-zhong-xin/an-quan/virtuals-protocol-an-quan-zheng-ce-yu-lou-dong-pi-lu.md).

# Virtuals Protocol 安全政策与漏洞披露

### 负责任披露与漏洞赏金计划

Virtuals Protocol 正在与 [Immunefi](https://immunefi.com/) 合作开展一项全面的漏洞赏金计划。

### 报告安全漏洞

安全是 [Virtuals Protocol](https://app.virtuals.io/)的首要任务。截止 2025 年 8 月 5 日，我们已支付超过 30,000 美元的赏金。我们感谢负责任地报告漏洞的安全研究人员。

如果您发现安全漏洞，请发送邮件至 <security@virtuals.io> 并附上：

* 对漏洞的详细描述
* 复现步骤
* 漏洞的潜在影响
* 您已识别出的任何可能的缓解方法

### 漏洞报告响应时间表

* 在 **24 小时** 内初步回复，以确认我们已收到您的报告
* 每 3 个工作日提供一次进展更新
* 严重问题最迟在 15 天内解决
* 我们将与您协调公开披露的时间

在我们修复问题之前，请不要在博客、X 或其他任何地方发布。我们将与您协调公开披露。

### 漏洞披露范围

Virtuals Protocol 所涉及的一切都在范围内。这包括：

* 智能合约
* SDK
* 生产就绪的仓库代码，包括 [Virtuals Protocol](https://github.com/Virtual-Protocol) 和 [G.A.M.E](https://github.com/game-by-virtuals)

### 安全研究人员认可与赏金奖励

我们认可那些提升关键基础设施安全性的安全研究人员。贡献者将：

* 在安全致谢中被列名
* 因发现安全问题而获得赏金

#### 漏洞赏金奖励如何确定

* **描述质量：** 请提交一份写作清晰的报告。
* **可复现性：** 请包含概念验证（POC）。代码、脚本和细节都有助于提高可复现性和奖励。
* **修复质量：** 包含修复方案可获得更高奖励。

我们使用 [CVSS 评分](https://nvd.nist.gov/vuln-metrics/cvss) 来确定公平的支付金额。

### 安全联系方式

将安全问题报告至 <security@virtuals.io>.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-bai-pi-shu/xin-xi-zhong-xin/an-quan/virtuals-protocol-an-quan-zheng-ce-yu-lou-dong-pi-lu.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
