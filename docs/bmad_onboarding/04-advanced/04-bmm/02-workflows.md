---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "BMM Workflows Reference"
---

# BMM Workflows - Complete Reference

> **Module**: BMM (BMAD Method Module)  
> **Location**: `_bmad/bmm/workflows/`  
> **Categories**: 8 workflow categories  
> **Total Files**: ~206 files  
> **Coverage**: Complete SDLC from discovery to deployment

---

## 📋 Table of Contents

**By Phase**:
1. [Phase 1: Analysis](#phase-1-analysis) - Discovery & research (2 workflows, 30 files)
2. [Phase 2: Planning](#phase-2-planning) - PRD & UX design (2 workflows, 55 files)
3. [Phase 3: Solutioning](#phase-3-solutioning) - Architecture & stories (3 workflows, 27 files)
4. [Phase 4: Implementation](#phase-4-implementation) - Sprint & development (7 workflows, 21 files)

**Specialized**:
5. [Quick Flow](#quick-flow) - Fast path (2 workflows, 13 files)
6. [TestArch](#testarch) - Complete testing suite (8 workflows, 33 files)
7. [Excalidraw](#excalidraw) - Visual documentation (4 workflows, 14 files)
8. [Document Project](#document-project) - Brownfield onboarding (1 workflow, 13 files)

**Navigation**:
- [Workflow Selection Matrix](#workflow-selection-matrix)
- [Multi-Workflow Patterns](#multi-workflow-patterns)
- [Architecture Patterns](#architecture-patterns)

---

## 🎯 Overview

BMM workflows implement complete **agile AI-driven development** methodology:

### **Development Phases**

```
Analysis → Planning → Solutioning → Implementation
   ↓          ↓           ↓              ↓
Research   PRD+UX    Architecture    Sprint+Dev
  (2)       (2)        (3)            (7)
```

**Quick Path**:
```
Quick Flow (skip phases)
    ↓
Spec → Dev
```

**Quality Gates**:
- **After Solutioning**: Implementation Readiness Check (ADVERSARIAL)
- **After Implementation**: Code Review (ADVERSARIAL)

---

## Phase 1: Analysis

**Purpose**: Discovery & requirements gathering  
**Location**: `_bmad/bmm/workflows/1-analysis/`  
**Workflows**: 2 | **Files**: 30 | **Primary Agent**: analyst 📊

### 1.1 create-product-brief

**Files**: 9 (step-file architecture)  
**Agent**: analyst 📊 (Mary)  
**Output**: `{planning_artifacts}/product-brief.md`  
**Required**: ❌ Optional

#### **Architecture: Step-File Pattern**

**Core Principles**:
- ✅ Micro-file design - each step = self-contained
- ✅ Just-in-time loading - only current step in memory
- ✅ Sequential enforcement - no skipping
- ✅ State tracking - `stepsCompleted` array
- ✅ Append-only building

**Critical Rules**:
- 🛑 NEVER load multiple steps simultaneously
- 📖 ALWAYS read entire step before execution
- 🚫 NEVER skip or optimize sequence
- ⏸️ ALWAYS halt at menus
- 💾 ALWAYS update frontmatter

#### **Steps**

| # | File | Purpose |
|---|------|---------|
| 01 | step-01-init.md | Initialize brief, gather basic info |
| 02 | step-02-problem.md | Define problem statement |
| 03 | step-03-solution.md | Outline solution approach |
| 04 | step-04-users.md | Identify target users |
| 05 | step-05-value.md | Define value proposition |
| 06 | step-06-scope.md | Establish scope boundaries |
| 07 | step-07-constraints.md | Document constraints |
| 08 | step-08-success.md | Define success metrics |
| 09 | step-09-finalize.md | Review and finalize |

#### **When to Use**
- ✅ Early stage ideas needing structure
- ✅ Stakeholder alignment
- ✅ Pre-PRD foundation
- ✅ Executive communication

---

### 1.2 research

**Files**: 21 (routing-based, 3 research types)  
**Agent**: analyst 📊 (Mary)  
**Output**: `{planning_artifacts}/research/{type}-{topic}-{date}.md`  
**Web Search**: ⚠️ **REQUIRED**  
**Required**: ❌ Optional

#### **Architecture: Routing Pattern**

**Research Types** (3):
1. **Market Research** (7 steps) - Market size, competition, customers
2. **Domain Research** (7 steps) - Industry, regulations, best practices
3. **Technical Research** (7 steps) - Technology evaluation, architecture

#### **Web Research Standards** 🔍

**Anti-Hallucination Protocol**:
- ✅ Current data only - verify via web search
- ✅ Source verification - citations for ALL factual claims
- ✅ Multiple sources - 2+ independent for critical claims
- ✅ Confidence levels - Flag [High/Medium/Low]
- ✅ URL citations - Always include source URLs

#### **Flow**
```
User: /research
    ↓
Collaborative Topic Discovery:
    - What topic?
    - What goals?
    - What scope?
    - What timeline?
    ↓
Identify Research Type:
├── Market → ./market-steps/ (7 steps)
├── Domain → ./domain-steps/ (7 steps)
└── Technical → ./technical-steps/ (7 steps)
    ↓
Execute Research → Comprehensive Document
```

#### **Research Type Selection**

| Goal | Type | Example |
|------|------|---------|
| Market opportunity | Market | "EV market in Europe" |
| Industry context | Domain | "Healthcare HIPAA compliance" |
| Technology options | Technical | "Cloud migration strategies" |
| Customer insights | Market | "B2B SaaS buyer behavior" |
| Best practices | Domain | "Sustainable packaging" |
| Implementation | Technical | "AI in financial services" |

---

## Phase 2: Planning

**Purpose**: PRD & UX design  
**Location**: `_bmad/bmm/workflows/2-plan-workflows/`  
**Workflows**: 2 | **Files**: 55 | **Primary Agent**: pm 📋, ux-designer 🎨

### 2.1 create-prd

**Files**: 38 (tri-modal: Create/Validate/Edit)  
**Agent**: pm 📋 (John)  
**Output**: `{planning_artifacts}/prd.md`  
**Required**: ✅ **YES** (blocks Solutioning phase)

#### **Architecture: Tri-Modal**

**3 Modes**:
1. **Create Mode** (28 steps) - New PRD from scratch
2. **Validate Mode** (5 steps) - ADVERSARIAL validation
3. **Edit Mode** (5 steps) - Improve existing PRD

#### **Mode Detection**

```
Command/Flag:
- "create prd" → Create
- "validate prd" → Validate
- "edit prd" → Edit

If unclear → Show menu:
[C] Create - New PRD
[V] Validate - Check existing
[E] Edit - Improve existing
```

#### **Create Mode Steps** (28 steps)

**Foundation** (Steps 1-8):
1. Initialize - Project context
2. Problem - Problem statement
3. Goals - Product goals
4. Success Metrics - Measurable outcomes
5. Target Users - User personas
6. User Needs - Jobs-to-be-done
7. Use Cases - Primary scenarios
8. User Stories - Detailed stories

**Solution** (Steps 9-16):
9. Solution Overview - High-level approach
10. Core Features - Feature breakdown
11. User Experience - UX  principles
12. Technical Approach - Architecture overview
13. Data Model - Key entities
14. Dependencies - External dependencies
15. API Design - Interface design
16. Security - Security requirements

**Planning** (Steps 17-24):
17. Assumptions - Key assumptions
18. Risks - Risk assessment
19. Constraints - Technical/Business constraints
20. Out of Scope - Explicitly excluded
21. Future - Future roadmap
22. Launch - Launch strategy
23. Requirements - Non-functional requirem ents
24. Glossary - Term definitions

**Finalization** (Steps 25-28):
25. Review - Comprehensive review
26. Validation - Internal validation
27. Final Polish - Final edits
28. Complete - Save and finalize

#### **Validate Mode**

**ADVERSARIAL Validation** - finds issues systematically:
1. Discovery - Load PRD
2. Completeness Check - Missing sections?
3. Quality Review - Clarity, specificity
4. Consistency Check - Internal contradictions?
5. Report - Validation findings

#### **Edit Mode**

Conversational improvement:
1. Discovery - Load PRD, identify improvements
2. Guided editing - Section-by-section
3. Review changes
4. Finalize

#### **When to Use**

**Create**:
- ✅ New products/features
- ✅ After product brief
- ✅ Foundation for architecture

**Validate**:
- ✅ Before architecture phase
- ✅ Quality gate
- ✅ Stakeholder review prep

**Edit**:
- ✅ Refinement after feedback
- ✅ Scope changes
- ✅ Update existing PRD

---

### 2.2 create-ux-design

**Files**: 17 (step-file architecture)  
**Agent**: ux-designer 🎨 (Sally)  
**Output**: `{planning_artifacts}/ux-design.md`  
**Required**: ❌ Optional

#### **Purpose**
Plan UX patterns, look & feel, user flows

#### **Steps** (estimated 12-15)

**Core UX Areas**:
- Design principles
- User flows
- Information architecture
- Visual design system
- Interaction patterns
- Accessibility requirements
- Responsive design
- Component library

#### **When to Use**
- ✅ UI-heavy applications
- ✅ Complex user journeys
- ✅ Design system needed
- ✅ Before wire framing

---

## Phase 3: Solutioning

**Purpose**: Architecture & story breakdown  
**Location**: `_bmad/bmm/workflows/3-solutioning/`  
**Workflows**: 3 | **Files**: 27 | **Primary Agent**: architect 🏗️, pm 📋

### 3.1 create-architecture

**Files**: ~12 (step-file architecture)  
**Agent**: architect 🏗️ (Winston)  
**Output**: `{planning_artifacts}/architecture.md`  
**Required**: ✅ **YES**

#### **Purpose**
Collaborative architectural decision-making

#### **Steps** (estimated 10-12)

**Architecture Areas**:
- System architecture overview
- Component design
- Data architecture
- API design
- Infrastructure
- Security architecture
- Deployment architecture
- Technical decisions (ADRs)

#### **When to Use**
- ✅ After PRD complete
- ✅ Before story breakdown
- ✅ Technical foundation needed

---

### 3.2 create-epics-and-stories

**Files**: ~10 (step-file architecture)  
**Agent**: pm 📋 (John)  
**Input**: PRD + Architecture  
**Output**: `{planning_artifacts}/epics-and-stories.md`  
**Required**: ✅ **YES**

#### **Purpose**
Transform PRD + Architecture into implementation-ready stories

#### **Process**
1. Load PRD and Architecture
2. Identify epics (user value groupings)
3. Break down into user stories
4. Define acceptance criteria
5. Add technical context from architecture
6. Estimate and prioritize

#### **When to Use**
- ✅ After PRD + Architecture
- ✅ Before implementation
- ✅ Sprint planning input

---

###  3.3 check-implementation-readiness

**Files**: ~5 (ADVERSARIAL review)  
**Agent**: architect 🏗️ (Winston)  
**Input**: PRD + Architecture + Epics  
**Output**: `{planning_artifacts}/implementation-readiness.md`  
**Required**: ✅ **YES** (Quality gate)

#### **Purpose**
**ADVERSARIAL** validation before implementation starts

#### **Quality Gate**
Must find minimum 3-10 issues in:
- PRD completeness
- Architecture soundness
- Story readiness
- Technical feasibility
- Risk assessment

#### **Outcome**
- ✅ **PASS** - Ready for implementation
- ⚠️ **CONCERNS** - Issues documented, proceed with caution
- ❌ **FAIL** - Block implementation until resolved
- 🔄 **WAIVED** - Issues acknowledged, proceed anyway

#### **When to Use**
- ✅ Before Phase 4 (Implementation)
- ✅ Quality gate
- ✅ Risk mitigation

---

## Phase 4: Implementation

**Purpose**: Sprint management & development  
**Location**: `_bmad/bmm/workflows/4-implementation/`  
**Workflows**: 7 | **Files**: 21 | **Primary Agents**: sm 🏃, dev 💻

### 4.1 sprint-planning

**Files**: ~3  
**Agent**: sm 🏃 (Bob)  
**Output**: `{implementation_artifacts}/sprint-status.yaml`  
**Required**: ✅ **YES** (Once per sprint)

#### **Purpose**
Initialize sprint tracking file from epics/stories

#### **Process**
1. Load epics-and-stories.md
2. Extract all epics and stories
3. Create sprint-status.yaml
4. Initialize status: not_started

#### **Output Structure**
```yaml
sprint:
  number: 1
  startDate: 2026-01-28
  endDate: 2026-02-11

epics:
  - id: epic-01
    title: "User Authentication"
    status: in_progress
    stories:
      - id: story-01
        title: "Login functionality"
        status: completed
      - id: story-02
        title: "Password reset"
        status: in_progress
```

---

### 4.2 sprint-status

**Files**: ~3  
**Agent**: sm 🏃 (Bob)  
**Input**: `sprint-status.yaml`  
**Output**: Status summary  
**Required**: ❌ Optional (Anytime)

#### **Purpose**
Summarize sprint progress, surface risks

#### **Outputs**
- Sprint progress %
- Completed stories
- In-progress stories
- Blocked stories
- Risks and recommendations

---

### 4.3 create-story

**Files**: ~4  
**Agent**: sm 🏃 (Bob)  
**Input**: epics-and-stories.md  
**Output**: `{implementation_artifacts}/stories/story-{id}.md`  
**Required**: ✅ **YES** (Story cycle start)

#### **Purpose**
Create next implementation-ready story file

#### **Story File Structure**
```markdown
---
storyId: story-01
epic: epic-01
status: ready_for_dev
---

# Story: Login Functionality

## Description
As a user, I want to log in...

## Acceptance Criteria
- [ ] AC1: User can enter email/password
- [ ] AC2: Invalid credentials show error
- [ ] AC3: Valid credentials redirect to dashboard

## Tasks
- [ ] Task 1: Create login form component
  - [ ] Subtask: Email input validation
  - [ ] Subtask: Password input
- [ ] Task 2: Implement authentication API
  - [ ] Subtask: POST /auth/login endpoint
  - [ ] Subtask: JWT token generation

## Technical Context
[From architecture.md]

## Dev Agent Record
[Filled by dev agent]

## File List
[Updated by dev agent]
```

---

### 4.4 validate-story

**Files**: ~3  
**Agent**: sm 🏃 (Bob)  
**Input**: Story file  
**Output**: Validation report  
**Required**: ❌ Optional

#### **Purpose**
Validate story before dev implementation

---

### 4.5 dev-story

**Files**: ~5  
**Agent**: dev 💻 (Amelia)  
**Input**: Story file  
**Output**: Code + tests + updated story file  
**Required**: ✅ **YES** (Implementation)

#### **Purpose**
TDD implementation of story

#### **Dev Agent Activation Extensions**

Special rules:
1. READ entire story file BEFORE implementation
2. Execute tasks/subtasks IN ORDER
3. Mark [x] ONLY when implementation AND tests complete
4. Run full test suite after each task
5. Execute continuously without pausing
6. Document in Dev Agent Record
7. Update File List
8. **NEVER lie about tests** - must exist and pass 100%

#### **Process**
```
Load story file
    ↓
For each task:
    For each subtask:
        1. Write failing test (TDD)
        2. Implement code
        3. Run tests until green
        4. Mark [x]
        5. Update File List
    ↓
All tests pass 100%
    ↓
Update story status: ready_for_review
```

---

### 4.6 code-review

**Files**: ~4  
**Agent**: dev 💻 (Amelia)  
**Input**: Story file + code  
**Output**: Review findings  
**Required**: ❌ Optional (but recommended)

#### **Purpose**
**ADVERSARIAL** code review - must find 3-10 issues

#### **Review Areas**
- Code quality
- Test coverage
- Architecture compliance
- Security
- Performance
- Documentation

#### **Outcome**
- Issues found → Fix → Re-review
- No issues → Suspicious, review harder
- All resolved → Story complete

---

### 4.7 correct-course

**Files**: ~3  
**Agent**: sm 🏃 (Bob)  
**Purpose**: Navigate significant changes during sprint

---

### 4.8 retrospective

**Files**: ~3  
**Agent**: sm 🏃 (Bob)  
**Purpose**: Epic completion review, extract lessons

---

## Quick Flow

**Purpose**: Fast path without full BMM ceremony  
**Location**: `_bmad/bmm/workflows/bmad-quick-flow/`  
**Workflows**: 2 | **Files**: 13 | **Primary Agent**: quick-flow-solo-dev 🚀 (Barry)

### 5.1 quick-spec

**Files**: ~6  
**Agent**: quick-flow-solo-dev 🚀  
**Output**: Tech spec  
**Required**: ❌ Optional

#### **Purpose**
Conversational spec engineering - ask questions, investigate code, produce spec

#### **When to Use**
- ✅ Small tasks, bug fixes
- ✅ Simple features
- ✅ Solo developer
- ✅ Need spec but not full PRD

---

### 5.2 quick-dev

**Files**: ~7  
**Agent**: quick-flow-solo-dev 🚀  
**Output**: Code + tests  
**Required**: ❌ Optional

#### **Purpose**
Flexible development - execute tech-spec OR direct instructions

#### **Modes**
1. **With Tech-Spec**: Load spec → Implement
2. **Direct**: User instructions → Implement

#### **When to Use**
- ✅ Fast prototyping
- ✅ Bug fixes
- ✅ Skip planning overhead
- ✅ Solo work

---

## TestArch

**Purpose**: Complete testing framework & workflows  
**Location**: `_bmad/bmm/workflows/testarch/`  
**Workflows**: 8 | **Files**: 33 | **Primary Agent**: tea 🧪 (Murat)

### 6.1 testarch-framework

**Files**: ~4  
**Purpose**: Initialize production-ready test framework (Playwright/Cypress)

---

### 6.2 testarch-test-design

**Files**: ~5  
**Purpose**: Dual-mode - System-level (Solutioning) or Epic-level (Implementation) test planning

---

### 6.3 testarch-atdd

**Files**: ~4  
**Purpose**: Acceptance TDD - Generate failing tests BEFORE implementation (red-green-refactor)

---

### 6.4 testarch-automate

**Files**: ~5  
**Purpose**: Expand test automation coverage after implementation

---

### 6.5 testarch-test-review

**Files**: ~4  
**Purpose**: Review test quality using best practices validation

---

### 6.6 testarch-trace

**Files**: ~4  
**Purpose**: Requirements-to-tests traceability matrix, coverage analysis, quality gate

---

### 6.7 testarch-nfr

**Files**: ~4  
**Purpose**: Non-functional requirements assessment (performance, security, reliability)

---

### 6.8 testarch-ci

**Files**: ~3  
**Purpose**: Scaffold CI/CD quality pipeline with test execution, burn-in loops

---

## Excalidraw

**Purpose**: Visual documentation generation  
**Location**: `_bmad/bmm/workflows/excalidraw-diagrams/`  
**Workflows**: 4 | **Files**: 14 | **Primary Agent**: ux-designer 🎨

### 7.1 create-excalidraw-diagram

**Files**: ~4  
**Purpose**: Architecture diagrams, ERDs, UML

---

### 7.2 create-excalidraw-dataflow

**Files**: ~4  
**Purpose**: Data flow diagrams (DFD)

---

### 7.3 create-excalidraw-flowchart

**Files**: ~3  
**Purpose**: Process flowcharts, logic flows

---

### 7.4 create-excalidraw-wireframe

**Files**: ~3  
**Purpose**: UI wireframes

---

## Document Project

**Purpose**: Brownfield project documentation  
**Location**: `_bmad/bmm/workflows/document-project/`  
**Workflows**: 1 | **Files**: 13 | **Primary Agent**: analyst 📊 / tech-writer 📚

### 8.1 document-project

**Files**: 13  
**Purpose**: Analyze existing codebase → Comprehensive documentation

#### **Process**
1. Scan codebase
2. Identify architecture patterns
3. Document components
4. Create reference docs for AI-assisted development

#### **When to Use**
- ✅ Brownfield onboarding
- ✅ Legacy code documentation
- ✅ Knowledge transfer

---

## Workflow Selection Matrix

### By Phase

| Phase | Workflow | Agent | Required | Output |
|-------|----------|-------|----------|--------|
| **1-Analysis** | create-product-brief | analyst 📊 | ❌ | Product brief |
| | research | analyst 📊 | ❌ | Research doc |
| **2-Planning** | create-prd | pm 📋 | ✅ | PRD |
| | create-ux-design | ux-designer 🎨 | ❌ | UX design |
| **3-Solutioning** | create-architecture | architect 🏗️ | ✅ | Architecture |
| | create-epics-stories | pm 📋 | ✅ | Stories |
| | check-readiness | architect 🏗️ | ✅ | Quality gate |
| **4-Implementation** | sprint-planning | sm 🏃 | ✅ | Sprint tracking |
| | create-story | sm 🏃 | ✅ | Story file |
| | dev-story | dev 💻 | ✅ | Code + tests |
| | code-review | dev 💻 | ❌ | Review findings |

### By Use Case

| Use Case | Workflow Path | Agents |
|----------|---------------|--------|
| **New Product** | brief → research → PRD → UX → arch → stories → readiness → sprint | analyst → pm → ux-designer → architect → sm → dev |
| **New Feature** | PRD → arch → stories → readiness → sprint | pm → architect → sm → dev |
| **Bug Fix** | quick-dev | quick-flow-solo-dev 🚀 |
| **Small Task** | quick-spec → quick-dev | quick-flow-solo-dev 🚀 |
| **Technical Research** | research (technical) → arch | analyst → architect |
| **Brownfield** | document-project → arch → stories | analyst/tech-writer → architect → pm |

---

## Multi-Workflow Patterns

### Pattern 1: Full BMM Cycle
```
Analysis:
├── create-product-brief
└── research (market)
    ↓
Planning:
├── create-prd (Create Mode)
└── create-ux-design
    ↓
Solutioning:
├── create-architecture
├── create-epics-stories
└── check-implementation-readiness ⚠️ QUALITY GATE
    ↓
Implementation (per epic):
├── sprint-planning (once)
└── For each story:
    ├── create-story
    ├── dev-story
    └── code-review ⚠️ QUALITY GATE
```

### Pattern 2: Quick Flow
```
quick-spec (optional)
    ↓
quick-dev
    ↓
code-review
```

### Pattern 3: TestArch Integration
```
Solutioning:
├── testarch-test-design (system-level)
    ↓
Implementation:
├── testarch-atdd (before dev-story)
├── dev-story
├── testarch-test-review
└── testarch-trace
```

---

## Architecture Patterns

### Step-File Architecture
**Used by**: create-product-brief, create-prd (Create), create-architecture, create-epics-stories, create-ux-design

**Characteristics**:
- Micro-file design
- Just-in-time loading
- Sequential enforcement
- State tracking in frontmatter
- Append-only document building

**Example**: PRD Create Mode (28 steps)

---

### Routing-Based Discovery
**Used by**: research, testarch-test-design

**Characteristics**:
- Collaborative discovery
- Type/mode identification
- Route to sub-workflow
- Context passed to next step

**Example**: research → market/domain/technical

---

### Tri-Modal Pattern
**Used by**: create-prd

**Characteristics**:
- 3 modes: Create/Validate/Edit
- Mode detection from command/flags/menu
- Different workflows per mode
- Shared principles

**Example**: create-prd → Create (28 steps) / Validate (5 steps) / Edit (5 steps)

---

### ADVERSARIAL Review Pattern
**Used by**: check-implementation-readiness, code-review, create-prd (Validate Mode)

**Characteristics**:
- Must find minimum 3-10 issues
- Never accepts "looks good"
- Systematic coverage of quality facets
- Outcome: PASS/CONCERNS/FAIL/WAIVED

**Example**: Code review must challenge: quality, tests, architecture, security, performance

---

## 📝 Summary

BMM workflows provide **complete SDLC coverage**:

✅ **8 Workflow Categories**:
- Analysis (2) - Discovery
- Planning (2) - PRD + UX
- Solutioning (3) - Architecture + Stories
- Implementation (7) - Sprint + Dev
- Quick Flow (2) - Fast path
- TestArch (8) - Complete testing
- Excalidraw (4) - Visual docs
- Document Project (1) - Brownfield

✅ **~206 Total Files** organized by workflow

✅ **Quality Gates**:
- check-implementation-readiness (ADVERSARIAL)
- code-review (ADVERSARIAL)
- create-prd Validate Mode (ADVERSARIAL)

✅ **Architecture Patterns**:
- Step-file (incremental, state-tracked)
- Routing-based (discovery → sub-workflow)
- Tri-modal (Create/Validate/Edit)
- ADVERSARIAL (must find issues)

✅ **Flexibility**:
- Full BMM: Complete governance
- Quick Flow: Skip ceremony
- TestArch: Optional but comprehensive
- Excalidraw: Visual documentation

**Next**: Explore individual workflow details or agent deep dives

---

## 🔗 Related Documentation

- [../01-agents/01-agents-overview.md](../01-agents/01-agents-overview.md) - All 9 BMM agents
- [../../02-config/01-manifest-hub.md](../../../02-config/01-manifest-hub.md) - bmad-help.csv workflow sequencing
- [../../README.md](../../README.md) - Advanced documentation navigation
