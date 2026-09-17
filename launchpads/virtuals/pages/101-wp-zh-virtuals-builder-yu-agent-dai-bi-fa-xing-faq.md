# Virtuals Protocol - Virtuals Builder 与 Agent 代币发行 FAQ

> Source: https://whitepaper.virtuals.io/virtuals-bai-pi-shu/xin-xi-zhong-xin/virtuals-builder-yu-agent-dai-bi-fa-xing-faq
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Virtuals Builder 与 Agent 代币发行 FAQ

{% hint style="info" %}
本 FAQ 反映的是截至 2026 年 8 月 14 日的当前系统。随着协议迭代，细节可能会随时间演变。
{% endhint %}

{% hint style="info" %}

## 找不到你需要的内容？

通过我们的工单联系 [Discord 支持](https://discord.com/invite/virtualsio).
{% endhint %}

### Virtuals Protocol 构建者与代理代币发币 FAQ

查找有关在 Virtuals Protocol 上启动并代币化代理的答案。本 FAQ 涵盖发币支持、交易税分配以及归属代币领取。

<details>

<summary>如何在 Virtuals Protocol 上启动/代币化一个代理？</summary>

请先查看 [Virtuals Launch Mechanics](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/virtuals-qi-dong-ji-zhi.md)。其中涵盖创建、交易、流动性和毕业。

</details>

<details>

<summary>如何获得我的代理发币支持？</summary>

请参阅 [Agent Launch Support](/virtuals-bai-pi-shu/xin-xi-zhong-xin/gou-jian-zhe-zhong-xin/zhi-neng-ti-fa-bu-zhi-chi.md) 获取营销和技术支持资源。

</details>

<details>

<summary>在 Base 上如何跟踪和处理交易税？</summary>

要跟踪 Base 上的交易税流向，有三种方法：<br>

**选项 1：从 Virtuals Tax Checker Dashboard 跟踪**\
\
你可以通过官方的 [Virtuals Tax Checker Dashboard](https://dune.com/virtual_protocol/tax-checker)跟踪你的代理交易费用累积和分配状态。\
\
向下滚动到标注为“按项目划分的未分配 Virtual 明细”的部分，并对表格排序以查看待分配项。

注意：

* 当某个代理代币的交易税累积达到 1 $VIRTUAL 或以上时，将触发费用分配。 *（上方详情）*

**选项 2：通过合约追踪**

1. 代币交换到 Tax Swapper\
   \
   产生税费的代理代币交易将路由到 Tax Swapper：\
   \
   0x8e0253dA409Faf5918FE2A15979fd878F4495D0E<br>
2. Swapper 转换为 $VIRTUAL → 发送至 Tax Manager\
   \
   Tax Swapper 会将带税代币转换为 $VIRTUAL，然后将输出发送至 Tax Manager：\
   \
   0x7e26173192d72fd6d75a759f888d61c2cdbb64b1<br>
3. Tax Manager 以 $VIRTUAL 分发费用\
   \
   Tax Manager 会直接以 $VIRTUAL 向创作者和平台分发费用。

**选项 3：从 Tax Manager 合约读取**

在 Tax Manager 代理合约上使用函数 5：

[BaseScan - Tax Manager 合约](https://basescan.org/address/0x7e26173192d72fd6d75a759f888d61c2cdbb64b1#readProxyContract)

此函数会返回分配余额的当前统计信息。

</details>

<details>

<summary>在 Solana 上如何跟踪和处理代理交易税？</summary>

在 Solana 上，税费收益会直接从代理钱包发送到创作者的分配钱包。

* 如果目标钱包未知，创作者应联系 Virtuals 团队进行验证。
* 或者，也可以通过 LP 费用分配钱包进行监控：

  9WBoFXeAbskmi6aMK5jvyNgXVKeZrcVeFJtDBLikzdnm

</details>

<details>

<summary>交易税是如何处理和分配的？</summary>

交易税会在每个代理代币中累积。一旦某个代理代币的交易税达到 1 $VIRTUAL 或更多，系统就会将其兑换为 USDC，并将其分配给代币持有者。

</details>

<details>

<summary>如何领取归属代币？</summary>

归属代币不会自动分发。

接收钱包必须登录 [app.virtuals.io](https://app.virtuals.io) 并手动领取任何归属代币。

</details>

### 代理代币发币规划与配置

<details>

<summary>我的代币如何从发币阶段进入流动性池？</summary>

代理创建后即可开始交易。当绑定曲线达到 42,000 $VIRTUAL 时，会进入流动性池毕业。请参阅 [Virtuals Launch Mechanics](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/virtuals-qi-dong-ji-zhi.md) 了解完整生命周期。

</details>

<details>

<summary>如何保护我的发币免受早期抢跑？</summary>

在创建时启用防抢跑保护。它会在你选择的保护窗口内施加递减税率。配置前请查看 [代币发币防抢跑保护](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/dai-bi-fa-bu-fan-ju-ji-bao-hu.md) 。

</details>

<details>

<summary>什么是 60 Days 模块，何时应使用？</summary>

60 Days 是一个可选的创始人试用期。它让你在做出长期承诺前验证市场需求。请阅读 [60 Days](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/60-tian.md) 了解承诺、退款和融资规则。

</details>

<details>

<summary>费用委托如何为我的项目发币提供支持？</summary>

费用委托允许任何人发行 AI 代理代币，同时为你保留创作者费用份额。

发币器会通过你的 X 账号或钱包地址识别你。创作者 70% 的交易费用份额会累积到与你身份关联的余额中。发币器无法领取这部分余额。

请在 Virtuals Protocol 上验证关联资料以领取累积费用。之后的费用将直接流向你。请参阅 [代币发币费用委托](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/mian-xiang-ai-zhi-neng-ti-dai-bi-fa-xing-de-fei-yong-wei-tuo.md).

</details>

<details>

<summary>为什么在创建流动性池时，开发者钱包会收到质押代币？</summary>

当通过 Virtuals Protocol 创建流动性池时，池创建者是 LP 的所有者。为确保永久性并防止流动性被提取，所有 LP 代币都会立即质押并长期锁定。

随后，协议会将已质押的 LP 仓位转回创作者的钱包。这意味着：

* 所有权 → 创作者保留对 LP 的所有权
* 锁定流动性 → LP 代币会质押多年，且无法提取
* 生态系统协同 → 流动性永久安全，同时项目保留所有权权益

这一机制在 Virtuals Protocol 中是标准化的。每个池都设计为由创作者拥有，但由协议保障，以保护构建者和参与者。

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-bai-pi-shu/xin-xi-zhong-xin/virtuals-builder-yu-agent-dai-bi-fa-xing-faq.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
