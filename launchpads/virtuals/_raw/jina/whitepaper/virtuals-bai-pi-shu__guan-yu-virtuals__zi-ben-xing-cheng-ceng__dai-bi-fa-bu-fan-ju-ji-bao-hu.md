> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/dai-bi-fa-bu-fan-ju-ji-bao-hu.md).

# 代币发布反狙击保护

### 代币发行反狙击保护

反狙击保护是 Virtuals Protocol 为 AI 代理代币发行提供的免费上线模块。它会在 TGE 时对买入端施加动态税率。这能减少早期交易中的机器人活动和机会主义抢跑。

该模块默认启用，且免费。

<figure><img src="/files/92c2b51264e658d1864d355fcc698e906948ccd0" alt=""><figcaption><p>在 TGE 保护窗口期间动态递减的买入税。</p></figcaption></figure>

### 动态狙击税的工作原理

狙击税在 TGE 时从 99% 开始。

* 它会在创始人选择的保护窗口内逐步降至 1% 的基础交易税。
* 创始人可选择税率适用的交易方向：
  * **买入：** 防止机器人在买入时抢跑代币。这是默认选项。
  * **卖出：** 抑制早期持有者在流动性不足时抛售。
  * **买入与卖出：** 将递减税率同时应用于双向交易。
* 在窗口期间收取的狙击税将用于自动链上代理代币回购。
* 回购的代币将归入团队钱包。它们遵循 3 个月 cliff 和 9 个月线性归属计划。

这种代币发行保护有助于保护早期流动性免受机器人和狙击者侵害。它将早期交易税转化为项目创始人与项目长期一致的激励。

### 配置 TGE 保护窗口

创始人在创建阶段设置保护窗口和适用方向（买入、卖出或买入与卖出），可从四个预设窗口中选择。税率递减会自动调整，在所选窗口结束时降至 1% 的基础税率。

可用窗口：

* **0 秒：** 不适用反狙击保护。交易税从上线起保持 1%。
* **60 秒：** 税率在 1 分钟内从 99% 递减至 1%。
* **10 分钟：** 税率在 10 分钟内从 99% 递减至 1%。
* **98 分钟：** 税率在 98 分钟内从 99% 递减至 1%，约每分钟 1%。

当前 60 秒和 10 分钟预设仅适用于买入侧交易。98 分钟预设可应用于买入侧、卖出侧或两者，从而让创始人对上线保护配置拥有最细粒度的控制。

### 反狙击保护常见问题

<details>

<summary>狙击税回购何时开始？</summary>

一旦配置的保护窗口结束，且受保护一侧（买入或卖出）的税率降至 1% 的基础水平，回购就会自动开始。

</details>

<details>

<summary>收取的狙击税会一次性用于一次回购吗？</summary>

不会。链上回购会在 24 小时内逐步执行。

</details>

<details>

<summary>我可以在上线后更改反狙击保护窗口吗？</summary>

不可以。保护窗口在创建时设定，在 Agent Launch Page 发布后无法修改。

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/dai-bi-fa-bu-fan-ju-ji-bao-hu.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
