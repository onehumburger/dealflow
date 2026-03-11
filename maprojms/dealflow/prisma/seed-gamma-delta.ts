import { PrismaClient, DealPhase, DealSource } from "../src/generated/prisma/client";

const prisma = new PrismaClient();

async function main() {
  // ── Fetch existing users ──────────────────────────────────────
  const liWei = await prisma.user.findUnique({ where: { email: "li.wei@jingtian.com" } });
  const zhangLin = await prisma.user.findUnique({ where: { email: "zhang.lin@jingtian.com" } });
  const wangHao = await prisma.user.findUnique({ where: { email: "wang.hao@jingtian.com" } });
  const chenYu = await prisma.user.findUnique({ where: { email: "chen.yu@jingtian.com" } });
  const liuMing = await prisma.user.findUnique({ where: { email: "liu.ming@jingtian.com" } });
  const zhouJing = await prisma.user.findUnique({ where: { email: "zhou.jing@jingtian.com" } });
  const heXin = await prisma.user.findUnique({ where: { email: "he.xin@jingtian.com" } });
  const yangFei = await prisma.user.findUnique({ where: { email: "yang.fei@jingtian.com" } });
  const admin = await prisma.user.findUnique({ where: { email: "admin@dealflow.local" } });

  if (!liWei || !zhangLin || !wangHao || !chenYu || !liuMing || !zhouJing || !heXin || !yangFei || !admin) {
    throw new Error("Team members not found. Run seed-demo.ts and seed-update.ts first.");
  }

  // ════════════════════════════════════════════════════════════════
  // Project Gamma — 意大利公司收购国内国企，代表卖方（我们的客户）
  // 项目在NBO阶段被客户（卖方/国企）内部叫停
  // ════════════════════════════════════════════════════════════════

  const gamma = await prisma.deal.create({
    data: {
      name: "Project Gamma",
      codeName: "Gamma",
      dealType: "Auction",
      ourRole: "SellSide",
      clientName: "中机精密装备集团有限公司",
      targetCompany: "Montecchi Industriale S.p.A. (买方)",
      jurisdictions: ["PRC", "Italy"],
      status: "OnHold",
      phase: DealPhase.DueDiligence,
      dealValue: 900000000,
      valueCurrency: "CNY",
      keyTerms: "出售60%股权，预征集+产权交易所挂牌模式，国资委审批",
      source: DealSource.DirectClient,
      summary:
        "中机精密装备集团（国有独资）拟出售旗下高端数控机床业务板块60%股权。意大利工业集团Montecchi Industriale S.p.A.通过其在华代表处表达收购意向。本所代表卖方/国企。交易采用竞标流程，预估交易价值¥8-10亿。项目在NBO阶段因客户（国企母公司）内部战略调整而叫停——集团层面决定暂不推进该板块出售，保留自主发展可能。",
      dealLeadId: liWei.id,
    },
  });

  await prisma.dealMember.createMany({
    data: [
      { dealId: gamma.id, userId: liWei.id },
      { dealId: gamma.id, userId: zhangLin.id },
      { dealId: gamma.id, userId: chenYu.id },
      { dealId: gamma.id, userId: zhouJing.id },
      { dealId: gamma.id, userId: admin.id },
    ],
    skipDuplicates: true,
  });

  // ── Milestones ────────────────────────────────────────────────
  await prisma.milestone.createMany({
    data: [
      { name: "委托协议签署", type: "Contractual", date: new Date("2025-10-15"), isDone: true, sortOrder: 0, dealId: gamma.id },
      { name: "VDR准备完成", type: "Internal", date: new Date("2025-11-20"), isDone: true, sortOrder: 1, dealId: gamma.id },
      { name: "信息备忘录发出", type: "Internal", date: new Date("2025-12-01"), isDone: true, sortOrder: 2, dealId: gamma.id },
      { name: "NBO截止", type: "External", date: new Date("2026-01-31"), isDone: false, sortOrder: 3, dealId: gamma.id },
      { name: "Phase 2入围", type: "External", date: null, isDone: false, sortOrder: 4, dealId: gamma.id },
      { name: "BO截止", type: "External", date: null, isDone: false, sortOrder: 5, dealId: gamma.id },
      { name: "SPA签署", type: "Contractual", date: null, isDone: false, sortOrder: 6, dealId: gamma.id },
      { name: "交割", type: "Contractual", date: null, isDone: false, sortOrder: 7, dealId: gamma.id },
    ],
  });

  // ── WS1: VDR准备与管理 ────────────────────────────────────────
  const wsGammaVdr = await prisma.workstream.create({
    data: { name: "VDR准备与管理", sortOrder: 0, dealId: gamma.id },
  });

  await prisma.task.create({
    data: {
      title: "设计VDR结构及文件索引",
      description: "按国际竞标惯例设计VDR目录结构：公司组织架构、股东文件、重大合同、知识产权、劳动人事、财务报表、税务、不动产、环境合规、诉讼仲裁等。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-11-01"),
      assigneeId: zhangLin.id,
      workstreamId: wsGammaVdr.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "协调客户收集VDR文件",
      description: "与中机集团法务部、财务部、人力资源部对接，按VDR索引清单收集全部文件。国企内部审批流程较长，需提前沟通保密要求及文件脱敏规范。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-11-15"),
      assigneeId: zhouJing.id,
      workstreamId: wsGammaVdr.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "VDR文件审阅及质量控制",
      description: "审阅已上传的680份文件，确认完整性和准确性。标记需要补充的文件，确认敏感信息已适当脱敏处理。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-11-18"),
      assigneeId: zhangLin.id,
      workstreamId: wsGammaVdr.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "管理买方Q&A",
      description: "Montecchi及其顾问提交的尽调问题汇总和回复协调。共收到82个问题，已回复45个后项目叫停。",
      status: "InProgress",
      priority: "Normal",
      dueDate: new Date("2026-02-15"),
      assigneeId: zhouJing.id,
      workstreamId: wsGammaVdr.id,
      sortOrder: 3,
    },
  });

  // ── WS2: 信息备忘录与流程管理 ──────────────────────────────────
  const wsGammaIm = await prisma.workstream.create({
    data: { name: "信息备忘录与流程管理", sortOrder: 1, dealId: gamma.id },
  });

  await prisma.task.create({
    data: {
      title: "起草Teaser（项目简介）",
      description: "一页纸项目简介，不披露客户名称。核心信息：行业（高端数控机床）、营收规模（¥12亿）、出售比例（60%）、预计时间线。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-10-30"),
      assigneeId: zhangLin.id,
      workstreamId: wsGammaIm.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "起草信息备忘录(IM)",
      description: "约60页中英双语IM，内容涵盖：公司概况、业务描述、市场分析、财务摘要（近三年审计报告要点）、管理团队、竞争优势、出售理由。需客户审阅确认后方可发出。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-11-25"),
      assigneeId: zhangLin.id,
      workstreamId: wsGammaIm.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "起草Process Letter",
      description: "竞标规则文件：NBO提交截止日期、格式要求、评估标准、保密义务、排他期条款、时间表。中英双语。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-11-28"),
      assigneeId: liWei.id,
      workstreamId: wsGammaIm.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "向潜在买方发送IM及Process Letter",
      description: "已向5家潜在买方（含Montecchi）发送NDA→IM→Process Letter。最终3家签署NDA并进入VDR：Montecchi (意大利)、DMG Mori子公司(日本)、通用技术集团(国内)。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-12-01"),
      assigneeId: liWei.id,
      workstreamId: wsGammaIm.id,
      sortOrder: 3,
    },
  });

  const taskGammaNboCollect = await prisma.task.create({
    data: {
      title: "收集及评估NBO",
      description: "原定1月31日收集NBO。Montecchi已口头表示计划提交约¥9亿报价。但在截止日前2周，客户内部叫停项目。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-01-31"),
      assigneeId: liWei.id,
      workstreamId: wsGammaIm.id,
      sortOrder: 4,
    },
  });

  // ── WS3: 国企特殊程序 ──────────────────────────────────────────
  const wsGammaSoe = await prisma.workstream.create({
    data: { name: "国企特殊审批程序", sortOrder: 2, dealId: gamma.id },
  });

  await prisma.task.create({
    data: {
      title: "国有股权转让审批流程梳理",
      description: "涉及国有资产监督管理部门审批、产权交易所挂牌（或协议转让审批）、资产评估。国有独资企业股权转让需报国资委批准。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-10-25"),
      assigneeId: chenYu.id,
      workstreamId: wsGammaSoe.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "聘请评估机构进行资产评估",
      description: "已聘请中联资产评估集团。评估范围：拟出售的数控机床业务板块（含固定资产、无形资产、在建工程等）。评估基准日2025年9月30日。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-11-10"),
      assigneeId: chenYu.id,
      workstreamId: wsGammaSoe.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "国资委内部报批",
      description: "向中机集团上级主管部门报送股权转让方案。包括：转让理由、交易方案、评估报告、职工安置方案、国有资产权益保护措施。报批过程中收到上级指示，集团层面战略调整，暂停出售。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-01-15"),
      assigneeId: chenYu.id,
      workstreamId: wsGammaSoe.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "产权交易所挂牌准备",
      description: "根据国资监管要求，外资收购国有股权需在产权交易所公开挂牌。已开始准备挂牌材料，但因项目叫停而终止。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-02-28"),
      assigneeId: chenYu.id,
      workstreamId: wsGammaSoe.id,
      sortOrder: 3,
    },
  });

  await prisma.task.create({
    data: {
      title: "职工安置方案",
      description: "涉及该业务板块约450名员工。需制定职工安置方案并经职工代表大会审议通过。方案草案已完成，但未进入审议程序。",
      status: "InProgress",
      priority: "Normal",
      dueDate: new Date("2026-01-20"),
      assigneeId: zhouJing.id,
      workstreamId: wsGammaSoe.id,
      sortOrder: 4,
    },
  });

  // ── WS4: 监管分析 ─────────────────────────────────────────────
  const wsGammaReg = await prisma.workstream.create({
    data: { name: "监管审批分析", sortOrder: 3, dealId: gamma.id },
  });

  await prisma.task.create({
    data: {
      title: "外商投资准入审查",
      description: "确认数控机床行业是否属于外商投资限制/禁止类目录。经查：通用数控机床不在负面清单内，但高精度五轴联动数控机床可能涉及出口管制。需进一步确认业务板块具体产品。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-11-05"),
      assigneeId: chenYu.id,
      workstreamId: wsGammaReg.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "反垄断申报分析",
      description: "Montecchi全球营收约€20亿，中机集团年营收¥180亿。初步判断：可能触发经营者集中申报门槛。需在NBO阶段向买方明确申报义务。",
      status: "Done",
      priority: "Normal",
      dueDate: new Date("2025-12-15"),
      assigneeId: chenYu.id,
      workstreamId: wsGammaReg.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "意大利黄金权力(Golden Power)分析",
      description: "意大利对涉及战略行业的外资收购实施Golden Power审查。但本案为意大利公司在中国的收购，意大利审查机制不适用。备注供参考。",
      status: "Done",
      priority: "Normal",
      dueDate: new Date("2025-12-10"),
      assigneeId: liuMing.id,
      workstreamId: wsGammaReg.id,
      sortOrder: 2,
    },
  });

  // ── WS5: 客户沟通 ─────────────────────────────────────────────
  const wsGammaClient = await prisma.workstream.create({
    data: { name: "客户沟通与策略", sortOrder: 4, dealId: gamma.id },
  });

  await prisma.task.create({
    data: {
      title: "签署委托协议",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-10-15"),
      assigneeId: liWei.id,
      workstreamId: wsGammaClient.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "竞标流程设计与客户确认",
      description: "与客户讨论竞标流程设计：两轮竞标(NBO→BO)、时间表、评标标准（价格40%、产业协同30%、员工保障20%、确定性10%）。客户审批通过。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2025-10-25"),
      assigneeId: liWei.id,
      workstreamId: wsGammaClient.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "通知潜在买方项目暂停",
      description: "客户决定暂停出售后，需正式通知已进入流程的3家潜在买方。起草通知函并经客户确认后发出。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-01-20"),
      assigneeId: liWei.id,
      workstreamId: wsGammaClient.id,
      sortOrder: 2,
    },
  });

  // ── Contacts ──────────────────────────────────────────────────
  const contactGammaClient = await prisma.contact.create({
    data: {
      name: "郑大伟",
      organization: "中机精密装备集团有限公司",
      role: "Client",
      title: "副总经理",
      phone: "+86 10 8888 6600",
      email: "zheng.dawei@cmpe-group.com",
      timezone: "Asia/Shanghai",
      notes: "集团分管领导，本次股权转让的内部项目负责人。后因集团战略调整，传达了暂停出售的决定。",
    },
  });

  const contactGammaClientLegal = await prisma.contact.create({
    data: {
      name: "钱芳",
      organization: "中机精密装备集团有限公司",
      role: "Client",
      title: "法务部部长",
      phone: "+86 10 8888 6680",
      email: "qian.fang@cmpe-group.com",
      timezone: "Asia/Shanghai",
      notes: "日常对接人。国企法务出身，注重合规和流程。",
    },
  });

  const contactGammaBuyer = await prisma.contact.create({
    data: {
      name: "Marco Rossi",
      organization: "Montecchi Industriale S.p.A.",
      role: "Other",
      title: "Chief Strategy Officer",
      phone: "+39 02 8866 1234",
      email: "m.rossi@montecchi.it",
      timezone: "Europe/Rome",
      notes: "买方战略负责人。对中国市场有长期兴趣。项目叫停后表示遗憾，希望保持联系。",
    },
  });

  const contactGammaBuyerCounsel = await prisma.contact.create({
    data: {
      name: "Avv. Giulia Bianchi",
      organization: "Bonelli Erede",
      role: "CounterpartyCounsel",
      title: "Partner",
      phone: "+39 02 771 131",
      email: "giulia.bianchi@belex.com",
      timezone: "Europe/Rome",
      notes: "买方意大利律师。负责交易结构和意大利法事务。",
    },
  });

  const contactGammaEvaluator = await prisma.contact.create({
    data: {
      name: "刘建军",
      organization: "中联资产评估集团有限公司",
      role: "Accountant",
      title: "合伙人",
      phone: "+86 10 6578 9900",
      email: "liu.jianjun@unionappraisal.com",
      timezone: "Asia/Shanghai",
      notes: "国有资产评估项目负责人。",
    },
  });

  await prisma.dealContact.createMany({
    data: [
      { dealId: gamma.id, contactId: contactGammaClient.id, roleInDeal: "客户项目负责人" },
      { dealId: gamma.id, contactId: contactGammaClientLegal.id, roleInDeal: "客户法务对接人" },
      { dealId: gamma.id, contactId: contactGammaBuyer.id, roleInDeal: "买方战略负责人" },
      { dealId: gamma.id, contactId: contactGammaBuyerCounsel.id, roleInDeal: "买方律师" },
      { dealId: gamma.id, contactId: contactGammaEvaluator.id, roleInDeal: "资产评估机构" },
    ],
  });

  // ── Decisions ──────────────────────────────────────────────────
  await prisma.decision.create({
    data: {
      title: "竞标方式选择：公开挂牌 vs. 定向竞标",
      background: "国有股权转让原则上需在产权交易所公开挂牌。但经协商，集团层面倾向先进行定向询价，在满足合规要求的前提下引入具有产业协同的战略投资者。",
      source: "Other",
      analysis: "经与客户法务部确认，如果先以非公开方式征集意向，后期仍需在产权交易所履行挂牌程序。建议采用'预征集+挂牌'模式：先定向邀请3-5家有能力的战略买方，同步准备产权交易所挂牌材料。",
      clientDecision: "采用'预征集+挂牌'模式。先向5家目标企业发送Teaser，收集意向后再履行产权交易所程序。",
      status: "Implemented",
      dealId: gamma.id,
      workstreamId: wsGammaIm.id,
    },
  });

  await prisma.decision.create({
    data: {
      title: "项目暂停处理方案",
      background: "2026年1月中旬，客户传达集团内部决定：因国资委对精密装备板块定位调整，暂不推进出售。需妥善处理已启动的竞标流程。",
      source: "Other",
      analysis: "需处理：(1) 正式通知潜在买方，措辞需中性，保留未来重启可能性；(2) VDR关闭和文件归档；(3) 已签NDA的保密义务持续有效；(4) 评估机构费用结算。",
      clientDecision: "发送正式暂停通知函，不明确是否永久终止。VDR于2月1日关闭。保留全部工作成果以备未来可能重启。",
      status: "Implemented",
      dealId: gamma.id,
      workstreamId: wsGammaClient.id,
    },
  });

  // ── Activity Entries ──────────────────────────────────────────
  const gammaActivities = [
    { type: "Note" as const, content: "项目启动。中机集团委托本所担任股权出售的法律顾问。团队：李伟（负责人）、张琳、陈宇、周静。", date: "2025-10-15", author: liWei.id },
    { type: "Meeting" as const, content: "与客户法务部钱芳部长及投资发展部团队召开Kick-off会议。明确：出售数控机床板块60%股权，保留40%及一定治理权。目标引入具有技术和市场协同的外资战略投资者。", date: "2025-10-18", author: liWei.id },
    { type: "Note" as const, content: "完成国有股权转让审批流程梳理。关键节点：集团审批→国资委备案→资产评估→产权交易所挂牌→竞价/协议转让→工商变更。", date: "2025-10-25", author: chenYu.id },
    { type: "Note" as const, content: "中联资产评估已进场开始评估工作。预计11月中旬出具初步评估报告。", date: "2025-11-01", author: chenYu.id },
    { type: "Note" as const, content: "VDR准备完成，共680份文件。Teaser和IM已经客户审阅确认。开始向5家潜在买方发送。", date: "2025-11-20", author: zhangLin.id },
    { type: "Note" as const, content: "Montecchi、DMG Mori子公司、通用技术集团三家签署NDA并获得VDR访问权限。另外两家(韩国斗山和德国通快)因战略优先级放弃。", date: "2025-12-05", author: liWei.id },
    { type: "Call" as const, content: "与Montecchi的Marco Rossi电话。Montecchi对目标公司五轴机床技术线很感兴趣，计划春节后提交NBO。预计报价区间¥8.5-9.5亿。", date: "2025-12-15", author: liWei.id },
    { type: "Meeting" as const, content: "年度项目进展汇报。向客户郑大伟副总汇报竞标进展。三家潜在买方均在积极推进尽调。Montecchi兴趣最高。", date: "2025-12-28", author: liWei.id },
    { type: "ClientInstruction" as const, content: "【重要】客户紧急通知：集团层面战略调整，国资委对精密装备板块重新定位为'核心主业'，暂不推进股权出售。要求立即暂停竞标流程。", date: "2026-01-14", author: liWei.id },
    { type: "Meeting" as const, content: "紧急内部会议。讨论项目叫停后的善后工作：(1) 起草暂停通知函；(2) 安排VDR关闭；(3) 处理评估机构费用；(4) 与各方沟通。", date: "2026-01-15", author: liWei.id },
    { type: "Note" as const, content: "已向三家潜在买方发送正式暂停通知函。Montecchi回函表示遗憾，希望如有重启机会能优先考虑。DMG Mori和通用技术集团亦确认收到。", date: "2026-01-20", author: liWei.id },
    { type: "Note" as const, content: "VDR已关闭（2月1日）。全部项目文件已归档。NDA保密义务持续有效。与评估机构结算中期费用¥35万。项目进入暂停/冻结状态。", date: "2026-02-01", author: zhangLin.id },
  ];

  for (const act of gammaActivities) {
    await prisma.activityEntry.create({
      data: {
        type: act.type,
        content: act.content,
        dealId: gamma.id,
        authorId: act.author,
        createdAt: new Date(act.date),
      },
    });
  }

  // ── Task Comments ─────────────────────────────────────────────
  await prisma.taskComment.createMany({
    data: [
      {
        content: "VDR中680份文件已全部上传并完成交叉审阅。文件质量较好，仅3份需要补充（环境许可证更新件、2024年审计报告附注、部分专利证书扫描件）。",
        taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "VDR文件审阅" } } }))!.id,
        authorId: zhangLin.id,
        createdAt: new Date("2025-11-19"),
      },
      {
        content: "Montecchi的Q&A中多次追问五轴机床的技术参数和出口管制风险。需与客户确认：高精度五轴联动产品是否在出口管制清单内？如果是，可能影响交易结构（外资不能控股）。",
        taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "管理买方Q&A" } } }))!.id,
        authorId: zhouJing.id,
        createdAt: new Date("2026-01-05"),
      },
      {
        content: "国资委内部传达文件显示精密装备被列入集团'核心主业'清单。这意味着短期内重启出售的可能性很低。建议做好项目冻结归档工作。",
        taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "国资委内部报批" } } }))!.id,
        authorId: chenYu.id,
        createdAt: new Date("2026-01-16"),
      },
    ],
  });

  // ── Gamma Billing Rates ──────────────────────────────────────
  await prisma.dealBillingRate.createMany({
    data: [
      { dealId: gamma.id, userId: liWei.id, ratePerHour: 4500, currency: "CNY" },
      { dealId: gamma.id, userId: zhangLin.id, ratePerHour: 2800, currency: "CNY" },
      { dealId: gamma.id, userId: chenYu.id, ratePerHour: 2500, currency: "CNY" },
      { dealId: gamma.id, userId: zhouJing.id, ratePerHour: 1800, currency: "CNY" },
    ],
  });

  // ── Gamma Time Entries ──────────────────────────────────────
  await prisma.timeEntry.createMany({
    data: [
      // 李伟 — 合伙人
      { description: "项目启动、竞标流程设计与客户确认", durationMinutes: 180, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "竞标流程设计" } } }))!.id, userId: liWei.id, dealId: gamma.id, createdAt: new Date("2025-10-20") },
      { description: "Process Letter起草及审阅", durationMinutes: 180, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "Process Letter" } } }))!.id, userId: liWei.id, dealId: gamma.id, createdAt: new Date("2025-11-25") },
      { description: "向潜在买方分发IM — 电话沟通及邮件协调", durationMinutes: 120, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "向潜在买方发送" } } }))!.id, userId: liWei.id, dealId: gamma.id, createdAt: new Date("2025-12-01") },
      { description: "与Montecchi Marco Rossi电话 — 了解买方初步意向", durationMinutes: 60, isManual: true, isBillable: true, taskId: taskGammaNboCollect.id, userId: liWei.id, dealId: gamma.id, createdAt: new Date("2025-12-15") },
      { description: "起草暂停通知函、与客户沟通善后方案", durationMinutes: 150, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "通知潜在买方" } } }))!.id, userId: liWei.id, dealId: gamma.id, createdAt: new Date("2026-01-18") },

      // 张琳 — VDR准备及IM
      { description: "VDR目录结构设计", durationMinutes: 180, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "设计VDR结构" } } }))!.id, userId: zhangLin.id, dealId: gamma.id, createdAt: new Date("2025-10-28") },
      { description: "VDR文件审阅及质量控制（680份）", durationMinutes: 360, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "VDR文件审阅" } } }))!.id, userId: zhangLin.id, dealId: gamma.id, createdAt: new Date("2025-11-17") },
      { description: "信息备忘录起草 — 中英双语（约60页）", durationMinutes: 720, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "信息备忘录" } } }))!.id, userId: zhangLin.id, dealId: gamma.id, createdAt: new Date("2025-11-15") },
      { description: "Teaser起草（中英双语一页纸）", durationMinutes: 90, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "Teaser" } } }))!.id, userId: zhangLin.id, dealId: gamma.id, createdAt: new Date("2025-10-28") },

      // 陈宇 — 国企特殊程序及监管
      { description: "国有股权转让审批流程梳理及备忘录", durationMinutes: 240, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "国有股权转让审批" } } }))!.id, userId: chenYu.id, dealId: gamma.id, createdAt: new Date("2025-10-22") },
      { description: "聘请评估机构 — 范围确认及合同审阅", durationMinutes: 120, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "聘请评估机构" } } }))!.id, userId: chenYu.id, dealId: gamma.id, createdAt: new Date("2025-11-05") },
      { description: "国资委报批材料准备", durationMinutes: 300, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "国资委内部报批" } } }))!.id, userId: chenYu.id, dealId: gamma.id, createdAt: new Date("2025-12-20") },
      { description: "外商投资准入审查分析备忘录", durationMinutes: 180, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "外商投资准入" } } }))!.id, userId: chenYu.id, dealId: gamma.id, createdAt: new Date("2025-11-03") },
      { description: "反垄断申报门槛分析", durationMinutes: 120, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "反垄断申报" } } }))!.id, userId: chenYu.id, dealId: gamma.id, createdAt: new Date("2025-12-12") },

      // 周静 — Q&A管理
      { description: "协调客户各部门收集VDR文件", durationMinutes: 300, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "协调客户收集" } } }))!.id, userId: zhouJing.id, dealId: gamma.id, createdAt: new Date("2025-11-08") },
      { description: "买方Q&A回复协调（已回复45/82问）", durationMinutes: 360, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "管理买方Q&A" } } }))!.id, userId: zhouJing.id, dealId: gamma.id, createdAt: new Date("2026-01-05") },
      { description: "职工安置方案草案起草", durationMinutes: 240, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: gamma.id }, title: { contains: "职工安置" } } }))!.id, userId: zhouJing.id, dealId: gamma.id, createdAt: new Date("2026-01-10") },
    ],
  });

  console.log("✅ Project Gamma created: SOE sell-side, terminated at NBO stage, 5 workstreams, 16 tasks, 5 contacts, 2 decisions, 12 activity entries, 17 time entries, 4 billing rates");

  // ════════════════════════════════════════════════════════════════
  // Project Delta — 境内D轮融资，代表被投资方（融资方）
  // 估值¥10亿，对方为境内基金，目前在SPA/SHA审阅阶段
  // ════════════════════════════════════════════════════════════════

  const delta = await prisma.deal.create({
    data: {
      name: "Project Delta",
      codeName: "Delta",
      dealType: "Negotiated",
      ourRole: "SellSide",
      clientName: "智元数据科技有限公司",
      targetCompany: "远景成长基金二期 (投资方)",
      jurisdictions: ["PRC"],
      status: "Active",
      phase: DealPhase.Negotiation,
      dealValue: 250000000,
      valueCurrency: "CNY",
      keyTerms: "Pre-money估值¥10亿，D轮优先股，1x非参与型优先清算权，加权平均反稀释，5+2年回购",
      source: DealSource.PartnerReferral,
      sourceNote: "经合伙人朋友介绍",
      summary:
        "智元数据科技有限公司D轮融资项目。智元数据是一家专注于工业AI和数字孪生技术的科技公司，成立于2018年，已完成A/B/C轮融资，累计融资¥4.5亿。本轮D轮由远景成长基金二期领投，融资金额¥2.5亿，投前估值¥10亿（Pre-money），投后估值¥12.5亿。本所代表融资方（智元数据）。目前处于SPA及SHA（股东协议）审阅和谈判阶段。核心谈判点：反稀释条款、优先清算权、回购权触发条件、董事会席位安排。",
      dealLeadId: liWei.id,
    },
  });

  await prisma.dealMember.createMany({
    data: [
      { dealId: delta.id, userId: liWei.id },
      { dealId: delta.id, userId: heXin.id },
      { dealId: delta.id, userId: wangHao.id },
      { dealId: delta.id, userId: zhouJing.id },
      { dealId: delta.id, userId: admin.id },
    ],
    skipDuplicates: true,
  });

  // ── Milestones ────────────────────────────────────────────────
  await prisma.milestone.createMany({
    data: [
      { name: "Term Sheet签署", type: "Contractual", date: new Date("2026-01-20"), isDone: true, sortOrder: 0, dealId: delta.id },
      { name: "投资方尽调完成", type: "External", date: new Date("2026-02-28"), isDone: true, sortOrder: 1, dealId: delta.id },
      { name: "SPA/SHA定稿", type: "Contractual", date: new Date("2026-03-25"), isDone: false, sortOrder: 2, dealId: delta.id },
      { name: "政府审批/备案", type: "Regulatory", date: new Date("2026-04-10"), isDone: false, sortOrder: 3, dealId: delta.id },
      { name: "交割", type: "Contractual", date: new Date("2026-04-20"), isDone: false, sortOrder: 4, dealId: delta.id },
    ],
  });

  // ── WS1: 尽调支持 ─────────────────────────────────────────────
  const wsDeltaDd = await prisma.workstream.create({
    data: { name: "尽调支持与配合", sortOrder: 0, dealId: delta.id },
  });

  await prisma.task.create({
    data: {
      title: "准备尽调资料清单回复",
      description: "远景基金委托君合律师事务所进行法律尽调。收到尽调资料清单共126项。协调客户各部门准备回复材料。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-05"),
      assigneeId: zhouJing.id,
      workstreamId: wsDeltaDd.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "审阅并回复投资方律师尽调问题",
      description: "君合提出38个补充问题，主要涉及：(1) 核心技术知识产权权属（创始人职务发明转让）；(2) 关键员工竞业禁止执行情况；(3) 政府补贴合规性；(4) 关联交易公允性；(5) 数据安全合规。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-20"),
      assigneeId: heXin.id,
      workstreamId: wsDeltaDd.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "协调管理层配合投资方访谈",
      description: "安排CTO、CFO和技术VP分别与远景基金投资团队会面。投资方重点关注：技术壁垒、客户粘性、续约率、研发管线、未来18个月的ARR增长预期。",
      status: "Done",
      priority: "Normal",
      dueDate: new Date("2026-02-15"),
      assigneeId: heXin.id,
      workstreamId: wsDeltaDd.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "处理尽调发现的合规问题",
      description: "尽调中发现两个问题需整改：(1) 3项软件著作权登记名称与公司主体不一致（历史遗留）；(2) 部分员工竞业禁止协议缺少补偿金条款（无效风险）。已启动整改。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-25"),
      assigneeId: heXin.id,
      workstreamId: wsDeltaDd.id,
      sortOrder: 3,
    },
  });

  // ── WS2: SPA（增资协议）────────────────────────────────────────
  const wsDeltaSpa = await prisma.workstream.create({
    data: { name: "增资协议(SPA)", sortOrder: 1, dealId: delta.id },
  });

  const taskDeltaSpaReview = await prisma.task.create({
    data: {
      title: "审阅投资方律师起草的增资协议",
      description: "君合起草的SPA共68页，含15项先决条件、28项陈述与保证、特别赔偿条款。我方需逐条审阅并提出修改意见。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-03-15"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaSpa.id,
      sortOrder: 0,
    },
  });

  await prisma.subtask.createMany({
    data: [
      { title: "先决条件条款审阅", isDone: true, sortOrder: 0, taskId: taskDeltaSpaReview.id },
      { title: "陈述与保证条款审阅", isDone: true, sortOrder: 1, taskId: taskDeltaSpaReview.id },
      { title: "特别赔偿条款审阅", isDone: true, sortOrder: 2, taskId: taskDeltaSpaReview.id },
      { title: "交割机制条款审阅", isDone: false, sortOrder: 3, taskId: taskDeltaSpaReview.id },
      { title: "违约及终止条款审阅", isDone: false, sortOrder: 4, taskId: taskDeltaSpaReview.id },
      { title: "修改意见汇总及内部讨论", isDone: false, sortOrder: 5, taskId: taskDeltaSpaReview.id },
    ],
  });

  const taskDeltaSpaMarkup = await prisma.task.create({
    data: {
      title: "SPA Mark-up及修改意见发送",
      description: "汇总我方修改意见，重点争议条款：(1) 反稀释保护的计算方式（加权平均 vs. 全面棘轮）；(2) 回购权触发条件中'未能上市'的期限（投资方要5年，我方希望7年）；(3) 创始人连带担保责任范围。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-03-18"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaSpa.id,
      sortOrder: 1,
    },
  });

  const taskDeltaSpaNegotiate = await prisma.task.create({
    data: {
      title: "SPA条款谈判",
      description: "与投资方律师就mark-up进行谈判。预计2-3轮修改。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-03-25"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaSpa.id,
      sortOrder: 2,
    },
  });

  // ── WS3: SHA（股东协议）────────────────────────────────────────
  const wsDeltaSha = await prisma.workstream.create({
    data: { name: "股东协议(SHA)", sortOrder: 2, dealId: delta.id },
  });

  const taskDeltaShaReview = await prisma.task.create({
    data: {
      title: "审阅投资方起草的股东协议",
      description: "SHA（股东协议/投资人权利协议）核心条款：董事会组成、投资人特殊权利（知情权、优先认购权、共售权、领售权）、竞业及关联交易限制、信息权、优先清算权、反稀释、回购权。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-03-15"),
      assigneeId: heXin.id,
      workstreamId: wsDeltaSha.id,
      sortOrder: 0,
    },
  });

  await prisma.subtask.createMany({
    data: [
      { title: "董事会组成及表决机制审阅", isDone: true, sortOrder: 0, taskId: taskDeltaShaReview.id },
      { title: "优先清算权条款审阅", isDone: true, sortOrder: 1, taskId: taskDeltaShaReview.id },
      { title: "反稀释条款审阅", isDone: false, sortOrder: 2, taskId: taskDeltaShaReview.id },
      { title: "回购权条款审阅", isDone: false, sortOrder: 3, taskId: taskDeltaShaReview.id },
      { title: "领售权/共售权条款审阅", isDone: false, sortOrder: 4, taskId: taskDeltaShaReview.id },
      { title: "竞业及关联交易限制审阅", isDone: false, sortOrder: 5, taskId: taskDeltaShaReview.id },
    ],
  });

  const taskDeltaShaMarkup = await prisma.task.create({
    data: {
      title: "SHA修改意见汇总及发送",
      description: "核心谈判点：(1) 董事会席位（投资方要求1席+1观察员，现有投资人已有2席，创始团队3席，总计需平衡）；(2) 优先清算权倍数（投资方要1.5x，市场惯例1x）；(3) 领售权触发条件。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-03-18"),
      assigneeId: heXin.id,
      workstreamId: wsDeltaSha.id,
      sortOrder: 1,
    },
  });

  const taskDeltaShaNegotiate = await prisma.task.create({
    data: {
      title: "SHA条款谈判",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-03-25"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaSha.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "修订公司章程配合SHA条款",
      description: "SHA中的治理安排需反映到公司章程修订中：董事会组成变化、投资人特殊表决事项、分红机制等。需在交割前完成章程修订并通过股东会决议。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-03-28"),
      assigneeId: heXin.id,
      workstreamId: wsDeltaSha.id,
      sortOrder: 3,
    },
  });

  // ── WS4: 交割前准备 ───────────────────────────────────────────
  const wsDeltaClosing = await prisma.workstream.create({
    data: { name: "交割前准备", sortOrder: 3, dealId: delta.id },
  });

  await prisma.task.create({
    data: {
      title: "工商变更预审材料准备",
      description: "增资完成后需办理工商变更登记（注册资本、股东信息）。提前准备全套材料以加快交割后办理速度。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-03-30"),
      assigneeId: zhouJing.id,
      workstreamId: wsDeltaClosing.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "现有股东知情同意",
      description: "根据现有SHA约定，新一轮融资需取得现有投资人（B轮领投方红杉中国、C轮领投方高瓴创投）的知情同意/放弃优先认购权确认函。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-03-15"),
      assigneeId: wangHao.id,
      workstreamId: wsDeltaClosing.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "创始人配偶财产确认",
      description: "投资方要求创始人配偶出具股权非夫妻共同财产确认函或同意函。涉及2位创始人。",
      status: "InProgress",
      priority: "Normal",
      dueDate: new Date("2026-03-12"),
      assigneeId: zhouJing.id,
      workstreamId: wsDeltaClosing.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "ESOP方案审阅及调整",
      description: "D轮进入后ESOP pool需从12%调整至10%（释放2%给D轮投资人）。需修改ESOP方案并取得董事会决议。同时确认已授予期权不受影响。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-03-25"),
      assigneeId: wangHao.id,
      workstreamId: wsDeltaClosing.id,
      sortOrder: 3,
    },
  });

  await prisma.task.create({
    data: {
      title: "资金到账及验资",
      description: "¥2.5亿投资款需一次性打入公司账户。安排验资并出具验资报告。配合办理注册资本变更。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-04-15"),
      assigneeId: wangHao.id,
      workstreamId: wsDeltaClosing.id,
      sortOrder: 4,
    },
  });

  // ── WS5: 客户沟通 ─────────────────────────────────────────────
  const wsDeltaClient = await prisma.workstream.create({
    data: { name: "客户沟通与策略", sortOrder: 4, dealId: delta.id },
  });

  await prisma.task.create({
    data: {
      title: "签署委托协议",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-01-10"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaClient.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "Term Sheet谈判协助",
      description: "协助客户与远景基金谈判Term Sheet。最终条款：Pre-money估值¥10亿，投资金额¥2.5亿，D轮优先股，1x非参与型优先清算权。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-01-18"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaClient.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "SPA/SHA核心条款谈判策略确认",
      description: "与客户CEO和CFO讨论SPA/SHA谈判底线：(1) 反稀释只接受加权平均，不接受全面棘轮；(2) 回购期限底线6年；(3) 创始人担保仅限特别赔偿条款，不承担一般R&W连带；(4) 领售权需加保护（最低价格门槛）。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-03-05"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaClient.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "与客户同步SPA/SHA审阅进展",
      status: "InProgress",
      priority: "Normal",
      dueDate: new Date("2026-03-20"),
      assigneeId: liWei.id,
      workstreamId: wsDeltaClient.id,
      sortOrder: 3,
    },
  });

  // ── Task Dependencies ─────────────────────────────────────────
  await prisma.taskDependency.createMany({
    data: [
      { type: "Blocks", taskId: taskDeltaSpaMarkup.id, dependsOnTaskId: taskDeltaSpaReview.id },
      { type: "Blocks", taskId: taskDeltaSpaNegotiate.id, dependsOnTaskId: taskDeltaSpaMarkup.id },
      { type: "Blocks", taskId: taskDeltaShaMarkup.id, dependsOnTaskId: taskDeltaShaReview.id },
      { type: "Blocks", taskId: taskDeltaShaNegotiate.id, dependsOnTaskId: taskDeltaShaMarkup.id },
    ],
  });

  // ── Contacts ──────────────────────────────────────────────────
  const contactDeltaCeo = await prisma.contact.create({
    data: {
      name: "陈明哲",
      organization: "智元数据科技有限公司",
      role: "Client",
      title: "创始人兼CEO",
      phone: "+86 136 0000 8888",
      email: "mingzhe.chen@zhiyuan-data.com",
      timezone: "Asia/Shanghai",
      notes: "公司创始人，清华大学计算机系博士，前阿里云技术VP。对融资条款有较强的谈判意识，关注控制权保护。",
    },
  });

  const contactDeltaCfo = await prisma.contact.create({
    data: {
      name: "孙洁",
      organization: "智元数据科技有限公司",
      role: "Client",
      title: "CFO",
      phone: "+86 139 0000 6666",
      email: "jie.sun@zhiyuan-data.com",
      timezone: "Asia/Shanghai",
      notes: "日常财务对接人。前四大（KPMG）背景。负责融资时间线管理和投资方沟通。",
    },
  });

  const contactDeltaInvestor = await prisma.contact.create({
    data: {
      name: "徐浩然",
      organization: "远景成长基金管理有限公司",
      role: "Other",
      title: "执行董事",
      phone: "+86 138 0000 3333",
      email: "haoran.xu@vision-growth.com",
      timezone: "Asia/Shanghai",
      notes: "远景基金D轮领投项目负责人。关注AI赛道，之前投过3家类似公司。谈判风格直接、高效。",
    },
  });

  const contactDeltaInvestorCounsel = await prisma.contact.create({
    data: {
      name: "李明远",
      organization: "君合律师事务所",
      role: "CounterpartyCounsel",
      title: "合伙人",
      phone: "+86 10 8519 1300",
      email: "limingyuan@junhe.com",
      timezone: "Asia/Shanghai",
      notes: "投资方律师。VC/PE交易经验丰富。SPA/SHA由其团队起草。谈判风格：条款细致但可沟通。",
    },
  });

  const contactDeltaSequoia = await prisma.contact.create({
    data: {
      name: "王思聪（投资经理）",
      organization: "红杉资本中国基金",
      role: "Other",
      title: "投资经理",
      phone: "+86 137 0000 5555",
      email: "sicong.wang@sequoiacap.com",
      timezone: "Asia/Shanghai",
      notes: "B轮领投方红杉的项目负责人。需其确认放弃D轮优先认购权。日常沟通响应快。",
    },
  });

  const contactDeltaHillhouse = await prisma.contact.create({
    data: {
      name: "张雅琪",
      organization: "高瓴创投",
      role: "Other",
      title: "副总裁",
      phone: "+86 135 0000 7777",
      email: "yaqi.zhang@hillhousevc.com",
      timezone: "Asia/Shanghai",
      notes: "C轮领投方高瓴的项目跟进人。需其确认放弃D轮优先认购权并签署同意函。",
    },
  });

  await prisma.dealContact.createMany({
    data: [
      { dealId: delta.id, contactId: contactDeltaCeo.id, roleInDeal: "客户创始人/CEO" },
      { dealId: delta.id, contactId: contactDeltaCfo.id, roleInDeal: "客户CFO/日常对接" },
      { dealId: delta.id, contactId: contactDeltaInvestor.id, roleInDeal: "D轮领投方负责人" },
      { dealId: delta.id, contactId: contactDeltaInvestorCounsel.id, roleInDeal: "投资方律师" },
      { dealId: delta.id, contactId: contactDeltaSequoia.id, roleInDeal: "B轮投资方（红杉）" },
      { dealId: delta.id, contactId: contactDeltaHillhouse.id, roleInDeal: "C轮投资方（高瓴）" },
    ],
  });

  // ── Decisions ──────────────────────────────────────────────────
  await prisma.decision.create({
    data: {
      title: "反稀释条款类型选择",
      background: "投资方Term Sheet中约定反稀释保护，但未明确计算方式。正式文件中投资方律师采用全面棘轮(Full Ratchet)方式起草，对融资方极为不利。",
      source: "Negotiation",
      analysis: "全面棘轮意味着如果下一轮估值低于D轮，D轮投资人的转换价格直接调整至下一轮价格，不考虑融资金额差异。市场上B轮以后通常采用加权平均(Broad-Based Weighted Average)。建议坚持加权平均。如果投资方坚持，可以在加权平均基础上加上Pay-to-Play条款作为交换条件。",
      status: "PendingAnalysis",
      dealId: delta.id,
      workstreamId: wsDeltaSpa.id,
    },
  });

  await prisma.decision.create({
    data: {
      title: "回购权期限及触发条件",
      background: "投资方要求5年未上市即可触发回购权，回购价格为投资金额+8%年化利息。创始人需对回购义务承担连带责任。",
      source: "Negotiation",
      analysis: "5年上市对赌在目前IPO环境下偏紧。建议谈到7年，且触发条件应加限定（如'非因公司原因未能上市'）。创始人连带责任建议限于重大违约情形，不应覆盖一般回购。可参考近期同行业D轮案例：平均回购期限6-7年，利率6-8%。",
      status: "PendingAnalysis",
      dealId: delta.id,
      workstreamId: wsDeltaSpa.id,
    },
  });

  await prisma.decision.create({
    data: {
      title: "优先清算权倍数及参与方式",
      background: "投资方要求1.5倍非参与型优先清算权(1.5x Non-Participating Liquidation Preference)。Term Sheet中约定1x。",
      source: "Negotiation",
      analysis: "Term Sheet明确约定1x非参与型，正式文件中变成1.5x属于条款升级。建议坚持Term Sheet约定的1x。如投资方要求溢价，可考虑1x参与型（参与后cap at 3x）作为替代方案——但需评估对未来轮次的影响。",
      clientDecision: "客户同意坚持1x非参与型，以Term Sheet为准。",
      status: "Decided",
      dealId: delta.id,
      workstreamId: wsDeltaSha.id,
    },
  });

  // ── Activity Entries ──────────────────────────────────────────
  const deltaActivities = [
    { type: "Note" as const, content: "项目启动。智元数据CEO陈明哲经合伙人朋友介绍委托本所担任D轮融资法律顾问。客户之前轮次使用的是方达律师事务所。", date: "2026-01-10", author: liWei.id },
    { type: "Meeting" as const, content: "Kick-off会议。出席：陈明哲（CEO）、孙洁（CFO）、李伟、何欣、王浩。了解公司业务、融资历史、本轮诉求。客户核心关注：控制权不被稀释、回购条款不要太苛刻、ESOP池调整最小化。", date: "2026-01-12", author: liWei.id },
    { type: "Note" as const, content: "审阅客户现有股权架构和前轮融资文件（B轮红杉、C轮高瓴的SPA/SHA）。确认D轮不会触发反稀释（D轮估值高于C轮）。现有SHA中的优先认购权需要处理。", date: "2026-01-15", author: heXin.id },
    { type: "Note" as const, content: "Term Sheet已签署。核心条款：Pre-money ¥10亿，投资¥2.5亿，D轮优先股，1x非参与型优先清算权，加权平均反稀释，5+2年回购，远景基金获1个董事会席位。", date: "2026-01-20", author: liWei.id },
    { type: "ClientInstruction" as const, content: "客户指示：回购条款5年太短，底线是6年，争取7年。创始人担保坚决不接受覆盖一般R&W。ESOP池从12%调到10%可以接受。", date: "2026-01-22", author: liWei.id },
    { type: "Note" as const, content: "投资方尽调正式启动。君合律所代表远景基金发来法律尽调资料清单（126项）。财务尽调由毕马威负责。", date: "2026-01-25", author: zhouJing.id },
    { type: "Note" as const, content: "配合尽调过程中发现两个需要整改的问题：(1) 3项软件著作权登记主体不一致；(2) 部分竞业禁止协议缺补偿金条款。已启动整改流程。", date: "2026-02-10", author: heXin.id },
    { type: "Note" as const, content: "投资方尽调基本完成。君合出具的法律尽调报告未发现Deal Breaker。财务尽调（毕马威）亦无重大发现。软著权整改和竞业协议补签已完成。", date: "2026-02-28", author: heXin.id },
    { type: "Note" as const, content: "收到投资方律师起草的SPA和SHA初稿。SPA 68页，SHA 45页。开始逐条审阅。", date: "2026-03-03", author: liWei.id },
    { type: "Meeting" as const, content: "SPA/SHA审阅策略内部会议。讨论重点条款及谈判策略。发现投资方律师多处条款超出Term Sheet约定（反稀释改为全面棘轮、优先清算权从1x改为1.5x、新增领售权条款）。需与客户确认谈判底线。", date: "2026-03-05", author: liWei.id },
    { type: "ClientInstruction" as const, content: "客户CEO陈明哲明确指示：超出Term Sheet的条款一律拒绝。反稀释必须加权平均，优先清算权1x，领售权如果一定要加则必须设最低价格门槛（不低于D轮估值的2倍）。", date: "2026-03-06", author: liWei.id },
    { type: "Call" as const, content: "与红杉王思聪电话，沟通D轮进入事宜。红杉确认不行使优先认购权，将出具正式放弃函。", date: "2026-03-08", author: wangHao.id },
    { type: "Call" as const, content: "与高瓴张雅琪电话。高瓴同样确认不行使优先认购权。但提出一个条件：希望D轮SHA中增加'共售权跟随比例不低于10%'的条款。已转达客户。", date: "2026-03-09", author: wangHao.id },
  ];

  for (const act of deltaActivities) {
    await prisma.activityEntry.create({
      data: {
        type: act.type,
        content: act.content,
        dealId: delta.id,
        authorId: act.author,
        createdAt: new Date(act.date),
      },
    });
  }

  // ── Task Comments ─────────────────────────────────────────────
  await prisma.taskComment.createMany({
    data: [
      {
        content: "SPA第12条陈述与保证中，知识产权R&W要求公司保证'不存在任何侵权或潜在侵权'。这个表述过于绝对，建议改为'据公司所知'(to the best knowledge of the Company)限定。",
        taskId: taskDeltaSpaReview.id,
        authorId: liWei.id,
        createdAt: new Date("2026-03-08"),
      },
      {
        content: "SPA第18条特别赔偿条款要求创始人对所有R&W违反承担连带赔偿责任，无上限。这远超Term Sheet约定。建议：创始人担保仅限于(1)股权权属、(2)竞业禁止、(3)关联交易三项特别赔偿，且设cap为投资金额的30%。",
        taskId: taskDeltaSpaReview.id,
        authorId: heXin.id,
        createdAt: new Date("2026-03-10"),
      },
      {
        content: "SHA第8条反稀释条款采用全面棘轮写法，与Term Sheet约定的加权平均不一致。这是重大分歧。已标记为A级谈判议题。",
        taskId: taskDeltaShaReview.id,
        authorId: heXin.id,
        createdAt: new Date("2026-03-09"),
      },
      {
        content: "SHA第15条新增了领售权(Drag-Along)条款，Term Sheet中未出现。投资方律师的版本：D轮后3年，如投资人要求出售，创始人和其他股东必须跟售。这对融资方极为不利。建议坚持删除，或加严格限定（价格门槛+多数投资人同意）。",
        taskId: taskDeltaShaReview.id,
        authorId: heXin.id,
        createdAt: new Date("2026-03-11"),
      },
      {
        content: "红杉已确认放弃优先认购权，正式函件预计本周五前发来。高瓴那边的共售权比例条件，客户表示可以接受——10%的共售跟随比例合理。",
        taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "现有股东知情同意" } } }))!.id,
        authorId: wangHao.id,
        createdAt: new Date("2026-03-10"),
      },
    ],
  });

  // ── Delta Billing Rates ──────────────────────────────────────
  await prisma.dealBillingRate.createMany({
    data: [
      { dealId: delta.id, userId: liWei.id, ratePerHour: 4500, currency: "CNY" },
      { dealId: delta.id, userId: heXin.id, ratePerHour: 2200, currency: "CNY" },
      { dealId: delta.id, userId: wangHao.id, ratePerHour: 2500, currency: "CNY" },
      { dealId: delta.id, userId: zhouJing.id, ratePerHour: 1800, currency: "CNY" },
    ],
  });

  // ── Delta Time Entries ──────────────────────────────────────
  await prisma.timeEntry.createMany({
    data: [
      // 李伟 — 合伙人，Term Sheet谈判及SPA审阅
      { description: "项目启动、了解客户融资历史及本轮诉求", durationMinutes: 120, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: "签署委托协议" } }))!.id, userId: liWei.id, dealId: delta.id, createdAt: new Date("2026-01-10") },
      { description: "Term Sheet条款审阅及谈判策略讨论", durationMinutes: 180, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "Term Sheet谈判" } } }))!.id, userId: liWei.id, dealId: delta.id, createdAt: new Date("2026-01-15") },
      { description: "SPA/SHA审阅策略内部会议", durationMinutes: 120, isManual: true, isBillable: true, taskId: taskDeltaSpaReview.id, userId: liWei.id, dealId: delta.id, createdAt: new Date("2026-03-05") },
      { description: "SPA先决条件及陈述与保证条款审阅", durationMinutes: 300, isManual: true, isBillable: true, taskId: taskDeltaSpaReview.id, userId: liWei.id, dealId: delta.id, createdAt: new Date("2026-03-08") },
      { description: "SPA特别赔偿及违约条款审阅", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskDeltaSpaReview.id, userId: liWei.id, dealId: delta.id, createdAt: new Date("2026-03-10") },
      { description: "与客户CEO讨论谈判底线", durationMinutes: 90, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "SPA/SHA核心条款谈判策略" } } }))!.id, userId: liWei.id, dealId: delta.id, createdAt: new Date("2026-03-06") },

      // 何欣 — SHA审阅及尽调配合
      { description: "审阅现有B轮/C轮融资文件（红杉、高瓴SHA）", durationMinutes: 240, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "准备尽调资料" } } }))!.id, userId: heXin.id, dealId: delta.id, createdAt: new Date("2026-01-15") },
      { description: "回复投资方律师尽调补充问题（38项）", durationMinutes: 360, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "审阅并回复投资方" } } }))!.id, userId: heXin.id, dealId: delta.id, createdAt: new Date("2026-02-15") },
      { description: "软著权整改 — 名称变更登记申请材料准备", durationMinutes: 120, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "处理尽调发现" } } }))!.id, userId: heXin.id, dealId: delta.id, createdAt: new Date("2026-02-12") },
      { description: "竞业禁止协议补充条款起草", durationMinutes: 90, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "处理尽调发现" } } }))!.id, userId: heXin.id, dealId: delta.id, createdAt: new Date("2026-02-18") },
      { description: "SHA董事会组成及表决机制条款审阅", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskDeltaShaReview.id, userId: heXin.id, dealId: delta.id, createdAt: new Date("2026-03-06") },
      { description: "SHA反稀释条款分析 — 全面棘轮 vs 加权平均比较备忘录", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskDeltaShaReview.id, userId: heXin.id, dealId: delta.id, createdAt: new Date("2026-03-09") },
      { description: "SHA领售权及优先清算权条款审阅", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskDeltaShaReview.id, userId: heXin.id, dealId: delta.id, createdAt: new Date("2026-03-11") },

      // 王浩 — 交割前准备及股东沟通
      { description: "与红杉沟通D轮优先认购权放弃事宜", durationMinutes: 60, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "现有股东知情同意" } } }))!.id, userId: wangHao.id, dealId: delta.id, createdAt: new Date("2026-03-08") },
      { description: "与高瓴沟通 — 放弃优先认购权及共售权比例条件", durationMinutes: 90, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "现有股东知情同意" } } }))!.id, userId: wangHao.id, dealId: delta.id, createdAt: new Date("2026-03-09") },

      // 周静 — 尽调资料协调
      { description: "协调客户各部门准备尽调资料（126项清单）", durationMinutes: 480, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "准备尽调资料" } } }))!.id, userId: zhouJing.id, dealId: delta.id, createdAt: new Date("2026-01-28") },
      { description: "管理层访谈安排协调（CTO、CFO、技术VP）", durationMinutes: 60, isManual: true, isBillable: false, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "协调管理层" } } }))!.id, userId: zhouJing.id, dealId: delta.id, createdAt: new Date("2026-02-10") },
      { description: "创始人配偶确认函起草及协调签署", durationMinutes: 90, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: delta.id }, title: { contains: "创始人配偶" } } }))!.id, userId: zhouJing.id, dealId: delta.id, createdAt: new Date("2026-03-05") },
    ],
  });

  console.log("✅ Project Delta created: Series D financing, SPA/SHA review stage, 5 workstreams, 20+ tasks, 6 contacts, 3 decisions, 13 activity entries, 17 time entries, 4 billing rates");
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });
