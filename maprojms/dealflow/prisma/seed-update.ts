import { PrismaClient, DealPhase, DealSource } from "../src/generated/prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  // ════════════════════════════════════════════════════════════════
  // Part 1: Update Project Alpha — DD完成，进入Key Issue List阶段
  // ════════════════════════════════════════════════════════════════

  const alpha = await prisma.deal.findFirst({ where: { name: "Project Alpha" } });
  if (!alpha) throw new Error("Project Alpha not found. Run seed-demo.ts first.");

  const liWei = await prisma.user.findUnique({ where: { email: "li.wei@jingtian.com" } });
  const zhangLin = await prisma.user.findUnique({ where: { email: "zhang.lin@jingtian.com" } });
  const wangHao = await prisma.user.findUnique({ where: { email: "wang.hao@jingtian.com" } });
  const chenYu = await prisma.user.findUnique({ where: { email: "chen.yu@jingtian.com" } });
  const liuMing = await prisma.user.findUnique({ where: { email: "liu.ming@jingtian.com" } });
  const zhouJing = await prisma.user.findUnique({ where: { email: "zhou.jing@jingtian.com" } });

  if (!liWei || !zhangLin || !wangHao || !chenYu || !liuMing || !zhouJing) {
    throw new Error("Team members not found");
  }

  // Mark DD Phase 2, IP DD, Environmental DD as Done
  await prisma.task.updateMany({
    where: {
      workstream: { dealId: alpha.id, name: "尽职调查" },
      title: { in: [
        "第二阶段尽调 — 深入调查及管理层访谈",
        "知识产权专项尽调",
        "环境合规尽调",
      ] },
    },
    data: { status: "Done" },
  });

  // Mark all subtasks of DD Phase 2 as done
  const ddPhase2 = await prisma.task.findFirst({
    where: { workstream: { dealId: alpha.id }, title: { contains: "第二阶段尽调" } },
  });
  if (ddPhase2) {
    await prisma.subtask.updateMany({
      where: { taskId: ddPhase2.id },
      data: { isDone: true },
    });
  }

  // Key Issue List task → InProgress
  await prisma.task.updateMany({
    where: {
      workstream: { dealId: alpha.id, name: "尽职调查" },
      title: { contains: "Key Issue List" },
    },
    data: { status: "InProgress" },
  });

  // Mark DD milestone as done
  await prisma.milestone.updateMany({
    where: { dealId: alpha.id, name: "尽调完成" },
    data: { isDone: true, date: new Date("2026-03-11") },
  });

  // Advance deal phase to Negotiation (DD complete, SPA drafting underway)
  await prisma.deal.update({
    where: { id: alpha.id },
    data: { phase: DealPhase.Negotiation },
  });

  // Add activity entries
  await prisma.activityEntry.createMany({
    data: [
      {
        type: "Note",
        content: "管理层面谈完成（3月25-26日Stuttgart现场）。CEO Dr. Müller确认退休后6个月过渡期。CTO Dr. Hoffmann表示愿意留任。关键客户Bosch和Continental的合同续约前景良好。",
        dealId: alpha.id,
        authorId: zhangLin.id,
        createdAt: new Date("2026-03-26"),
      },
      {
        type: "Note",
        content: "知识产权尽调完成。37项专利权属清晰，无质押。前员工专利纠纷（案号7 O 158/25）经德国律师评估，预计最大风险敞口€250K，建议在SPA中设special indemnity。员工发明人补偿义务已全部清偿。",
        dealId: alpha.id,
        authorId: wangHao.id,
        createdAt: new Date("2026-03-28"),
      },
      {
        type: "Note",
        content: "环境尽调完成。ERM出具Phase II环境报告：Stuttgart工厂土壤重金属含量在限值范围内，无需修复。但建议交割后定期监测。历史电镀车间区域已于2010年封闭处理，无额外义务。",
        dealId: alpha.id,
        authorId: chenYu.id,
        createdAt: new Date("2026-04-02"),
      },
      {
        type: "Meeting",
        content: "尽调总结内部会议。全部工作组尽调报告已收齐。主要发现：(1) IP纠纷风险可控；(2) 环境无重大问题；(3) 3份客户合同含变更控制条款需通知；(4) 劳动合同整体合规，works council需提前沟通。开始编制Key Issue List。",
        dealId: alpha.id,
        authorId: zhangLin.id,
        createdAt: new Date("2026-04-05"),
      },
      {
        type: "ClientInstruction",
        content: "客户指示：环境问题既然可控，不再要求价格调整。IP纠纷用special indemnity处理即可。请尽快完成Key Issue List，安排董事会汇报。",
        dealId: alpha.id,
        authorId: liWei.id,
        createdAt: new Date("2026-04-06"),
      },
    ],
  });

  // Update environmental decision to Decided
  await prisma.decision.updateMany({
    where: { dealId: alpha.id, title: { contains: "环境风险" } },
    data: {
      status: "Decided",
      clientDecision: "环境尽调结果显示土壤指标在限值范围内，无修复义务。客户决定不要求价格调整，仅在SPA中加入环境相关R&W和定期监测义务。",
    },
  });

  console.log("✅ Project Alpha updated: DD complete, Key Issue List in progress");

  // ════════════════════════════════════════════════════════════════
  // Part 2: Create Project Beta
  // ════════════════════════════════════════════════════════════════

  const passwordHash = await bcrypt.hash("password123", 10);

  // Add 2 new team members for Beta
  const heXin = await prisma.user.upsert({
    where: { email: "he.xin@jingtian.com" },
    update: {},
    create: {
      name: "何欣",
      email: "he.xin@jingtian.com",
      passwordHash,
      role: "Member",
      locale: "zh",
    },
  });

  const yangFei = await prisma.user.upsert({
    where: { email: "yang.fei@jingtian.com" },
    update: {},
    create: {
      name: "杨飞",
      email: "yang.fei@jingtian.com",
      passwordHash,
      role: "Member",
      locale: "en",
    },
  });

  const admin = await prisma.user.findUnique({ where: { email: "admin@dealflow.local" } });

  const beta = await prisma.deal.create({
    data: {
      name: "Project Beta",
      codeName: "Beta",
      dealType: "Auction",
      ourRole: "BuySide",
      clientName: "中远海运国际贸易有限公司",
      targetCompany: "Duval Industries Kft. (匈牙利子公司)",
      jurisdictions: ["PRC", "France", "Hungary", "EU"],
      status: "Active",
      phase: DealPhase.DueDiligence,
      dealValue: 60000000,
      valueCurrency: "EUR",
      keyTerms: "EV/EBITDA 7-8x，竞标流程(两轮NBO→BO)，匈牙利政府补贴合规为关键风险点",
      source: DealSource.DirectClient,
      summary:
        "中远海运国际拟收购法国Duval集团旗下匈牙利子公司Duval Industries Kft.的100%股权。目标公司为布达佩斯汽车零部件制造商，年营收约€45M，员工约320人。卖方Duval SA (Paris)聘请Rothschild作为财务顾问，采用竞标流程出售。本项目现处于Phase 1阶段，需在4月15日前提交Non-Binding Offer。交易预估价值€55-65M。涉及中国ODI备案、匈牙利外商投资审查及欧盟反垄断分析。",
      dealLeadId: liWei.id,
    },
  });

  // Deal members
  await prisma.dealMember.createMany({
    data: [
      { dealId: beta.id, userId: liWei.id },
      { dealId: beta.id, userId: heXin.id },
      { dealId: beta.id, userId: yangFei.id },
      { dealId: beta.id, userId: wangHao.id },
      { dealId: beta.id, userId: chenYu.id },
      { dealId: beta.id, userId: admin!.id },
    ],
    skipDuplicates: true,
  });

  // ── Milestones ────────────────────────────────────────────────
  await prisma.milestone.createMany({
    data: [
      { name: "NDA签署", type: "Contractual", date: new Date("2026-02-20"), isDone: true, sortOrder: 0, dealId: beta.id },
      { name: "VDR开通", type: "External", date: new Date("2026-03-01"), isDone: true, sortOrder: 1, dealId: beta.id },
      { name: "NBO截止", type: "External", date: new Date("2026-04-15"), isDone: false, sortOrder: 2, dealId: beta.id },
      { name: "Phase 2入围通知", type: "External", date: new Date("2026-05-01"), isDone: false, sortOrder: 3, dealId: beta.id },
      { name: "管理层面谈", type: "External", date: new Date("2026-05-20"), isDone: false, sortOrder: 4, dealId: beta.id },
      { name: "BO截止", type: "External", date: new Date("2026-06-30"), isDone: false, sortOrder: 5, dealId: beta.id },
      { name: "SPA签署", type: "Contractual", date: null, isDone: false, sortOrder: 6, dealId: beta.id },
      { name: "交割", type: "Contractual", date: null, isDone: false, sortOrder: 7, dealId: beta.id },
    ],
  });

  // ── WS1: Phase 1 尽调 ────────────────────────────────────────
  const wsDd = await prisma.workstream.create({
    data: { name: "Phase 1 尽职调查", sortOrder: 0, dealId: beta.id },
  });

  const taskBetaNda = await prisma.task.create({
    data: {
      title: "签署NDA并获取VDR访问权限",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-20"),
      assigneeId: heXin.id,
      workstreamId: wsDd.id,
      sortOrder: 0,
    },
  });

  const taskBetaVdr = await prisma.task.create({
    data: {
      title: "VDR文件索引及分工",
      description: "VDR由Rothschild通过Intralinks平台提供，共1,842份文件。已按工作组分配审阅任务。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-03-05"),
      assigneeId: heXin.id,
      workstreamId: wsDd.id,
      sortOrder: 1,
    },
  });

  const taskBetaDdLegal = await prisma.task.create({
    data: {
      title: "法律尽调 — 公司、合同、劳动",
      description: "审阅目标公司匈牙利法律文件。重点：(1) Kft.章程及股东决议；(2) 重大商业合同（前10大客户/供应商）；(3) 匈牙利劳动法合规（320名员工，含works council）；(4) 不动产租赁（布达佩斯工厂租赁至2032年）。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-04-01"),
      assigneeId: heXin.id,
      workstreamId: wsDd.id,
      sortOrder: 2,
    },
  });

  await prisma.subtask.createMany({
    data: [
      { title: "公司章程及股东文件审阅", isDone: true, sortOrder: 0, taskId: taskBetaDdLegal.id },
      { title: "重大合同审阅（15份）", isDone: false, sortOrder: 1, taskId: taskBetaDdLegal.id },
      { title: "劳动合同及集体协议审阅", isDone: false, sortOrder: 2, taskId: taskBetaDdLegal.id },
      { title: "不动产租赁协议审阅", isDone: false, sortOrder: 3, taskId: taskBetaDdLegal.id },
      { title: "诉讼/仲裁档案审阅", isDone: false, sortOrder: 4, taskId: taskBetaDdLegal.id },
    ],
  });

  const taskBetaDdHungary = await prisma.task.create({
    data: {
      title: "协调匈牙利当地律所尽调",
      description: "已聘请DLA Piper Budapest办公室负责匈牙利法律尽调。重点：匈牙利公司法、劳动法、环境法、政府补贴合规。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-04-05"),
      assigneeId: yangFei.id,
      workstreamId: wsDd.id,
      sortOrder: 3,
    },
  });

  const taskBetaDdIp = await prisma.task.create({
    data: {
      title: "知识产权及技术许可审阅",
      description: "目标公司使用部分母公司Duval SA的技术许可。需审阅：(1) 技术许可协议条款及交割后延续性；(2) 目标公司自有专利（12项匈牙利/EU专利）；(3) 商标使用权（Duval品牌过渡期使用安排）。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-04-05"),
      assigneeId: wangHao.id,
      workstreamId: wsDd.id,
      sortOrder: 4,
    },
  });

  const taskBetaDdGrant = await prisma.task.create({
    data: {
      title: "匈牙利政府补贴合规审查",
      description: "目标公司2022年获得匈牙利政府€3M投资补贴（用于新生产线），附带就业维持及投资金额承诺至2027年。需确认：交割是否触发补贴退还义务。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-04-08"),
      assigneeId: yangFei.id,
      workstreamId: wsDd.id,
      sortOrder: 5,
    },
  });

  // ── WS2: NBO准备 ─────────────────────────────────────────────
  const wsNbo = await prisma.workstream.create({
    data: { name: "NBO准备", sortOrder: 1, dealId: beta.id },
  });

  const taskBetaValuation = await prisma.task.create({
    data: {
      title: "估值分析及报价策略",
      description: "与客户财务顾问CICC协调。初步估值：EV/EBITDA 7-8x，对应€55-65M。需考虑：匈牙利制造成本优势、Duval品牌过渡安排、政府补贴风险折价。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-04-10"),
      assigneeId: liWei.id,
      workstreamId: wsNbo.id,
      sortOrder: 0,
    },
  });

  const taskBetaNboLetter = await prisma.task.create({
    data: {
      title: "起草NBO函件",
      description: "按Process Letter要求准备NBO。内容：报价范围、交易结构概述、融资确认函、尽调确认要求、关键假设条件、预期时间表。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-04-12"),
      assigneeId: heXin.id,
      workstreamId: wsNbo.id,
      sortOrder: 1,
    },
  });

  await prisma.subtask.createMany({
    data: [
      { title: "NBO主体函件起草", isDone: true, sortOrder: 0, taskId: taskBetaNboLetter.id },
      { title: "融资确认函（中国银行）", isDone: false, sortOrder: 1, taskId: taskBetaNboLetter.id },
      { title: "交易结构说明附件", isDone: false, sortOrder: 2, taskId: taskBetaNboLetter.id },
      { title: "Phase 2尽调需求清单", isDone: false, sortOrder: 3, taskId: taskBetaNboLetter.id },
      { title: "客户审阅及签署", isDone: false, sortOrder: 4, taskId: taskBetaNboLetter.id },
    ],
  });

  const taskBetaStructure = await prisma.task.create({
    data: {
      title: "拟定交易结构方案",
      description: "方案选项：(1) 直接收购Kft. 100%股权（share deal）；(2) 通过香港SPV收购。需考虑中匈税收协定（股息预提税5%）、匈牙利9%企业所得税优势、母公司Duval SA的卖方担保能力。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-04-08"),
      assigneeId: wangHao.id,
      workstreamId: wsNbo.id,
      sortOrder: 2,
    },
  });

  const taskBetaClientApproval = await prisma.task.create({
    data: {
      title: "NBO提交前客户审批",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-04-13"),
      assigneeId: liWei.id,
      workstreamId: wsNbo.id,
      sortOrder: 3,
    },
  });

  // ── WS3: 监管初步分析 ────────────────────────────────────────
  const wsReg = await prisma.workstream.create({
    data: { name: "监管审批（初步分析）", sortOrder: 2, dealId: beta.id },
  });

  await prisma.task.create({
    data: {
      title: "梳理各法域所需审批",
      description: "初步确认：(1) 中国ODI备案（发改委+商务部）；(2) 匈牙利外商投资审查（2024年新规扩大审查范围至制造业）；(3) 欧盟反垄断（取决于营业额测试）；(4) 法国方面无需审批（卖方为法国公司，但标的在匈牙利）。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-03-15"),
      assigneeId: chenYu.id,
      workstreamId: wsReg.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "匈牙利外商投资审查预分析",
      description: "匈牙利2024年扩大外商投资筛查范围。目标公司属于制造业，中国买方可能触发审查。与DLA Piper Budapest确认申报要求及预计审批周期。",
      status: "InProgress",
      priority: "Normal",
      dueDate: new Date("2026-04-10"),
      assigneeId: yangFei.id,
      workstreamId: wsReg.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "反垄断申报门槛分析",
      description: "需分析是否触发匈牙利GVH和/或欧盟EUMR申报门槛。中远海运集团全球营收远超门槛，关键看目标公司在匈牙利和EU的营收分布。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-04-12"),
      assigneeId: yangFei.id,
      workstreamId: wsReg.id,
      sortOrder: 2,
    },
  });

  // ── WS4: 客户沟通 ────────────────────────────────────────────
  const wsClient = await prisma.workstream.create({
    data: { name: "客户沟通与策略", sortOrder: 3, dealId: beta.id },
  });

  await prisma.task.create({
    data: {
      title: "签署委托协议",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-15"),
      assigneeId: liWei.id,
      workstreamId: wsClient.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "竞标策略讨论",
      description: "与客户及CICC讨论竞标策略。已知至少3家竞标方。客户竞争优势：(1) 与目标公司现有供应链互补；(2) 可承诺维持匈牙利就业；(3) 融资确定性高。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-03-10"),
      assigneeId: liWei.id,
      workstreamId: wsClient.id,
      sortOrder: 1,
    },
  });

  await prisma.task.create({
    data: {
      title: "Phase 1尽调发现汇报及NBO策略确认",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-04-10"),
      assigneeId: liWei.id,
      workstreamId: wsClient.id,
      sortOrder: 2,
    },
  });

  // ── Task Dependencies ─────────────────────────────────────────
  await prisma.taskDependency.createMany({
    data: [
      { type: "Blocks", taskId: taskBetaNboLetter.id, dependsOnTaskId: taskBetaValuation.id },
      { type: "Blocks", taskId: taskBetaClientApproval.id, dependsOnTaskId: taskBetaNboLetter.id },
      { type: "RelatedTo", taskId: taskBetaNboLetter.id, dependsOnTaskId: taskBetaDdLegal.id },
      { type: "RelatedTo", taskId: taskBetaStructure.id, dependsOnTaskId: taskBetaDdGrant.id },
    ],
  });

  // ── Contacts ──────────────────────────────────────────────────
  const contactBetaClient = await prisma.contact.create({
    data: {
      name: "马宏远",
      organization: "中远海运国际贸易有限公司",
      role: "Client",
      title: "副总经理",
      phone: "+86 21 6596 8888",
      email: "ma.hongyuan@cosco-intl.com",
      timezone: "Asia/Shanghai",
      notes: "项目负责人。曾主导过2次欧洲收购，熟悉跨境交易流程。",
    },
  });

  const contactBetaClientLegal = await prisma.contact.create({
    data: {
      name: "林婷",
      organization: "中远海运国际贸易有限公司",
      role: "Client",
      title: "法务经理",
      phone: "+86 21 6596 8899",
      email: "lin.ting@cosco-intl.com",
      timezone: "Asia/Shanghai",
      notes: "日常对接人。负责内部审批及合规确认。",
    },
  });

  const contactBetaSeller = await prisma.contact.create({
    data: {
      name: "Jean-Pierre Duval",
      organization: "Duval SA",
      role: "Other",
      title: "PDG (CEO)",
      phone: "+33 1 4567 8900",
      email: "jp.duval@duval-group.fr",
      timezone: "Europe/Paris",
      notes: "卖方集团CEO。出售匈牙利子公司是集团战略收缩的一部分。",
    },
  });

  const contactBetaSellerCounsel = await prisma.contact.create({
    data: {
      name: "Maître Sophie Laurent",
      organization: "Bredin Prat",
      role: "CounterpartyCounsel",
      title: "Associée (Partner)",
      phone: "+33 1 4456 1234",
      email: "sophie.laurent@bredinprat.com",
      timezone: "Europe/Paris",
      notes: "卖方法律顾问。法国顶级M&A律所。",
    },
  });

  const contactBetaLocalCounsel = await prisma.contact.create({
    data: {
      name: "Dr. András Kovács",
      organization: "DLA Piper Budapest",
      role: "ExternalCounsel",
      title: "Partner",
      phone: "+36 1 510 1100",
      email: "andras.kovacs@dlapiper.com",
      timezone: "Europe/Budapest",
      notes: "我方匈牙利当地律师。负责匈牙利法律尽调、外商投资审查及公司法事务。",
    },
  });

  const contactBetaFA = await prisma.contact.create({
    data: {
      name: "陈思远",
      organization: "中国国际金融股份有限公司(CICC)",
      role: "FA",
      title: "副总裁",
      phone: "+86 10 6505 1166",
      email: "chen.siyuan@cicc.com.cn",
      timezone: "Asia/Shanghai",
      notes: "客户财务顾问。负责估值分析和竞标策略。",
    },
  });

  const contactBetaRothschild = await prisma.contact.create({
    data: {
      name: "Philippe Martin",
      organization: "Rothschild & Co",
      role: "FA",
      title: "Managing Director",
      phone: "+33 1 4013 4567",
      email: "philippe.martin@rothschildandco.com",
      timezone: "Europe/Paris",
      notes: "卖方财务顾问，竞标流程管理人。所有Process相关沟通通过其进行。",
    },
  });

  await prisma.dealContact.createMany({
    data: [
      { dealId: beta.id, contactId: contactBetaClient.id, roleInDeal: "客户项目负责人" },
      { dealId: beta.id, contactId: contactBetaClientLegal.id, roleInDeal: "客户法务对接人" },
      { dealId: beta.id, contactId: contactBetaSeller.id, roleInDeal: "卖方集团CEO" },
      { dealId: beta.id, contactId: contactBetaSellerCounsel.id, roleInDeal: "卖方律师" },
      { dealId: beta.id, contactId: contactBetaLocalCounsel.id, roleInDeal: "匈牙利当地律师" },
      { dealId: beta.id, contactId: contactBetaFA.id, roleInDeal: "客户财务顾问" },
      { dealId: beta.id, contactId: contactBetaRothschild.id, roleInDeal: "卖方财务顾问/流程管理" },
    ],
  });

  // ── Decisions ─────────────────────────────────────────────────
  await prisma.decision.create({
    data: {
      title: "NBO报价范围确定",
      background: "卖方指导价约€60M (EV basis)。CICC估值模型显示EV/EBITDA 6.5-8x区间合理（参考近期欧洲汽车零部件交易）。需确定NBO报价策略：激进争取入围 vs. 保守留有谈判空间。",
      source: "Negotiation",
      analysis: "竞标环境下需平衡竞争力与价格纪律。建议NBO报价区间€58-63M，表达对目标公司的诚意，同时为Phase 2保留调整空间。已知竞争方包括一家土耳其企业和一家印度企业。",
      status: "PendingAnalysis",
      dealId: beta.id,
      workstreamId: wsNbo.id,
    },
  });

  await prisma.decision.create({
    data: {
      title: "交易结构选择：直接收购 vs. SPV",
      background: "需确定收购主体：中远海运国际直接收购 vs. 通过香港/新加坡SPV。匈牙利企业所得税仅9%（欧盟最低），对中间控股架构的税务筹划空间有限。",
      source: "Other",
      analysis: "待税务顾问正式意见。初步分析：匈牙利本身税率极低，中间控股层节税效果不如Project Alpha（德国）案明显。但考虑集团整体资金管理，香港SPV仍有一定灵活性优势。",
      status: "PendingAnalysis",
      dealId: beta.id,
      workstreamId: wsNbo.id,
    },
  });

  await prisma.decision.create({
    data: {
      title: "母公司技术许可过渡安排",
      background: "目标公司部分产品使用Duval SA的专有技术（Technical License Agreement至2028年）。如交割后Duval SA终止许可，将影响约30%产品线。",
      source: "DDFinding",
      status: "PendingAnalysis",
      dealId: beta.id,
      workstreamId: wsDd.id,
    },
  });

  // ── Activity Entries ──────────────────────────────────────────
  const betaActivities = [
    { type: "Note" as const, content: "项目启动。中远海运国际委托本所作为跨境收购中国法律顾问。同步聘请DLA Piper Budapest负责匈牙利法律事务。", date: "2026-02-15", author: liWei.id },
    { type: "Meeting" as const, content: "客户Kick-off会议。出席：马宏远（客户副总）、林婷（客户法务）、陈思远（CICC）、李伟、何欣、杨飞。讨论竞标策略、时间线和团队分工。", date: "2026-02-18", author: liWei.id },
    { type: "Note" as const, content: "NDA已签署。通过Rothschild获取Process Letter和初步信息备忘录(IM)。竞标流程分两轮：Phase 1 NBO (4月15日) → Phase 2 BO (6月30日)。", date: "2026-02-20", author: heXin.id },
    { type: "Note" as const, content: "VDR已开通（Intralinks平台），共1,842份文件。按法律/财务/税务/商业四个维度分配审阅任务。", date: "2026-03-01", author: heXin.id },
    { type: "Call" as const, content: "与DLA Piper Dr. Kovács电话。确认匈牙利尽调范围和时间表。特别关注：(1) 政府补贴条件合规；(2) 2024年新外商投资审查规定；(3) works council沟通要求。", date: "2026-03-05", author: yangFei.id },
    { type: "Meeting" as const, content: "竞标策略讨论会。与客户及CICC确认NBO策略：报价区间€58-63M，强调产业协同和就业承诺。CICC将准备估值报告。", date: "2026-03-10", author: liWei.id },
    { type: "ClientInstruction" as const, content: "客户指示：NBO报价不超过€65M。如能入围Phase 2再做深入评估。政府补贴退还风险需提前评估清楚。", date: "2026-03-10", author: liWei.id },
    { type: "Note" as const, content: "初步发现：目标公司与母公司间存在多项关联交易（管理费、技术许可费、共享服务），需在SPA中要求独立运营安排或TSA。", date: "2026-03-15", author: heXin.id },
    { type: "Call" as const, content: "与Rothschild Philippe Martin电话。确认Phase 1时间线不变，NBO截止4月15日。目前约5-6家潜在买方进入VDR。", date: "2026-03-18", author: liWei.id },
  ];

  for (const act of betaActivities) {
    await prisma.activityEntry.create({
      data: {
        type: act.type,
        content: act.content,
        dealId: beta.id,
        authorId: act.author,
        createdAt: new Date(act.date),
      },
    });
  }

  // ── Task Comments ─────────────────────────────────────────────
  await prisma.taskComment.createMany({
    data: [
      {
        content: "VDR中发现目标公司2022年获得匈牙利政府补贴€3M，附带5年就业维持承诺。如交割后裁员可能触发补贴退还。这是重大风险点，需在NBO中标注为关键假设。",
        taskId: taskBetaDdLegal.id,
        authorId: heXin.id,
        createdAt: new Date("2026-03-12"),
      },
      {
        content: "匈牙利当地律所确认：根据2024年修订的外商投资筛查法(FDI Screening Act)，制造业领域的中国买方收购需向经济部提交通知。审查期约60天。建议在时间线中预留。",
        taskId: taskBetaDdHungary.id,
        authorId: yangFei.id,
        createdAt: new Date("2026-03-08"),
      },
      {
        content: "目标公司与Duval SA的Technical License Agreement（2022年签署，期限至2028年）中含变更控制条款：控制权变更需卖方书面同意，否则可终止。这是关键谈判点。",
        taskId: taskBetaDdIp.id,
        authorId: wangHao.id,
        createdAt: new Date("2026-03-14"),
      },
      {
        content: "CICC初步估值：基于目标公司FY2025 EBITDA €8.2M，可比交易EV/EBITDA中位数7.5x，隐含EV约€61.5M。考虑匈牙利低税率溢价和政府补贴风险折价后，建议NBO中心价€60M。",
        taskId: taskBetaValuation.id,
        authorId: liWei.id,
        createdAt: new Date("2026-03-11"),
      },
    ],
  });

  // ── Beta Billing Rates ───────────────────────────────────────
  await prisma.dealBillingRate.createMany({
    data: [
      { dealId: beta.id, userId: liWei.id, ratePerHour: 4500, currency: "CNY" },
      { dealId: beta.id, userId: heXin.id, ratePerHour: 2200, currency: "CNY" },
      { dealId: beta.id, userId: yangFei.id, ratePerHour: 2200, currency: "CNY" },
      { dealId: beta.id, userId: wangHao.id, ratePerHour: 2500, currency: "CNY" },
      { dealId: beta.id, userId: chenYu.id, ratePerHour: 2500, currency: "CNY" },
    ],
  });

  // ── Beta Time Entries ───────────────────────────────────────
  await prisma.timeEntry.createMany({
    data: [
      // 李伟 — 合伙人
      { description: "项目启动、委托协议签署、团队组建", durationMinutes: 90, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: beta.id }, title: "签署委托协议" } }))!.id, userId: liWei.id, dealId: beta.id, createdAt: new Date("2026-02-15") },
      { description: "竞标策略讨论会 — 与客户及CICC确认报价策略", durationMinutes: 180, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: beta.id }, title: { contains: "竞标策略" } } }))!.id, userId: liWei.id, dealId: beta.id, createdAt: new Date("2026-03-10") },
      { description: "与Rothschild电话 — 确认竞标时间线和买方数量", durationMinutes: 45, isManual: true, isBillable: true, taskId: taskBetaValuation.id, userId: liWei.id, dealId: beta.id, createdAt: new Date("2026-03-18") },
      { description: "NBO估值分析讨论及报价策略审阅", durationMinutes: 120, isManual: true, isBillable: true, taskId: taskBetaValuation.id, userId: liWei.id, dealId: beta.id, createdAt: new Date("2026-04-01") },

      // 何欣 — Phase 1尽调主力
      { description: "NDA签署协调及VDR访问权限获取", durationMinutes: 60, isManual: true, isBillable: true, taskId: taskBetaNda.id, userId: heXin.id, dealId: beta.id, createdAt: new Date("2026-02-20") },
      { description: "VDR文件索引、按工作组分配审阅任务", durationMinutes: 120, isManual: true, isBillable: true, taskId: taskBetaVdr.id, userId: heXin.id, dealId: beta.id, createdAt: new Date("2026-03-02") },
      { description: "法律尽调 — 公司章程及股东决议审阅", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskBetaDdLegal.id, userId: heXin.id, dealId: beta.id, createdAt: new Date("2026-03-08") },
      { description: "法律尽调 — 重大合同审阅（15份，进行中）", durationMinutes: 360, isManual: true, isBillable: true, taskId: taskBetaDdLegal.id, userId: heXin.id, dealId: beta.id, createdAt: new Date("2026-03-15") },
      { description: "NBO函件主体框架起草", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskBetaNboLetter.id, userId: heXin.id, dealId: beta.id, createdAt: new Date("2026-03-25") },
      { description: "关联交易梳理及独立运营安排分析", durationMinutes: 120, isManual: true, isBillable: true, taskId: taskBetaDdLegal.id, userId: heXin.id, dealId: beta.id, createdAt: new Date("2026-03-20") },

      // 杨飞 — 匈牙利当地律所协调
      { description: "与DLA Piper Budapest对接，确认尽调范围和匈牙利法律事项", durationMinutes: 120, isManual: true, isBillable: true, taskId: taskBetaDdHungary.id, userId: yangFei.id, dealId: beta.id, createdAt: new Date("2026-03-05") },
      { description: "匈牙利外商投资审查规定研究", durationMinutes: 240, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: beta.id }, title: { contains: "匈牙利外商投资" } } }))!.id, userId: yangFei.id, dealId: beta.id, createdAt: new Date("2026-03-12") },
      { description: "DLA Piper匈牙利尽调中期报告审阅", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskBetaDdHungary.id, userId: yangFei.id, dealId: beta.id, createdAt: new Date("2026-03-20") },

      // 王浩 — 交易结构
      { description: "交易结构方案比较（直接收购 vs 香港SPV），考虑中匈税收协定", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskBetaStructure.id, userId: wangHao.id, dealId: beta.id, createdAt: new Date("2026-03-10") },
      { description: "知识产权及技术许可审阅 — Duval SA技术许可协议分析", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskBetaDdIp.id, userId: wangHao.id, dealId: beta.id, createdAt: new Date("2026-03-14") },

      // 陈宇 — 监管
      { description: "各法域审批清单梳理（PRC ODI、匈牙利FDI、欧盟反垄断）", durationMinutes: 180, isManual: true, isBillable: true, taskId: (await prisma.task.findFirst({ where: { workstream: { dealId: beta.id }, title: "梳理各法域所需审批" } }))!.id, userId: chenYu.id, dealId: beta.id, createdAt: new Date("2026-03-12") },
    ],
  });

  console.log("✅ Project Beta created: Auction buy-side, NBO stage, 4 workstreams, 15+ tasks, 7 contacts, 3 decisions, 9 activity entries, 17 time entries, 5 billing rates");
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });
