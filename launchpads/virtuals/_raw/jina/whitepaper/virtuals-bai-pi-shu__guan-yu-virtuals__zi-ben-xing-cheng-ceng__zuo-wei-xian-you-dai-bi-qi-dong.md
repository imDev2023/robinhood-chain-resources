> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/zuo-wei-xian-you-dai-bi-qi-dong.md).

# 作为现有代币启动

此模块允许拥有已部署代币的团队将其接入 Virtuals Protocol，并解锁完整的 AI 代理功能套件。该模块免费。

### 工作原理

创始人提供其现有代币合约地址，以注入流动性池并确定其上线估值。

这使得：

* 将现有社区和代币迁移到 Virtuals 生态系统中
* 访问 ACP 以及完整的代理基础设施
* 与 $VIRTUAL 流动性配对
* 在 Virtuals 平台上上线

适用最低 FDV 要求。上线参数将在 TGE 前最终确定。

### 配置

在创建过程中，创始人需要指定：

* 现有代币合约地址
* 期望的上线 FDV
* 流动性注入参数


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/zuo-wei-xian-you-dai-bi-qi-dong.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
