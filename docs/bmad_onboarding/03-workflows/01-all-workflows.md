---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "All Workflows Reference"
---

# Tài Liệu Chi Tiết: `.agent/workflows/` Directory

## 📋 Tổng Quan

Thư mục `.agent/workflows/` chứa **47 files** - đây là **integration layer** giữa AI IDE và BMAD framework.

### **Cơ Chế Hoạt Động**

Mỗi file trong `.agent/workflows/` là một **shortcut** có 2 nhiệm vụ:

1. **Metadata**: Chứa `name` và `description` trong YAML frontmatter
2. **Pointer**: Trỏ đến file thực thi trong `_bmad/core/` hoặc `_bmad/bmm/`

### **2 Loại Shortcuts**

| Loại | Pattern | Ví Dụ |
|------|---------|-------|
| **Workflow Shortcuts** | `bmad-*-workflow.md` | `bmad-bmm-create-prd.md` |
| **Agent Shortcuts** | `bmad-*-agent.md` | `bmad-bmm-pm.agent.md` |

---

## 🗂️ Phân Loại 47 Workflows

Tôi đã phân tích và nhóm thành **8 categories**:

### **📊 Thống Kê Tổng Quan**

```
Total Files: 47
├── Universal Tools (Core): 7 workflows
├── Agents: 10 agent shortcuts
├── Discovery Phase (BMM): 2 workflows
├── Planning Phase (BMM): 3 workflows
├── Solutioning Phase (BMM): 3 workflows
├── Implementation Phase (BMM): 7 workflows
├── Test Architecture (BMM): 8 workflows
└── Documentation/Editorial (Core): 4 workflows
```

---

## 1️⃣ Universal Tools (Core Module)

Các workflows này có thể dùng **anytime**, không phụ thuộc vào phase.

### 1.1 `/bmad-help` - AI-Guided Help System
**File**: `bmad-help.md`  
**Target**: `_bmad/core/tasks/help.md`

**Chức Năng**:
- Smart context-aware help
- Phân tích workflow vừa hoàn thành
- Suggest next steps based on phase
- Module detection
- Artifact-based completion tracking

**Khi Nào Dùng**:
- Khi không biết làm gì tiếp theo
- Hoặc: `/bmad-help I just finished the architecture, what's next?`

---

### 1.2 `/brainstorming` - Creative Ideation
**File**: `bmad-brainstorming.md`  
**Target**: `_bmad/core/workflows/brainstorming/workflow.md`

**Chức Năng**:
- Facilitate brainstorming sessions
- Multiple creative techniques
- Ideation methods
- Problem-solving frameworks

**Khi Nào Dùng**:
- Khi cần explore ideas
- Problem-solving sessions
- Feature ideation

---

### 1.3 `/party-mode` - Multi-Agent Discussions
**File**: `bmad-party-mode.md`  
**Target**: `_bmad/core/workflows/party-mode/workflow.md`

**Chức Năng**:
- Orchestrate multiple agents in one session
- Natural multi-agent conversations
- Different perspectives
- Collaborative problem-solving

**Khi Nào Dùng**:
- Khi cần nhiều góc nhìn chuyên gia
- Complex decision making
- Architecture reviews

---

### 1.4 `/editorial-review-prose` - Copy Editing
**File**: `bmad-editorial-review-prose.md`  
**Target**: `_bmad/core/tasks/editorial-review-prose.xml`

**Chức Năng**:
- Clinical copy-editor persona
- Review text for communication issues
- Grammar, clarity, tone
- Writing quality improvement

**Khi Nào Dùng**:
- Documents cần polish
- Marketing copy
- User-facing content

---

### 1.5 `/editorial-review-structure` - Structural Editing
**File**: `bmad-editorial-review-structure.md`  
**Target**: `_bmad/core/tasks/editorial-review-structure.xml`

**Chức Năng**:
- Structural editor persona
- Propose cuts and reorganization
- Simplification while preserving comprehension
- Document architecture review

**Khi Nào Dùng**:
- Long documents cần restructure
- PRDs, architecture docs quá dài

---

### 1.6 `/review-adversarial-general` - Critical Review
**File**: `bmad-review-adversarial-general.md`  
**Target**: `_bmad/core/tasks/review-adversarial-general.xml`

**Chức Năng**:
- Cynical review approach
- Find problems and gaps
- Challenge assumptions
- Produce findings

**Khi Nào Dùng**:
- Before finalizing major documents
- Quality gate reviews

---

### 1.7 `/index-docs` - Documentation Indexing
**File**: `bmad-index-docs.md`  
**Target**: `_bmad/core/tasks/index-docs.xml`

**Chức Năng**:
- Generate/update index.md
- Catalog all documents in directory
- Organize documentation

**Khi Nào Dùng**:
- After creating many docs
- Maintain documentation structure

---

### 1.8 `/shard-doc` - Document Splitting
**File**: `bmad-shard-doc.md`  
**Target**: `_bmad/core/tasks/shard-doc.xml`

**Chức Năng**:
- Split large markdown documents
- Organize into smaller files
- Based on level 2 sections (default)

**Khi Nào Dùng**:
- Documents quá lớn (>1000 lines)
- Cần modularize content

---

## 2️⃣ Agents (BMAD Personas)

Các file này load specialized agents với personas riêng.

### 2.1 `/bmad-master` - Master Orchestrator Agent
**File**: `bmad-bmad-master.agent.md`  
**Target**: `_bmad/core/agents/bmad-master.md`  
**Icon**: 🧙

**Persona**:
- Master Task Executor
- BMad Expert
- Workflow Orchestrator

**Menu Items**:
- List Available Tasks
- List Workflows
- Start Party Mode
- Chat

---

### 2.2 `/analyst` - Business Analyst Agent
**File**: `bmad-bmm-analyst.agent.md`  
**Target**: `_bmad/bmm/agents/analyst.md`  
**Icon**: 📊

**Persona**:
- Business Analyst expert
- Requirements gathering
- Stakeholder interviews

**Specialty**: Data analysis, requirements discovery

---

### 2.3 `/architect` - Software Architect Agent
**File**: `bmad-bmm-architect.agent.md`  
**Target**: `_bmad/bmm/agents/architect.md`  
**Icon**: 🏗️

**Persona**:
- Technical architecture expert
- System design decisions
- Technology choices

**Specialty**: Architecture patterns, scalability

---

### 2.4 `/pm` - Product Manager Agent
**File**: `bmad-bmm-pm.agent.md`  
**Target**: `_bmad/bmm/agents/pm.md`  
**Icon**: 📋  
**Name**: John

**Persona**:
- Product Manager veteran (8+ years)
- Asks "WHY?" relentlessly
- Data-driven decision making

**Communication Style**: Direct and data-sharp, cuts through fluff

**Menu Items**:
- Create PRD
- Validate PRD
- Edit PRD
- Create Epics and Stories
- Implementation Readiness Check

---

### 2.5 `/dev` - Developer Agent
**File**: `bmad-bmm-dev.agent.md`  
**Target**: `_bmad/bmm/agents/dev.md`  
**Icon**: 💻

**Persona**:
- Senior Developer
- Code quality focus
- Test-driven development

---

### 2.6 `/sm` - Scrum Master Agent
**File**: `bmad-bmm-sm.agent.md`  
**Target**: `_bmad/bmm/agents/sm.md`  
**Icon**: 🎯

**Persona**:
- Agile coach
- Sprint facilitation
- Team coordination

---

### 2.7 `/tea` - Test Engineer Agent (TEA)
**File**: `bmad-bmm-tea.agent.md`  
**Target**: `_bmad/bmm/agents/tea.md`  
**Icon**: ✅

**Persona**:
- Test Architect
- Quality assurance expert
- Automation specialist

---

### 2.8 `/ux-designer` - UX Designer Agent
**File**: `bmad-bmm-ux-designer.agent.md`  
**Target**: `_bmad/bmm/agents/ux-designer.md`  
**Icon**: 🎨

**Persona**:
- UX/UI expert
- User experience design
- Interface patterns

---

### 2.9 `/tech-writer` - Technical Writer Agent
**File**: `bmad-bmm-tech-writer-tech-writer.agent.md`  
**Target**: `_bmad/bmm/agents/tech-writer/`  
**Icon**: 📝

**Persona**:
- Documentation expert
- API docs, user guides
- Technical communication

---

### 2.10 `/quick-flow-solo-dev` - Solo Developer Agent
**File**: `bmad-bmm-quick-flow-solo-dev.agent.md`  
**Target**: `_bmad/bmm/agents/quick-flow-solo-dev.md`

**Persona**:
- Full-stack solo developer
- Fast iteration
- Minimal planning overhead

---

## 3️⃣ Phase 1: Discovery (BMM Module)

Workflows cho giai đoạn khám phá và nghiên cứu.

### 3.1 `/create-product-brief` - Product Brief Creation
**File**: `bmad-bmm-create-product-brief.md`  
**Target**: `_bmad/bmm/workflows/1-analysis/create-product-brief/workflow.md`  
**Phase**: Discovery

**Chức Năng**:
- Collaborative step-by-step discovery
- Business Analyst persona
- Problem definition
- User identification
- MVP scope

**Output**: `_bmad-output/product-brief/product-brief.md`

**Khi Nào Dùng**:
- Starting point cho new projects
- Before writing full PRD

---

### 3.2 `/research` - Comprehensive Research
**File**: `bmad-bmm-research.md`  
**Target**: `_bmad/bmm/workflows/1-analysis/research/workflow.md`  
**Phase**: Discovery

**Chức Năng**:
- Market research
- Technical research
- Domain research
- Current web data
- Verified sources

**Output**: Research reports in `_bmad-output/research/`

**Khi Nào Dùng**:
- Need market validation
- Technical feasibility study
- Competitive analysis

---

## 4️⃣ Phase 2: Planning (BMM Module)

Workflows cho giai đoạn lập kế hoạch chi tiết.

### 4.1 `/create-prd` - Product Requirements Document
**File**: `bmad-bmm-create-prd.md`  
**Target**: `_bmad/bmm/workflows/2-plan-workflows/create-prd/workflow.md`  
**Phase**: Planning

**Chức Năng**:
- **Tri-modal**: Create, Validate, or Edit
- Full requirements documentation
- Personas, metrics, risks
- User stories foundation

**Output**: `_bmad-output/prd/prd.md`

**Modes**:
1. **Create Mode**: New PRD from scratch
2. **Validate Mode**: Review existing PRD
3. **Edit Mode**: Update existing PRD

**Khi Nào Dùng**:
- After product brief
- Before architecture

---

### 4.2 `/create-ux-design` - UX Design Planning
**File**: `bmad-bmm-create-ux-design.md`  
**Target**: `_bmad/bmm/workflows/2-plan-workflows/create-ux-design/workflow.md`  
**Phase**: Planning

**Chức Năng**:
- UX patterns planning
- Look and feel design
- User flow design
- Peer UX expert collaboration

**Output**: `_bmad-output/ux-design/`

**Khi Nào Dùng**:
- Products với UI/UX important
- Before implementation
- Optional workflow

---

### 4.3 `/document-project` - Brownfield Documentation
**File**: `bmad-bmm-document-project.md`  
**Target**: `_bmad/bmm/workflows/document-project/workflow.yaml`  
**Phase**: Planning (or anytime)

**Chức Năng**:
- Analyze existing codebase
- Scan architecture patterns
- Create comprehensive reference docs
- AI-assisted development prep

**Output**: Project documentation

**Khi Nào Dùng**:
- Joining existing project
- Legacy codebase handover
- AI onboarding to project

---

## 5️⃣ Phase 3: Solutioning (BMM Module)

Workflows cho giai đoạn thiết kế giải pháp.

### 5.1 `/create-architecture` - Architecture Design
**File**: `bmad-bmm-create-architecture.md`  
**Target**: `_bmad/bmm/workflows/3-solutioning/create-architecture/workflow.md`  
**Phase**: Solutioning

**Chức Năng**:
- Collaborative architectural decisions
- System design
- Technology choices
- AI-agent consistency optimization
- Decision-focused (not template-driven)

**Output**: `_bmad-output/architecture/architecture.md`

**Khi Nào Dùng**:
- After PRD
- Before epics/stories

---

### 5.2 `/create-epics-and-stories` - Epic & Story Breakdown
**File**: `bmad-bmm-create-epics-and-stories.md`  
**Target**: `_bmad/bmm/workflows/3-solutioning/create-epics-and-stories/workflow.md`  
**Phase**: Solutioning

**Chức Năng**:
- Transform PRD + Architecture into stories
- Organized by user value
- Implementation-ready epics
- Complete acceptance criteria
- Incorporates UX context if available

**Output**: `_bmad-output/epics/*.md`

**Requirements**:
- ✅ PRD completed
- ✅ Architecture completed
- ⚠️ UX Design (recommended for UI)

**Khi Nào Dùng**:
- After PRD + Architecture
- Before implementation

---

### 5.3 `/check-implementation-readiness` - Readiness Validation
**File**: `bmad-bmm-check-implementation-readiness.md`  
**Target**: `_bmad/bmm/workflows/3-solutioning/check-implementation-readiness/workflow.md`  
**Phase**: Solutioning

**Chức Năng**:
- **ADVERSARIAL REVIEW**
- Assess PRD, Architecture, Epics completeness
- Find gaps and issues
- Alignment check
- Quality gate before implementation

**Output**: Findings report

**Khi Nào Dùng**:
- After all planning docs completed
- **Before starting implementation**

---

## 6️⃣ Phase 4: Implementation (BMM Module)

Workflows cho giai đoạn xây dựng và implementation.

### 6.1 `/sprint-planning` - Sprint Initialization
**File**: `bmad-bmm-sprint-planning.md`  
**Target**: `_bmad/bmm/workflows/4-implementation/sprint-planning/workflow.yaml`  
**Phase**: Implementation

**Chức Năng**:
- Generate sprint tracking file
- Extract all epics and stories
- Initialize sprint-status.yaml
- Track development lifecycle

**Output**: `_bmad-output/sprint/sprint-status.yaml`

**Khi Nào Dùng**:
- Once, at start of implementation phase
- After epics/stories created

---

### 6.2 `/sprint-status` - Sprint Status Summary
**File**: `bmad-bmm-sprint-status.md`  
**Target**: `_bmad/bmm/workflows/4-implementation/sprint-status/workflow.yaml`  
**Phase**: Implementation

**Chức Năng**:
- Summarize sprint-status.yaml
- Surface risks
- Route to right implementation workflow
- Progress tracking

**Khi Nào Dùng**:
- During sprint
- Check what to do next

---

### 6.3 `/create-story` - Next Story Creation
**File**: `bmad-bmm-create-story.md`  
**Target**: `_bmad/bmm/workflows/4-implementation/create-story/workflow.yaml`  
**Phase**: Implementation

**Chức Năng**:
- Create next user story
- Enhanced context analysis
- Direct ready-for-dev marking
- Pull from epics+stories

**Output**: Individual story file

**Khi Nào Dùng**:
- When ready for next story
- Iterative development

---

### 6.4 `/quick-spec` - Quick Tech Spec
**File**: `bmad-bmm-quick-spec.md`  
**Target**: `_bmad/bmm/workflows/bmad-quick-flow/quick-spec/workflow.md`  
**Phase**: Implementation (Quick Flow)

**Chức Năng**:
- Conversational spec engineering
- Ask questions
- Investigate code
- Produce implementation-ready tech-spec
- **Fast path alternative**

**Output**: `_bmad-output/tech-specs/`

**Khi Nào Dùng**:
- Small features
- Bug fixes
- Clear scope
- **Quick Flow path**

---

### 6.5 `/dev-story` - Story Implementation
**File**: `bmad-bmm-dev-story.md`  
**Target**: `_bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml`  
**Phase**: Implementation

**Chức Năng**:
- Execute story implementation
- Implement tasks/subtasks
- Write tests
- Validate against acceptance criteria
- Update story file

**Output**: Code, tests, updated story

**Khi Nào Dùng**:
- After `/create-story` or `/quick-spec`
- Core implementation workflow

---

### 6.6 `/quick-dev` - Quick Development
**File**: `bmad-bmm-quick-dev.md`  
**Target**: `_bmad/bmm/workflows/bmad-quick-flow/quick-dev/workflow.md`  
**Phase**: Implementation (Quick Flow)

**Chức Năng**:
- Flexible development
- Execute tech-specs OR direct instructions
- Optional planning
- **Fast path**

**Khi Nào Dùng**:
- Quick changes
- Direct implementation
- **Quick Flow path**

---

### 6.7 `/code-review` - Adversarial Code Review
**File**: `bmad-bmm-code-review.md`  
**Target**: `_bmad/bmm/workflows/4-implementation/code-review/workflow.yaml`  
**Phase**: Implementation

**Chức Năng**:
- **ADVERSARIAL Senior Developer review**
- Find 3-10 specific problems (minimum)
- **NEVER accepts "looks good"**
- Challenge: code quality, tests, architecture, security, performance
- Can auto-fix with user approval

**Output**: Review findings + fixes

**Khi Nào Dùng**:
- After `/dev-story` or `/quick-dev`
- **MANDATORY quality gate**

---

### 6.8 `/correct-course` - Course Correction
**File**: `bmad-bmm-correct-course.md`  
**Target**: `_bmad/bmm/workflows/4-implementation/correct-course/workflow.yaml`  
**Phase**: Implementation

**Chức Năng**:
- Navigate significant changes during sprint
- Analyze impact
- Propose solutions
- Route for implementation

**Khi Nào Dùng**:
- Major changes discovered mid-sprint
- Scope change
- Blocker resolution

---

### 6.9 `/retrospective` - Epic Retrospective
**File**: `bmad-bmm-retrospective.md`  
**Target**: `_bmad/bmm/workflows/4-implementation/retrospective/workflow.yaml`  
**Phase**: Implementation

**Chức Năng**:
- Run after epic completion
- Review overall success
- Extract lessons learned
- Explore new information
- Impact assessment for next epic

**Khi Nào Dùng**:
- After completing an epic
- Before starting next epic

---

## 7️⃣ Test Architecture (TestArch) - BMM Module

8 workflows chuyên về testing và quality assurance.

### 7.1 `/testarch-framework` - Test Framework Setup
**File**: `bmad-bmm-testarch-framework.md`  
**Target**: `_bmad/bmm/workflows/testarch/framework/workflow.yaml`

**Chức Năng**:
- Initialize production-ready test framework
- Playwright or Cypress
- Fixtures, helpers, configuration
- Architecture scaffolding

**Khi Nào Dùng**:
- Start of project
- Setting up test infrastructure

---

### 7.2 `/testarch-test-design` - Test Design
**File**: `bmad-bmm-testarch-test-design.md`  
**Target**: `_bmad/bmm/workflows/testarch/test-design/workflow.yaml`

**Chức Năng**:
- **Dual-mode**:
  1. System-level testability review (Solutioning phase)
  2. Epic-level test planning (Implementation phase)
- Auto-detects mode based on phase

**Khi Nào Dùng**:
- Solutioning: Architecture review
- Implementation: Per-epic planning

---

### 7.3 `/testarch-atdd` - Acceptance Test-Driven Development
**File**: `bmad-bmm-testarch-atdd.md`  
**Target**: `_bmad/bmm/workflows/testarch/atdd/workflow.yaml`

**Chức Năng**:
- Generate **failing** acceptance tests
- **BEFORE implementation**
- TDD red-green-refactor cycle
- Behavior-driven development

**Khi Nào Dùng**:
- Before implementing features
- TDD workflow

---

### 7.4 `/testarch-automate` - Test Automation
**File**: `bmad-bmm-testarch-automate.md`  
**Target**: `_bmad/bmm/workflows/testarch/automate/workflow.yaml`

**Chức Năng**:
- Expand test automation coverage
- After implementation
- Or analyze existing codebase
- Generate comprehensive test suite

**Khi Nào Dùng**:
- Increase coverage
- Legacy code testing

---

### 7.5 `/testarch-test-review` - Test Quality Review
**File**: `bmad-bmm-testarch-test-review.md`  
**Target**: `_bmad/bmm/workflows/testarch/test-review/workflow.yaml`

**Chức Năng**:
- Review test quality
- Comprehensive knowledge base
- Best practices validation
- Test effectiveness

**Khi Nào Dùng**:
- Review existing tests
- Quality improvement

---

### 7.6 `/testarch-trace` - Requirements Traceability
**File**: `bmad-bmm-testarch-trace.md`  
**Target**: `_bmad/bmm/workflows/testarch/trace/workflow.yaml`

**Chức Năng**:
- Generate requirements-to-tests matrix
- Analyze coverage
- Quality gate decision: **PASS / CONCERNS / FAIL / WAIVED**

**Output**: Traceability matrix

**Khi Nào Dùng**:
- Before release
- Coverage validation

---

### 7.7 `/testarch-nfr` - Non-Functional Requirements
**File**: `bmad-bmm-testarch-nfr.md`  
**Target**: `_bmad/bmm/workflows/testarch/nfr-assess/workflow.yaml`

**Chức Năng**:
- Assess NFRs before release
- Performance, security, reliability, maintainability
- Evidence-based validation

**Khi Nào Dùng**:
- Pre-release validation
- Production readiness

---

### 7.8 `/testarch-ci` - CI/CD Pipeline
**File**: `bmad-bmm-testarch-ci.md`  
**Target**: `_bmad/bmm/workflows/testarch/ci/workflow.yaml`

**Chức Năng**:
- Scaffold CI/CD quality pipeline
- Test execution automation
- Burn-in loops
- Artifact collection

**Khi Nào Dùng**:
- Setting up CI/CD
- Quality automation

---

## 8️⃣ Excalidraw Diagrams (BMM Module)

4 workflows để tạo diagrams trong Excalidraw format.

### 8.1 `/create-excalidraw-diagram` - General Diagrams
**File**: `bmad-bmm-create-excalidraw-diagram.md`  
**Target**: `_bmad/bmm/workflows/excalidraw-diagrams/create-diagram/workflow.yaml`

**Chức Năng**:
- System architecture diagrams
- ERDs (Entity-Relationship Diagrams)
- UML diagrams
- General technical diagrams

---

### 8.2 `/create-excalidraw-dataflow` - Data Flow Diagrams
**File**: `bmad-bmm-create-excalidraw-dataflow.md`  
**Target**: `_bmad/bmm/workflows/excalidraw-diagrams/create-dataflow/workflow.yaml`

**Chức Năng**:
- Data Flow Diagrams (DFD)
- Data processing visualization
- System data flows

---

### 8.3 `/create-excalidraw-flowchart` - Flowcharts
**File**: `bmad-bmm-create-excalidraw-flowchart.md`  
**Target**: `_bmad/bmm/workflows/excalidraw-diagrams/create-flowchart/workflow.yaml`

**Chức Năng**:
- Process flowcharts
- Pipeline visualization
- Logic flows

---

### 8.4 `/create-excalidraw-wireframe` - Wireframes
**File**: `bmad-bmm-create-excalidraw-wireframe.md`  
**Target**: `_bmad/bmm/workflows/excalidraw-diagrams/create-wireframe/workflow.yaml`

**Chức Năng**:
- Website wireframes
- App wireframes
- UI mockups

---

## 📊 Workflow Patterns

### **Pattern 1: Simple Workflow Shortcut**
```markdown
---
description: 'Workflow description'
---

IT IS CRITICAL: LOAD @{project-root}/_bmad/core/workflows/name/workflow.md
```

**Ví dụ**: `bmad-brainstorming.md`, `bmad-party-mode.md`

---

### **Pattern 2: YAML Workflow with workflow.xml OS**
```markdown
---
name: 'workflow-name'
description: 'Workflow description'
---

<steps CRITICAL="TRUE">
1. LOAD @{project-root}/_bmad/core/tasks/workflow.xml
2. READ entire contents - CORE OS
3. Pass yaml path as 'workflow-config' parameter
4. Follow workflow.xml instructions EXACTLY
5. Save outputs after EACH section
</steps>
```

**Ví dụ**: `bmad-bmm-code-review.md`, `bmad-bmm-sprint-planning.md`

**Giải thích**: 
- `workflow.xml` = BMAD's workflow execution OS
- Workflow config (`.yaml`) = Data file
- Separation of execution engine and config

---

### **Pattern 3: Agent Shortcut**
```markdown
---
name: 'agent-name'
description: 'Agent description'
---

<agent-activation CRITICAL="TRUE">
1. LOAD {project-root}/_bmad/bmm/agents/name.md
2. READ entire contents
3. FOLLOW activation section precisely
4. DISPLAY welcome/greeting
5. PRESENT numbered menu
6. WAIT for user input
</agent-activation>
```

**Ví dụ**: `bmad-bmm-pm.agent.md`, `bmad-bmm-dev.agent.md`

---

## 🎯 Quick Reference: Khi Nào Dùng Workflow Nào?

### **Scenario: Bắt đầu project mới**
```
1. /create-product-brief
2. /create-prd
3. /create-architecture
4. /create-epics-and-stories
5. /check-implementation-readiness
6. /sprint-planning
7. Loop: /create-story → /dev-story → /code-review
```

### **Scenario: Quick feature/bug fix**
```
1. /quick-spec
2. /quick-dev
3. /code-review
```

### **Scenario: Stuck/Don't know what to do**
```
/bmad-help
```

### **Scenario: Need expert opinion**
```
/party-mode    (multi-agent discussion)
OR
/pm            (Product Manager persona)
/architect     (Architecture persona)
```

### **Scenario: Testing**
```
Setup: /testarch-framework
TDD: /testarch-atdd → implement → /testarch-test-review
Coverage: /testarch-automate
Pre-release: /testarch-trace + /testarch-nfr
```

---

## 🔑 Key Insights

### 1. **Two Execution Patterns**
- **Direct execution**: `.md` workflows (`brainstorming`, `party-mode`)
- **workflow.xml OS**: `.yaml` workflows (`code-review`, `dev-story`)

### 2. **Workflow vs Agent**
- **Workflow**: Task-focused, execute and exit
- **Agent**: Persona-based, interactive menu, stay in character

### 3. **Phase Organization (BMM)**
```
Discovery → Planning → Solutioning → Implementation
   ↓            ↓           ↓              ↓
Research     PRD      Architecture    Sprint Planning
Product      UX       Epics/Stories   Dev + Review
Brief       Design
```

### 4. **Quality Gates**
- `/check-implementation-readiness` - Before implementation
- `/code-review` - After every dev story (ADVERSARIAL, must find issues)
- `/testarch-trace` - Before release
- `/testarch-nfr` - Production readiness

### 5. **Fast vs Full Path**
- **Fast (Quick Flow)**: `/quick-spec` → `/quick-dev` → `/code-review`
- **Full (BMM Method)**: Product Brief → PRD → Architecture → Epics → Stories → Dev

---

## 📋 Summary Table

| Category | Count | Examples |
|----------|-------|----------|
| Universal Tools | 7 | help, brainstorming, party-mode, editorial |
| Agents | 10 | pm, architect, dev, ux-designer, tea |
| Discovery | 2 | product-brief, research |
| Planning | 3 | prd, ux-design, document-project |
| Solutioning | 3 | architecture, epics-stories, readiness |
| Implementation | 7 | sprint-planning, dev-story, code-review |
| TestArch | 8 | framework, atdd, automate, trace, nfr |
| Excalidraw | 4 | diagram, dataflow, flowchart, wireframe |
| **TOTAL** | **47** | |

---

**Kết Luận**: Thư mục `.agent/workflows/` là **command registry** - nơi AI IDE tìm kiếm khi user gọi slash commands. Mỗi file là một shortcut nhẹ, trỏ đến workflow/agent thực tế trong `_bmad/`. Design này cho phép:
- Fast command lookup
- Clean separation: shortcuts vs implementation
- Easy IDE integration
