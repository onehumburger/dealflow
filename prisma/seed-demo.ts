import { PrismaClient } from "../src/generated/prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash("password123", 10);

  // ── Team Members ──────────────────────────────────────────────
  const admin = await prisma.user.findUnique({ where: { email: "admin@dealflow.local" } });
  if (!admin) throw new Error("Run `npx prisma db seed` first to create admin user");

  const liWei = await prisma.user.upsert({
    where: { email: "li.wei@jingtian.com" },
    update: {},
    create: {
      name: "李伟",
      email: "li.wei@jingtian.com",
      passwordHash,
      role: "Admin",
      locale: "zh",
    },
  });

  const zhangLin = await prisma.user.upsert({
    where: { email: "zhang.lin@jingtian.com" },
    update: {},
    create: {
      name: "张琳",
      email: "zhang.lin@jingtian.com",
      passwordHash,
      role: "Member",
      locale: "zh",
    },
  });

  const wangHao = await prisma.user.upsert({
    where: { email: "wang.hao@jingtian.com" },
    update: {},
    create: {
      name: "王浩",
      email: "wang.hao@jingtian.com",
      passwordHash,
      role: "Member",
      locale: "zh",
    },
  });

  const chenYu = await prisma.user.upsert({
    where: { email: "chen.yu@jingtian.com" },
    update: {},
    create: {
      name: "陈宇",
      email: "chen.yu@jingtian.com",
      passwordHash,
      role: "Member",
      locale: "zh",
    },
  });

  const liuMing = await prisma.user.upsert({
    where: { email: "liu.ming@jingtian.com" },
    update: {},
    create: {
      name: "刘明",
      email: "liu.ming@jingtian.com",
      passwordHash,
      role: "Member",
      locale: "en",
    },
  });

  const zhouJing = await prisma.user.upsert({
    where: { email: "zhou.jing@jingtian.com" },
    update: {},
    create: {
      name: "周静",
      email: "zhou.jing@jingtian.com",
      passwordHash,
      role: "Member",
      locale: "zh",
    },
  });

  // ── Deal: Project Alpha ───────────────────────────────────────
  const deal = await prisma.deal.create({
    data: {
      name: "Project Alpha",
      codeName: "Alpha",
      dealType: "Negotiated",
      ourRole: "BuySide",
      clientName: "华鑫精密制造集团有限公司",
      targetCompany: "Müller Präzisionstechnik GmbH",
      jurisdictions: ["PRC", "Germany", "Hong Kong"],
      status: "Active",
      summary:
        "华鑫集团拟通过其香港子公司收购德国Müller精密技术有限公司100%股权。目标公司为巴登-符腾堡州精密零部件制造商，年营收约€85M，拥有多项精密加工专利。交易价值约€120M，采用无现金无负债基础定价，含锁箱机制。涉及中国境外投资备案(ODI)、德国外商投资审查(AWV §55)及欧盟反垄断申报。",
      dealLeadId: liWei.id,
    },
  });

  // Deal members
  await prisma.dealMember.createMany({
    data: [
      { dealId: deal.id, userId: liWei.id },
      { dealId: deal.id, userId: zhangLin.id },
      { dealId: deal.id, userId: wangHao.id },
      { dealId: deal.id, userId: chenYu.id },
      { dealId: deal.id, userId: liuMing.id },
      { dealId: deal.id, userId: zhouJing.id },
      { dealId: deal.id, userId: admin.id },
    ],
    skipDuplicates: true,
  });

  // ── Milestones ────────────────────────────────────────────────
  const milestones = await Promise.all([
    prisma.milestone.create({
      data: {
        name: "NDA签署",
        type: "Contractual",
        date: new Date("2026-01-15"),
        isDone: true,
        sortOrder: 0,
        dealId: deal.id,
      },
    }),
    prisma.milestone.create({
      data: {
        name: "LOI签署",
        type: "Contractual",
        date: new Date("2026-02-10"),
        isDone: true,
        sortOrder: 1,
        dealId: deal.id,
      },
    }),
    prisma.milestone.create({
      data: {
        name: "尽调完成",
        type: "Internal",
        date: new Date("2026-04-15"),
        isDone: false,
        sortOrder: 2,
        dealId: deal.id,
      },
    }),
    prisma.milestone.create({
      data: {
        name: "SPA签署",
        type: "Contractual",
        date: new Date("2026-05-30"),
        isDone: false,
        sortOrder: 3,
        dealId: deal.id,
      },
    }),
    prisma.milestone.create({
      data: {
        name: "德国外商投资审批",
        type: "Regulatory",
        date: new Date("2026-07-15"),
        isDone: false,
        sortOrder: 4,
        dealId: deal.id,
      },
    }),
    prisma.milestone.create({
      data: {
        name: "中国ODI备案完成",
        type: "Regulatory",
        date: new Date("2026-06-30"),
        isDone: false,
        sortOrder: 5,
        dealId: deal.id,
      },
    }),
    prisma.milestone.create({
      data: {
        name: "交割",
        type: "Contractual",
        date: new Date("2026-08-15"),
        isDone: false,
        sortOrder: 6,
        dealId: deal.id,
      },
    }),
  ]);

  // ── Workstreams & Tasks ───────────────────────────────────────

  // WS1: Due Diligence
  const wsDd = await prisma.workstream.create({
    data: { name: "尽职调查", sortOrder: 0, dealId: deal.id },
  });

  const taskNda = await prisma.task.create({
    data: {
      title: "签署NDA并获取VDR访问权限",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-01-15"),
      assigneeId: zhangLin.id,
      workstreamId: wsDd.id,
      sortOrder: 0,
    },
  });

  const taskDdCoord = await prisma.task.create({
    data: {
      title: "协调德国当地律所进行法律尽调",
      description: "与Gleiss Lutz律所对接，明确尽调范围、时间线和报告格式。重点关注劳动法、环境合规及知识产权。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-20"),
      assigneeId: liuMing.id,
      workstreamId: wsDd.id,
      sortOrder: 1,
    },
  });

  const taskDdPhase1 = await prisma.task.create({
    data: {
      title: "第一阶段尽调 — 法律、财务、税务框架性审阅",
      description: "审阅VDR中2,300+份文件。法律重点：公司章程、重大合同、劳动合同、知识产权登记、诉讼档案、环境许可。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-03-10"),
      assigneeId: zhangLin.id,
      workstreamId: wsDd.id,
      sortOrder: 2,
    },
  });

  const taskDdPhase2 = await prisma.task.create({
    data: {
      title: "第二阶段尽调 — 深入调查及管理层访谈",
      description: "针对Phase 1发现的问题进行深入调查。安排管理层面谈，重点了解：关键客户依赖度、技术人员留任计划、环境修复义务、未决劳资纠纷。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-04-05"),
      assigneeId: zhangLin.id,
      workstreamId: wsDd.id,
      sortOrder: 3,
    },
  });

  const taskDdReport = await prisma.task.create({
    data: {
      title: "编制Key Issue List和DD Summary Report",
      description: "汇总各工作组尽调发现，编制关键问题清单。按红/黄/绿分类标注风险等级，提出SPA中需要对应保护条款的建议。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-04-12"),
      assigneeId: zhangLin.id,
      workstreamId: wsDd.id,
      sortOrder: 4,
    },
  });

  const taskDdIp = await prisma.task.create({
    data: {
      title: "知识产权专项尽调",
      description: "审阅目标公司37项专利注册情况（德国、欧洲专利局），确认专利权属清晰、无质押或许可冲突。审查员工发明人补偿义务（德国ArbNErfG）。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-03-25"),
      assigneeId: wangHao.id,
      workstreamId: wsDd.id,
      sortOrder: 5,
    },
  });

  const taskDdEnv = await prisma.task.create({
    data: {
      title: "环境合规尽调",
      description: "目标公司Stuttgart工厂涉及金属加工及化学品使用，需审查：BImSchG许可证、废水排放许可、土壤污染历史检测报告、REACH合规记录。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-03-30"),
      assigneeId: chenYu.id,
      workstreamId: wsDd.id,
      sortOrder: 6,
    },
  });

  // DD subtasks
  await prisma.subtask.createMany({
    data: [
      { title: "VDR访问权限已获取", isDone: true, sortOrder: 0, taskId: taskDdPhase2.id },
      { title: "管理层面谈日程已确认（3月25-26日现场）", isDone: true, sortOrder: 1, taskId: taskDdPhase2.id },
      { title: "劳动法深入审阅完成", isDone: false, sortOrder: 2, taskId: taskDdPhase2.id },
      { title: "重大合同变更控制条款审阅完成", isDone: false, sortOrder: 3, taskId: taskDdPhase2.id },
      { title: "管理层面谈纪要整理完成", isDone: false, sortOrder: 4, taskId: taskDdPhase2.id },
    ],
  });

  // WS2: SPA & Documentation
  const wsSpa = await prisma.workstream.create({
    data: { name: "SPA及交易文件", sortOrder: 1, dealId: deal.id },
  });

  const taskLoi = await prisma.task.create({
    data: {
      title: "谈判并签署LOI/意向书",
      description: "LOI核心条款：€120M对价（无现金无负债基础），锁箱机制（锁箱日2025年12月31日），排他期60天，分手费€2M。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-10"),
      assigneeId: liWei.id,
      workstreamId: wsSpa.id,
      sortOrder: 0,
    },
  });

  const taskSpaDraft = await prisma.task.create({
    data: {
      title: "起草SPA（买方版本）",
      description: "基于LOI条款起草SPA。重点：锁箱保护条款（Permitted Leakage清单）、陈述与保证（含知识产权、环境、劳动专项R&W）、赔偿机制（de minimis €50K, basket €1.2M, cap €24M）、W&I保险配合条款。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-04-20"),
      assigneeId: liWei.id,
      workstreamId: wsSpa.id,
      sortOrder: 1,
    },
  });

  await prisma.subtask.createMany({
    data: [
      { title: "SPA主体框架完成", isDone: true, sortOrder: 0, taskId: taskSpaDraft.id },
      { title: "陈述与保证条款起草", isDone: true, sortOrder: 1, taskId: taskSpaDraft.id },
      { title: "赔偿条款起草", isDone: false, sortOrder: 2, taskId: taskSpaDraft.id },
      { title: "先决条件条款起草", isDone: false, sortOrder: 3, taskId: taskSpaDraft.id },
      { title: "锁箱保护条款及Permitted Leakage清单", isDone: false, sortOrder: 4, taskId: taskSpaDraft.id },
      { title: "附件（Disclosure Schedules）", isDone: false, sortOrder: 5, taskId: taskSpaDraft.id },
    ],
  });

  const taskSpaReview = await prisma.task.create({
    data: {
      title: "SPA谈判 — 与卖方律师交换意见",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-05-10"),
      assigneeId: liWei.id,
      workstreamId: wsSpa.id,
      sortOrder: 2,
    },
  });

  const taskSpaFinal = await prisma.task.create({
    data: {
      title: "SPA定稿及签署",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-05-30"),
      assigneeId: liWei.id,
      workstreamId: wsSpa.id,
      sortOrder: 3,
    },
  });

  const taskTsa = await prisma.task.create({
    data: {
      title: "起草过渡服务协议(TSA)",
      description: "卖方同意在交割后6个月内继续提供IT系统、财务共享中心及部分行政服务。明确服务范围、SLA、费用及退出机制。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-05-15"),
      assigneeId: zhangLin.id,
      workstreamId: wsSpa.id,
      sortOrder: 4,
    },
  });

  // WS3: Regulatory
  const wsReg = await prisma.workstream.create({
    data: { name: "监管审批", sortOrder: 2, dealId: deal.id },
  });

  const taskRegId = await prisma.task.create({
    data: {
      title: "梳理各法域所需审批清单",
      description: "已确认需要的审批：(1) 中国商务部/发改委ODI备案；(2) 外管局资金出境登记；(3) 德国经济和气候保护部(BMWK)外商投资审查（AWV §55）；(4) 欧盟反垄断申报待确认（取决于营业额测试）。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-28"),
      assigneeId: chenYu.id,
      workstreamId: wsReg.id,
      sortOrder: 0,
    },
  });

  const taskOdi = await prisma.task.create({
    data: {
      title: "办理中国ODI备案（发改委+商务部）",
      description: "发改委项目备案 → 商务部境外投资备案 → 外管局登记。预计周期：2-3个月。需准备：项目信息说明、投资协议、资金来源说明、境外投资申请表等。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-06-30"),
      assigneeId: chenYu.id,
      workstreamId: wsReg.id,
      sortOrder: 1,
    },
  });

  await prisma.subtask.createMany({
    data: [
      { title: "发改委备案材料准备完成", isDone: true, sortOrder: 0, taskId: taskOdi.id },
      { title: "发改委备案已提交", isDone: true, sortOrder: 1, taskId: taskOdi.id },
      { title: "发改委备案通过", isDone: false, sortOrder: 2, taskId: taskOdi.id },
      { title: "商务部备案材料准备", isDone: false, sortOrder: 3, taskId: taskOdi.id },
      { title: "商务部备案提交及获批", isDone: false, sortOrder: 4, taskId: taskOdi.id },
      { title: "外管局登记", isDone: false, sortOrder: 5, taskId: taskOdi.id },
    ],
  });

  const taskAwv = await prisma.task.create({
    data: {
      title: "德国外商投资审查（AWV §55）",
      description: "目标公司涉及精密制造技术，属于德国BMWK审查范围。需提交投资审查申请，审查期2个月（可延长至4个月）。已与德国律所确认申报策略。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-07-15"),
      assigneeId: liuMing.id,
      workstreamId: wsReg.id,
      sortOrder: 2,
    },
  });

  const taskAntitrust = await prisma.task.create({
    data: {
      title: "反垄断申报分析",
      description: "基于华鑫集团和Müller的营业额数据，分析是否触发德国GWB和欧盟EUMR申报门槛。初步判断：德国国内申报可能触发，欧盟层面不触发。",
      status: "InProgress",
      priority: "Normal",
      dueDate: new Date("2026-03-20"),
      assigneeId: liuMing.id,
      workstreamId: wsReg.id,
      sortOrder: 3,
    },
  });

  const taskSafe = await prisma.task.create({
    data: {
      title: "外管局资金出境登记及汇款",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-08-01"),
      assigneeId: chenYu.id,
      workstreamId: wsReg.id,
      sortOrder: 4,
    },
  });

  // WS4: Deal Structure & Tax
  const wsTax = await prisma.workstream.create({
    data: { name: "交易结构与税务", sortOrder: 3, dealId: deal.id },
  });

  const taskVehicle = await prisma.task.create({
    data: {
      title: "确认收购主体架构",
      description: "最终架构：华鑫集团 → 华鑫(香港)控股 → 德国SPV(GmbH) → 目标公司。香港作为中间控股层，利用中德税收协定降低股息预提税。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-02-15"),
      assigneeId: wangHao.id,
      workstreamId: wsTax.id,
      sortOrder: 0,
    },
  });

  const taskTaxAdvice = await prisma.task.create({
    data: {
      title: "获取跨境税务架构意见",
      description: "已聘请PWC提供税务意见。关注点：转让定价、利润汇回路径、增值税链条、德国不动产转让税(RETT)、反避税条款。",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-03-01"),
      assigneeId: wangHao.id,
      workstreamId: wsTax.id,
      sortOrder: 1,
    },
  });

  const taskFinancing = await prisma.task.create({
    data: {
      title: "融资安排确认",
      description: "融资方案：自有资金40%（约€48M）+ 中国银行并购贷款60%（约€72M）。贷款已获原则性批复，需完成正式贷款协议。",
      status: "InProgress",
      priority: "High",
      dueDate: new Date("2026-05-15"),
      assigneeId: wangHao.id,
      workstreamId: wsTax.id,
      sortOrder: 2,
    },
  });

  const taskWi = await prisma.task.create({
    data: {
      title: "W&I保险投保",
      description: "拟投保买方W&I保险，保额€24M（即SPA赔偿上限）。已联系AIG和Zurich询价，预计保费约€500K。需配合保险公司完成独立尽调确认。",
      status: "ToDo",
      priority: "Normal",
      dueDate: new Date("2026-05-20"),
      assigneeId: zhangLin.id,
      workstreamId: wsTax.id,
      sortOrder: 3,
    },
  });

  // WS5: Client Communication
  const wsClient = await prisma.workstream.create({
    data: { name: "客户沟通与策略", sortOrder: 4, dealId: deal.id },
  });

  await prisma.task.create({
    data: {
      title: "签署委托协议",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-01-10"),
      assigneeId: liWei.id,
      workstreamId: wsClient.id,
      sortOrder: 0,
    },
  });

  await prisma.task.create({
    data: {
      title: "LOI谈判策略讨论",
      status: "Done",
      priority: "High",
      dueDate: new Date("2026-01-30"),
      assigneeId: liWei.id,
      workstreamId: wsClient.id,
      sortOrder: 1,
    },
  });

  const taskClientBrief = await prisma.task.create({
    data: {
      title: "向客户汇报尽调关键发现及SPA策略",
      description: "准备中文PPT向客户董事会汇报：(1) 尽调主要发现及风险评估；(2) SPA核心条款建议；(3) 监管审批时间线；(4) 总体交易时间表更新。",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-04-18"),
      assigneeId: liWei.id,
      workstreamId: wsClient.id,
      sortOrder: 2,
    },
  });

  await prisma.task.create({
    data: {
      title: "签署前客户最终审批",
      status: "ToDo",
      priority: "High",
      dueDate: new Date("2026-05-25"),
      assigneeId: liWei.id,
      workstreamId: wsClient.id,
      sortOrder: 3,
    },
  });

  // WS6: Conditions Precedent
  const wsCp = await prisma.workstream.create({
    data: { name: "先决条件跟踪", sortOrder: 5, dealId: deal.id },
  });

  await prisma.task.create({
    data: { title: "德国BMWK投资审批", status: "ToDo", priority: "High", workstreamId: wsCp.id, sortOrder: 0 },
  });
  await prisma.task.create({
    data: { title: "中国ODI备案完成", status: "ToDo", priority: "High", workstreamId: wsCp.id, sortOrder: 1 },
  });
  await prisma.task.create({
    data: { title: "反垄断审批（如需要）", status: "ToDo", priority: "Normal", workstreamId: wsCp.id, sortOrder: 2 },
  });
  await prisma.task.create({
    data: { title: "目标公司关键客户变更控制同意函", status: "ToDo", priority: "Normal", workstreamId: wsCp.id, sortOrder: 3 },
  });
  await prisma.task.create({
    data: { title: "目标公司股东会决议", status: "ToDo", priority: "Normal", workstreamId: wsCp.id, sortOrder: 4 },
  });
  await prisma.task.create({
    data: { title: "买方董事会决议", status: "ToDo", priority: "Normal", workstreamId: wsCp.id, sortOrder: 5 },
  });
  await prisma.task.create({
    data: { title: "无重大不利变化确认", status: "ToDo", priority: "Normal", workstreamId: wsCp.id, sortOrder: 6 },
  });
  await prisma.task.create({
    data: { title: "双方法律意见书", status: "ToDo", priority: "Normal", workstreamId: wsCp.id, sortOrder: 7 },
  });
  await prisma.task.create({
    data: { title: "外管局登记及资金汇出", status: "ToDo", priority: "High", workstreamId: wsCp.id, sortOrder: 8 },
  });

  // WS7: Closing Checklist
  const wsClosing = await prisma.workstream.create({
    data: { name: "交割清单", sortOrder: 6, dealId: deal.id },
  });

  await prisma.task.create({
    data: { title: "收集各方签字页", status: "ToDo", priority: "Normal", workstreamId: wsClosing.id, sortOrder: 0 },
  });
  await prisma.task.create({
    data: { title: "董事会决议签署", status: "ToDo", priority: "Normal", workstreamId: wsClosing.id, sortOrder: 1 },
  });
  await prisma.task.create({
    data: { title: "各法域法律意见书交付", status: "ToDo", priority: "Normal", workstreamId: wsClosing.id, sortOrder: 2 },
  });
  await prisma.task.create({
    data: { title: "汇款指令确认", status: "ToDo", priority: "Normal", workstreamId: wsClosing.id, sortOrder: 3 },
  });
  await prisma.task.create({
    data: { title: "交割资金到账确认", status: "ToDo", priority: "High", workstreamId: wsClosing.id, sortOrder: 4 },
  });
  await prisma.task.create({
    data: { title: "德国商业登记变更（Handelsregister）", status: "ToDo", priority: "Normal", workstreamId: wsClosing.id, sortOrder: 5 },
  });
  await prisma.task.create({
    data: { title: "交割后通知（员工、客户、供应商）", status: "ToDo", priority: "Normal", workstreamId: wsClosing.id, sortOrder: 6 },
  });
  await prisma.task.create({
    data: { title: "归档交割文件夹", status: "ToDo", priority: "Normal", workstreamId: wsClosing.id, sortOrder: 7 },
  });

  // ── Task Dependencies ─────────────────────────────────────────
  await prisma.taskDependency.createMany({
    data: [
      { type: "Blocks", taskId: taskDdReport.id, dependsOnTaskId: taskDdPhase2.id },
      { type: "Blocks", taskId: taskDdReport.id, dependsOnTaskId: taskDdIp.id },
      { type: "Blocks", taskId: taskDdReport.id, dependsOnTaskId: taskDdEnv.id },
      { type: "Blocks", taskId: taskSpaReview.id, dependsOnTaskId: taskSpaDraft.id },
      { type: "Blocks", taskId: taskSpaFinal.id, dependsOnTaskId: taskSpaReview.id },
      { type: "Blocks", taskId: taskClientBrief.id, dependsOnTaskId: taskDdReport.id },
      { type: "Blocks", taskId: taskAwv.id, dependsOnTaskId: taskSpaFinal.id },
      { type: "Blocks", taskId: taskSafe.id, dependsOnTaskId: taskOdi.id },
      { type: "RelatedTo", taskId: taskWi.id, dependsOnTaskId: taskSpaDraft.id },
      { type: "RelatedTo", taskId: taskFinancing.id, dependsOnTaskId: taskSpaDraft.id },
    ],
  });

  // ── Task Comments ─────────────────────────────────────────────
  await prisma.taskComment.createMany({
    data: [
      {
        content: "已与Gleiss Lutz的Dr. Schmidt确认尽调范围和报告格式，预计3月5日前完成Phase 1报告初稿。",
        taskId: taskDdCoord.id,
        authorId: liuMing.id,
        createdAt: new Date("2026-02-18"),
      },
      {
        content: "VDR中发现目标公司与前员工有一起专利权属纠纷（案号：Landgericht Stuttgart 7 O 158/25），金额约€300K。需进一步评估。",
        taskId: taskDdIp.id,
        authorId: wangHao.id,
        createdAt: new Date("2026-03-12"),
      },
      {
        content: "已联系PWC德国办公室确认，本次交易不会触发RETT（目标公司名下无不动产，厂房为租赁）。",
        taskId: taskTaxAdvice.id,
        authorId: wangHao.id,
        createdAt: new Date("2026-02-25"),
      },
      {
        content: "发改委备案窗口目前审批效率较高，2-3周内应有结果。商务部备案可在发改委批复后同步准备材料。",
        taskId: taskOdi.id,
        authorId: chenYu.id,
        createdAt: new Date("2026-03-08"),
      },
      {
        content: "客户确认：可接受的最高对价为€125M。如尽调发现重大问题，需重新讨论价格调整机制。",
        taskId: taskLoi.id,
        authorId: liWei.id,
        createdAt: new Date("2026-02-05"),
      },
      {
        content: "SPA框架已参考ICC model。锁箱日定为2025.12.31，与卖方财务顾问确认了锁箱期间Permitted Leakage的初步清单。",
        taskId: taskSpaDraft.id,
        authorId: liWei.id,
        createdAt: new Date("2026-03-15"),
      },
      {
        content: "初步分析：华鑫集团全球营收¥28亿（约€3.5亿），Müller营收€85M。德国申报门槛（合并营收€500M）可能触发，需进一步确认华鑫集团合并口径。",
        taskId: taskAntitrust.id,
        authorId: liuMing.id,
        createdAt: new Date("2026-03-10"),
      },
    ],
  });

  // ── Decisions ─────────────────────────────────────────────────
  const decVehicle = await prisma.decision.create({
    data: {
      title: "收购架构选择",
      background: "需确定华鑫集团收购Müller的持股架构。直接持股 vs. 通过香港/新加坡中间控股公司持股，涉及税务效率、资金出境便利性及未来退出灵活性。",
      source: "Other",
      analysis: "经PWC税务意见确认，通过香港中间控股公司持股可享受中德税收协定优惠（股息预提税5% vs. 直接持股的10%），且香港不征收资本利得税，有利于未来退出。新加坡方案税务效果类似但额外增加一层架构复杂度。",
      clientDecision: "采用香港控股架构。华鑫(香港)控股有限公司已设立完成。",
      status: "Implemented",
      dealId: deal.id,
      workstreamId: wsTax.id,
    },
  });

  await prisma.decisionOption.createMany({
    data: [
      { description: "方案A：华鑫集团直接收购Müller 100%股权", prosAndCons: "优点：架构简单。缺点：股息预提税10%，资金出境需逐笔审批。", sortOrder: 0, decisionId: decVehicle.id },
      { description: "方案B：通过华鑫(香港)控股收购（推荐）", prosAndCons: "优点：股息预提税降至5%，香港无资本利得税，资金调度灵活。缺点：需维护香港公司。", sortOrder: 1, decisionId: decVehicle.id },
      { description: "方案C：通过新加坡SPV收购", prosAndCons: "优点：税务效果与香港类似。缺点：多一层架构，华鑫在新加坡无现有实体。", sortOrder: 2, decisionId: decVehicle.id },
    ],
  });

  await prisma.decisionTaskLink.create({
    data: { decisionId: decVehicle.id, taskId: taskVehicle.id },
  });

  const decWi = await prisma.decision.create({
    data: {
      title: "是否投保W&I保险",
      background: "卖方要求将SPA赔偿上限降至€6M（对价的5%）。客户希望维持€24M（20%）的赔偿保护。W&I保险可弥补差距。",
      source: "Negotiation",
      analysis: "W&I保险可将赔偿保护提升至€24M而不增加卖方负担。市场报价约€480-520K（保额的2%），含18个月保单期。关键排除事项：已知事项、罚款、环境修复（需单独购买环境险）。建议投保。",
      status: "PendingAnalysis",
      dealId: deal.id,
      workstreamId: wsSpa.id,
    },
  });

  await prisma.decisionOption.createMany({
    data: [
      { description: "投保W&I保险（推荐）", prosAndCons: "优点：保护到位，加速谈判。缺点：约€500K保费成本。", sortOrder: 0, decisionId: decWi.id },
      { description: "不投保，坚持SPA赔偿上限€24M", prosAndCons: "优点：无额外成本。缺点：可能导致谈判僵持。", sortOrder: 1, decisionId: decWi.id },
      { description: "折中方案：SPA赔偿上限€12M + W&I保险补足至€24M", prosAndCons: "优点：双方各让一步。缺点：保费仍需支付。", sortOrder: 2, decisionId: decWi.id },
    ],
  });

  await prisma.decisionTaskLink.create({
    data: { decisionId: decWi.id, taskId: taskWi.id },
  });

  const decEnvRisk = await prisma.decision.create({
    data: {
      title: "目标公司环境风险应对方案",
      background: "Phase 1尽调发现目标公司Stuttgart工厂2019年土壤检测报告显示部分区域重金属含量接近限值。工厂建于1965年，历史上曾从事电镀加工。",
      source: "DDFinding",
      analysis: "待Phase 2环境尽调结果确认后决定。如确认存在修复义务，可能的应对包括：价格调整、环境赔偿专项条款（escrow）、或要求卖方在交割前完成修复。",
      status: "PendingAnalysis",
      dealId: deal.id,
      workstreamId: wsDd.id,
    },
  });

  await prisma.decisionTaskLink.create({
    data: { decisionId: decEnvRisk.id, taskId: taskDdEnv.id },
  });

  // ── Contacts ──────────────────────────────────────────────────
  const contactClient = await prisma.contact.create({
    data: {
      name: "赵建国",
      organization: "华鑫精密制造集团有限公司",
      role: "Client",
      title: "董事长",
      phone: "+86 21 5888 6666",
      email: "zhao.jianguo@huaxin-group.com",
      timezone: "Asia/Shanghai",
      notes: "决策人。偏好微信沟通。每周三下午3点定期电话会。",
    },
  });

  const contactClientGC = await prisma.contact.create({
    data: {
      name: "孙丽华",
      organization: "华鑫精密制造集团有限公司",
      role: "Client",
      title: "法务总监",
      phone: "+86 21 5888 6688",
      email: "sun.lihua@huaxin-group.com",
      timezone: "Asia/Shanghai",
      notes: "日常对接人。英文流利。负责内部审批流程协调。",
    },
  });

  const contactSeller = await prisma.contact.create({
    data: {
      name: "Dr. Klaus Müller",
      organization: "Müller Präzisionstechnik GmbH",
      role: "Other",
      title: "Geschäftsführer (Managing Director)",
      phone: "+49 711 888 5500",
      email: "k.mueller@mueller-praezision.de",
      timezone: "Europe/Berlin",
      notes: "卖方创始人兼总经理。退休是出售原因。同意在交割后担任6个月顾问。",
    },
  });

  const contactSellerCounsel = await prisma.contact.create({
    data: {
      name: "Dr. Anna Weber",
      organization: "Hengeler Mueller",
      role: "CounterpartyCounsel",
      title: "Partner",
      phone: "+49 211 8304 200",
      email: "anna.weber@hengeler.com",
      timezone: "Europe/Berlin",
      notes: "卖方律师，负责SPA谈判。风格务实但细节导向。",
    },
  });

  const contactLocalCounsel = await prisma.contact.create({
    data: {
      name: "Dr. Thomas Schmidt",
      organization: "Gleiss Lutz",
      role: "ExternalCounsel",
      title: "Counsel",
      phone: "+49 711 8997 123",
      email: "thomas.schmidt@gleisslutz.com",
      timezone: "Europe/Berlin",
      notes: "我方聘请的德国当地律所，负责德国法律尽调及AWV申报。",
    },
  });

  const contactFA = await prisma.contact.create({
    data: {
      name: "Michael Chen",
      organization: "华泰联合证券",
      role: "FA",
      title: "执行董事",
      phone: "+86 10 6621 1166",
      email: "michael.chen@htsc.com",
      timezone: "Asia/Shanghai",
      notes: "客户财务顾问。负责估值、融资安排及整体交易协调。",
    },
  });

  const contactAccountant = await prisma.contact.create({
    data: {
      name: "Lisa Wang",
      organization: "PricewaterhouseCoopers",
      role: "Accountant",
      title: "Director, International Tax",
      phone: "+86 21 2323 8888",
      email: "lisa.wang@cn.pwc.com",
      timezone: "Asia/Shanghai",
      notes: "负责财税尽调和跨境税务架构。与PWC德国办公室协调。",
    },
  });

  const contactRegulator = await prisma.contact.create({
    data: {
      name: "张处长",
      organization: "国家发展和改革委员会外资司",
      role: "Regulator",
      title: "处长",
      phone: "+86 10 6850 xxxx",
      timezone: "Asia/Shanghai",
      notes: "ODI备案对接窗口。",
    },
  });

  // Link contacts to deal
  await prisma.dealContact.createMany({
    data: [
      { dealId: deal.id, contactId: contactClient.id, roleInDeal: "客户决策人" },
      { dealId: deal.id, contactId: contactClientGC.id, roleInDeal: "客户法务对接人" },
      { dealId: deal.id, contactId: contactSeller.id, roleInDeal: "卖方/目标公司管理层" },
      { dealId: deal.id, contactId: contactSellerCounsel.id, roleInDeal: "卖方律师" },
      { dealId: deal.id, contactId: contactLocalCounsel.id, roleInDeal: "德国当地律师" },
      { dealId: deal.id, contactId: contactFA.id, roleInDeal: "客户财务顾问" },
      { dealId: deal.id, contactId: contactAccountant.id, roleInDeal: "税务顾问" },
      { dealId: deal.id, contactId: contactRegulator.id, roleInDeal: "发改委对接人" },
    ],
  });

  // ── Activity Entries ──────────────────────────────────────────
  const activities = [
    { type: "Note" as const, content: "项目启动。华鑫集团委托本所作为中国法律顾问，负责跨境收购的全程法律服务。", date: "2026-01-08", author: liWei.id },
    { type: "Meeting" as const, content: "客户Kick-off会议。出席：赵建国（客户董事长）、孙丽华（客户法务总监）、李伟、张琳、刘明。确认交易时间线目标及团队分工。", date: "2026-01-10", author: liWei.id },
    { type: "Note" as const, content: "NDA已签署。与卖方律师Hengeler Mueller交换已签署的双向NDA。", date: "2026-01-15", author: zhangLin.id },
    { type: "Call" as const, content: "与Gleiss Lutz Dr. Schmidt电话，讨论德国法律尽调范围和时间表。确认2月底前完成Phase 1报告。", date: "2026-01-20", author: liuMing.id },
    { type: "ClientInstruction" as const, content: "客户指示：可接受最高对价€125M。锁箱机制优先于completion accounts。排他期至少45天。", date: "2026-01-28", author: liWei.id },
    { type: "Meeting" as const, content: "LOI谈判会议（视频）。与卖方律师Dr. Weber就LOI核心条款进行了3小时谈判。主要分歧：排他期长度和分手费金额。", date: "2026-02-03", author: liWei.id },
    { type: "Note" as const, content: "LOI已签署。最终条款：€120M对价，锁箱日2025.12.31，60天排他期，€2M分手费。", date: "2026-02-10", author: liWei.id },
    { type: "Note" as const, content: "VDR已开通，共有2,347份文件。已安排团队按工作流分工开始审阅。", date: "2026-02-12", author: zhangLin.id },
    { type: "Call" as const, content: "与PWC Lisa Wang电话，确认税务架构建议采用香港中间控股方案。将出具正式税务意见。", date: "2026-02-20", author: wangHao.id },
    { type: "Meeting" as const, content: "内部尽调进度会议。Phase 1进度约60%。初步发现：(1) 前员工专利权属纠纷；(2) 部分客户合同含变更控制条款；(3) Stuttgart工厂土壤检测历史数据需关注。", date: "2026-03-05", author: zhangLin.id },
    { type: "ClientInstruction" as const, content: "客户指示：专利纠纷问题需深入评估。如金额可控（<€1M）可接受，否则需在SPA中设专项赔偿条款。", date: "2026-03-08", author: liWei.id },
    { type: "Call" as const, content: "与发改委张处长沟通ODI备案材料清单。确认本项目属于备案类（非核准类），流程相对简化。", date: "2026-03-10", author: chenYu.id },
    { type: "Note" as const, content: "发改委备案材料已正式提交。等待审批。", date: "2026-03-11", author: chenYu.id },
  ];

  for (const act of activities) {
    await prisma.activityEntry.create({
      data: {
        type: act.type,
        content: act.content,
        dealId: deal.id,
        authorId: act.author,
        createdAt: new Date(act.date),
      },
    });
  }

  console.log("Demo data seeded: Project Alpha with 7 workstreams, 35+ tasks, 8 contacts, 3 decisions, 13 activity entries");
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });
