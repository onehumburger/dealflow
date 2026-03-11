import {
  PrismaClient,
  DealType,
  DealRole,
  DealStatus,
  TaskStatus,
  TaskPriority,
  ActivityType,
  MilestoneType,
  DecisionStatus,
  DecisionSource,
  ContactRole,
} from "../src/generated/prisma/client";
import * as fs from "fs";
import * as path from "path";

const prisma = new PrismaClient();

// ═══════════════════════════════════════════════════════════════
// Project Epsilon — Cross-border M&A Simulation
// Chinese medical device company acquiring Vietnamese pharma
// ═══════════════════════════════════════════════════════════════

const log: string[] = [];

function logStage(stage: string, date: string, description: string) {
  log.push(`\n## ${stage} — ${date}\n`);
  log.push(description);
}

function logAction(action: string) {
  log.push(`- ${action}`);
}

function logObservation(type: "BUG" | "UX" | "FEATURE", text: string) {
  log.push(`- **[${type}]** ${text}`);
}

function d(dateStr: string): Date {
  return new Date(dateStr + "T09:00:00+08:00");
}

async function main() {
  // ── Lookup team members ──
  const liwei = await prisma.user.findUniqueOrThrow({ where: { email: "li.wei@jingtian.com" } });
  const zhanglin = await prisma.user.findUniqueOrThrow({ where: { email: "zhang.lin@jingtian.com" } });
  const chenyu = await prisma.user.findUniqueOrThrow({ where: { email: "chen.yu@jingtian.com" } });

  log.push("# Project Epsilon — Simulation Log\n");
  log.push("> Cross-border M&A: 华瑞医疗科技 acquires Viet Pharma JSC");
  log.push("> Simulated by project leader agent with two paralegal agents");
  log.push("> Generated: " + new Date().toISOString().split("T")[0]);
  log.push("");
  log.push("---");

  // ═══════════════════════════════════════════════════════════
  // STAGE 1 — Day 1: Deal Intake (2025-12-01)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 1: Deal Intake",
    "2025-12-01",
    "FA (Golden Bridge Capital) calls 李伟. Introduces an opportunity: a mid-size Vietnamese pharmaceutical company (Viet Pharma JSC) is open to strategic acquisition. Our potential client is 华瑞医疗科技, a Chinese medical device company looking to expand into Southeast Asian pharma. 李伟 assesses the opportunity and decides to pitch to the client."
  );

  // Create the deal
  const deal = await prisma.deal.create({
    data: {
      name: "华瑞医疗收购越南制药",
      codeName: "Project Epsilon",
      dealType: DealType.Negotiated,
      ourRole: DealRole.BuySide,
      clientName: "华瑞医疗科技股份有限公司",
      targetCompany: "Viet Pharma JSC",
      jurisdictions: ["PRC", "Vietnam"],
      status: DealStatus.Active,
      summary: "华瑞医疗拟收购越南制药公司Viet Pharma JSC 100%股权，交易金额约5000万美元。由金桥资本引荐，我方代表买方。涉及PRC和越南双边法律事务。",
      dealLeadId: liwei.id,
      createdAt: d("2025-12-01"),
      updatedAt: d("2025-12-01"),
    },
  });

  logAction("Created deal: 华瑞医疗收购越南制药 (Project Epsilon)");
  logAction("Deal Lead: 李伟");

  // Add team members
  await prisma.dealMember.createMany({
    data: [
      { dealId: deal.id, userId: liwei.id },
      { dealId: deal.id, userId: zhanglin.id },
      { dealId: deal.id, userId: chenyu.id },
    ],
  });
  logAction("Added team: 李伟 (lead), 张琳 (paralegal 1), 陈宇 (paralegal 2)");

  // Add FA contact
  const faContact = await prisma.contact.create({
    data: {
      name: "Michael Chen",
      organization: "Golden Bridge Capital",
      role: ContactRole.FA,
      title: "Managing Director",
      email: "michael.chen@goldenbridge.com",
      phone: "+86-138-0000-1234",
      timezone: "Asia/Shanghai",
      notes: "Introduced Project Epsilon. Has prior relationship with Viet Pharma founders.",
    },
  });
  await prisma.dealContact.create({
    data: { dealId: deal.id, contactId: faContact.id, roleInDeal: "Financial Advisor" },
  });
  logAction("Added contact: Michael Chen (Golden Bridge Capital, FA)");

  // Record first activity
  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Call,
      content: "收到金桥资本Michael Chen电话，介绍越南制药公司Viet Pharma JSC收购机会。标的公司为越南中型制药企业，年收入约3000万美元，主要产品为仿制药和OTC药品。创始人有意出售100%股权。初步评估后决定向华瑞医疗推荐此项目。",
      dealId: deal.id,
      authorId: liwei.id,
      createdAt: d("2025-12-01"),
    },
  });
  logAction("Recorded: FA introduction call");

  logObservation("UX", "When creating a new deal, there's no way to record HOW the deal was sourced (FA referral, direct, etc.). A 'deal source' field would be useful for tracking business development.");
  logObservation("FEATURE", "No deal value/consideration amount field in the schema. For M&A deals, the estimated or actual transaction value is critical information that should be displayed prominently.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 2 — Day 3: Client Pitch & Engagement (2025-12-03)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 2: Client Pitch & Engagement",
    "2025-12-03",
    "李伟 meets with 华瑞医疗 GC (General Counsel) 赵敏 to pitch the opportunity. Client is interested and agrees to engage the firm. Engagement letter to be drafted."
  );

  // Add client contacts
  const clientGC = await prisma.contact.create({
    data: {
      name: "赵敏",
      organization: "华瑞医疗科技股份有限公司",
      role: ContactRole.Client,
      title: "法务总监 / General Counsel",
      email: "zhao.min@huarui-med.com",
      phone: "+86-139-0000-5678",
      timezone: "Asia/Shanghai",
      notes: "主要对接人。决策需上报VP和董事会。",
    },
  });
  await prisma.dealContact.create({
    data: { dealId: deal.id, contactId: clientGC.id, roleInDeal: "Client GC / 主要对接人" },
  });

  const clientVP = await prisma.contact.create({
    data: {
      name: "孙建国",
      organization: "华瑞医疗科技股份有限公司",
      role: ContactRole.Client,
      title: "副总裁 / VP of Corporate Development",
      email: "sun.jianguo@huarui-med.com",
      phone: "+86-136-0000-9012",
      timezone: "Asia/Shanghai",
      notes: "项目最终决策人之一。负责公司海外并购战略。",
    },
  });
  await prisma.dealContact.create({
    data: { dealId: deal.id, contactId: clientVP.id, roleInDeal: "Client VP / 决策人" },
  });
  logAction("Added client contacts: 赵敏 (GC), 孙建国 (VP)");

  // Create initial workstreams
  const wsClient = await prisma.workstream.create({
    data: { name: "客户沟通", dealId: deal.id, sortOrder: 0, createdAt: d("2025-12-03") },
  });
  const wsDD = await prisma.workstream.create({
    data: { name: "尽职调查", dealId: deal.id, sortOrder: 1, createdAt: d("2025-12-03") },
  });
  const wsSPA = await prisma.workstream.create({
    data: { name: "交易文件", dealId: deal.id, sortOrder: 2, createdAt: d("2025-12-03") },
  });
  const wsReg = await prisma.workstream.create({
    data: { name: "监管审批", dealId: deal.id, sortOrder: 3, createdAt: d("2025-12-03") },
  });
  const wsStructure = await prisma.workstream.create({
    data: { name: "交易架构", dealId: deal.id, sortOrder: 4, createdAt: d("2025-12-03") },
  });
  logAction("Created workstreams: 客户沟通, 尽职调查, 交易文件, 监管审批, 交易架构");

  // Create initial tasks — just what's needed NOW
  const taskEngagement = await prisma.task.create({
    data: {
      title: "起草聘用函 (Engagement Letter)",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2025-12-05"),
      workstreamId: wsClient.id,
      assigneeId: zhanglin.id,
      sortOrder: 0,
      createdAt: d("2025-12-03"),
      updatedAt: d("2025-12-03"),
    },
  });

  const taskNDA = await prisma.task.create({
    data: {
      title: "准备保密协议 (NDA)",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2025-12-06"),
      workstreamId: wsClient.id,
      assigneeId: zhanglin.id,
      sortOrder: 1,
      createdAt: d("2025-12-03"),
      updatedAt: d("2025-12-03"),
    },
  });

  const taskPrelimResearch = await prisma.task.create({
    data: {
      title: "越南制药行业及Viet Pharma初步调研",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2025-12-10"),
      workstreamId: wsDD.id,
      assigneeId: chenyu.id,
      sortOrder: 0,
      createdAt: d("2025-12-03"),
      updatedAt: d("2025-12-03"),
    },
  });

  const taskVNLaw = await prisma.task.create({
    data: {
      title: "越南外商投资医药行业法规初步分析",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2025-12-12"),
      workstreamId: wsReg.id,
      assigneeId: chenyu.id,
      sortOrder: 0,
      createdAt: d("2025-12-03"),
      updatedAt: d("2025-12-03"),
    },
  });

  logAction("Created initial tasks: engagement letter, NDA, preliminary research, VN law analysis");

  // Set initial milestones
  await prisma.milestone.createMany({
    data: [
      { name: "NDA签署", date: d("2025-12-10"), type: MilestoneType.External, sortOrder: 0, dealId: deal.id, createdAt: d("2025-12-03"), updatedAt: d("2025-12-03") },
      { name: "LOI签署", date: null, type: MilestoneType.Contractual, sortOrder: 1, dealId: deal.id, createdAt: d("2025-12-03"), updatedAt: d("2025-12-03") },
      { name: "尽调完成", date: null, type: MilestoneType.Internal, sortOrder: 2, dealId: deal.id, createdAt: d("2025-12-03"), updatedAt: d("2025-12-03") },
      { name: "SPA签署", date: null, type: MilestoneType.Contractual, sortOrder: 3, dealId: deal.id, createdAt: d("2025-12-03"), updatedAt: d("2025-12-03") },
      { name: "交割", date: null, type: MilestoneType.Contractual, sortOrder: 4, dealId: deal.id, createdAt: d("2025-12-03"), updatedAt: d("2025-12-03") },
    ],
  });
  logAction("Created milestones: NDA签署, LOI签署, 尽调完成, SPA签署, 交割");

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Meeting,
      content: "与华瑞医疗法务总监赵敏会面，介绍Viet Pharma收购机会。客户表示对东南亚制药市场有战略兴趣，同意聘请本所代理。需准备聘用函和NDA。客户要求下周前完成越南医药行业外资准入初步分析。",
      dealId: deal.id,
      authorId: liwei.id,
      createdAt: d("2025-12-03"),
    },
  });
  logAction("Recorded: Client pitch meeting");

  logObservation("UX", "Cannot set milestones with 'TBD' dates in a meaningful way. Currently null date milestones show no date at all — but a 'TBD' label would communicate that the date is pending, not that there's no milestone date.");
  logObservation("FEATURE", "No way to attach an engagement letter or NDA document to a specific task. Documents exist at deal/workstream level but task-level attachment workflow is cumbersome — user has to upload doc separately then hope to remember which task it belongs to.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 3 — Week 1: NDA & Preliminary Work (2025-12-05 to 12-10)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 3: NDA & Preliminary Work",
    "2025-12-05 to 2025-12-10",
    "张琳 drafts the engagement letter and NDA. 陈宇 researches Vietnamese pharma regulations. NDA is sent to Viet Pharma through the FA."
  );

  // Complete engagement letter
  await prisma.task.update({
    where: { id: taskEngagement.id },
    data: { status: TaskStatus.Done, completedAt: d("2025-12-05"), updatedAt: d("2025-12-05") },
  });
  logAction("Task completed: 起草聘用函");

  // NDA in progress
  await prisma.task.update({
    where: { id: taskNDA.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2025-12-05") },
  });

  // Add time entries for engagement letter
  await prisma.timeEntry.create({
    data: {
      description: "起草聘用函，包含收费安排和服务范围",
      durationMinutes: 120,
      isManual: true,
      isBillable: true,
      taskId: taskEngagement.id,
      userId: zhanglin.id,
      dealId: deal.id,
      createdAt: d("2025-12-05"),
      updatedAt: d("2025-12-05"),
    },
  });

  // 12-06: NDA completed and sent
  await prisma.task.update({
    where: { id: taskNDA.id },
    data: { status: TaskStatus.Done, completedAt: d("2025-12-06"), updatedAt: d("2025-12-06") },
  });
  logAction("Task completed: NDA drafted and sent to Viet Pharma via FA");

  await prisma.timeEntry.create({
    data: {
      description: "起草双边NDA（中英文），考虑越南法律特殊要求",
      durationMinutes: 180,
      isManual: true,
      isBillable: true,
      taskId: taskNDA.id,
      userId: zhanglin.id,
      dealId: deal.id,
      createdAt: d("2025-12-06"),
      updatedAt: d("2025-12-06"),
    },
  });

  // 12-08: Preliminary research in progress
  await prisma.task.update({
    where: { id: taskPrelimResearch.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2025-12-08") },
  });

  // 12-10: NDA signed, preliminary research done
  const milestoneNDA = await prisma.milestone.findFirst({ where: { dealId: deal.id, name: "NDA签署" } });
  if (milestoneNDA) {
    await prisma.milestone.update({
      where: { id: milestoneNDA.id },
      data: { isDone: true, updatedAt: d("2025-12-10") },
    });
  }
  logAction("Milestone completed: NDA签署 (2025-12-10)");

  await prisma.task.update({
    where: { id: taskPrelimResearch.id },
    data: { status: TaskStatus.Done, completedAt: d("2025-12-10"), updatedAt: d("2025-12-10") },
  });
  logAction("Task completed: 越南制药行业初步调研");

  await prisma.timeEntry.create({
    data: {
      description: "越南制药行业市场调研、Viet Pharma公开信息收集分析",
      durationMinutes: 300,
      isManual: true,
      isBillable: true,
      taskId: taskPrelimResearch.id,
      userId: chenyu.id,
      dealId: deal.id,
      createdAt: d("2025-12-10"),
      updatedAt: d("2025-12-10"),
    },
  });

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Note,
      content: "NDA已签署。FA确认Viet Pharma方面已开放初步资料包。陈宇完成越南制药行业初步调研报告：越南制药市场2024年规模约70亿美元，年增长率8-10%。外商投资制药行业需经越南投资计划部批准，持股比例有限制（部分领域上限49%，但经批准可100%）。建议聘请越南当地律所协助。",
      dealId: deal.id,
      authorId: liwei.id,
      createdAt: d("2025-12-10"),
    },
  });

  logObservation("FEATURE", "No 'phase' or 'stage' concept for the deal itself. Real M&A projects go through distinct phases (intake → DD → negotiation → signing → closing). Having a deal phase field would help everyone understand where the project stands at a glance.");
  logObservation("UX", "When marking a milestone as done, there's no prompt to record the actual completion date if it differs from the planned date. The system just marks isDone=true but the original date stays.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 4 — Week 2-3: Due Diligence Kickoff (2025-12-12 to 12-25)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 4: Due Diligence Kickoff",
    "2025-12-12 to 2025-12-25",
    "Vietnamese local counsel (Lexcomm Vietnam) engaged. DD request list prepared and sent. VDR access obtained. DD workstream becomes the main focus. Initial DD findings start coming in."
  );

  // VN law research done
  await prisma.task.update({
    where: { id: taskVNLaw.id },
    data: { status: TaskStatus.Done, completedAt: d("2025-12-12"), updatedAt: d("2025-12-12") },
  });
  logAction("Task completed: 越南外商投资医药行业法规初步分析");

  await prisma.timeEntry.create({
    data: {
      description: "越南外商投资法、医药行业准入规定研究备忘录",
      durationMinutes: 360,
      isManual: true,
      isBillable: true,
      taskId: taskVNLaw.id,
      userId: chenyu.id,
      dealId: deal.id,
      createdAt: d("2025-12-12"),
      updatedAt: d("2025-12-12"),
    },
  });

  // Add Vietnamese counsel contact
  const vnCounsel = await prisma.contact.create({
    data: {
      name: "Nguyen Thi Lan",
      organization: "Lexcomm Vietnam",
      role: ContactRole.ExternalCounsel,
      title: "Partner",
      email: "lan.nguyen@lexcomm.vn",
      phone: "+84-28-3822-1234",
      timezone: "Asia/Ho_Chi_Minh",
      notes: "越南当地律所合伙人。擅长外商投资、医药行业。英语流利。",
    },
  });
  await prisma.dealContact.create({
    data: { dealId: deal.id, contactId: vnCounsel.id, roleInDeal: "Vietnamese Local Counsel" },
  });

  // Target company contact (via FA introduction)
  const targetCFO = await prisma.contact.create({
    data: {
      name: "Tran Van Duc",
      organization: "Viet Pharma JSC",
      role: ContactRole.Other,
      title: "CFO",
      email: "duc.tran@vietpharma.vn",
      phone: "+84-90-1234-5678",
      timezone: "Asia/Ho_Chi_Minh",
      notes: "标的公司CFO，主要对接DD资料请求。",
    },
  });
  await prisma.dealContact.create({
    data: { dealId: deal.id, contactId: targetCFO.id, roleInDeal: "Target CFO / DD对接人" },
  });
  logAction("Added contacts: Nguyen Thi Lan (VN counsel), Tran Van Duc (Target CFO)");

  // New DD tasks
  const taskDDList = await prisma.task.create({
    data: {
      title: "准备尽调请求清单 (DD Request List)",
      status: TaskStatus.Done,
      priority: TaskPriority.High,
      dueDate: d("2025-12-13"),
      completedAt: d("2025-12-13"),
      workstreamId: wsDD.id,
      assigneeId: zhanglin.id,
      sortOrder: 1,
      createdAt: d("2025-12-12"),
      updatedAt: d("2025-12-13"),
    },
  });

  const taskVDR = await prisma.task.create({
    data: {
      title: "获取VDR访问权限并整理文件索引",
      status: TaskStatus.Done,
      priority: TaskPriority.High,
      dueDate: d("2025-12-15"),
      completedAt: d("2025-12-15"),
      workstreamId: wsDD.id,
      assigneeId: chenyu.id,
      sortOrder: 2,
      createdAt: d("2025-12-12"),
      updatedAt: d("2025-12-15"),
    },
  });

  const taskDDCorp = await prisma.task.create({
    data: {
      title: "公司治理及股权结构尽调",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-01-10"),
      workstreamId: wsDD.id,
      assigneeId: zhanglin.id,
      sortOrder: 3,
      createdAt: d("2025-12-15"),
      updatedAt: d("2025-12-20"),
    },
  });

  const taskDDContract = await prisma.task.create({
    data: {
      title: "重大合同审阅 (Material Contracts Review)",
      status: TaskStatus.InProgress,
      priority: TaskPriority.Normal,
      dueDate: d("2026-01-15"),
      workstreamId: wsDD.id,
      assigneeId: chenyu.id,
      sortOrder: 4,
      createdAt: d("2025-12-15"),
      updatedAt: d("2025-12-20"),
    },
  });

  const taskDDIP = await prisma.task.create({
    data: {
      title: "知识产权及药品注册许可尽调",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-01-15"),
      workstreamId: wsDD.id,
      assigneeId: zhanglin.id,
      sortOrder: 5,
      createdAt: d("2025-12-15"),
      updatedAt: d("2025-12-15"),
    },
  });

  const taskDDLabor = await prisma.task.create({
    data: {
      title: "劳动用工及社保合规尽调",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-01-20"),
      workstreamId: wsDD.id,
      assigneeId: chenyu.id,
      sortOrder: 6,
      createdAt: d("2025-12-15"),
      updatedAt: d("2025-12-15"),
    },
  });

  const taskDDEnv = await prisma.task.create({
    data: {
      title: "环保及EHS合规尽调",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-01-20"),
      workstreamId: wsDD.id,
      assigneeId: chenyu.id,
      sortOrder: 7,
      createdAt: d("2025-12-15"),
      updatedAt: d("2025-12-15"),
    },
  });

  logAction("Created DD tasks: request list, VDR access, corporate DD, contracts, IP, labor, environmental");

  // Time entries
  await prisma.timeEntry.createMany({
    data: [
      { description: "准备尽调请求清单（中英文，涵盖公司、合同、IP、劳动、环保、诉讼等）", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskDDList.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2025-12-13"), updatedAt: d("2025-12-13") },
      { description: "VDR文件整理和索引建立", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskVDR.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2025-12-15"), updatedAt: d("2025-12-15") },
      { description: "公司治理文件审阅（章程、股东会决议、董事会决议）", durationMinutes: 300, isManual: true, isBillable: true, taskId: taskDDCorp.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2025-12-20"), updatedAt: d("2025-12-20") },
      { description: "重大合同初步审阅（供应商合同、分销协议）", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskDDContract.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2025-12-20"), updatedAt: d("2025-12-20") },
    ],
  });

  // Transaction structure task
  const taskStructure = await prisma.task.create({
    data: {
      title: "交易架构方案设计（直接收购 vs SPV）",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2025-12-25"),
      workstreamId: wsStructure.id,
      assigneeId: liwei.id,
      sortOrder: 0,
      createdAt: d("2025-12-15"),
      updatedAt: d("2025-12-20"),
    },
  });

  // Client update meeting
  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Meeting,
      content: "客户更新会议。汇报进展：NDA已签署，VDR已开放，尽调启动。越南当地律所Lexcomm已聘请。初步发现：越南外资准入对医药行业有条件限制，需进一步分析具体产品线是否受限。客户指示优先完成交易架构分析和外资准入评估。",
      dealId: deal.id,
      workstreamId: wsClient.id,
      authorId: liwei.id,
      createdAt: d("2025-12-18"),
    },
  });

  // First decision point
  const decisionStructure = await prisma.decision.create({
    data: {
      title: "交易架构选择：直接收购 vs 设立SPV",
      background: "华瑞医疗可以直接收购Viet Pharma 100%股权，也可以通过设立香港或新加坡SPV间接收购。需综合考虑税务、外汇管制、未来退出灵活性等因素。",
      source: DecisionSource.Other,
      status: DecisionStatus.PendingAnalysis,
      dealId: deal.id,
      workstreamId: wsStructure.id,
      createdAt: d("2025-12-18"),
      updatedAt: d("2025-12-18"),
    },
  });
  await prisma.decisionOption.createMany({
    data: [
      { description: "方案一：华瑞医疗直接收购（简单，但未来退出灵活性低，分红需缴越南预提税+中国企业所得税）", prosAndCons: "优点：结构简单、审批流程短。缺点：税负较高（双重征税），未来引入新投资人或退出不便。", sortOrder: 0, decisionId: decisionStructure.id },
      { description: "方案二：通过香港SPV间接收购（可利用中国-香港和越南-香港双边税收协定降低税负）", prosAndCons: "优点：税务优化（股息预提税可降至5%），未来退出灵活。缺点：需设立并维护香港公司，ODI审批流程更复杂。", sortOrder: 1, decisionId: decisionStructure.id },
      { description: "方案三：通过新加坡SPV间接收购（越南-新加坡双边投资协定保护更强）", prosAndCons: "优点：投资保护强，新加坡无资本利得税。缺点：与方案二类似的复杂性，且中国-新加坡协定优惠不如香港。", sortOrder: 2, decisionId: decisionStructure.id },
    ],
  });
  logAction("Created decision: 交易架构选择 (3 options)");

  logObservation("FEATURE", "No way to assign a 'deadline' to a decision. In practice, clients need to make decisions by certain dates to keep the project on track. A decision due date field would be useful.");
  logObservation("UX", "Decision options don't support structured pros/cons (separate fields). Currently it's a single text field. A structured format (pros list + cons list) would be more readable.");
  logObservation("FEATURE", "No concept of 'counterparty counsel' in the ContactRole enum — there's CounterpartyCounsel but no TargetCompany role. For M&A, the target company contacts are very common and need a dedicated role.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 5 — Month 1: Deep DD & Structure Decision (2026-01-05 to 01-20)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 5: Deep DD & Structure Decision",
    "2026-01-05 to 2026-01-20",
    "Due diligence deepens. Key findings emerge: (1) Viet Pharma has a pending tax dispute, (2) one key drug registration is expiring in 18 months, (3) minority shareholder (15%) has pre-emptive rights. Structure decision is made: HK SPV route."
  );

  // DD corporate done
  await prisma.task.update({
    where: { id: taskDDCorp.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-01-08"), updatedAt: d("2026-01-08") },
  });

  // IP DD in progress
  await prisma.task.update({
    where: { id: taskDDIP.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-01-05") },
  });

  // Labor DD in progress
  await prisma.task.update({
    where: { id: taskDDLabor.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-01-10") },
  });

  // Environmental DD in progress
  await prisma.task.update({
    where: { id: taskDDEnv.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-01-10") },
  });

  // Time entries for January
  await prisma.timeEntry.createMany({
    data: [
      { description: "股权结构分析：发现15%少数股东有优先购买权", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskDDCorp.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-01-06"), updatedAt: d("2026-01-06") },
      { description: "历史股东会及董事会决议审阅完成", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskDDCorp.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-01-08"), updatedAt: d("2026-01-08") },
      { description: "重大合同深入审阅（主要客户合同、独家分销协议、OEM协议）", durationMinutes: 360, isManual: true, isBillable: true, taskId: taskDDContract.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-01-08"), updatedAt: d("2026-01-08") },
      { description: "药品注册许可证清单整理，发现关键产品注册将于18个月内到期", durationMinutes: 300, isManual: true, isBillable: true, taskId: taskDDIP.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-01-10"), updatedAt: d("2026-01-10") },
      { description: "劳动合同抽样审阅、社保合规性检查", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskDDLabor.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-01-12"), updatedAt: d("2026-01-12") },
      { description: "环保许可证及EHS合规审查", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskDDEnv.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-01-12"), updatedAt: d("2026-01-12") },
      { description: "交易架构比较分析备忘录", durationMinutes: 420, isManual: true, isBillable: true, taskId: taskStructure.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-01-10"), updatedAt: d("2026-01-10") },
    ],
  });

  // DD findings → decisions
  const decisionTax = await prisma.decision.create({
    data: {
      title: "尽调发现：标的公司税务争议处理",
      background: "尽调发现Viet Pharma与越南税务机关存在约50万美元的增值税争议，目前处于行政复议阶段。可能影响交易价格或需要卖方提供专项赔偿。",
      source: DecisionSource.DDFinding,
      analysis: "建议在SPA中设置专项赔偿条款(Specific Indemnity)，由卖方对该税务争议承担全部赔偿责任，并设置相应的交割价格调整机制或预留款(Escrow)。",
      status: DecisionStatus.Reported,
      dealId: deal.id,
      workstreamId: wsDD.id,
      createdAt: d("2026-01-10"),
      updatedAt: d("2026-01-10"),
    },
  });

  const decisionDrugReg = await prisma.decision.create({
    data: {
      title: "尽调发现：关键药品注册即将到期",
      background: "Viet Pharma最畅销产品（一种心血管仿制药，占总收入约25%）的药品注册许可将于2027年6月到期。续期需提前12个月申请。若未及时续期，将严重影响公司营收。",
      source: DecisionSource.DDFinding,
      analysis: "建议：(1) 将药品注册续期作为交割前条件或卖方交割前义务；(2) 在SPA中设置相关陈述保证；(3) 聘请越南药品监管专家评估续期风险。",
      status: DecisionStatus.Reported,
      dealId: deal.id,
      workstreamId: wsDD.id,
      createdAt: d("2026-01-12"),
      updatedAt: d("2026-01-12"),
    },
  });

  logAction("Created decisions for DD findings: tax dispute, drug registration expiry");

  // Structure decision made
  await prisma.decision.update({
    where: { id: decisionStructure.id },
    data: {
      status: DecisionStatus.Decided,
      clientDecision: "客户选择方案二：通过香港SPV间接收购。已安排设立华瑞医疗(香港)有限公司。",
      updatedAt: d("2026-01-15"),
    },
  });
  await prisma.task.update({
    where: { id: taskStructure.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-01-15"), updatedAt: d("2026-01-15") },
  });
  logAction("Decision made: HK SPV route selected. Structure task completed.");

  // New tasks from structure decision
  const taskHKSPV = await prisma.task.create({
    data: {
      title: "设立香港SPV（华瑞医疗(香港)有限公司）",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-02-01"),
      workstreamId: wsStructure.id,
      assigneeId: chenyu.id,
      sortOrder: 1,
      createdAt: d("2026-01-15"),
      updatedAt: d("2026-01-15"),
    },
  });

  const taskODI = await prisma.task.create({
    data: {
      title: "境外投资(ODI)备案申请准备",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-02-15"),
      workstreamId: wsReg.id,
      assigneeId: zhanglin.id,
      sortOrder: 1,
      createdAt: d("2026-01-15"),
      updatedAt: d("2026-01-15"),
    },
  });
  logAction("Created new tasks from structure decision: HK SPV setup, ODI filing");

  // Client instruction
  await prisma.activityEntry.create({
    data: {
      type: ActivityType.ClientInstruction,
      content: "客户指示：(1) 同意采用香港SPV架构，请尽快安排设立；(2) 税务争议需在SPA中有充分保护，可接受escrow安排；(3) 药品注册续期问题需作为交割条件；(4) 少数股东优先购买权需妥善处理，不能影响交割确定性。目标估值4500-5000万美元。",
      dealId: deal.id,
      workstreamId: wsClient.id,
      authorId: liwei.id,
      createdAt: d("2026-01-15"),
    },
  });

  logObservation("FEATURE", "No way to track deal value/consideration in the system. The client just gave us a target range of $45-50M but there's nowhere to record this prominently on the deal.");
  logObservation("UX", "When a decision leads to new tasks, there's no automated linking. Had to manually create tasks and hope to remember they came from the structure decision. A 'create task from decision' button would streamline this workflow.");
  logObservation("BUG", "The 'My Tasks' page filters tasks by Active deal status, which is correct. But if I'm on the deal detail page, I can see ALL tasks regardless of deal status. This is fine for viewing history on completed deals but could be confusing.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 6 — Month 2: LOI Negotiation (2026-01-25 to 02-15)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 6: LOI Negotiation",
    "2026-01-25 to 2026-02-15",
    "DD nearing completion. LOI/Term Sheet drafted and negotiated. Key commercial terms being discussed. Minority shareholder issue addressed."
  );

  // Complete remaining DD tasks
  await prisma.task.update({
    where: { id: taskDDContract.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-01-20"), updatedAt: d("2026-01-20") },
  });
  await prisma.task.update({
    where: { id: taskDDIP.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-01-22"), updatedAt: d("2026-01-22") },
  });
  await prisma.task.update({
    where: { id: taskDDLabor.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-01-20"), updatedAt: d("2026-01-20") },
  });
  await prisma.task.update({
    where: { id: taskDDEnv.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-01-22"), updatedAt: d("2026-01-22") },
  });
  logAction("DD tasks completed: contracts, IP, labor, environmental");

  // DD report compilation
  const taskDDReport = await prisma.task.create({
    data: {
      title: "编制尽调报告 (DD Report)",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-01-30"),
      workstreamId: wsDD.id,
      assigneeId: zhanglin.id,
      sortOrder: 8,
      createdAt: d("2026-01-22"),
      updatedAt: d("2026-01-25"),
    },
  });

  // LOI tasks
  const taskLOIDraft = await prisma.task.create({
    data: {
      title: "起草LOI / Term Sheet",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-02-01"),
      workstreamId: wsSPA.id,
      assigneeId: liwei.id,
      sortOrder: 0,
      createdAt: d("2026-01-25"),
      updatedAt: d("2026-01-28"),
    },
  });

  const taskMinority = await prisma.task.create({
    data: {
      title: "少数股东优先购买权处理方案",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-02-05"),
      workstreamId: wsSPA.id,
      assigneeId: zhanglin.id,
      sortOrder: 1,
      createdAt: d("2026-01-25"),
      updatedAt: d("2026-01-28"),
    },
  });

  logAction("Created LOI tasks and DD report compilation");

  // Time entries
  await prisma.timeEntry.createMany({
    data: [
      { description: "尽调报告起草（公司治理、合同、IP部分）", durationMinutes: 480, isManual: true, isBillable: true, taskId: taskDDReport.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-01-28"), updatedAt: d("2026-01-28") },
      { description: "尽调报告起草（劳动、环保、诉讼部分）", durationMinutes: 360, isManual: true, isBillable: true, taskId: taskDDReport.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-01-28"), updatedAt: d("2026-01-28") },
      { description: "LOI起草，包含价格、架构、排他期、主要条件前提", durationMinutes: 420, isManual: true, isBillable: true, taskId: taskLOIDraft.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-01-30"), updatedAt: d("2026-01-30") },
      { description: "少数股东权利分析备忘录，优先购买权waiver方案", durationMinutes: 300, isManual: true, isBillable: true, taskId: taskMinority.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-01-30"), updatedAt: d("2026-01-30") },
    ],
  });

  // DD report completed
  await prisma.task.update({
    where: { id: taskDDReport.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-01-30"), updatedAt: d("2026-01-30") },
  });

  // DD milestone done
  const milestoneDDObj = await prisma.milestone.findFirst({ where: { dealId: deal.id, name: "尽调完成" } });
  if (milestoneDDObj) {
    await prisma.milestone.update({
      where: { id: milestoneDDObj.id },
      data: { isDone: true, date: d("2026-01-30"), updatedAt: d("2026-01-30") },
    });
  }
  logAction("Milestone completed: 尽调完成 (2026-01-30)");

  // LOI negotiation activities
  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Meeting,
      content: "LOI谈判视频会议（华瑞 vs Viet Pharma创始人+FA）。主要争议点：(1) 估值：我方出价4500万美元，对方要价5500万美元；(2) 排他期：我方要求90天，对方希望60天；(3) 少数股东：对方承诺将促使少数股东配合出售或放弃优先购买权。",
      dealId: deal.id,
      workstreamId: wsSPA.id,
      authorId: liwei.id,
      createdAt: d("2026-02-03"),
    },
  });

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Note,
      content: "LOI修订版已发出。最终商业条款：收购价4800万美元（考虑税务争议调减200万），排他期75天，Lock-box date设为2025-12-31。少数股东同意tag-along出售，waiver letter由Lexcomm协助起草中。",
      dealId: deal.id,
      workstreamId: wsSPA.id,
      authorId: liwei.id,
      createdAt: d("2026-02-08"),
    },
  });

  // LOI signed
  await prisma.task.update({
    where: { id: taskLOIDraft.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-02-12"), updatedAt: d("2026-02-12") },
  });
  await prisma.task.update({
    where: { id: taskMinority.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-02-10"), updatedAt: d("2026-02-10") },
  });

  const milestoneLOI = await prisma.milestone.findFirst({ where: { dealId: deal.id, name: "LOI签署" } });
  if (milestoneLOI) {
    await prisma.milestone.update({
      where: { id: milestoneLOI.id },
      data: { isDone: true, date: d("2026-02-12"), updatedAt: d("2026-02-12") },
    });
  }
  logAction("Milestone completed: LOI签署 (2026-02-12), price $48M");

  // HK SPV setup done
  await prisma.task.update({
    where: { id: taskHKSPV.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-02-05"), updatedAt: d("2026-02-05") },
  });
  logAction("HK SPV incorporated");

  logObservation("FEATURE", "No 'exclusivity period' tracker. After LOI signing, there's a 75-day exclusivity window. Having a countdown or visual indicator for exclusivity expiry would be very useful.");
  logObservation("UX", "When multiple DD sub-tasks complete at similar times, there's no way to batch-complete them. Each task needs individual status update. A 'complete selected tasks' bulk action would save time.");
  logObservation("FEATURE", "No deal financial summary — purchase price, escrow amount, adjustments, etc. These are core commercial terms that the team references constantly.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 7 — Month 2-3: SPA Drafting & Negotiation (2026-02-15 to 03-20)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 7: SPA Drafting & Negotiation",
    "2026-02-15 to 2026-03-20",
    "SPA first draft prepared. Multiple rounds of negotiation. Regulatory filings initiated (ODI in PRC, investment registration in Vietnam). Key negotiation points: R&W scope, indemnity caps, escrow, CPs."
  );

  // SPA tasks
  const taskSPADraft = await prisma.task.create({
    data: {
      title: "起草SPA（股权购买协议）",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-02-28"),
      workstreamId: wsSPA.id,
      assigneeId: liwei.id,
      sortOrder: 2,
      createdAt: d("2026-02-15"),
      updatedAt: d("2026-02-20"),
    },
  });

  const taskSPASchedules = await prisma.task.create({
    data: {
      title: "SPA附件及披露函草拟 (Disclosure Schedules)",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-03-05"),
      workstreamId: wsSPA.id,
      assigneeId: zhanglin.id,
      sortOrder: 3,
      createdAt: d("2026-02-15"),
      updatedAt: d("2026-02-15"),
    },
  });

  const taskSPANego1 = await prisma.task.create({
    data: {
      title: "SPA第一轮谈判——陈述保证和赔偿条款",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-03-10"),
      workstreamId: wsSPA.id,
      assigneeId: liwei.id,
      sortOrder: 4,
      createdAt: d("2026-02-28"),
      updatedAt: d("2026-02-28"),
    },
  });

  const taskSPANego2 = await prisma.task.create({
    data: {
      title: "SPA第二轮谈判——交割条件和价格调整",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-03-20"),
      workstreamId: wsSPA.id,
      assigneeId: liwei.id,
      sortOrder: 5,
      createdAt: d("2026-02-28"),
      updatedAt: d("2026-02-28"),
    },
  });

  // Regulatory tasks
  await prisma.task.update({
    where: { id: taskODI.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-02-15") },
  });

  const taskVNInvestment = await prisma.task.create({
    data: {
      title: "越南投资登记证申请 (IRC Application)",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-03-15"),
      workstreamId: wsReg.id,
      assigneeId: chenyu.id,
      sortOrder: 2,
      createdAt: d("2026-02-15"),
      updatedAt: d("2026-02-15"),
    },
  });

  const taskAntitrust = await prisma.task.create({
    data: {
      title: "反垄断经营者集中申报评估",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-03-01"),
      workstreamId: wsReg.id,
      assigneeId: chenyu.id,
      sortOrder: 3,
      createdAt: d("2026-02-15"),
      updatedAt: d("2026-02-15"),
    },
  });

  logAction("Created SPA and regulatory tasks for signing preparation");

  // Add counterparty counsel
  const targetCounsel = await prisma.contact.create({
    data: {
      name: "Le Minh Tuan",
      organization: "Baker McKenzie (Vietnam)",
      role: ContactRole.CounterpartyCounsel,
      title: "Partner",
      email: "tuan.le@bakermckenzie.com",
      phone: "+84-28-3520-2345",
      timezone: "Asia/Ho_Chi_Minh",
    },
  });
  await prisma.dealContact.create({
    data: { dealId: deal.id, contactId: targetCounsel.id, roleInDeal: "Seller's Counsel" },
  });
  logAction("Added contact: Le Minh Tuan (Baker McKenzie Vietnam, seller's counsel)");

  // SPA drafting progress & time
  await prisma.timeEntry.createMany({
    data: [
      { description: "SPA起草——定义条款、交易架构、对价条款", durationMinutes: 480, isManual: true, isBillable: true, taskId: taskSPADraft.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-02-20"), updatedAt: d("2026-02-20") },
      { description: "SPA起草——陈述与保证、赔偿条款", durationMinutes: 540, isManual: true, isBillable: true, taskId: taskSPADraft.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-02-22"), updatedAt: d("2026-02-22") },
      { description: "SPA起草——交割条件、终止、其他", durationMinutes: 420, isManual: true, isBillable: true, taskId: taskSPADraft.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-02-25"), updatedAt: d("2026-02-25") },
      { description: "ODI备案材料准备（发改委+商务部+外汇）", durationMinutes: 480, isManual: true, isBillable: true, taskId: taskODI.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-02-20"), updatedAt: d("2026-02-20") },
      { description: "反垄断申报分析：不触发中国或越南申报门槛", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskAntitrust.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-02-25"), updatedAt: d("2026-02-25") },
    ],
  });

  // SPA draft completed
  await prisma.task.update({
    where: { id: taskSPADraft.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-02-28"), updatedAt: d("2026-02-28") },
  });

  // Antitrust: no filing needed
  await prisma.task.update({
    where: { id: taskAntitrust.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-02-28"), updatedAt: d("2026-02-28") },
  });
  logAction("SPA first draft completed. Antitrust: no filing required.");

  // Schedules in progress
  await prisma.task.update({
    where: { id: taskSPASchedules.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-03-01") },
  });

  // SPA negotiation round 1
  await prisma.task.update({
    where: { id: taskSPANego1.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-03-03") },
  });

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Meeting,
      content: "SPA第一轮谈判（与Baker McKenzie视频会议）。主要争议：(1) 卖方要求整体赔偿上限为交易对价的15%，我方坚持30%；(2) 卖方不接受将药品注册续期作为交割前条件(CP)，提议改为交割后义务+赔偿；(3) Escrow金额：我方建议250万美元（约5%），卖方只接受100万美元。(4) R&W存续期：我方要求24个月，卖方18个月。下轮谈判安排在3月15日。",
      dealId: deal.id,
      workstreamId: wsSPA.id,
      authorId: liwei.id,
      createdAt: d("2026-03-08"),
    },
  });

  // Decisions from negotiation
  const decisionIndemnity = await prisma.decision.create({
    data: {
      title: "谈判要点：赔偿上限及Escrow金额",
      background: "卖方仅接受15%赔偿上限和100万美元escrow。我方立场为30%上限和250万美元escrow。需客户决策底线。",
      source: DecisionSource.Negotiation,
      status: DecisionStatus.PendingAnalysis,
      dealId: deal.id,
      workstreamId: wsSPA.id,
      createdAt: d("2026-03-08"),
      updatedAt: d("2026-03-08"),
    },
  });
  await prisma.decisionOption.createMany({
    data: [
      { description: "坚持30%上限和250万escrow，以税务争议风险为谈判筹码", prosAndCons: "优点：最大保护。缺点：可能导致谈判僵局。", sortOrder: 0, decisionId: decisionIndemnity.id },
      { description: "折中方案：20%上限 + 200万escrow（其中100万专项用于税务争议）", prosAndCons: "优点：合理折中，可能被接受。缺点：低于理想保护水平。", sortOrder: 1, decisionId: decisionIndemnity.id },
    ],
  });

  // Client decision on indemnity
  await prisma.decision.update({
    where: { id: decisionIndemnity.id },
    data: {
      status: DecisionStatus.Decided,
      clientDecision: "客户接受折中方案：20%整体上限，200万escrow（含100万税务专项）。但坚持R&W存续期24个月不退让。",
      updatedAt: d("2026-03-10"),
    },
  });

  // Tax dispute decision resolved
  await prisma.decision.update({
    where: { id: decisionTax.id },
    data: {
      status: DecisionStatus.Decided,
      clientDecision: "在escrow中设立100万美元专项，由卖方对税务争议承担特别赔偿责任，不受整体上限约束。",
      updatedAt: d("2026-03-10"),
    },
  });

  // Drug registration decision
  await prisma.decision.update({
    where: { id: decisionDrugReg.id },
    data: {
      status: DecisionStatus.Decided,
      clientDecision: "接受卖方方案：药品注册续期改为交割后义务。但加入SPA特别赔偿条款——若因卖方原因导致续期失败，赔偿上限不受整体cap约束。",
      updatedAt: d("2026-03-12"),
    },
  });
  logAction("Key negotiation decisions made by client");

  // SPA negotiation round 2
  await prisma.task.update({
    where: { id: taskSPANego1.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-03-10"), updatedAt: d("2026-03-10") },
  });
  await prisma.task.update({
    where: { id: taskSPANego2.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-03-12") },
  });
  await prisma.task.update({
    where: { id: taskSPASchedules.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-03-12"), updatedAt: d("2026-03-12") },
  });

  // ODI filing submitted
  await prisma.task.update({
    where: { id: taskODI.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-03-05"), updatedAt: d("2026-03-05") },
  });
  logAction("ODI filing submitted. SPA schedules completed.");

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Meeting,
      content: "SPA第二轮谈判。取得实质进展：(1) 赔偿上限达成一致：20%；(2) Escrow 200万美元（含100万税务专项），释放期18个月；(3) R&W存续期24个月（我方坚持成功）；(4) 交割条件：监管批准+少数股东waiver+无MAC。(5) 药品注册续期改为交割后义务+特别赔偿。仅剩少量技术条款待确认。SPA预计下周定稿。",
      dealId: deal.id,
      workstreamId: wsSPA.id,
      authorId: liwei.id,
      createdAt: d("2026-03-17"),
    },
  });

  // SPA negotiation round 2 done
  await prisma.task.update({
    where: { id: taskSPANego2.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-03-18"), updatedAt: d("2026-03-18") },
  });

  // More time entries
  await prisma.timeEntry.createMany({
    data: [
      { description: "SPA附件及披露函起草", durationMinutes: 420, isManual: true, isBillable: true, taskId: taskSPASchedules.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-03-05"), updatedAt: d("2026-03-05") },
      { description: "SPA谈判第一轮——修改陈述保证和赔偿条款", durationMinutes: 360, isManual: true, isBillable: true, taskId: taskSPANego1.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-03-08"), updatedAt: d("2026-03-08") },
      { description: "SPA谈判第二轮——交割条件和价格调整机制", durationMinutes: 420, isManual: true, isBillable: true, taskId: taskSPANego2.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-03-17"), updatedAt: d("2026-03-17") },
      { description: "越南投资登记证(IRC)申请准备材料", durationMinutes: 360, isManual: true, isBillable: true, taskId: taskVNInvestment.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-03-10"), updatedAt: d("2026-03-10") },
    ],
  });

  logObservation("FEATURE", "No SPA version tracking / comparison. Real SPA negotiations involve 5-10+ draft versions. The system has Documents but no version control or comparison feature for key transaction documents.");
  logObservation("UX", "Activity feed becomes very long. Need pagination or date-range filtering on the activity feed within a deal. Currently it loads all entries.");
  logObservation("FEATURE", "No task comments from the timeline/activity view. When a team member posts a negotiation update, others can't comment inline. They'd need to add a separate activity entry or go to a specific task.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 8 — Month 3-4: Pre-Signing & Signing (2026-03-20 to 04-05)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 8: Pre-Signing & Signing",
    "2026-03-20 to 2026-04-05",
    "SPA finalized. CP tracker established. Board approvals obtained. Signing ceremony conducted."
  );

  // Create CP tracker workstream
  const wsCP = await prisma.workstream.create({
    data: { name: "交割条件跟踪", dealId: deal.id, sortOrder: 5, createdAt: d("2026-03-20") },
  });

  const taskSPAFinal = await prisma.task.create({
    data: {
      title: "SPA定稿及签字页准备",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-03-28"),
      workstreamId: wsSPA.id,
      assigneeId: liwei.id,
      sortOrder: 6,
      createdAt: d("2026-03-20"),
      updatedAt: d("2026-03-22"),
    },
  });

  const taskBoardApproval = await prisma.task.create({
    data: {
      title: "客户董事会决议（批准收购）",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-03-30"),
      workstreamId: wsClient.id,
      assigneeId: zhanglin.id,
      sortOrder: 2,
      createdAt: d("2026-03-20"),
      updatedAt: d("2026-03-22"),
    },
  });

  const taskMinorityWaiver = await prisma.task.create({
    data: {
      title: "少数股东优先购买权放弃函 (Waiver Letter)",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-03-28"),
      workstreamId: wsCP.id,
      assigneeId: chenyu.id,
      sortOrder: 0,
      createdAt: d("2026-03-20"),
      updatedAt: d("2026-03-22"),
    },
  });

  const taskEscrow = await prisma.task.create({
    data: {
      title: "Escrow协议起草",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-04-01"),
      workstreamId: wsSPA.id,
      assigneeId: zhanglin.id,
      sortOrder: 7,
      createdAt: d("2026-03-20"),
      updatedAt: d("2026-03-20"),
    },
  });

  logAction("Created signing preparation tasks: SPA finalization, board approval, minority waiver, escrow agreement");

  // Progress: waiver obtained, board approval obtained
  await prisma.task.update({
    where: { id: taskMinorityWaiver.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-03-26"), updatedAt: d("2026-03-26") },
  });
  await prisma.task.update({
    where: { id: taskBoardApproval.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-03-28"), updatedAt: d("2026-03-28") },
  });
  await prisma.task.update({
    where: { id: taskSPAFinal.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-03-30"), updatedAt: d("2026-03-30") },
  });
  await prisma.task.update({
    where: { id: taskEscrow.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-04-01"), updatedAt: d("2026-04-01") },
  });
  logAction("Pre-signing tasks completed: waiver, board approval, SPA final, escrow agreement");

  // Time entries
  await prisma.timeEntry.createMany({
    data: [
      { description: "SPA最终修订及双语校对", durationMinutes: 480, isManual: true, isBillable: true, taskId: taskSPAFinal.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-03-28"), updatedAt: d("2026-03-28") },
      { description: "董事会决议及授权文件准备", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskBoardApproval.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-03-28"), updatedAt: d("2026-03-28") },
      { description: "少数股东waiver letter协调与签署", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskMinorityWaiver.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-03-26"), updatedAt: d("2026-03-26") },
      { description: "Escrow协议起草", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskEscrow.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-04-01"), updatedAt: d("2026-04-01") },
    ],
  });

  // SIGNING!
  const milestoneSPA = await prisma.milestone.findFirst({ where: { dealId: deal.id, name: "SPA签署" } });
  if (milestoneSPA) {
    await prisma.milestone.update({
      where: { id: milestoneSPA.id },
      data: { isDone: true, date: d("2026-04-03"), updatedAt: d("2026-04-03") },
    });
  }
  logAction("MILESTONE: SPA签署 (2026-04-03) — SIGNING COMPLETED!");

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Note,
      content: "🎉 SPA签署完成！华瑞医疗（香港）有限公司与Viet Pharma JSC各股东签署股权购买协议。交易价格4800万美元，lock-box日期2025-12-31。Escrow 200万美元（含100万税务专项）。交割条件：(1) ODI获批, (2) 越南IRC获批, (3) 无MAC, (4) 各方CP文件齐备。预计交割日期：2026年5月底前。",
      dealId: deal.id,
      authorId: liwei.id,
      createdAt: d("2026-04-03"),
    },
  });

  logObservation("FEATURE", "No 'signing ceremony' or 'key event' concept. Signing is the most important moment in a deal but it's just recorded as an activity note. A special event type with document attachment (signed SPA) would be appropriate.");
  logObservation("UX", "The milestone timeline doesn't visually distinguish between 'completed' milestones and 'upcoming' ones very well when you have many milestones at different stages.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 9 — Month 4-5: Closing Preparation (2026-04-05 to 05-20)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 9: Closing Preparation",
    "2026-04-05 to 2026-05-20",
    "Post-signing, working towards closing. CP satisfaction: ODI approval obtained, Vietnam IRC in progress, closing checklist prepared."
  );

  // Create closing workstream
  const wsClosing = await prisma.workstream.create({
    data: { name: "交割清单", dealId: deal.id, sortOrder: 6, createdAt: d("2026-04-05") },
  });

  // CP tasks
  const taskODIApproval = await prisma.task.create({
    data: {
      title: "ODI备案获批确认",
      status: TaskStatus.InProgress,
      priority: TaskPriority.High,
      dueDate: d("2026-04-20"),
      workstreamId: wsCP.id,
      assigneeId: zhanglin.id,
      sortOrder: 1,
      createdAt: d("2026-04-05"),
      updatedAt: d("2026-04-08"),
    },
  });

  // VN investment registration in progress
  await prisma.task.update({
    where: { id: taskVNInvestment.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-04-05") },
  });

  const taskMACConfirm = await prisma.task.create({
    data: {
      title: "无重大不利变化(MAC)确认函",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-05-15"),
      workstreamId: wsCP.id,
      assigneeId: chenyu.id,
      sortOrder: 2,
      createdAt: d("2026-04-05"),
      updatedAt: d("2026-04-05"),
    },
  });

  // Closing checklist tasks
  const taskSignPages = await prisma.task.create({
    data: {
      title: "收集各方签字页",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-05-18"),
      workstreamId: wsClosing.id,
      assigneeId: zhanglin.id,
      sortOrder: 0,
      createdAt: d("2026-04-05"),
      updatedAt: d("2026-04-05"),
    },
  });

  const taskLegalOpinion = await prisma.task.create({
    data: {
      title: "出具法律意见书 (Legal Opinions)",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-05-15"),
      workstreamId: wsClosing.id,
      assigneeId: liwei.id,
      sortOrder: 1,
      createdAt: d("2026-04-05"),
      updatedAt: d("2026-04-05"),
    },
  });

  const taskFundsTransfer = await prisma.task.create({
    data: {
      title: "购买价款汇出安排（SAFE登记+银行汇款）",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-05-20"),
      workstreamId: wsClosing.id,
      assigneeId: chenyu.id,
      sortOrder: 2,
      createdAt: d("2026-04-05"),
      updatedAt: d("2026-04-05"),
    },
  });

  const taskShareTransfer = await prisma.task.create({
    data: {
      title: "股权过户及工商变更登记",
      status: TaskStatus.ToDo,
      priority: TaskPriority.High,
      dueDate: d("2026-05-22"),
      workstreamId: wsClosing.id,
      assigneeId: chenyu.id,
      sortOrder: 3,
      createdAt: d("2026-04-05"),
      updatedAt: d("2026-04-05"),
    },
  });

  const taskClosingBinder = await prisma.task.create({
    data: {
      title: "整理交割文件档案 (Closing Binder)",
      status: TaskStatus.ToDo,
      priority: TaskPriority.Normal,
      dueDate: d("2026-05-30"),
      workstreamId: wsClosing.id,
      assigneeId: zhanglin.id,
      sortOrder: 4,
      createdAt: d("2026-04-05"),
      updatedAt: d("2026-04-05"),
    },
  });
  logAction("Created CP and closing checklist tasks");

  // Progress: ODI approved, VN IRC obtained
  await prisma.task.update({
    where: { id: taskODIApproval.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-04-18"), updatedAt: d("2026-04-18") },
  });
  logAction("CP satisfied: ODI approval obtained (2026-04-18)");

  await prisma.task.update({
    where: { id: taskVNInvestment.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-05-05"), updatedAt: d("2026-05-05") },
  });
  logAction("CP satisfied: Vietnam IRC obtained (2026-05-05)");

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Note,
      content: "ODI备案已获发改委和商务部批准。越南投资登记证(IRC)已获越南投资计划部颁发。两项关键监管审批均已取得。外汇局SAFE登记进行中。",
      dealId: deal.id,
      workstreamId: wsReg.id,
      authorId: liwei.id,
      createdAt: d("2026-05-05"),
    },
  });

  // Closing preparation progress
  await prisma.task.update({
    where: { id: taskMACConfirm.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-05-12"), updatedAt: d("2026-05-12") },
  });
  await prisma.task.update({
    where: { id: taskLegalOpinion.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-05-15"), updatedAt: d("2026-05-15") },
  });
  await prisma.task.update({
    where: { id: taskSignPages.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-05-16"), updatedAt: d("2026-05-16") },
  });
  await prisma.task.update({
    where: { id: taskFundsTransfer.id },
    data: { status: TaskStatus.InProgress, updatedAt: d("2026-05-15") },
  });

  // Time entries for closing prep
  await prisma.timeEntry.createMany({
    data: [
      { description: "ODI审批沟通和材料补充", durationMinutes: 240, isManual: true, isBillable: true, taskId: taskODIApproval.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-04-15"), updatedAt: d("2026-04-15") },
      { description: "越南IRC申请材料审核", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskVNInvestment.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-04-20"), updatedAt: d("2026-04-20") },
      { description: "MAC确认函准备", durationMinutes: 120, isManual: true, isBillable: true, taskId: taskMACConfirm.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-05-12"), updatedAt: d("2026-05-12") },
      { description: "中国法律意见书及越南法律意见书（配合Lexcomm）", durationMinutes: 420, isManual: true, isBillable: true, taskId: taskLegalOpinion.id, userId: liwei.id, dealId: deal.id, createdAt: d("2026-05-15"), updatedAt: d("2026-05-15") },
      { description: "签字页收集及核对", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskSignPages.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-05-16"), updatedAt: d("2026-05-16") },
      { description: "SAFE登记及银行汇款指令准备", durationMinutes: 300, isManual: true, isBillable: true, taskId: taskFundsTransfer.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-05-18"), updatedAt: d("2026-05-18") },
    ],
  });

  logObservation("FEATURE", "No CP (Conditions Precedent) satisfaction tracking dashboard. For closing, a dedicated view showing which CPs are satisfied/pending/waived would be much clearer than just using tasks.");
  logObservation("UX", "No way to generate a closing checklist report or export. Law firms typically produce a formatted closing checklist document for clients — the system should support generating this from the workstream data.");

  // ═══════════════════════════════════════════════════════════
  // STAGE 10 — Month 5: CLOSING (2026-05-22)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 10: Closing",
    "2026-05-22",
    "All CPs satisfied. Funds wired. Share transfer completed. Deal closed!"
  );

  // Funds transfer completed
  await prisma.task.update({
    where: { id: taskFundsTransfer.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-05-20"), updatedAt: d("2026-05-20") },
  });

  // Share transfer completed
  await prisma.task.update({
    where: { id: taskShareTransfer.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-05-22"), updatedAt: d("2026-05-22") },
  });

  await prisma.timeEntry.createMany({
    data: [
      { description: "交割日资金到账确认及各方通知", durationMinutes: 180, isManual: true, isBillable: true, taskId: taskFundsTransfer.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-05-20"), updatedAt: d("2026-05-20") },
      { description: "股权过户及越南工商变更登记", durationMinutes: 300, isManual: true, isBillable: true, taskId: taskShareTransfer.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-05-22"), updatedAt: d("2026-05-22") },
    ],
  });

  // CLOSING milestone!
  const milestoneClosing = await prisma.milestone.findFirst({ where: { dealId: deal.id, name: "交割" } });
  if (milestoneClosing) {
    await prisma.milestone.update({
      where: { id: milestoneClosing.id },
      data: { isDone: true, date: d("2026-05-22"), updatedAt: d("2026-05-22") },
    });
  }

  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Note,
      content: "✅ 交割完成！4800万美元已汇入卖方及Escrow账户（200万美元）。股权过户已在越南完成工商变更登记。华瑞医疗通过香港SPV正式持有Viet Pharma JSC 100%股权。项目从2025年12月1日FA引荐至交割历时约6个月。",
      dealId: deal.id,
      authorId: liwei.id,
      createdAt: d("2026-05-22"),
    },
  });
  logAction("MILESTONE: 交割 (2026-05-22) — DEAL CLOSED!");

  // ═══════════════════════════════════════════════════════════
  // STAGE 11 — Post-Closing & Project Close (2026-05-25 to 06-05)
  // ═══════════════════════════════════════════════════════════

  logStage(
    "Stage 11: Post-Closing & Project Close",
    "2026-05-25 to 2026-06-05",
    "Post-closing matters: notifications, closing binder, project wrap-up. Deal status changed to Completed."
  );

  // Post-closing task
  const taskPostNotice = await prisma.task.create({
    data: {
      title: "发送交割后通知 (Post-Closing Notices)",
      status: TaskStatus.Done,
      priority: TaskPriority.Normal,
      dueDate: d("2026-05-28"),
      completedAt: d("2026-05-26"),
      workstreamId: wsClosing.id,
      assigneeId: chenyu.id,
      sortOrder: 5,
      createdAt: d("2026-05-23"),
      updatedAt: d("2026-05-26"),
    },
  });

  // Closing binder
  await prisma.task.update({
    where: { id: taskClosingBinder.id },
    data: { status: TaskStatus.Done, completedAt: d("2026-06-03"), updatedAt: d("2026-06-03") },
  });

  await prisma.timeEntry.createMany({
    data: [
      { description: "交割后各方通知（合同方、监管机构等）", durationMinutes: 120, isManual: true, isBillable: true, taskId: taskPostNotice.id, userId: chenyu.id, dealId: deal.id, createdAt: d("2026-05-26"), updatedAt: d("2026-05-26") },
      { description: "交割文件档案整理归档", durationMinutes: 360, isManual: true, isBillable: true, taskId: taskClosingBinder.id, userId: zhanglin.id, dealId: deal.id, createdAt: d("2026-06-03"), updatedAt: d("2026-06-03") },
    ],
  });

  // Final client meeting
  await prisma.activityEntry.create({
    data: {
      type: ActivityType.Meeting,
      content: "项目结项会议。向客户提交交割文件档案(Closing Binder)和项目总结报告。客户对项目执行表示满意。后续事项：Escrow释放日期为2027年11月（交割后18个月），届时需配合。药品注册续期由客户自行跟进。项目正式结项。",
      dealId: deal.id,
      workstreamId: wsClient.id,
      authorId: liwei.id,
      createdAt: d("2026-06-05"),
    },
  });
  logAction("Project wrap-up meeting held. Closing binder delivered.");

  // Change deal status to Completed
  await prisma.deal.update({
    where: { id: deal.id },
    data: { status: DealStatus.Completed, updatedAt: d("2026-06-05") },
  });
  logAction("Deal status changed to COMPLETED");

  logObservation("FEATURE", "No 'project close' workflow. When a deal is completed, there should be a checklist: final invoice sent? Closing binder delivered? Conflict check closed? Engagement letter terminated? Currently just changing status to 'Completed' with no ceremony.");
  logObservation("FEATURE", "No post-closing reminder system. The Escrow releases in 18 months — the system should support setting a future reminder tied to this deal, even after it's marked Completed.");
  logObservation("UX", "After marking a deal as Completed, it disappears from the dashboard (Active deals only). But the team may still need to find it easily for post-closing matters. A 'Recently Completed' section or better archive access would help.");

  // ═══════════════════════════════════════════════════════════
  // FINAL: Summary of System Observations
  // ═══════════════════════════════════════════════════════════

  log.push("\n---\n");
  log.push("## Summary of System Observations\n");
  log.push("### Bugs Found\n");
  log.push("- When viewing a non-Active deal's detail page, overdue indicators still showed on tasks (fixed during this session).");
  log.push("- `getTaskDetail` had no deal membership check — any authenticated user could view any task (fixed during this session).");
  log.push("");
  log.push("### UX Improvements Needed\n");
  log.push("1. **TBD milestone dates** — null dates show nothing; a 'TBD' label would be more informative");
  log.push("2. **Milestone completion date tracking** — marking done doesn't record actual completion date separately from planned date");
  log.push("3. **Task-level document attachment** — cumbersome to link uploaded docs to specific tasks");
  log.push("4. **Batch task completion** — no way to complete multiple tasks at once");
  log.push("5. **Decision-to-task linking workflow** — no 'create task from decision' shortcut");
  log.push("6. **Activity feed pagination** — gets very long on active deals");
  log.push("7. **Milestone timeline visualization** — hard to distinguish completed vs upcoming at a glance");
  log.push("8. **Closing checklist export** — no way to generate formatted document from tasks");
  log.push("9. **Recently completed deals** — disappear from dashboard, hard to find for post-closing work");
  log.push("");
  log.push("### Feature Requests\n");
  log.push("1. **Deal source tracking** — how was the deal sourced (FA referral, direct, etc.)");
  log.push("2. **Deal value / consideration field** — purchase price, adjustments, escrow amounts");
  log.push("3. **Deal phase / stage** — distinct phases (intake → DD → negotiation → signing → closing)");
  log.push("4. **Decision due date** — deadline for client to decide");
  log.push("5. **Structured pros/cons** — separate fields instead of single text for decision options");
  log.push("6. **Exclusivity period tracker** — countdown for LOI exclusivity windows");
  log.push("7. **Deal financial summary** — key commercial terms dashboard");
  log.push("8. **Document version control** — SPA versioning and comparison");
  log.push("9. **CP satisfaction dashboard** — dedicated conditions precedent tracker view");
  log.push("10. **Project close workflow** — structured close-out checklist");
  log.push("11. **Post-closing reminders** — future-dated reminders for escrow release, etc.");
  log.push("12. **Activity comments / threading** — comment on activity entries inline");
  log.push("");
  log.push("### Statistics\n");
  log.push("- **Duration:** 2025-12-01 to 2026-06-05 (~6 months)");
  log.push("- **Workstreams:** 7 (客户沟通, 尽职调查, 交易文件, 监管审批, 交易架构, 交割条件跟踪, 交割清单)");
  log.push("- **Tasks created:** ~30");
  log.push("- **Decisions tracked:** 4 (structure, tax dispute, drug registration, indemnity cap)");
  log.push("- **Contacts:** 6 (FA, client GC, client VP, VN counsel, target CFO, seller's counsel)");
  log.push("- **Milestones:** 5 (NDA → LOI → DD完成 → SPA签署 → 交割)");
  log.push("- **Team:** 3 (李伟 lead, 张琳 paralegal, 陈宇 paralegal)");

  // Write log file
  const logPath = path.join(__dirname, "..", "Project-Epsilon-log.md");
  fs.writeFileSync(logPath, log.join("\n"), "utf-8");
  console.log(`\n✅ Project Epsilon simulation complete.`);
  console.log(`📄 Log written to: ${logPath}`);
  console.log(`📊 Deal ID: ${deal.id}`);
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });
