---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "Manifest Hub Deep Dive"
---

# `_bmad/_config/` - Manifest Hub Deep Dive

> **Deep technical documentation** về BMAD's configuration và discovery system  
> **Prerequisites**: Đọc [`02-core-concepts/01-folder-structure.md`](../../02-core-concepts/01-folder-structure.md) trước

---

## 📋 Tổng Quan

`_bmad/_config/` là **central registry** và **discovery mechanism** của toàn bộ BMAD framework.

### **Vai Trò**

1. **Resource Discovery**: AI agents tìm workflows, agents, tasks qua manifests
2. **Installation Tracking**: Version và module tracking
3. **Help System**: Workflow sequencing và intelligent routing
4. **Customization**: User overrides và extensions

### **Cấu Trúc**

```
_config/
├── manifest.yaml              # Installation manifest
├── agent-manifest.csv         # 11 agents catalog
├── workflow-manifest.csv      # 32 workflows catalog
├── task-manifest.csv         # 7 tasks catalog
├── tool-manifest.csv         # Tool integrations
├── bmad-help.csv             # Workflow sequencing (40 entries)
├── files-manifest.csv        # All framework files (282 files)
├── agents/                   # Agent customization files (10 files)
│   ├── bmm-pm.customize.yaml
│   ├── bmm-dev.customize.yaml
│   └── ...
└── custom/                   # User custom resources (empty)
```

**Total**: 7 manifest files + 2 directories

---

## 1️⃣ `manifest.yaml` - Installation Manifest

### **Purpose**
Track installed BMAD version, modules, và IDE integrations

### **Full Content**

```yaml
installation:
  version: 6.0.0-Beta.2
  installDate: 2026-01-28T07:12:00.295Z
  lastUpdated: 2026-01-28T07:12:00.295Z

modules:
  - name: core
    version: 6.0.0-Beta.2
    installDate: 2026-01-28T07:12:00.295Z
    lastUpdated: 2026-01-28T07:12:00.295Z
    source: built-in
    npmPackage: null
    repoUrl: null
    
  - name: bmm
    version: 6.0.0-Beta.2
    installDate: 2026-01-28T07:12:00.277Z
    lastUpdated: 2026-01-28T07:12:00.295Z
    source: built-in
    npmPackage: null
    repoUrl: null

ides:
  - antigravity
```

### **Schema Analysis**

#### **`installation` Block**
| Field | Type | Purpose |
|-------|------|---------|
| `version` | semver | BMAD framework version |
| `installDate` | ISO 8601 | When BMAD was first installed |
| `lastUpdated` | ISO 8601 | Last modification timestamp |

#### **`modules[]` Block**
| Field | Type | Purpose | Example |
|-------|------|---------|---------|
| `name` | string | Module identifier | `core`, `bmm` |
| `version` | semver | Module version | `6.0.0-Beta.2` |
| `source` | enum | Installation source | `built-in`, `npm`, `git` |
| `npmPackage` | string? | NPM package name | `@bmad/my-module` |
| `repoUrl` | string? | Git repository | `https://github.com/...` |

#### **`ides[]` Block**
Array of IDE slugs: `antigravity`, `cursor`, `windsurf`, `claude-code`

### **Use Cases**

#### **Version Checking**
```javascript
// Pseudo-code AI agent logic
const manifest = loadYAML('_config/manifest.yaml');
if (manifest.installation.version < '6.0.0') {
  warn('Outdated BMAD version');
}
```

#### **Module Discovery**
```javascript
const modules = manifest.modules.map(m => m.name);
// ['core', 'bmm']
```

#### **IDE-Specific Behavior**
```javascript
if (manifest.ides.includes('antigravity')) {
  // Use Antigravity-specific features
}
```

---

## 2️⃣ `agent-manifest.csv` - Agent Registry

### **Purpose**
Catalog tất cả available agents với complete metadata cho agent selection

### **Schema**

```csv
name,displayName,title,icon,role,identity,communicationStyle,principles,module,path
```

**10 columns**:
1. `name` - Agent slug (e.g., `pm`)  
2. `displayName` - Human name (e.g., `John`)
3. `title` - Role title (e.g., `Product Manager`)
4. `icon` - Emoji icon (e.g., `📋`)
5. `role` - Short role description
6. `identity` - Detailed identity/background
7. `communicationStyle` - How agent communicates
8. `principles` - Agent's guiding principles
9. `module` - Module name (`core`, `bmm`)
10. `path` - Relative path to agent definition

### **Complete Agent Catalog** (11 agents)

#### **Core Module** (1 agent)

**`bm ad-master` - Master Orchestrator** 🧙  
- **Name**: BMad Master  
- **Role**: Master Task Executor + BMad Expert + Workflow Orchestrator  
- **Identity**: Master-level expert with comprehensive knowledge of all resources, tasks, and workflows  
- **Communication**: Direct, 3rd person, expert-level, numbered lists  
- **Principles**: "Load resources at runtime never pre-load, and always present numbered lists for choices"  
- **Path**: `_bmad/core/agents/bmad-master.md`

---

#### **BMM Module** (10 agents)

**`analyst` - Mary** 📊  
- **Title**: Business Analyst  
- **Role**: Strategic Business Analyst + Requirements Expert  
- **Identity**: Senior analyst with deep expertise in market research, competitive analysis  
- **Communication**: Treasure hunter - thrilled by every clue, energized when patterns emerge  
- **Principles**: 
  - Channel expert business analysis frameworks (Porter's Five Forces, SWOT, root cause)
  - Articulate requirements with absolute precision
  - Ensure all stakeholder voices heard
- **Path**: `_bmad/bmm/agents/analyst.md`

---

**`architect` - Winston** 🏗️  
- **Title**: Architect  
- **Role**: System Architect + Technical Design Leader  
- **Identity**: Senior architect with distributed systems, cloud, API design expertise  
- **Communication**: Calm, pragmatic tones, balancing 'what could be' with 'what should be'  
- **Principles**:
  - Channel lean architecture wisdom
  - User journeys drive technical decisions
  - Embrace boring technology for stability
  - Design simple solutions that scale
- **Path**: `_bmad/bmm/agents/architect.md`

---

**`dev` - Amelia** 💻  
- **Title**: Developer Agent  
- **Role**: Senior Software Engineer  
- **Identity**: Executes approved stories with strict adherence to story details  
- **Communication**: **Ultra-succinct** - speaks in file paths and AC IDs, no fluff, all precision  
- **Principles**:
  - All tests must pass 100% before review
  - Every task/subtask covered by comprehensive unit tests
- **Path**: `_bmad/bmm/agents/dev.md`

---

**`pm` - John** 📋  
- **Title**: Product Manager  
- **Role**: PM specializing in collaborative PRD creation  
- **Identity**: 8+ years veteran launching B2B and consumer products  
- **Communication**: **Asks "WHY?" relentlessly** like a detective, direct and data-sharp  
- **Principles**:
  - PRDs emerge from user interviews, not template filling
  - Ship smallest thing that validates assumption
  - Technical feasibility is constraint, not driver
- **Path**: `_bmad/bmm/agents/pm.md`

---

**`quick-flow-solo-dev` - Barry** 🚀  
- **Title**: Quick Flow Solo Dev  
- **Role**: Elite Full-Stack Developer + Quick Flow Specialist  
- **Identity**: Minimum ceremony, lean artifacts, ruthless efficiency  
- **Communication**: Direct, confident, tech slang (refactor, patch, extract, spike)  
- **Principles**:
  - Planning and execution are two sides of the same coin
  - Specs for building, not bureaucracy
  - Code that ships > perfect code that doesn't
- **Path**: `_bmad/bmm/agents/quick-flow-solo-dev.md`

---

**`sm` - Bob** 🏃  
- **Title**: Scrum Master  
- **Role**: Technical Scrum Master + Story Preparation Specialist  
- **Identity**: Certified Scrum Master with deep technical background  
- **Communication**: **Crisp and checklist-driven**, zero tolerance for ambiguity  
- **Principles**:
  - Servant leader - helping with any task
  - Love to talk about Agile process and theory
- **Path**: `_bmad/bmm/agents/sm.md`

---

**`tea` - Murat** 🧪  
- **Title**: Master Test Architect  
- **Role**: Test Architect  
- **Identity**: API testing, backend, UI automation, CI/CD, quality gates expert  
- **Communication**: **Data + gut instinct**, "Strong opinions, weakly held"  
- **Principles**:
  - Risk-based testing - depth scales with impact
  - Fl akiness is critical technical debt
  - API tests are first-class citizens
  - Calculate risk vs value
- **Path**: `_bmad/bmm/agents/tea.md`

---

**`tech-writer` - Paige** 📚  
- **Title**: Technical Writer  
- **Role**: Technical Documentation Specialist + Knowledge Curator  
- **Identity**: Expert in CommonMark, DITA, OpenAPI  
- **Communication**: **Patient educator**, analogies that make complex simple  
- **Principles**:
  - Clarity above all
  - Picture/diagram worth 1000s words
  - Understand intended audience
  - Follow documentation standards
- **Path**: `_bmad/bmm/agents/tech-writer/tech-writer.md`

---

**`ux-designer` - Sally** 🎨  
- **Title**: UX Designer  
- **Role**: User Experience Designer + UI Specialist  
- **Identity**: 7+ years creating intuitive experiences  
- **Communication**: **Paints pictures with words**, empathetic storytelling  
- **Principles**:
  - Every decision serves genuine user needs
  - Start simple, evolve through feedback
  - Balance empathy with edge case attention
- **Path**: `_bmad/bmm/agents/ux-designer.md`

---

### **Agent Selection Logic**

```javascript
// How `/bmad-help` chooses agent
function suggestAgent(taskType) {
  const agentMap = {
    requirements: 'analyst',
    architecture: 'architect',
    coding: 'dev',
    prd: 'pm',
    sprint: 'sm',
    testing: 'tea',
    uxDesign: 'ux-designer',
    fastDev: 'quick-flow-solo-dev'
  };
  
  const agentData = loadCSV('_config/agent-manifest.csv')
    .find(a => a.name === agentMap[taskType]);
    
  return {
    name: agentData.displayName,
    icon: agentData.icon,
    path: agentData.path
  };
}
```

---

## 3️⃣ `workflow-manifest.csv` - Workflow Registry

### **Purpose**
Fast lookup table cho tất cả workflows

### **Schema**

```csv
name,description,module,path
```

**4 columns**:
1. `name` - Workflow slug (e.g., `create-prd`)
2. `description` - Human-readable description
3. `module` - Module name (`core`, `bmm`)
4. `path` - Relative path to workflow file

### **Complete Workflow Catalog** (32 workflows)

#### **Core Module** (2 workflows)

| Name | Description | Path |
|------|-------------|------|
| `brainstorming` | Facilitate interactive brainstorming sessions | `_bmad/core/workflows/brainstorming/workflow.md` |
| `party-mode` | Orchestrates multi-agent conversations | `_bmad/core/workflows/party-mode/workflow.md` |

#### **BMM Module** (30 workflows)

**Phase 1: Analysis** (2)
| Name | Description | Path |
|------|-------------|------|
| `create-product-brief` | Collaborative product brief creation | `_bmad/bmm/workflows/1-analysis/create-product-brief/workflow.md` |
| `research` | Comprehensive research (market/technical/domain) | `_bmad/bmm/workflows/1-analysis/research/workflow.md` |

**Phase 2: Planning** (2)
| Name | Description | Path |
|------|-------------|------|
| `create-prd` | Tri-modal PRD workflow | `_bmad/bmm/workflows/2-plan-workflows/create-prd/workflow.md` |
| `create-ux-design` | UX patterns planning | `_bmad/bmm/workflows/2-plan-workflows/create-ux-design/workflow.md` |

**Phase 3: Solutioning** (3)
| Name | Description | Path |
|------|-------------|------|
| `check-implementation-readiness` | ADVERSARIAL validation | `_bmad/bmm/workflows/3-solutioning/check-implementation-readiness/workflow.md` |
| `create-architecture` | Collaborative architecture decisions | `_bmad/bmm/workflows/3-solutioning/create-architecture/workflow.md` |
| `create-epics-and-stories` | Transform PRD+Architecture into stories | `_bmad/bmm/workflows/3-solutioning/create-epics-and-stories/workflow.md` |

**Phase 4: Implementation** (7)
| Name | Description | Path |
|------|-------------|------|
| `code-review` | ADVERSARIAL code review (must find 3-10 issues) | `_bmad/bmm/workflows/4-implementation/code-review/workflow.yaml` |
| `correct-course` | Navigate significant changes | `_bmad/bmm/workflows/4-implementation/correct-course/workflow.yaml` |
| `create-story` | Create next user story | `_bmad/bmm/workflows/4-implementation/create-story/workflow.yaml` |
| `dev-story` | Execute story implementation | `_bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml` |
| `retrospect ive` | Epic completion review | `_bmad/bmm/workflows/4-implementation/retrospective/workflow.yaml` |
| `sprint-planning` | Initialize sprint tracking | `_bmad/bmm/workflows/4-implementation/sprint-planning/workflow.yaml` |
| `sprint-status` | Summarize sprint progress | `_bmad/bmm/workflows/4-implementation/sprint-status/workflow.yaml` |

**Quick Flow** (2)
| Name | Description | Path |
|------|-------------|------|
| `quick-dev` | Flexible development | `_bmad/bmm/workflows/bmad-quick-flow/quick-dev/workflow.md` |
| `quick-spec` | Conversational spec engineering | `_bmad/bmm/workflows/bmad-quick-flow/quick-spec/workflow.md` |

**Utilities** (1)
| Name | Description | Path |
|------|-------------|------|
| `document-project` | Brownfield project documentation | `_bmad/bmm/workflows/document-project/workflow.yaml` |

**Excalidraw** (4)
| Name | Description | Path |
|------|-------------|------|
| `create-excalidraw-dataflow` | Data flow diagrams | `_bmad/bmm/workflows/excalidraw-diagrams/create-dataflow/workflow.yaml` |
| `create-excalidraw-diagram` | Architecture diagrams, ERDs, UML | `_bmad/bmm/workflows/excalidraw-diagrams/create-diagram/workflow.yaml` |
| `create-excalidraw-flowchart` | Process flowcharts | `_bmad/bmm/workflows/excalidraw-diagrams/create-flowchart/workflow.yaml` |
| `create-excalidraw-wireframe` | UI wireframes | `_bmad/bmm/workflows/excalidraw-diagrams/create-wireframe/workflow.yaml` |

**TestArch** (8)
| Name | Description | Path |
|------|-------------|------|
| `testarch-atdd` | Acceptance Test-Driven Development | `_bmad/bmm/workflows/testarch/atdd/workflow.yaml` |
| `testarch-automate` | Expand test automation | `_bmad/bmm/workflows/testarch/automate/workflow.yaml` |
| `testarch-ci` | CI/CD pipeline setup | `_bmad/bmm/workflows/testarch/ci/workflow.yaml` |
| `testarch-framework` | Initialize test framework | `_bmad/bmm/workflows/testarch/framework/workflow.yaml` |
| `testarch-nfr` | Non-functional requirements assessment | `_bmad/bmm/workflows/testarch/nfr-assess/workflow.yaml` |
| `testarch-test-design` | Dual-mode test planning | `_bmad/bmm/workflows/testarch/test-design/workflow.yaml` |
| `testarch-test-review` | Test quality review | `_bmad/bmm/workflows/testarch/test-review/workflow.yaml` |
| `testarch-trace` | Requirements traceability | `_bmad/bmm/workflows/testarch/trace/workflow.yaml` |

### **Workflow Resolution Process**

```javascript
// How AI IDE resolves /create-prd to actual file
function resolveWorkflow(command) {
  const slug = command.replace('/bmad-bmm-', ''); // 'create-prd'
  const manifestRow = loadCSV('_config/workflow-manifest.csv')
    .find(w => w.name === slug);
  
  if (!manifestRow) {
    throw new Error(`Workflow ${slug} not found in manifest`);
  }
  
  const fullPath = `{project-root}/${manifestRow.path}`;
  return loadFile(fullPath);
}
```

---

## 4️⃣ `task-manifest.csv` - Task Registry

### **Purpose**
Catalog standalone tasks (not full workflows)

### **Schema**

```csv
name,displayName,description,module,path,standalone
```

**6 columns**:
1. `name` - Task slug
2. `displayName` - Human-readable name
3. `description` - Purpose
4. `module` - Module (`core`)
5. `path` - File path
6. `standalone` - `true` if user-callable, `false` if infrastructure

### **Complete Task Catalog** (7 tasks)

| Name | Display Name | Standalone? | Purpose | Path |
|------|--------------|-------------|---------|------|
| `editorial-review-prose` | Editorial Review - Prose | ✅ true | Copy-editor review | `_bmad/core/tasks/editorial-review-prose.xml` |
| `editorial-review-structure` | Editorial Review - Structure | ✅ true | Structural editing | `_bmad/core/tasks/editorial-review-structure.xml` |
| `help` | help | ✅ true | Smart help system | `_bmad/core/tasks/help.md` |
| `index-docs` | Index Docs | ✅ true | Generate index.md | `_bmad/core/tasks/index-docs.xml` |
| `review-adversarial-general` | Adversarial Review | ✅ true | Cynical review | `_bmad/core/tasks/review-adversarial-general.xml` |
| `shard-doc` | Shard Document | ✅ true | Split large docs | `_bmad/core/tasks/shard-doc.xml` |
| **`workflow`** | **Execute Workflow** | ❌ **false** | **Workflow execution engine** | `_bmad/core/tasks/workflow.xml` |

### **Critical: `workflow.xml` - The Execution Engine**

**WHY `standalone: false`?**
- Infrastructure task, not user-facing
- Called internally by workflow shortcuts
- Users never call `/workflow` directly

**How it works**:
```
User runs: /dev-story
    ↓
.agent/workflows/dev-story.md says:
  "Load workflow.xml + pass dev-story/workflow.yaml"
    ↓
workflow.xml (execution engine) loads config
    ↓
Execute based on YAML config
```

**Pattern**: Separation of **execution logic** (workflow.xml) vs **configuration data** (.yaml)

---

## 5️⃣ `bmad-help.csv` - Workflow Sequencing & Help System

### **Purpose**
**THE BRAIN** của `/bmad-help` - defines workflow sequences, dependencies, và intelligent routing

### **Schema** (16 columns!)

```csv
module,phase,name,code,sequence,workflow-file,command,required,
agent-name,agent-command,agent-display-name,agent-title,options,
description,output-location,outputs
```

**Key Columns**:
- `phase` - Workflow phase (1-analysis, 2-planning, 3-solutioning, 4-implementation, anytime)
- `sequence` - Order within phase (10, 20, 30... gaps for future)
- `required` - `true` blocks progress if incomplete
- `agent-name` - Suggested agent
- `options` - Mode parameters (e.g., "Create Mode", "Validate Mode")
- `outputs` - What artifacts are created

### **40 Workflow Sequence Entries**

*(Tôi sẽ cont inue với file này trong một write tiếp theo vì quá dài...)*

---

## 5️⃣ `bmad-help.csv` - Workflow Sequencing Brain

### **Purpose**
**THE MOST INTELLIGENT MANIFEST** - powers `/bmad-help` smart routing system

### **Schema** (16 columns)

```csv
module,phase,name,code,sequence,workflow-file,command,required,
agent-name,agent-command,agent-display-name,agent-title,options,
description,output-location,outputs
```

### **Key Columns Explained**

| Column | Type | Purpose | Example |
|--------|------|---------|---------|
| `module` | string | Module name | `bmm`, `core` |
| `phase` | string | Development phase | `1-analysis`, `2-planning`, `3-solutioning`, `4-implementation`, `anytime` |
| `name` | string | Workflow name | `Create PRD` |
| `code` | string | Short code | `CP` (2-3 chars) |
| `sequence` | int | Order in phase | `10`, `20`, `30` (gaps of 10) |
| `workflow-file` | path | Actual workflow path | `_bmad/bmm/workflows/.../workflow.md` |
| `command` | string | Slash command | `bmad-bmm-prd` |
| `required` | boolean | Blocks next phase? | `true`, `false` |
| `agent-name` | string | Suggested agent slug | `pm`, `architect` |
| `agent-display-name` | string | Agent's human name | `John`, `Winston` |
| `agent-title` | string | Agent role | `📋 Product Manager` |
| `options` | string | Mode/parameters | `Create Mode`, `Validate Mode` |
| `description` | text | What this does | `Expert led facilitation...` |
| `output-location` | string | Where artifacts go | `planning_artifacts`, `implementation_artifacts` |
| `outputs` | string | Artifact type | `prd`, `architecture`, `sprint status` |

### **Complete Sequencing Map** (40 entries)

#### **BMM - Phase 1: Analysis** (7 entries)

| Seq | Code | Name | Agent | Required? | Output |
|-----|------|------|-------|-----------|--------|
| 10 | BP | Brainstorm Project | analyst | ❌ | brainstorming session |
| 20 | MR | Market Research | analyst | ❌ | research documents |
| 21 | DR | Domain Research | analyst | ❌ | research documents |
| 22 | TR | Technical Research | analyst | ❌ | research documents |
| 30 | CB | Create Brief | analyst | ❌ | product brief |
| 40 | VB | Validate Brief | analyst | ❌ | brief validation report |

**Pattern**: All use `analyst` agent, none required, all output to `planning_artifacts`

---

#### **BMM - Phase 2: Planning** (4 entries)

| Seq | Code | Name | Agent | Required? | Output |
|-----|------|------|-------|-----------|--------|
| 10 | CP | **Create PRD** | pm | ✅ **YES** | prd |
| 20 | VP | Validate PRD | pm | ❌ | prd validation report |
| 30 | CU | Create UX | ux-designer | ❌ | ux design |
| 40 | VU | Validate UX | ux-designer | ❌ | ux validation report |

**Critical**: `Create PRD` is **required** - blocks progress to Solutioning phase

---

#### **BMM - Phase 3: Solutioning** (6 entries)

| Seq | Code | Name | Agent | Required? | Output |
|-----|------|------|-------|-----------|--------|
| 10 | CA | **Create Architecture** | architect | ✅ **YES** | architecture |
| 20 | VA | Validate Architecture | architect | ❌ | arch validation report |
| 30 | CE | **Create Epics/Stories** | pm | ✅ **YES** | epics and stories |
| 40 | VE | Validate Epics/Stories | pm | ❌ | epics validation report |
| 50 | TD | Test Design | tea | ❌ | test design |
| 70 | IR | **Check Readiness** | architect | ✅ **YES** | readiness report |

**Quality Gate**: `Check Implementation Readiness` is **required** - ADVERSARIAL review before coding

---

#### **BMM - Phase 4: Implementation** (6 entries)

| Seq | Code | Name | Agent | Required? | Cycle |
|-----|------|------|-------|-----------|-------|
| 10 | SP | **Sprint Planning** | sm | ✅ **YES** | Once per sprint |
| 20 | SS | Sprint Status | sm | ❌ | Anytime |
| 30 | CS | **Create Story** | sm | ✅ **YES** | **Story cycle start** |
| 35 | VS | Validate Story | sm | ❌ | After CS |
| 40 | DS | **Dev Story** | dev | ✅ **YES** | **Implementation** |
| 50 | CR | **Code Review** | dev | ❌ | **After DS** |
| 60 | ER | Retrospective | sm | ❌ | Epic end |

**Story Cycle Pattern**:
```
CS (Create Story) → VS (Validate) → DS (Dev) → CR (Review)
    ↓ if issues
    DS (Fix) → CR (Re-review)
    ↓ if approved
    Next CS or ER (if epic complete)
```

---

#### **BMM - Anytime Workflows** (13 entries)

| Code | Name | Agent | When to Use |
|------|------|-------|-------------|
| DP | Document Project | analyst | Brownfield projects |
| TS | Quick Spec | quick-flow-solo-dev | Small tasks |
| QD | Quick Dev | quick-flow-solo-dev | Direct implementation |
| CC | Correct Course | sm | Significant changes |
| CDF | Create Dataflow | ux-designer | Data flow diagrams |
| CED | Create Diagram | ux-designer | Architecture diagrams |
| CFC | Create Flowchart | ux-designer | Process flows |
| CEW | Create Wireframe | ux-designer | UI mockups |

**Quick Flow vs Full BMM**:
- Quick Flow: For 1-off tasks, bug fixes, simple features
- Full BMM: For complex features requiring planning

---

#### **Core Module** (4 entries)

| Code | Name | Phase | Agent | Purpose |
|------|------|-------|-------|---------|
| BS | Brainstorming | anytime | analyst | Creative ideation |
| PM | Party Mode | anytime | party-facilitator | Multi-agent discussions |
| BH | bmad-help | anytime | - | This help system! |
| ID | Index Docs | anytime | - | Generate index.md |
| SD | Shard Document | anytime | - | Split large docs |
| EP | Editorial Prose | anytime | - | Copy editing |
| ES | Editorial Structure | anytime | - | Structural editing |
| AR | Adversarial Review | anytime | - | Cynical review |

---

### **Help System Intelligence**

#### **Phase Detection Logic**

```javascript
function detectCurrentPhase(projectRoot) {
  const artifacts = scanDirectory(`${projectRoot}/_bmad-output/planning_artifacts`);
  
  // Check for completed artifacts
  const hasPRD = artifacts.includes('prd.md');
  const hasArchitecture = artifacts.includes('architecture.md');
  const hasEpics = artifacts.includes('epics-and-stories.md');
  const hasReadiness = artifacts.includes('implementation-readiness.md');
  
  if (!hasPRD) return 'phase-2-planning';
  if (!hasArchitecture || !hasEpics) return 'phase-3-solutioning';
  if (!hasReadiness) return 'phase-3-quality-gate';
  
  // Check implementation artifacts
  const implArtifacts = scanDirectory(`${projectRoot}/_bmad-output/implementation_artifacts`);
  const hasSprintPlan = implArtifacts.includes('sprint-status.yaml');
  
  if (!hasSprintPlan) return 'phase-4-sprint-planning';
  return 'phase-4-implementation';
}
```

#### **Next Step Suggestion**

```javascript
function suggestNextWorkflow(currentPhase) {
  const helpData = loadCSV('_config/bmad-help.csv');
  
  // Filter by phase
  const phaseWorkflows = helpData.filter(w => 
    w.phase === currentPhase || w.phase === 'anytime'
  );
  
  // Sort by sequence
  phaseWorkflows.sort((a, b) => a.sequence - b.sequence);
  
  // Find first incomplete required workflow
  for (const workflow of phaseWorkflows) {
    if (workflow.required === 'true' && !isCompleted(workflow)) {
      return {
        code: workflow.code,
        name: workflow.name,
        command: workflow.command,
        agent: workflow['agent-display-name'],
        description: workflow.description
      };
    }
  }
  
  // No required workflows left - suggest optional
  return phaseWorkflows.filter(w => w.required === 'false')[0];
}
```

#### **Example Help Output**

```
🧙 BMad Master: You are currently in Phase 3: Solutioning

✅ Completed:
  ✓ Create PRD (CP)
  ✓ Create Architecture (CA)

📋 Next Required Step:
  → Create Epics and Stories (CE)
     Agent: John 📋 (Product Manager)
     Command: /create-epics-and-stories
     Output: planning_artifacts/epics-and-stories.md

Optional:
  • Validate Architecture (VA) - Review architecture completeness
  • Test Design (TD) - Plan testing strategy early
```

---

## 6️⃣ `files-manifest.csv` - Complete File Registry

### **Purpose**
Hash-based file integrity tracking và complete file catalog

### **Schema**

```csv
type,name,module,path,hash
```

**5 columns**:
1. `type` - File extension (`md`, `yaml`, `xml`, `csv`, `json`)
2. `name` - File basename (without extension)
3. `module` - Module name (`_config`, `core`, `bmm`)
4. `path` - Relative path from `_bmad/`
5. `hash` - SHA-256 hash for integrity checking

### **Statistics**

**Total Files**: 282 files

**By Type**:
| Type | Count | Usage |
|------|-------|-------|
| `md` | ~200 | Workflows, agents, templates, docs |
| `yaml` | ~40 | Configs, workflow definitions |
| `xml` | ~10 | Tasks, structured prompts |
| `csv` | ~10 | Manifests, data tables |
| `json` | ~2 | Schemas, libraries |

**By Module**:
| Module | Files | % |
|--------|-------|---|
| `bmm` | ~240 | 85% |
| `core` | ~30 | 11% |
| `_config` | ~12 | 4% |

**Examples**:
```csv
type,name,module,path,hash
"yaml","manifest","_config","_config/manifest.yaml","a95b1564a8d10..."
"md","bmad-master","core","core/agents/bmad-master.md","5d9adf90c28df..."
"yaml","workflow","bmm","bmm/workflows/4-implementation/dev-story/workflow.yaml","270cb47b01e5..."
```

### **Integrity Checking**

```javascript
function verifyFrameworkIntegrity() {
  const manifest = loadCSV('_config/files-manifest.csv');
  const errors = [];
  
  for (const entry of manifest) {
    const filePath = `_bmad/${entry.path}`;
    const actualHash = sha256(readFile(filePath));
    
    if (actualHash !== entry.hash) {
      errors.push({
        file: entry.path,
        expected: entry.hash,
        actual: actualHash,
        status: 'MODIFIED or CORRUPTED'
      });
    }
  }
  
  return errors.length === 0 ? 'VALID' : errors;
}
```

---

## 7️⃣ `agents/` Directory - Customization System

### **Purpose**
User-specific agent customizations WITHOUT modifying core files

### **Structure**

```
_config/agents/
├── bmm-analyst.customize.yaml
├── bmm-architect.customize.yaml
├── bmm-dev.customize.yaml
├── bmm-pm.customize.yaml
├── bmm-quick-flow-solo-dev.customize.yaml
├── bmm-sm.customize.yaml
├── bmm-tea.customize.yaml
├── bmm-tech-writer.customize.yaml
├── bmm-ux-designer.customize.yaml
└── core-bmad-master.customize.yaml
```

**10 files** - one for each agent

### **Customization Schema**

```yaml
# Agent Customization
# Customize any section below - all are optional

# Override agent name
agent:
  metadata:
    name: ""

# Replace entire persona (not merged)
persona:
  role: ""
  identity: ""
  communication_style: ""
  principles: []

# Add custom critical actions (appended after standard config loading)
critical_actions: []

# Add persistent memories for the agent
memories: []
# Example:
# memories:
#   - "User prefers detailed technical explanations"
#   - "Current project uses React and TypeScript"

# Add custom menu items (appended to base menu)
# Don't include * prefix or help/exit - auto-injected
menu: []
# Example:
# menu:
#   - trigger: my-workflow
#     workflow: "{project-root}/custom/my.yaml"
#     description: My custom workflow

# Add custom prompts (for action="#id" handlers)
prompts: []
# Example:
# prompts:
# - id: my-prompt
#   content: |
#     Prompt instructions here
```

### **Customization Levels**

#### **Level 1: Memories** (Non-Destructive)

Add project-specific context:
```yaml
# bmm-dev.customize.yaml
memories:
  - "Project uses strict TDD - write tests before implementation"
  - "Code style: 2-space indent, no semicolons"
  - "All PRs require 100% test coverage"
```

**Effect**: Amelia (dev agent) will remember these across sessions

---

#### **Level 2: Menu Extensions** (Additive)

Add custom workflows:
```yaml
# bmm-pm.customize.yaml
menu:
  - trigger: validate-roadmap
    workflow: "{project-root}/.agent/custom/roadmap-validation.yaml"
    description: Validate product roadmap alignment
```

**Effect**: John (pm) will show this in menu

---

#### **Level 3: Persona Override** (Destructive)

**WARNING**: Replaces entire persona
```yaml
# bmm-architect.customize.yaml
persona:
  role: "Cloud-Native Architect specializing in Kubernetes"
  identity: "Winston is now a k8s expert with 10 years in cloud infrastructure"
  communication_style: "Technical and infrastructure-focused"
  principles:
    - "Always design for cloud-native deployment"
    - "Kubernetes-first architecture"
```

**Effect**: Winston's personality completely replaced

---

### **Customization Loading Order**

```
1. Load base agent from _bmad/{module}/agents/{agent}.md
    ↓
2. Load agent-manifest.csv metadata
    ↓
3. Check _config/agents/{module}-{agent}.customize.yaml
    ↓
4. IF customization exists:
     - Replace persona (if defined)
     - Append memories
     - Append menu items
     - Append critical actions
    ↓
5. Activate agent
```

---

## 8️⃣ `custom/` Directory - User Extensions

### **Purpose**
Reserved directory for user-created workflows, agents, templates

### **Current State**
**Empty** - no custom resources yet

### **Intended Usage**

```
_config/custom/
├── workflows/
│   ├── my-custom-workflow.yaml
│   └── company-specific-review.md
├── agents/
│   ├── data-scientist.md
│   └── security-expert.md
├── templates/
│   └── company-prd-template.md
└── data/
    └── industry-standards.csv
```

### **Adding Custom Workflow**

**Step 1**: Create workflow file
```yaml
# _config/custom/workflows/security-review.yaml
name: security-review
description: "Security-focused code review"
agent: architect
instructions: |
  Review code for security vulnerabilities:
  - SQL injection risks
  - XSS vulnerabilities
  - Authentication flaws
```

**Step 2**: Add to workflow-manifest
```csv
# _config/workflow-manifest.csv (append)
"security-review","Security code review","custom","_config/custom/workflows/security-review.yaml"
```

**Step 3**: Create shortcut
```markdown
<!-- .agent/workflows/security-review.md -->
---
description: Security-focused code review
---

Load workflow.xml and execute _config/custom/workflows/security-review.yaml
```

**Now callable**: `/security-review`

---

## 🎯 Practical Use Cases

### **Use Case 1: Finding Next Workflow**

**Scenario**: User asks "What should I do next?"

**Process**:
1. Read `bmad-help.csv`
2. Detect current phase from artifacts
3. Filter workflows by phase
4. Find first incomplete required workflow
5. Return: name, command, agent, description

**Implementation**:
```javascript
// This is what /bmad-help does
const helpData = loadCSV('_config/bmad-help.csv');
const currentPhase = detectPhase(); // '3-solutioning'

const nextStep = helpData
  .filter(w => w.phase === currentPhase && w.required === 'true')
  .sort((a, b) => a.sequence - b.sequence)
  .find(w => !artifactExists(w.outputs));

console.log(`Run: /${nextStep.command}`);
console.log(`Agent: ${nextStep['agent-display-name']} ${nextStep['agent-title']}`);
```

---

### **Use Case 2: Agent Selection**

**Scenario**: User wants to create PRD

**Process**:
1. Resolve command `/create-prd` → workflow name `create-prd`
2. Look up in `workflow-manifest.csv` → module `bmm`, path `...`
3. Look up in `bmad-help.csv` → agent `pm`
4. Look up in `agent-manifest.csv` → displayName `John`, icon `📋`
5. Load agent from path `_bmad/bmm/agents/pm.md`
6. Check customization `_config/agents/bmm-pm.customize.yaml`
7. Activate "John the PM"

---

### **Use Case 3: Workflow Validation**

**Scenario**: Check if all required workflows completed before implementation

**Process**:
```javascript
function canStartImplementation() {
  const helpData = loadCSV('_config/bmad-help.csv');
  
  const requiredPhases = ['2-planning', '3-solutioning'];
  const requiredWorkflows = helpData.filter(w => 
    requiredPhases.includes(w.phase) && w.required === 'true'
  );
  
  const incomplete = requiredWorkflows.filter(w => 
    !artifactExists(w['output-location'], w.outputs)
  );
  
  if (incomplete.length > 0) {
    return {
      ready: false,
      missing: incomplete.map(w => w.name)
    };
  }
  
  return { ready: true };
}

// Result:
// { ready: false, missing: ['Create PRD', 'Create Architecture', 'Check Implementation Readiness'] }
```

---

### **Use Case 4: Custom Agent Personality**

**Scenario**: Make "dev" agent more verbose for team learning

**Solution**:
```yaml
# _config/agents/bmm-dev.customize.yaml
persona:
  communication_style: "Educational and detailed - explains reasoning behind code decisions"
  principles:
    - "All tests must pass 100%"
    - "Explain technical decisions for knowledge sharing"
    - "Use comments generously for team learning"

memories:
  - "Team is learning React - explain hooks usage"
  - "Junior developers benefit from detailed code reviews"
```

**Effect**: Amelia (dev) now explains more instead of ultra-succinct style

---

## 🔧 Advanced Scenarios

### **Scenario 1: Multi-Module Project**

**Goal**: Different modules use different methodologies

```yaml
# _config/manifest.yaml
modules:
  - name: core
  - name: bmm
  - name: enterprise-workflows  # Custom module
    source: npm
    npmPackage: "@company/bmad-enterprise"
```

**Custom workflows** registered:
```csv
# _config/workflow-manifest.csv
"enterprise-prd","Enterprise PRD with compliance","enterprise-workflows","..."
"soc2-review","SOC2 compliance review","enterprise-workflows","..."
```

---

### **Scenario 2: Industry-Specific Customization**

**Healthcare Project**:
```yaml
# _config/agents/bmm-architect.customize.yaml
memories:
  - "All architecture must be HIPAA compliant"
  - "PHI data must be encrypted at rest and in transit"
  - "Audit logging required for all data access"

menu:
  - trigger: hipaa-review
    workflow: "{project-root}/.agent/custom/hipaa-compliance.yaml"
    description: HIPAA compliance architecture review
```

---

### **Scenario 3: File Integrity Monitoring**

**CI/CD Integration**:
```bash
#!/bin/bash
# .github/workflows/verify-bmad.yml

# Verify BMAD framework integrity
node scripts/verify-framework.js

# verify-framework.js:
const manifest = loadCSV('_bmad/_config/files-manifest.csv');
for (const file of manifest) {
  const hash = sha256(`_bmad/${file.path}`);
  if (hash !== file.hash) {
    throw new Error(`Framework file modified: ${file.path}`);
  }
}
```

---

## 📊 Key Insights

### **Design Philosophy**

1. **CSV for Speed**: Fast parsing, grep-able, version control friendly
2. **Separation of Concerns**: 
   - `workflow-manifest` = catalog
   - `bmad-help` = sequencing logic
   - `agent-manifest` = personas
3. **Extensibility**: `custom/` + `customize.yaml` = non-destructive customization
4. **Integrity**: `files-manifest` với hashes = detect tampering

### **Why Not JSON?**

**CSV Advantages**:
- Grep-able: `grep "pm" agent-manifest.csv`
- Diff-friendly: Git shows row changes clearly
- Fast parsing: No nested objects
- Spreadsheet-editable: Non-developers can edit

**Trade-off**: Limited nesting, need multiple files

---

## 🎓 Learning Path

**If bạn là**:

### **User** (sử dụng BMAD)
- 📖 Read: `agent-manifest.csv` - know your team
- 📖 Read: `bmad-help.csv` - understand sequences
- 🔧 Use: `agents/*.customize.yaml` - add memories

### **Power User** (customize workflows)
- 📖 Read: All manifests
- 🔧 Create: Custom workflows in `custom/`
- 🔧 Modify: `workflow-manifest.csv` to register

### **Framework Developer** (extend BMAD)
- 📖 Master: All manifests + schemas
- 🔧 Create: New modules
- 🔧 Implement: Manifest-driven discovery pattern

---

## 🔗 Related Documentation

- [01-bmad-directory-internals.md](./01-bmad-directory-internals.md) - High-level `_bmad/` overview
- [02-core-concepts/01-folder-structure.md](../../02-core-concepts/01-folder-structure.md) - Project structure
- [03-workflows/01-all-workflows.md](../../03-workflows/01-all-workflows.md) - User-facing workflow guide

---

## 📝 Summary

`_bmad/_config/` is the **nervous system** of BMAD:

✅ **7 Manifest Files**:
- `manifest.yaml` - Installation tracking
- `agent-manifest.csv` - 11 agents with personalities
- `workflow-manifest.csv` - 32 workflows catalog
- `task-manifest.csv` - 7 tasks (including workflow.xml engine)
- `bmad-help.csv` - 40 workflow sequences with intelligence
- `files-manifest.csv` - 282 files integrity tracking
- `tool-manifest.csv` - Tool integrations

✅ **2 Directories**:
- `agents/` - 10 customization files
- `custom/` - User extensions (empty)

✅ **Core Capabilities**:
- Fast resource discovery via CSV
- Intelligent workflow routing
- Phase-aware help system
- Non-destructive customization
- File integrity verification

**Next**: Explore `_bmad/core/` internals để hiểu execution engine!
