# Project Epsilon — Simulation Log

> Cross-border M&A: 华瑞医疗科技 acquires Viet Pharma JSC
> Simulated by project leader agent with two paralegal agents
> Generated: 2026-03-11

---

## Stage 1: Deal Intake — 2025-12-01

FA (Golden Bridge Capital) calls 李伟. Introduces an opportunity: a mid-size Vietnamese pharmaceutical company (Viet Pharma JSC) is open to strategic acquisition. Our potential client is 华瑞医疗科技, a Chinese medical device company looking to expand into Southeast Asian pharma. 李伟 assesses the opportunity and decides to pitch to the client.
- Created deal: 华瑞医疗收购越南制药 (Project Epsilon)
- Deal Lead: 李伟
- Added team: 李伟 (lead), 张琳 (paralegal 1), 陈宇 (paralegal 2)
- Added contact: Michael Chen (Golden Bridge Capital, FA)
- Recorded: FA introduction call
- **[UX]** When creating a new deal, there's no way to record HOW the deal was sourced (FA referral, direct, etc.). A 'deal source' field would be useful for tracking business development.
- **[FEATURE]** No deal value/consideration amount field in the schema. For M&A deals, the estimated or actual transaction value is critical information that should be displayed prominently.

## Stage 2: Client Pitch & Engagement — 2025-12-03

李伟 meets with 华瑞医疗 GC (General Counsel) 赵敏 to pitch the opportunity. Client is interested and agrees to engage the firm. Engagement letter to be drafted.
- Added client contacts: 赵敏 (GC), 孙建国 (VP)
- Created workstreams: 客户沟通, 尽职调查, 交易文件, 监管审批, 交易架构
- Created initial tasks: engagement letter, NDA, preliminary research, VN law analysis
- Created milestones: NDA签署, LOI签署, 尽调完成, SPA签署, 交割
- Recorded: Client pitch meeting
- **[UX]** Cannot set milestones with 'TBD' dates in a meaningful way. Currently null date milestones show no date at all — but a 'TBD' label would communicate that the date is pending, not that there's no milestone date.
- **[FEATURE]** No way to attach an engagement letter or NDA document to a specific task. Documents exist at deal/workstream level but task-level attachment workflow is cumbersome — user has to upload doc separately then hope to remember which task it belongs to.

## Stage 3: NDA & Preliminary Work — 2025-12-05 to 2025-12-10

张琳 drafts the engagement letter and NDA. 陈宇 researches Vietnamese pharma regulations. NDA is sent to Viet Pharma through the FA.
- Task completed: 起草聘用函
- Task completed: NDA drafted and sent to Viet Pharma via FA
- Milestone completed: NDA签署 (2025-12-10)
- Task completed: 越南制药行业初步调研
- **[FEATURE]** No 'phase' or 'stage' concept for the deal itself. Real M&A projects go through distinct phases (intake → DD → negotiation → signing → closing). Having a deal phase field would help everyone understand where the project stands at a glance.
- **[UX]** When marking a milestone as done, there's no prompt to record the actual completion date if it differs from the planned date. The system just marks isDone=true but the original date stays.

## Stage 4: Due Diligence Kickoff — 2025-12-12 to 2025-12-25

Vietnamese local counsel (Lexcomm Vietnam) engaged. DD request list prepared and sent. VDR access obtained. DD workstream becomes the main focus. Initial DD findings start coming in.
- Task completed: 越南外商投资医药行业法规初步分析
- Added contacts: Nguyen Thi Lan (VN counsel), Tran Van Duc (Target CFO)
- Created DD tasks: request list, VDR access, corporate DD, contracts, IP, labor, environmental
- Created decision: 交易架构选择 (3 options)
- **[FEATURE]** No way to assign a 'deadline' to a decision. In practice, clients need to make decisions by certain dates to keep the project on track. A decision due date field would be useful.
- **[UX]** Decision options don't support structured pros/cons (separate fields). Currently it's a single text field. A structured format (pros list + cons list) would be more readable.
- **[FEATURE]** No concept of 'counterparty counsel' in the ContactRole enum — there's CounterpartyCounsel but no TargetCompany role. For M&A, the target company contacts are very common and need a dedicated role.

## Stage 5: Deep DD & Structure Decision — 2026-01-05 to 2026-01-20

Due diligence deepens. Key findings emerge: (1) Viet Pharma has a pending tax dispute, (2) one key drug registration is expiring in 18 months, (3) minority shareholder (15%) has pre-emptive rights. Structure decision is made: HK SPV route.
- Created decisions for DD findings: tax dispute, drug registration expiry
- Decision made: HK SPV route selected. Structure task completed.
- Created new tasks from structure decision: HK SPV setup, ODI filing
- **[FEATURE]** No way to track deal value/consideration in the system. The client just gave us a target range of $45-50M but there's nowhere to record this prominently on the deal.
- **[UX]** When a decision leads to new tasks, there's no automated linking. Had to manually create tasks and hope to remember they came from the structure decision. A 'create task from decision' button would streamline this workflow.
- **[BUG]** The 'My Tasks' page filters tasks by Active deal status, which is correct. But if I'm on the deal detail page, I can see ALL tasks regardless of deal status. This is fine for viewing history on completed deals but could be confusing.

## Stage 6: LOI Negotiation — 2026-01-25 to 2026-02-15

DD nearing completion. LOI/Term Sheet drafted and negotiated. Key commercial terms being discussed. Minority shareholder issue addressed.
- DD tasks completed: contracts, IP, labor, environmental
- Created LOI tasks and DD report compilation
- Milestone completed: 尽调完成 (2026-01-30)
- Milestone completed: LOI签署 (2026-02-12), price $48M
- HK SPV incorporated
- **[FEATURE]** No 'exclusivity period' tracker. After LOI signing, there's a 75-day exclusivity window. Having a countdown or visual indicator for exclusivity expiry would be very useful.
- **[UX]** When multiple DD sub-tasks complete at similar times, there's no way to batch-complete them. Each task needs individual status update. A 'complete selected tasks' bulk action would save time.
- **[FEATURE]** No deal financial summary — purchase price, escrow amount, adjustments, etc. These are core commercial terms that the team references constantly.

## Stage 7: SPA Drafting & Negotiation — 2026-02-15 to 2026-03-20

SPA first draft prepared. Multiple rounds of negotiation. Regulatory filings initiated (ODI in PRC, investment registration in Vietnam). Key negotiation points: R&W scope, indemnity caps, escrow, CPs.
- Created SPA and regulatory tasks for signing preparation
- Added contact: Le Minh Tuan (Baker McKenzie Vietnam, seller's counsel)
- SPA first draft completed. Antitrust: no filing required.
- Key negotiation decisions made by client
- ODI filing submitted. SPA schedules completed.
- **[FEATURE]** No SPA version tracking / comparison. Real SPA negotiations involve 5-10+ draft versions. The system has Documents but no version control or comparison feature for key transaction documents.
- **[UX]** Activity feed becomes very long. Need pagination or date-range filtering on the activity feed within a deal. Currently it loads all entries.
- **[FEATURE]** No task comments from the timeline/activity view. When a team member posts a negotiation update, others can't comment inline. They'd need to add a separate activity entry or go to a specific task.

## Stage 8: Pre-Signing & Signing — 2026-03-20 to 2026-04-05

SPA finalized. CP tracker established. Board approvals obtained. Signing ceremony conducted.
- Created signing preparation tasks: SPA finalization, board approval, minority waiver, escrow agreement
- Pre-signing tasks completed: waiver, board approval, SPA final, escrow agreement
- MILESTONE: SPA签署 (2026-04-03) — SIGNING COMPLETED!
- **[FEATURE]** No 'signing ceremony' or 'key event' concept. Signing is the most important moment in a deal but it's just recorded as an activity note. A special event type with document attachment (signed SPA) would be appropriate.
- **[UX]** The milestone timeline doesn't visually distinguish between 'completed' milestones and 'upcoming' ones very well when you have many milestones at different stages.

## Stage 9: Closing Preparation — 2026-04-05 to 2026-05-20

Post-signing, working towards closing. CP satisfaction: ODI approval obtained, Vietnam IRC in progress, closing checklist prepared.
- Created CP and closing checklist tasks
- CP satisfied: ODI approval obtained (2026-04-18)
- CP satisfied: Vietnam IRC obtained (2026-05-05)
- **[FEATURE]** No CP (Conditions Precedent) satisfaction tracking dashboard. For closing, a dedicated view showing which CPs are satisfied/pending/waived would be much clearer than just using tasks.
- **[UX]** No way to generate a closing checklist report or export. Law firms typically produce a formatted closing checklist document for clients — the system should support generating this from the workstream data.

## Stage 10: Closing — 2026-05-22

All CPs satisfied. Funds wired. Share transfer completed. Deal closed!
- MILESTONE: 交割 (2026-05-22) — DEAL CLOSED!

## Stage 11: Post-Closing & Project Close — 2026-05-25 to 2026-06-05

Post-closing matters: notifications, closing binder, project wrap-up. Deal status changed to Completed.
- Project wrap-up meeting held. Closing binder delivered.
- Deal status changed to COMPLETED
- **[FEATURE]** No 'project close' workflow. When a deal is completed, there should be a checklist: final invoice sent? Closing binder delivered? Conflict check closed? Engagement letter terminated? Currently just changing status to 'Completed' with no ceremony.
- **[FEATURE]** No post-closing reminder system. The Escrow releases in 18 months — the system should support setting a future reminder tied to this deal, even after it's marked Completed.
- **[UX]** After marking a deal as Completed, it disappears from the dashboard (Active deals only). But the team may still need to find it easily for post-closing matters. A 'Recently Completed' section or better archive access would help.

---

## Summary of System Observations

### Bugs Found

- When viewing a non-Active deal's detail page, overdue indicators still showed on tasks (fixed during this session).
- `getTaskDetail` had no deal membership check — any authenticated user could view any task (fixed during this session).

### UX Improvements Needed

1. **TBD milestone dates** — null dates show nothing; a 'TBD' label would be more informative
2. **Milestone completion date tracking** — marking done doesn't record actual completion date separately from planned date
3. **Task-level document attachment** — cumbersome to link uploaded docs to specific tasks
4. **Batch task completion** — no way to complete multiple tasks at once
5. **Decision-to-task linking workflow** — no 'create task from decision' shortcut
6. **Activity feed pagination** — gets very long on active deals
7. **Milestone timeline visualization** — hard to distinguish completed vs upcoming at a glance
8. **Closing checklist export** — no way to generate formatted document from tasks
9. **Recently completed deals** — disappear from dashboard, hard to find for post-closing work

### Feature Requests

1. **Deal source tracking** — how was the deal sourced (FA referral, direct, etc.)
2. **Deal value / consideration field** — purchase price, adjustments, escrow amounts
3. **Deal phase / stage** — distinct phases (intake → DD → negotiation → signing → closing)
4. **Decision due date** — deadline for client to decide
5. **Structured pros/cons** — separate fields instead of single text for decision options
6. **Exclusivity period tracker** — countdown for LOI exclusivity windows
7. **Deal financial summary** — key commercial terms dashboard
8. **Document version control** — SPA versioning and comparison
9. **CP satisfaction dashboard** — dedicated conditions precedent tracker view
10. **Project close workflow** — structured close-out checklist
11. **Post-closing reminders** — future-dated reminders for escrow release, etc.
12. **Activity comments / threading** — comment on activity entries inline

### Statistics

- **Duration:** 2025-12-01 to 2026-06-05 (~6 months)
- **Workstreams:** 7 (客户沟通, 尽职调查, 交易文件, 监管审批, 交易架构, 交割条件跟踪, 交割清单)
- **Tasks created:** ~30
- **Decisions tracked:** 4 (structure, tax dispute, drug registration, indemnity cap)
- **Contacts:** 6 (FA, client GC, client VP, VN counsel, target CFO, seller's counsel)
- **Milestones:** 5 (NDA → LOI → DD完成 → SPA签署 → 交割)
- **Team:** 3 (李伟 lead, 张琳 paralegal, 陈宇 paralegal)