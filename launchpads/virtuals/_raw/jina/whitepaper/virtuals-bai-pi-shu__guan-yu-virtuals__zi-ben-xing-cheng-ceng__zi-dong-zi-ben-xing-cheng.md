> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/zi-dong-zi-ben-xing-cheng.md).

# 自动资本形成

### 用于代币发行的自动化资本形成（ACF）

激活自动化资本形成模块需要支付 10 $VIRTUAL 费用。

激活后，50% 的代币供应将保留给创始团队。该分配在自动化资本形成和团队分配之间拆分。

<figure><img src="/files/5e9ac40d14e2e8fdfe58338441bee2b1c482a78f" alt="Automated Capital Formation token allocation for Virtuals Protocol AI agent token launches"><figcaption></figcaption></figure>

***

### ACF 代币分配和创始人融资（25%）

当项目达到 200 万美元 FDV 时，ACF 开始自动团队分配。分配将通过在每增加 10 万美元 FDV 时连续创建流动性池来进行，直到 1.6 亿美元 FDV 为止。

* ACF 收益将直接以 $USDC 支付给创始人。
* 分配是自动且透明的。它严格与市场估值挂钩。
* 只有当其代币表现出市场增长时，创始人才能获得流动性。
* 订单通过自然价格发现机制成交。

### 按 FDV 区间估算的资本形成

| 估值区间（美元，USD）             | 已售出（%） | 平均售出估值（美元，USD） | 募集金额（美元，USD） | 累计募集金额（美元，USD） |
| ------------------------ | ------ | -------------- | ------------ | -------------- |
| 2,000,000 - 10,000,000   | 5%     | 6,000,000      | 300,000      | 300,000        |
| 10,000,000 - 20,000,000  | 5%     | 15,000,000     | 750,000      | 1,050,000      |
| 20,000,000 - 40,000,000  | 5%     | 30,000,000     | 1,500,000    | 2,550,000      |
| 40,000,000 - 80,000,000  | 5%     | 60,000,000     | 3,000,000    | 5,550,000      |
| 80,000,000 - 160,000,000 | 5%     | 120,000,000    | 6,000,000    | 11,550,000     |

***

### 团队代币分配与归属（25%）

团队代币分配中剩余的 25% 在 TGE 后锁定一年。随后进入为期六个月的线性归属期。

如果项目在一年内达到 1.6 亿美元 FDV，则归属将立即开始。之后仍遵循为期六个月的线性归属计划。

这有助于强化创始人的责任感，并支持 AI 代理的长期发展。

***

### 团队通过 Pre-buy 模块进行的初始购买

当 [Pre-buy](/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/wei-ai-zhi-neng-ti-fa-bu-yu-gou-dai-bi.md) 模块被激活时，团队可在创建期间购买总供应量的最多 50%。这有助于稳定早期代币市场，防止抢跑，并传递创始人信心的信号。

所有预购代币都会在代币经济学中披露。它们默认遵循至少一个月的悬崖期和 12 个月的归属计划。团队可在上线前调整这些参数。

如果创始人在 TGE 时自购金额高于 200 万美元 FDV，则相应的 ACF 代币数量将重新归类为团队分配。它们不会立即分发。

这可防止创始人过早参与加速资本释放。它保持长期增长一致性和责任约束。

### 预购限制与代币重新上线

一旦 Agent Card 上线，团队若不重新发布 AI 代理，就无法执行 Pre-buy。

若要在 Agent Card 部署后添加 Pre-buy，团队必须取消现有代币发行并创建一个新的发行。此取消和重新发行功能可在计划上线前一天之前使用。模块费用不予退还。

这使得早期团队代币获取保持有意、透明且公平。它保护参与者并维护市场完整性。


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/virtuals-bai-pi-shu/guan-yu-virtuals/zi-ben-xing-cheng-ceng/zi-dong-zi-ben-xing-cheng.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
