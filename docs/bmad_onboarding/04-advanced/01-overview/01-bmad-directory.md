---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "BMAD Directory Deep Dive"
---

# `_bmad/` Directory - Deep Dive

> **Advanced documentation** về internal structure của BMAD framework  
> **Target audience**: Developers muốn hiểu sâu về BMAD architecture hoặc customize framework

---

## 📋 Tổng Quan

`_bmad/` là **framework core** - chứa toàn bộ logic, workflows, agents, và configurations của BMAD Method.

### **Cấu Trúc High-Level**

```
_bmad/
├── _config/          # Manifest hub - Registry của tất cả resources
├── core/             # Core module - Universal tools
└── bmm/              # BMM (BMad Method) module - Agile workflows
```

**Total Files**: 303 files + directories  
**Total Size**: ~2-5 MB (mostly text files)

---

## 🗂️ Part 1: `_config/` - Manifest Hub

**Purpose**: Central registry cho tất cả BMAD resources. AI agents load manifests này để discover available workflows, agents, và tasks.

### **Files trong `_config/`**

```
_config/
├── manifest.yaml              # Installation manifest
├── agent-manifest.csv         # 11 agents
├── workflow-manifest.csv      # 32 workflows
├── task-manifest.csv         # 7 tasks
├── tool-manifest.csv         # Tool integrations
├── bmad-help.csv             # Workflow sequencing & help system
├── files-manifest.csv        # All framework files
├── agents/                   # Agent shortcuts (10 files)
└── custom/                   # User customizations
```

---

### **1.1 `manifest.yaml` - Installation Manifest**

**Purpose**: Track installed modules and IDE integrations

**Content**:
```yaml
installation:
  version: 6.0.0-Beta.2
  installDate: 2026-01-28T07:12:00.295Z
modules:
  - name: core
    version: 6.0.0-Beta.2
    source: built-in
  - name: bmm
    version: 6.0.0-Beta.2
    source: built-in
ides:
  - antigravity
```

**Key Fields**:
- `modules[]` - Installed modules (core, bmm, custom modules)
- `ides[]` - Integrated AI IDEs
- `version` - BMAD version tracking

---

### **1.2 `agent-manifest.csv` - Agent Registry**

**Purpose**: Catalog tất cả available agents với metadata

**Columns**:
```
name, displayName, title, icon, role, identity, communicationStyle, principles, module, path
```

**11 Agents Registered**:

| Name | Display Name | Icon | Module | Personality |
|------|-------------|------|--------|-------------|
| `bmad-master` | BMad Master | 🧙 | core | Master orchestrator, 3rd person |
| `analyst` | Mary | 📊 | bmm | Treasure hunter analyst |
| `architect` | Winston | 🏗️ | bmm | Pragmatic architect |
| `dev` | Amelia | 💻 | bmm | Ultra-succinct engineer |
| `pm` | John | 📋 | bmm | Relentless "WHY?" asker |
| `quick-flow-solo-dev` | Barry | 🚀 | bmm | Fast implementation specialist |
| `sm` | Bob | 🏃 | bmm | Servant leader Scrum Master |
| `tea` | Murat | 🧪 | bmm | Risk-based test architect |
| `tech-writer` | Paige | 📚 | bmm | Clarity-focused writer |
| `ux-designer` | Sally | 🎨 | bmm | Empathetic UX expert |

**Example Row**:
```csv
pm,John,Product Manager,📋,PM veteran with 8+ years,"Asks 'WHY?' relentlessly",bmm,_bmad/bmm/agents/pm.md
```

**Usage**: `/bmad-help` reads này để suggest appropriate agent

---

### **1.3 `workflow-manifest.csv` - Workflow Registry**

**Purpose**: Catalog 32 workflows với paths

**Columns**:
```
name, description, module, path
```

**Sample Entries**:
```csv
create-prd,PRD tri-modal workflow,bmm,_bmad/bmm/workflows/2-plan-workflows/create-prd/workflow.md
dev-story,Execute story implementation,bmm,_bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml
```

**Workflow Distribution**:
- **Core**: 2 workflows (brainstorming, party-mode)
- **BMM**: 30 workflows (planning, implementation, testing)

**Usage**: AI IDE loads này để resolve `/command-name` → workflow file path

---

### **1.4 `task-manifest.csv` - Task Registry**

**Purpose**: Catalog 7 standalone tasks

**Columns**:
```
name, displayName, description, module, path, standalone
```

**7 Tasks**:

| Name | Module | Standalone | Purpose |
|------|--------|------------|---------|
| `editorial-review-prose` | core | true | Copy editing |
| `editorial-review-structure` | core | true | Structural editing |
| `help` | core | true | Smart help system |
| `index-docs` | core | true | Generate index.md |
| `review-adversarial-general` | core | true | Adversarial review |
| `shard-doc` | core | true | Split large docs |
| `workflow` | core | **false** | Workflow execution engine |

**`standalone: true`**: Can run independently  
**`standalone: false`**: Infrastructure task, not user-callable

**Critical**: `workflow.xml` is the **execution engine** for all `.yaml` workflows

---

### **1.5 `bmad-help.csv` - Workflow Sequencing**

**Purpose**: Define workflow sequences, phase organization, và help system logic

**Columns** (16 total):
```
module, phase, name, code, sequence, workflow-file, command, required, 
agent-name, agent-command, output-location, outputs, description, ...
```

**Key Features**:

#### **Phase Organization**
```csv
bmm,1-analysis,Create Brief,CB,30,_bmad/bmm/workflows/.../brief,required=false
bmm,2-planning,Create PRD,CP,10,_bmad/bmm/workflows/.../prd,required=true
bmm,3-solutioning,Create Architecture,CA,10,...,required=true
bmm,4-implementation,Sprint Planning,SP,10,...,required=true
```

**`required=true`**: Blocks progress to next phase nếu chưa complete

#### **Sequence Numbers**
```
10, 20, 30, ... - Gaps cho future insertions
```

#### **Routing Logic**
```csv
anytime,Quick Spec,TS,20 - Can run anytime regardless of phase
```

**Usage**: `/bmad-help` reads này để:
1. Detect current phase from completed artifacts
2. Suggest next required workflow
3. Show alternate paths

---

### **1.6 Sub-directories**

#### **`_config/agents/`**
10 agent shortcut files trỏ đến actual agent definitions

**Example**: `_config/agents/pm.md`
```markdown
name: pm
path: _bmad/bmm/agents/pm.md
```

#### **`_config/custom/`**
Reserved cho user customizations  
**Currently empty** - sẽ chứa custom workflows/agents nếu user tạo

---

## 🧩 Part 2: `core/` Module

**Purpose**: Universal tools available trong **mọi phases**, không phụ thuộc vào workflow state

### **Structure**

```
core/
├── config.yaml           # Core module config
├── module-help.csv       # Core help entries
├── agents/
│   └── bmad-master.md   # ONLY 1 agent
├── workflows/
│   ├── brainstorming/
│   ├── party-mode/
│   └── advanced-elicitation/
├── tasks/
│   ├── help.md
│   ├── workflow.xml     # ⭐ Workflow execution engine
│   ├── editorial-review-prose.xml
│   ├── editorial-review-structure.xml
│   ├── index-docs.xml
│   ├── shard-doc.xml
│   └── review-adversarial-general.xml
└── resources/
    └── (templates, examples)
```

**Total Files**: 31 items (4 subdirs + files)

---

### **2.1 Core Agent: `bmad-master`**

**File**: `core/agents/bmad-master.md`

**WHY only 1 agent in core?**
- Core = Orchestration layer
- BMad Master = Universal facilitator
- Không specialize vào domain
- Load other agents as needed

**Responsibilities**:
1. Load config (`_bmad/core/config.yaml`)
2. Display menu
3. Route to workflows
4. Execute commands

**Persona**:
- Speaks in 3rd person
- Direct và comprehensive
- Runtime resource loading (never pre-load)

---

### **2.2 Core Workflows**

#### **`brainstorming/`** (11 files)
- Creative facilitation
- Multiple ideation techniques
- Problem-solving frameworks

#### **`party-mode/`** (4 files)
- Multi-agent orchestration
- Natural conversations giữa agents
- Different perspectives

#### **`advanced-elicitation/`** (2 files)
- Advanced requirement gathering
- Expert elicitation techniques

---

### **2.3 Core Tasks** (7 files)

#### **⭐ `workflow.xml` - The Execution Engine**

**CRITICAL FILE** - đây là "Operating System" cho tất cả YAML workflows

**What it does**:
1. Load workflow config (`.yaml`)
2. Read instructions
3. Process templates
4. Execute steps
5. Save outputs

**Pattern**:
```
.agent/workflows/dev-story.md (shortcut)
    ↓
Load workflow.xml
    ↓
Pass _bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml
    ↓
workflow.xml executes based on YAML config
```

**Tại sao tách biệt?**
- **workflow.xml** = Execution logic (stable)
- **workflow.yaml** = Configuration data (flexible)
- Separation of concerns
- Easier to update workflows without touching engine

---

#### **`help.md` - Smart Help System**

**What it does**:
1. Detect active module from context
2. Load `bmad-help.csv`
3. Analyze completed artifacts
4. Determine current phase
5. Suggest next steps based on sequence

**Intelligence**:
- Phase detection from artifacts
- Module detection from keywords
- Required vs optional workflow routing

---

#### **Other Tasks**

| Task | Purpose |
|------|---------|
| `editorial-review-prose.xml` | Copy editor persona |
| `editorial-review-structure.xml` | Structural editor - cuts & reorganization |
| `index-docs.xml` | Generate index.md for docs folder |
| `shard-doc.xml` | Split large markdown files |
| `review-adversarial-general.xml` | Adversarial review - find problems |

**All XML format** - Structured task definitions với embedded prompts

---

## 🏗️ Part 3: `bmm/` Module

**Purpose**: BMM (BMAD Method Module) - Full agile development lifecycle workflows

### **Structure**

```
bmm/
├── config.yaml                    # BMM module config
├── module-help.csv               # BMM help entries (larger than core)
├── agents/                       # 9 specialized agents
│   ├── analyst.md
│   ├── architect.md
│   ├── dev.md
│   ├── pm.md
│   ├── quick-flow-solo-dev.md
│   ├── sm.md
│   ├── tea.md
│   ├── tech-writer/
│   └── ux-designer.md
├── workflows/                    # 8 categories, 206 files
│   ├── 1-analysis/              (30 files)
│   ├── 2-plan-workflows/        (55 files)
│   ├── 3-solutioning/           (27 files)
│   ├── 4-implementation/        (21 files)
│   ├── bmad-quick-flow/         (13 files)
│   ├── document-project/        (13 files)
│   ├── excalidraw-diagrams/     (14 files)
│   └── testarch/                (33 files)
├── teams/                       # Team configurations
├── testarch/                    # Test architecture resources (35 files)
└── data/                        # Templates & data files
```

**Total Files**: 255 items

---

### **3.1 BMM Agents** (9 agents)

Mỗi agent = Specialized expert với personality riêng

#### **Agent Details**

| Agent | Name | Specialty | Communication Style |
|-------|------|-----------|---------------------|
| **analyst** | Mary | Requirements, research | Treasure hunter - excited về discovery |
| **architect** | Winston | System design, tech stack | Calm, pragmatic, "what should be" |
| **dev** | Amelia | Code implementation | Ultra-succinct, file paths & AC IDs |
| **pm** | John | Product strategy, PRDs | Asks "WHY?" relentlessly, data-sharp |
| **quick-flow-solo-dev** | Barry | Fast iteration | Direct, tech slang, ruthless efficiency |
| **sm** | Bob | Scrum, sprint management | Crisp, checklist-driven, servant leader |
| **tea** | Murat | Testing, QA, automation | Data + gut, risk calculations |
| **tech-writer** | Paige | Documentation | Patient educator, clarity expert |
| **ux-designer** | Sally | User experience | Empathetic storyteller |

**WHY specialized agents?**
- Domain expertise
- Consistent personality per role
- Natural collaboration model (như real team)
- Different communication styles fit different tasks

---

### **3.2 BMM Workflows** - 8 Categories

#### **Category 1: `1-analysis/` (30 files)**

**Workflows**:
- `create-product-brief/` - Discovery session
- `research/` - Market, technical, domain research

**Phase**: Discovery  
**Purpose**: Understand problem, users, market

---

#### **Category 2: `2-plan-workflows/` (55 files)**

**Workflows**:
- `create-prd/` - Tri-modal PRD (Create/Validate/Edit)
  - Step-file architecture
  - 3 modes: `steps-c/`, `steps-v/`, `steps-e/`
  - Sequential execution enforcement
- `create-ux-design/` - UX patterns planning

**Phase**: Planning  
**Purpose**: Detailed requirements và UX design

---

#### **Category 3: `3-solutioning/` (27 files)**

**Workflows**:
- `create-architecture/` - Technical architecture decisions
- `create-epics-and-stories/` - Breakdown into implementable units
- `check-implementation-readiness/` - **Quality gate** - ADVERSARIAL review

**Phase**: Solutioning  
**Purpose**: Technical design và implementation planning

---

#### **Category 4: `4-implementation/` (21 files)**

**Workflows**:
- `sprint-planning/` - Initialize sprint tracking
- `create-story/` - Prepare next story
- `dev-story/` - Execute implementation
- `code-review/` - ADVERSARIAL review (must find 3-10 issues)
- `sprint-status/` - Progress tracking
- `correct-course/` - Handle significant changes
- `retrospective/` - Epic completion review

**Phase**: Implementation  
**Purpose**: Build, test, review, ship

**Workflow Pattern**:
```
sprint-planning (once)
    ↓
Loop:
    create-story → dev-story → code-review
    ↓ (if epic complete)
    retrospective
```

---

#### **Category 5: `bmad-quick-flow/` (13 files)**

**Workflows**:
- `quick-spec/` - Fast tech spec creation
- `quick-dev/` - Direct implementation

**Phase**: Anytime  
**Purpose**: Fast path cho small tasks, bug fixes  
**vs Full Flow**: Skip extensive planning

---

#### **Category 6: `document-project/` (13 files)**

**Workflow**: `document-project/`

**Modes**:
- `full-scan.yaml` - Comprehensive codebase analysis
- `deep-dive.yaml` - Focused deep dive

**Purpose**: Brownfield project onboarding  
**Output**: Project documentation cho AI context

---

#### **Category 7: `excalidraw-diagrams/` (14 files)**

**Workflows**:
- `create-diagram/` - Architecture diagrams, ERDs, UML
- `create-dataflow/` - Data flow diagrams
- `create-flowchart/` - Process flowcharts
- `create-wireframe/` - UI wireframes

**Phase**: Anytime  
**Purpose**: Visual documentation  
**Format**: `.excalidraw` files

---

#### **Category 8: `testarch/` (33 files)**

**8 Test Workflows**:

| Workflow | Purpose | Phase |
|----------|---------|-------|
| `framework/` | Setup Playwright/Cypress | Start of project |
| `test-design/` | Dual-mode: system/epic test planning | Solutioning or Implementation |
| `atdd/` | Acceptance tests BEFORE implementation | Implementation (TDD) |
| `automate/` | Expand test coverage | Implementation |
| `test-review/` | Test quality review | Implementation |
| `trace/` | Requirements traceability matrix | Pre-release |
| `nfr-assess/` | Non-functional requirements validation | Pre-release |
| `ci/` | CI/CD pipeline setup | Anytime |

**TestArch Philosophy**:
- Risk-based testing
- API tests = first-class citizens
- Flakiness = technical debt
- Tests first, AI implements, suite validates

---

### **3.3 BMM Supporting Resources**

#### **`teams/`**
Team configuration files  
**Example**: Multi-team projects

#### **`testarch/` (resources)**
35 files của test architecture templates, patterns, examples

#### **`data/`**
Templates và reference data  
**Example**: `project-context-template.md`

---

## 🔑 Key Architectural Patterns

### **Pattern 1: Manifest-Driven Discovery**

```
AI Agent needs to find workflows
    ↓
Load _config/workflow-manifest.csv
    ↓
Search by name/description
    ↓
Resolve path
    ↓
Load workflow file
```

**Benefits**:
- Fast lookup (CSV = simple parsing)
- Single source of truth
- Easy to extend (add new workflow = add CSV row)

---

### **Pattern 2: Workflow Execution Engine**

```
Shortcut: .agent/workflows/dev-story.md
    ↓
"Load workflow.xml + pass config path"
    ↓
workflow.xml (execution engine)
    ↓
Load workflow.yaml (configuration)
    ↓
Execute based on config
```

**Benefits**:
- Separation: logic vs data
- Stable execution engine
- Flexible workflow configs
- Easy to update workflows

---

### **Pattern 3: Step-File Architecture**

**Used in**: PRD, Architecture, Epics workflows

```
workflow.md (entry point)
    ↓
Mode detection (Create/Validate/Edit)
    ↓
Load first step: steps-c/step-01-init.md
    ↓
Execute step (read COMPLETE file)
    ↓
User interaction → save state → load next step
    ↓
steps-c/step-02-*.md
    ↓
Continue until workflow complete
```

**Rules**:
- 📖 Read ENTIRE step file before execution
- 🚫 NEVER load multiple steps
- 🔒 Execute sequence in order
- 💾 Update frontmatter before next step
- ⏸️ Halt at menus for user input

**Benefits**:
- Disciplined execution
- No skipping steps
- State tracking
- Append-only document building

---

### **Pattern 4: Dual-Mode Workflows**

**Example**: `testarch/test-design/`

```yaml
mode: auto-detect
    ↓
IF in Solutioning phase:
    → System-level testability review
    ↓
IF in Implementation phase:
    → Epic-level test planning
```

**Benefits**:
- Single workflow, multiple use cases
- Context-aware behavior
- Reusable components

---

## 📊 Statistics

### **Module Comparison**

| Metric | Core | BMM |
|--------|------|-----|
| **Agents** | 1 (orchestrator) | 9 (specialists) |
| **Workflows** | 3 | 29 |
| **Tasks** | 7 | 0 (uses workflows) |
| **Total Files** | 31 | 255 |
| **Purpose** | Universal tools | Agile lifecycle |
| **Phase Dependency** | None | 4 phases |

---

### **File Format Distribution**

| Format | Count | Usage |
|--------|-------|-------|
| **`.md`** | ~150 | Workflows, agents, docs |
| **`.yaml`** | ~50 | Workflow configs |
| **`.xml`** | ~10 | Tasks, structured prompts |
| **`.csv`** | ~10 | Manifests, help data |

---

### **Workflow Complexity**

| Workflow | Files | Complexity |
|----------|-------|------------|
| Simple (brainstorming) | 11 | Low |
| Medium (quick-spec) | 13 | Medium |
| Complex (create-prd) | 55+ | High (step-file architecture) |

---

## 🎯 Design Principles

### **1. Modularity**
- Core = universal
- BMM = agile-specific
- Easy to add new modules

### **2. Discoverability**
- Manifests = single source of truth
- CSV = fast lookups
- Help system = intelligent routing

### **3. Consistency**
- Agents have distinct personalities (not generic AI)
- Workflows follow patterns
- Naming conventions

### **4. Extensibility**
- Add workflow = add CSV row + files
- Custom agents in `_config/custom/`
- Module system

### **5. Separation of Concerns**
- Execution engine (`workflow.xml`) vs config (`.yaml`)
- Data (manifests) vs logic (workflows)
- Universal (core) vs specialized (bmm)

---

## 🚀 Advanced Use Cases

### **Customizing BMAD**

#### **Add Custom Workflow**
1. Create workflow files in `_config/custom/workflows/`
2. Add row to `_config/workflow-manifest.csv`
3. Create shortcut in `.agent/workflows/`

#### **Add Custom Agent**
1. Create agent file in `_config/custom/agents/`
2. Add row to `_config/agent-manifest.csv`
3. Create shortcut in `.agent/workflows/`

---

### **Creating Your Own Module**

```
_bmad/
├── _config/
├── core/
├── bmm/
└── your-module/              ← New module
    ├── config.yaml
    ├── module-help.csv
    ├── agents/
    └── workflows/
```

Add to `_config/manifest.yaml`:
```yaml
modules:
  - name: your-module
    version: 1.0.0
```

---

## 🔍 Debugging & Troubleshooting

### **Workflow Not Found**
**Check**: `_config/workflow-manifest.csv` - does entry exist?

### **Agent Behaving Wrong**
**Check**: `_bmad/{module}/agents/{agent}.md` - persona definition

### **Output in Wrong Location**
**Check**:
1. `_bmad/{module}/config.yaml` - output folder config
2. Workflow file - `output` field

### **Workflow Skipping Steps**
**Review**: Step-file architecture rules - AI might be violating sequential execution

---

## 📚 Further Reading

**Related Docs**:
- [02-core-concepts/01-folder-structure.md](../02-core-concepts/01-folder-structure.md) - High-level overview
- [02-core-concepts/02-file-formats.md](../02-core-concepts/02-file-formats.md) - Why different formats
- [03-workflows/01-all-workflows.md](../03-workflows/01-all-workflows.md) - User-facing workflow guide

**External**:
- [BMAD Docs](http://docs.bmad-method.org/)
- [GitHub](https://github.com/bmad-code-org/BMAD-METHOD/)

---

**Kết Luận**: `_bmad/` là một **well-architected framework** với clear separation of concerns, modular design, và intelligent discovery mechanisms. Hiểu rõ structure này giúp bạn customize, extend, và troubleshoot BMAD effectively.
