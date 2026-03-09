# 律师事务所 AI 培训课件 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 制作一套完整的律师AI培训 reveal.js 课件和配套讲稿

**Architecture:** 单HTML文件（slides.html）使用 reveal.js CDN，内联CSS自定义深色主题。配套 speaker-notes.md 提供每页讲解要点和demo操作步骤。

**Tech Stack:** reveal.js 5.x (CDN), HTML/CSS, Markdown

---

### Task 1: 创建 reveal.js HTML骨架 + 自定义深色主题

**Files:**
- Create: `slides.html`

**Step 1: 创建HTML骨架**

创建 `slides.html`，包含：
- reveal.js 5.x CDN 引入（CSS + JS）
- 使用 `night` 主题作为基础
- 自定义CSS覆盖：
  - 背景色：深蓝灰 `#1a1a2e`
  - 标题字体大小放大，正文大字少字
  - 术语高亮色：亮青色 `#00d4ff` 用于英文术语
  - 幻灯片间距和内边距优化
  - reveal.js speaker notes 启用（按 `S` 键打开演讲者视图）
- 仅包含标题页（封面）和目录页作为初始内容

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <title>AI 赋能法律实务 — 从 Chat 到 Agent</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/dist/reveal.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/dist/theme/night.css">
  <style>
    :root {
      --r-background-color: #1a1a2e;
      --r-main-font-size: 32px;
      --r-heading1-size: 2.2em;
      --r-heading2-size: 1.6em;
      --r-heading3-size: 1.2em;
    }
    .reveal { font-family: "PingFang SC", "Microsoft YaHei", sans-serif; }
    .reveal h1, .reveal h2, .reveal h3 { font-weight: 700; }
    .term { color: #00d4ff; font-weight: bold; }
    .highlight { color: #ffd700; }
    .reveal .slide-number { font-size: 14px; }
    .reveal section { text-align: left; padding: 40px; }
    .reveal section.center { text-align: center; }
    .reveal ul { line-height: 1.8; }
    .reveal li { margin-bottom: 0.3em; }
    .demo-slide { border-left: 4px solid #ffd700; padding-left: 30px !important; }
    .demo-badge {
      background: #ffd700; color: #1a1a2e; padding: 4px 16px;
      border-radius: 4px; font-size: 0.6em; font-weight: bold;
      display: inline-block; margin-bottom: 20px;
    }
    .tool-card {
      background: rgba(255,255,255,0.05); border-radius: 12px;
      padding: 20px; margin: 10px 0;
    }
    .vs { font-size: 1.5em; color: #ffd700; margin: 0 20px; }
    .section-divider h2 { font-size: 2em; }
    .section-divider p { font-size: 1.2em; opacity: 0.7; }
  </style>
</head>
<body>
  <div class="reveal">
    <div class="slides">
      <!-- 封面 + 目录在此 -->
      <!-- 后续Task逐步填充各section -->
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/dist/reveal.js"></script>
  <script>
    Reveal.initialize({
      hash: true,
      slideNumber: 'c/t',
      showNotes: false,
      width: 1280,
      height: 720,
      margin: 0.04,
      transition: 'slide',
    });
  </script>
</body>
</html>
```

封面页内容：
```html
<section class="center">
  <h1>AI 赋能法律实务</h1>
  <h3>从 <span class="term">Chat</span> 到 <span class="term">Agent</span></h3>
  <p style="opacity:0.6; margin-top:40px;">2026 · 律师事务所内部培训</p>
</section>
```

目录页内容：
```html
<section>
  <h2>今天聊什么</h2>
  <ol style="font-size:0.9em;">
    <li><strong>AI现在能做什么了</strong> — 你可能不知道的变化</li>
    <li><strong>Chat vs Agent</strong> — 为什么聊天只是起点</li>
    <li><strong>工具生态</strong> — Plugin / Skill / MCP</li>
    <li><strong>法律AI工具版图</strong> — 选对工具很重要</li>
    <li><strong>实战演示</strong> — 合同审查、法律研究、文书起草</li>
    <li><strong>提示词技巧 + Skill</strong> — 让AI输出质量翻倍</li>
    <li><strong>你的场景匹配</strong> — 互动讨论</li>
  </ol>
</section>
```

**Step 2: 浏览器打开验证**

Run: `open slides.html`（macOS）
Expected: 看到封面页和目录页，深色背景，中文字体正常显示，按右箭头可翻页

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add reveal.js slide skeleton with dark theme"
```

---

### Task 2: 第一部分幻灯片 — AI现在能做什么了（Section 1）

**Files:**
- Modify: `slides.html`

**Step 1: 添加分隔页 + Section 1 的4页幻灯片**

分隔页：
```html
<section class="center section-divider">
  <h2>Part 1</h2>
  <p>认知升级</p>
</section>
```

幻灯片内容（4页）：

页1 — "两年发生了什么"
- 2024年初：大多数人刚开始用ChatGPT聊天
- 2026年初：AI可以自主完成复杂任务、调用工具、读取整本合同
- 强调：速度比你想象的快

页2 — "上下文窗口的飞跃"
- 4K tokens → 200K tokens
- 4K ≈ 3页A4纸 / 200K ≈ 一整本书（约500页）
- 意味着：整份合同、整套案卷可以一次性丢给AI

页3 — "多模态：不只是文字"
- 读图片：合同扫描件、证据照片
- 读PDF：直接解析排版复杂的法律文书
- 读表格：财务报表、股权结构图

页4 — "推理能力的突破"
- 不是"背答案" → 而是"想问题"
- 能分析利弊、发现矛盾、提出反驳
- 对律师意味着：AI可以做初步的法律分析，不只是搜索

每页用 `<aside class="notes">` 写入简短speaker note提示。

**Step 2: 浏览器刷新验证**

Expected: 从目录页后可以翻到Part 1分隔页和4页内容，排版清晰

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add section 1 slides - AI capabilities overview"
```

---

### Task 3: 第一部分幻灯片 — Chat vs Agent（Section 2）

**Files:**
- Modify: `slides.html`

**Step 1: 添加Section 2 的4页幻灯片**

页1 — "你现在用的AI是这样的"
- 你问一句，它答一句
- 像微信聊天
- 这叫 <span class="term">Chat</span>（对话模式）

页2 — "但AI可以是这样的"
- 你给一个目标，它自己规划步骤
- 自动调用搜索、读取文件、生成文档
- 这叫 <span class="term">Agent</span>（智能代理）

页3 — "一个类比"
- Chat = 实习生：你说一步，他做一步
- Agent = 资深助理：你说目标，他安排整个流程
- 两列对比布局

页4 — Demo页（黄色左边框标记）
```html
<section class="demo-slide">
  <div class="demo-badge">LIVE DEMO</div>
  <h2>同一个任务，两种方式</h2>
  <p>任务：审查一份合同中的竞业禁止条款</p>
  <ul>
    <li>Chat方式：逐段粘贴，手动追问</li>
    <li>Agent方式：上传合同，一句话指令，自动完成</li>
  </ul>
  <aside class="notes">
    Demo步骤：
    1. 先用豆包/ChatGPT网页版，手动粘贴合同段落，问"这个条款有什么风险"
    2. 再用Claude Agent模式，上传整份合同，说"审查这份合同的竞业禁止条款，标注风险点"
    3. 对比两者的效率和输出质量
  </aside>
</section>
```

**Step 2: 浏览器刷新验证**

Expected: Section 2 四页内容完整，Demo页有黄色边框和LIVE DEMO标记

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add section 2 slides - Chat vs Agent"
```

---

### Task 4: 第一部分幻灯片 — 工具生态（Section 3）

**Files:**
- Modify: `slides.html`

**Step 1: 添加Section 3 的4页幻灯片**

页1 — "手机 vs 手机 + APP"
- 裸机AI = 通用能力
- AI + 工具 = 专业能力
- 三个概念：Plugin / Skill / MCP

页2 — Plugin（插件）
- 给AI接上专业数据源
- 例：法律数据库插件 → AI能搜判例
- 例：财务插件 → AI能读财报
- 你不需要自己做，装上就行

页3 — Skill（预设技能模板）
- = 专家级提示词 + 预设工作流
- 例：一个"合同审查 Skill"预设了审查步骤、关注要点、输出格式
- 你不需要成为prompt专家

页4 — MCP（Model Context Protocol）
- 让AI连接你的本地文件和系统
- 例：连接律所的案件管理系统
- 例：读取本地文件夹里的所有合同
- 技术在快速成熟，未来潜力巨大

**Step 2: 浏览器刷新验证**

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add section 3 slides - Plugin/Skill/MCP ecosystem"
```

---

### Task 5: 第一部分幻灯片 — 法律AI工具版图（Section 4）

**Files:**
- Modify: `slides.html`

**Step 1: 添加Section 4 的5页幻灯片**

页1 — "工具太多，怎么选？"
- 先分清类别：通用 vs 法律专用
- 不需要全部会，选1-2个深度用

页2 — "通用AI工具对比"
- 用tool-card样式展示：
  - 豆包：中文好，免费，大家已经在用
  - Kimi：长文档能力强，适合读合同
  - Claude：推理强、上下文长、有法律Plugin
  - ChatGPT：生态最大，Plugin最多

页3 — "法律专用工具"
- OpenClaw：开源法律AI
- Harvey AI / CoCounsel：国际大所在用
- Claude Legal Plugin：Claude的法律专业扩展

页4 — NotebookLM
- Google出品，免费
- 上传文档 → 自动生成摘要、问答、播客式讲解
- 律师场景：100页案卷 → 案情摘要 → 播客给客户听
- 门槛极低，推荐作为入门工具

页5 — Demo页
```html
<section class="demo-slide">
  <div class="demo-badge">LIVE DEMO</div>
  <h2>NotebookLM 实战</h2>
  <p>上传一份法律文书，现场看AI生成摘要和播客</p>
  <aside class="notes">
    Demo步骤：
    1. 打开 NotebookLM
    2. 上传预准备的法律文书（判决书或合同）
    3. 展示自动生成的摘要
    4. 播放自动生成的播客片段
    5. 展示问答功能：问一个关于文档内容的问题
  </aside>
</section>
```

**Step 2: 浏览器刷新验证**

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add section 4 slides - legal AI tools landscape"
```

---

### Task 6: 第二部分幻灯片 — 律师工作场景实战（Section 5）

**Files:**
- Modify: `slides.html`

**Step 1: 添加分隔页 + Section 5 的6页幻灯片**

分隔页：
```html
<section class="center section-divider">
  <h2>Part 2</h2>
  <p>实操 + 互动</p>
</section>
```

页1 — "五大场景"
- 合同审查 / 法律研究 / 文书起草 / 尽职调查 / 客户沟通
- 接下来逐一演示

页2 — Demo：合同审查
```html
<section class="demo-slide">
  <div class="demo-badge">LIVE DEMO</div>
  <h2>场景一：合同审查</h2>
  <p>上传合同 → AI标注风险条款 → 生成审查意见</p>
  <aside class="notes">
    Demo步骤：
    1. 准备一份样本合同（带常见风险条款）
    2. 上传到Claude/OpenClaw
    3. 指令："审查这份合同，标注所有对我方不利的条款，给出修改建议"
    4. 展示输出：逐条标注 + 修改建议
    5. 强调：这是初稿，律师需要复核
  </aside>
</section>
```

页3 — Demo：法律研究
```html
<section class="demo-slide">
  <div class="demo-badge">LIVE DEMO</div>
  <h2>场景二：法律研究</h2>
  <p>输入案情 → AI检索判例+法规 → 生成研究备忘录</p>
  <aside class="notes">
    Demo步骤：
    1. 描述一个案情（如：劳动争议、竞业禁止纠纷）
    2. 让AI检索相关法规和判例
    3. 生成研究备忘录
    4. 强调：判例引用必须人工校验（AI幻觉风险）
  </aside>
</section>
```

页4 — Demo：文书起草
```html
<section class="demo-slide">
  <div class="demo-badge">LIVE DEMO</div>
  <h2>场景三：文书起草</h2>
  <p>给定要点 → AI生成法律文书初稿</p>
  <aside class="notes">
    Demo步骤：
    1. 给出案件基本事实和诉求要点
    2. 让AI生成起诉状/法律意见书初稿
    3. 展示输出格式和内容质量
    4. 演示如何迭代修改
  </aside>
</section>
```

页5 — 场景四+五（讲解页，非Demo）
- 尽职调查：批量文档 → 提取关键信息 → 报告摘要
- 客户沟通：专业分析 → 客户能理解的邮件
- 简述场景和思路，不做完整demo

**Step 2: 浏览器刷新验证**

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add section 5 slides - practical demo scenarios"
```

---

### Task 7: 第二部分幻灯片 — 提示词 + Skill（Section 6）+ 互动（Section 7）

**Files:**
- Modify: `slides.html`

**Step 1: 添加Section 6 的3页 + Section 7 的1页幻灯片**

Section 6:

页1 — "提示词决定输出质量"
- 三个技巧：角色设定 / 结构化指令 / 分步拆解
- 示例对比：模糊指令 vs 精确指令

页2 — "Skill = 不用自己写prompt"
- Skill 帮你预设了专家级的角色、步骤、格式
- 演示对比：裸prompt vs 用Skill
```html
<section class="demo-slide">
  <div class="demo-badge">LIVE DEMO</div>
  <h2>裸 Prompt vs <span class="term">Skill</span></h2>
  <p>同一个任务，看看输出差距有多大</p>
  <aside class="notes">
    Demo步骤：
    1. 裸prompt：直接说"帮我审查合同"
    2. 用Skill/结构化prompt：设定角色+步骤+输出格式
    3. 对比两个输出的质量差异
    4. 结论：选对工具和Skill比学prompt更重要
  </aside>
</section>
```

页3 — "常见误区"
- 指令太模糊："帮我看看这个合同"
- 不给上下文：不说你是哪方、什么目的
- 不校验输出：AI说什么信什么
- 一次性丢太多：应该分步骤来

Section 7:

页1 — 互动讨论
```html
<section class="center">
  <h2>你最耗时的工作是什么？</h2>
  <p style="font-size:0.8em; opacity:0.7;">
    说出来，我们现场帮你匹配最合适的AI工具
  </p>
  <aside class="notes">
    引导方式：
    - 先让每人简短说一个最耗时的工作任务
    - 现场分析哪个AI工具最适合
    - 给出具体建议：用什么工具、怎么开始
    - 预留时间答疑
  </aside>
</section>
```

**Step 2: 浏览器刷新验证**

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add sections 6-7 slides - prompting skills and discussion"
```

---

### Task 8: 闭场幻灯片（Section 8-9）+ 结尾页

**Files:**
- Modify: `slides.html`

**Step 1: 添加闭场3页幻灯片**

分隔页：
```html
<section class="center section-divider">
  <h2>写在最后</h2>
  <p>边界、风险、下一步</p>
</section>
```

页1 — 数据隐私 + AI幻觉
- 客户数据上传的合规考量
- AI幻觉：判例引用必须校验
- 抛出讨论："你们觉得客户数据上传AI有什么合规考量？"

页2 — 下一步行动建议
- 推荐从NotebookLM开始（免费、简单）
- 进阶：尝试Claude或Kimi处理长文档
- 有技术支持的：尝试OpenClaw
- 推荐工具清单 + 链接

页3 — 结尾页
```html
<section class="center">
  <h2>AI 不会取代律师</h2>
  <h3>但用 AI 的律师会取代不用的</h3>
  <p style="opacity:0.5; margin-top:60px;">谢谢 · Q&A</p>
</section>
```

**Step 2: 浏览器刷新验证**

Expected: 完整课件可从头到尾翻阅，所有页面内容和样式正常

**Step 3: Commit**

```bash
git add slides.html
git commit -m "feat: add closing slides - privacy, next steps, finale"
```

---

### Task 9: 编写培训讲稿 speaker-notes.md

**Files:**
- Create: `speaker-notes.md`

**Step 1: 编写完整讲稿**

按幻灯片顺序编写，每页包含：
- 页码和标题
- 讲解要点（2-5句话）
- Demo页额外包含详细操作步骤
- 过渡语（从这页到下一页怎么衔接）

格式：

```markdown
# 培训讲稿：AI 赋能法律实务

## 封面页
- 开场白：简单自我介绍，说明今天的目的
- "今天不是来推销AI的，是来给大家看看现在AI已经能做什么了"

## 目录页
- 快速过一遍大纲
- "前半段我讲，后半段你们来——每个人说一个自己最耗时的工作，我们现场匹配工具"

## Section 1: AI现在能做什么了
### 页1: 两年发生了什么
- ...

### 页2: 上下文窗口
- ...
（以此类推）
```

每个Demo页的讲稿需要包含：
- 演示前说什么（为什么演示这个）
- 操作步骤（1-2-3）
- 演示后说什么（总结要点）
- 如果demo失败的备用说辞

**Step 2: 通读校验**

检查讲稿覆盖了所有幻灯片页面，demo步骤清晰可执行

**Step 3: Commit**

```bash
git add speaker-notes.md
git commit -m "feat: add speaker notes for training session"
```

---

### Task 10: 最终检查 + 完整提交

**Files:**
- Review: `slides.html`, `speaker-notes.md`

**Step 1: 浏览器完整通览**

Run: `open slides.html`
检查清单：
- [ ] 封面页显示正常
- [ ] 所有页面可正常翻页（共约30页左右）
- [ ] 深色主题一致
- [ ] 术语高亮（.term类）颜色正确
- [ ] Demo页黄色边框标记明显
- [ ] 按 S 键可打开speaker notes视图
- [ ] 最后一页结尾语显示正常

**Step 2: 确认讲稿与幻灯片一一对应**

逐页对照 speaker-notes.md 和 slides.html，确保无遗漏

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete lawyer AI training slides and speaker notes"
```
