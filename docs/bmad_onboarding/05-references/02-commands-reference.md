---
clickup_workspace_id: "90182277854"
type: "page"
title: "Commands Reference"
clickup_parent_doc_id: "2kzmgppy-2038"
---

# 📋 BMAD Commands Reference

Danh sách tất cả commands và khi nào sử dụng.

---

## 🔍 Quick Navigation

| Phase | Commands |
|-------|----------|
| [Analysis](#-phase-1-analysis) | `/research`, `/create-product-brief`, `/brainstorming` |
| [Planning](#-phase-2-planning) | `/create-prd`, `/create-ux-design` |
| [Solutioning](#-phase-3-solutioning) | `/create-architecture`, `/create-epics-and-stories`, `/check-implementation-readiness` |
| [Implementation](#-phase-4-implementation) | `/sprint-planning`, `/create-story`, `/dev-story`, `/code-review`, `/retrospective` |
| [Quick Flow](#-quick-flow) | `/quick-spec`, `/quick-dev` |
| [TestArch](#-testarch-commands) | `/testarch-*` |
| [Diagrams](#-excalidraw-diagrams) | `/create-excalidraw-*` |
| [Utilities](#️-utility-commands) | `/bmad-help`, `/party-mode`, `/document-project` |

---

## 📊 Phase 1: Analysis

### `/research`
**Agent:** Mary (📊 Business Analyst)

Conduct research với các types:
- `market` - Phân tích thị trường, competitors, trends
- `domain` - Deep dive vào industry domain
- `technical` - Technical feasibility, architecture options

```
Ví dụ: "Tôi cần research về thị trường e-commerce Việt Nam"
→ Agent tự động dùng /research type=market
```

---

### `/create-product-brief`
**Agent:** Mary (📊 Business Analyst)

Tạo product brief qua guided conversation.

**Khi dùng:**
- ✅ Bắt đầu project mới
- ✅ Nail down ý tưởng sản phẩm
- ❌ Đã có brief rõ ràng

**Output:** `planning_artifacts/product-brief.md`

---

### `/brainstorming`
**Agent:** Mary (📊 Business Analyst)

Interactive brainstorming session với các techniques:
- Mind mapping
- SCAMPER
- Six Thinking Hats
- And more...

**Khi dùng:**
- ✅ Explore ideas
- ✅ Generate alternatives
- ✅ Break creative blocks

---

## 📋 Phase 2: Planning

### `/create-prd`
**Agent:** John (📋 Product Manager)

Tạo Product Requirements Document.

**Modes:**
- Create - Tạo mới
- Validate - Kiểm tra PRD có đầy đủ không

**Khi dùng:**
- ✅ Sau khi có product brief
- ✅ Cần document requirements chi tiết
- ❌ Quick one-off tasks

**Output:** `planning_artifacts/prd.md`

---

### `/create-ux-design`
**Agent:** Sally (🎨 UX Designer)

Plan UX patterns và look-and-feel.

**Khi dùng:**
- ✅ Project có UI
- ✅ Cần UX strategy
- ❌ Backend-only projects

**Output:** `planning_artifacts/ux-design.md`

---

## 🏗️ Phase 3: Solutioning

### `/create-architecture`
**Agent:** Winston (🏗️ Architect)

Tạo architecture document với technical decisions.

**Prerequisites:**
- PRD (required)
- UX Design (recommended if UI exists)

**Khi dùng:**
- ✅ Sau PRD, trước implementation
- ✅ Cần document tech decisions

**Output:** `planning_artifacts/architecture.md`

---

### `/create-epics-and-stories`
**Agent:** John (📋 Product Manager)

Transform PRD + Architecture thành Epics & User Stories.

**Prerequisites:**
- PRD + Architecture (required)

**Khi dùng:**
- ✅ Sau architecture
- ✅ Chuẩn bị cho implementation

**Output:** `planning_artifacts/epics/*.md`

---

### `/check-implementation-readiness`
**Agent:** Winston (🏗️ Architect)

Adversarial review để đảm bảo PRD, Architecture, Epics aligned.

**Khi dùng:**
- ✅ Trước khi bắt đầu sprint
- ✅ Verify everything is ready

**Output:** Readiness report

---

## 💻 Phase 4: Implementation

### `/sprint-planning`
**Agent:** Bob (🏃 Scrum Master)

Generate sprint plan từ epics/stories.

**Khi dùng:**
- ✅ Kick off implementation phase
- ✅ Tạo plan cho dev team

**Output:** `implementation_artifacts/sprint-status.yaml`

---

### `/sprint-status`
**Agent:** Bob (🏃 Scrum Master)

Summarize sprint status và route to next workflow.

**Khi dùng:**
- ✅ Check progress anytime
- ✅ Find next task to do

---

### `/create-story`
**Agent:** Bob (🏃 Scrum Master)

Prepare next story from sprint plan.

**Khi dùng:**
- ✅ Start new story cycle
- ✅ Story cần detail hơn

**Output:** Story file with full details

---

### `/dev-story`
**Agent:** Amelia (💻 Developer)

Execute story implementation.

**Khi dùng:**
- ✅ Story đã ready
- ✅ Implement và test

**Flow:** `/dev-story` → `/code-review` → fix → repeat

---

### `/code-review`
**Agent:** Amelia (💻 Developer)

Adversarial code review - finds 3-10 issues per story.

**Khi dùng:**
- ✅ Sau `/dev-story`
- ✅ Before marking story complete

---

### `/retrospective`
**Agent:** Bob (🏃 Scrum Master)

Review epic completion, lessons learned.

**Khi dùng:**
- ✅ Sau khi complete một epic
- ✅ Extract lessons

---

## 🚀 Quick Flow

> ⚠️ Dùng cho simple tasks. KHÔNG dùng cho complex features!

### `/quick-spec`
**Agent:** Barry (🚀 Quick Flow Solo Dev)

Conversational spec engineering - nhanh, lean.

**Khi dùng:**
- ✅ One-off tasks
- ✅ Small changes
- ✅ Simple utilities
- ❌ Complex projects

**Output:** `planning_artifacts/tech-spec.md`

---

### `/quick-dev`
**Agent:** Barry (🚀 Quick Flow Solo Dev)

Execute tech-spec hoặc direct instructions.

**Khi dùng:**
- ✅ Implement quick specs
- ✅ Small fixes
- ❌ Epic-level work

---

## 🧪 TestArch Commands

### `/testarch-test-design`
**Agent:** Murat (🧪 Test Architect)

Create comprehensive test scenarios ahead of development.

**Modes:**
- System-level review (Solutioning phase)
- Epic-level planning (Implementation phase)

---

### `/testarch-framework`
Initialize test framework (Playwright/Cypress).

---

### `/testarch-automate`
Expand test automation coverage.

---

### `/testarch-atdd`
Generate failing acceptance tests (TDD approach).

---

### `/testarch-ci`
Scaffold CI/CD quality pipeline.

---

### `/testarch-nfr`
Assess non-functional requirements (performance, security).

---

### `/testarch-test-review`
Review test quality.

---

### `/testarch-trace`
Generate requirements-to-tests traceability matrix.

---

## 🎨 Excalidraw Diagrams

### `/create-excalidraw-diagram`
System architecture, ERD, UML diagrams.

### `/create-excalidraw-dataflow`
Data flow diagrams (DFD).

### `/create-excalidraw-flowchart`
Flowcharts for processes, pipelines.

### `/create-excalidraw-wireframe`
App/website wireframes.

---

## 🛠️ Utility Commands

### `/bmad-help`
**🌟 Most Important!**

Get unstuck - shows next workflow steps.

**Khi dùng:**
- ✅ Không biết làm gì tiếp
- ✅ Cần guidance
- ✅ Explore available workflows

---

### `/party-mode`
Multi-agent group discussion.

**Khi dùng:**
- ✅ Need multiple perspectives
- ✅ Complex decisions

---

### `/document-project`
Analyze existing codebase và tạo documentation.

**Khi dùng:**
- ✅ Brownfield projects
- ✅ Onboarding documentation

---

### `/correct-course`
Navigate significant changes during sprint.

**Khi dùng:**
- ✅ Requirements changed
- ✅ Need to pivot

---

### `/bmad-index-docs`
Generate/update index.md for a directory.

---

### `/bmad-shard-doc`
Split large markdown into smaller files.

---

### `/bmad-editorial-review-prose`
Copy-edit text for communication issues.

---

### `/bmad-editorial-review-structure`
Structural editing - cuts, reorganization.

---

### `/bmad-review-adversarial-general`
Cynical review of any content.

---

## 📌 Cheat Sheet

### Bắt Đầu Project Mới
```
/research → /create-product-brief → /create-prd → /create-architecture → /create-epics-and-stories → /check-implementation-readiness → /sprint-planning → /create-story → /dev-story
```

### Quick Task
```
/quick-spec → /quick-dev
```

### Đang Stuck?
```
/bmad-help
```

### Cần Nhiều Ý Kiến?
```
/party-mode
```
