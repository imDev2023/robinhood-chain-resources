> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/virtuals-qi-dong-ji-zhi.md).

# Virtuals 启动机制

### 工作原理

### 1. [创建](https://app.virtuals.io/create) 阶段

创始人可在 Virtuals 平台上免费创建他们的代理，从而发起上线。某些模块需支付激活费：Launch Radar（100 $VIRTUAL）、Capital Formation（10 $VIRTUAL）、SOL Launch（10 $VIRTUAL）。其余所有模块均免费。

在创建过程中，创始人通过开启或关闭各个模块来配置其上线。每个模块都是独立的，没有任何模块需要其他模块才能运行。

创建完成后，Agent Launch Page 会立即在 Virtuals Protocol 平台上发布，展示：

* 代币供应与分配参数
* 已启用的模块及其配置
* 创始团队详情
* 产品详情和代理信息

***

### 2. 上线与早期交易

代理创建后，交易会自动开启。

任何人都可以直接通过 Virtuals Protocol 平台进行交易。没有预售、白名单或受限分配。

#### **狙击税机制**&#x20;

**如果已启用反狙击保护：**

税率从 99% 开始，并在创始人选定的保护窗口内逐步衰减至 1% 的基础交易税。创始人在创建时可选择预设窗口：0 秒、60 秒、10 分钟或 98 分钟。

* 创始人还需选择保护适用于交易的哪一侧：仅买入、仅卖出，或买入与卖出都适用。默认情况下，保护仅适用于买入侧交易；卖出侧以及买卖双向保护需主动选择开启。
* 在保护窗口内收取的所有狙击税都会自动用于链上回购代理代币。
* 回购的代币将按照 3 个月悬崖期和 9 个月线性归属计划分配到团队钱包。
* 这一结构在保护早期流动性免受机器人和机会型狙击者影响的同时，将初始波动转化为项目创始人的长期一致性。

如果未启用反狙击保护，则交易税从上线开始固定为 1%。

{% hint style="info" %}

#### **狙击税机制常见问题**

可参考 [反狙击保护常见问题](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/dai-bi-fa-bu-fan-ju-ji-bao-hu.md#anti-sniper-protection-faq)
{% endhint %}

***

### 3. 上线生命周期

创建者部署代理并初始化其绑定曲线。代币会立即在 Virtuals 平台上开始交易。自第一天起适用 1% 的交易费：

* 70% 分配给代理创建者
* 30% 分配给 Virtuals 金库

对于使用 60 天模块的上线，创始人的 70% 份额会在试用期内被锁定，并且仅在确认承诺后释放。如果创始人未承诺，则该分配会转入退款池。

在领取前，创建者的 70% 份额可通过费用委托模块重新定向：参见 \[代币上线的费用委托]。

***

### 4. 流动性模型

随着交易持续进行，绑定曲线会自动累积 $VIRTUAL 流动性。

当总流动性达到 42,000 $VIRTUAL 时，系统会自动创建一个流动性池，并在 Uniswap V2 上与代理代币配对。

池建立后，用户可以直接在 Virtuals 平台上交易该代币，也可以通过任何与协议集成、受支持的 DEX、聚合器或交易机器人进行交易。

这确保了：

* 持续、可验证的链上流动性增长
* 从绑定曲线到公开市场的无缝过渡
* 在所有受支持的交易环境中完全兼容

{% hint style="success" %}
在代理升级毕业期间生成的所有流动性池（LP）代币都会自动质押，并锁定十（10）年。该机制旨在保证流动性的永久性，消除上线后流动性控制的不确定性，并确保所有通过 Virtuals 上线的代理都具备长期、不可抽取的流动性保障。
{% endhint %}

***

### **5. Hyperboost**

Hyperboost 是一种毕业后的奖励机制，会自动适用于每一个在 Virtuals 上完成绑定的代币。无需激活任何模块，也无需创始人配置。

**机制**

历史上，代币供应的一部分会在毕业时保持闲置，以维持向公开市场交易的平稳过渡。Hyperboost 将这部分供应作为面向毕业后市场参与者的按时释放奖励进行部署。

毕业后，奖励分配将进入为期 14 天的发放计划：

* 总奖励分配的 1/14 会在 14 天内每天释放一次
* 每日奖励分为两类分配：交易，按钱包在当日交易量中的占比分配；以及围绕该代币发布的内容。&#x20;
* 奖励一经发放，随时可领取，无归属期或锁定期

奖励参数，包括分配规模和内容评估标准，由协议设定，并可调整以维护分发的完整性。

**目的**

超过 75% 的代币在毕业时记录下其最高成交量的 24 小时。Hyperboost 通过引入第二个激励窗口来延续这一高峰之后的市场参与：交易者因提供交易量而获得奖励，持有者受益于毕业后持续的流动性，而创始人在毕业后也获得更长的曝光期。

**资格**

每个在 UTC 时间 7 月 27 日下午 4 点之后毕业的代币都会自动进入 Hyperboost。


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/virtuals-qi-dong-ji-zhi.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
