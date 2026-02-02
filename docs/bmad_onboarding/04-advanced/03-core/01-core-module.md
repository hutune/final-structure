---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "Core Module Reference"
---

# Core Module - Complete Reference

> **Module**: Core (Universal BMAD Tools)  
> **Location**: `_bmad/core/`  
> **Purpose**: Universal workflows, orchestration, and execution engine  
> **Components**: 1 agent, 3 workflows, 7 tasks, resources

---

## 📋 Overview

The Core module provides **universal tools** used across all BMAD implementations:

### **Key Components**

1. **Agent**: `bmad-master` - Master orchestrator
2. **Workflows**: Brainstorming, party-mode, advanced-elicitation
3. **Tasks**: **workflow.xml** (THE EXECUTION ENGINE), help system, utilities
4. **Resources**: Templates and examples

### **vs BMM Module**

| Aspect | Core | BMM |
|--------|------|-----|
| **Purpose** | Universal tools | Agile AI development |
| **Agents** | 1 (orchestrator) | 9 (specialized roles) |
| **Workflows** | 3 (universal) | 8 categories (206 files) |
| **Scope** | Any project type | Software development |
| **Customization** | Rarely needed | Frequently customized |

---

## 1️⃣ Core Agent: bmad-master

**File**: `_bmad/core/agents/bmad-master.md`  
**Name**: (Master Orchestrator)  
**Icon**: 🎭  
**Role**: Master orchestrator and multi-agent facilitator

### **Persona**

- **Role**: Strategic Orchestrator and Multi-Agent Facilitator
- **Identity**: Coordinates complex work across multiple specialized agents
- **Communication**: Clear, directive, big-picture thinking
- **Principles**:
  - Right agent for right job
  - Multi-agent collaboration when needed
  - Maintain project context across agents
  - Smooth handoffs between specialists

### **When to Use**

- ✅ Complex projects requiring multiple agents
- ✅ Unclear which agent to use
- ✅ Need agent recommendations
- ✅ Coordinating multi-agent workflows

### **Menu**

| CMD | Workflow | Description |
|-----|----------|-------------|
| MH | - | Redisplay Menu |
| CH | - | Chat |
| BP | brainstorming | Expert guided facilitation |
| PM | party-mode | Multi-agent orchestration |
| DA | - | Dismiss |

### **Capabilities**

**Agent Selection**:
- Analyze user request
- Recommend appropriate agent(s)
- Explain why specific agent fits
- Facilitate agent switching

**Multi-Agent Orchestration**:
- Coordinate party-mode discussions
- Maintain context across agents
- Ensure smooth handoffs
- Synthesize multi-agent outputs

---

## 2️⃣ Core Workflows

### 2.1 Brainstorming

**Location**: `_bmad/core/workflows/brainstorming/`  
**Files**: 11  
**Purpose**: Expert guided creative facilitation using diverse techniques  
**Output**: Brainstorming report with ideas and recommendations

#### **File Structure**

```
brainstorming/
├── workflow.md                      # Main workflow
├── techniques/
│   ├── brain-writing.md             # Silent idea generation
│   ├── brainwalking.md              # Rotate and build on ideas
│   ├── crazy-eights.md              # 8 sketches in 8 minutes
│   ├── five-whys.md                 # Root cause analysis
│   ├── mind-mapping.md              # Visual idea organization
│   ├── reverse-brainstorming.md     # Invert the problem
│   ├── scamper.md                   # 7 thinking prompts
│   ├── starbursting.md              # Question generation
│   └── swot-analysis.md             # Strengths, weaknesses, opportunities, threats
└── README.md
```

#### **Brainstorming Techniques** (9 techniques)

**Creative Techniques**:
1. **Mind Mapping** - Visual idea organization
2. **Crazy Eights** - Rapid sketching (8 ideas in 8 minutes)
3. **Brain Writing** - Silent collaborative ideation
4. **Brainwalking** - Rotate stations, build on ideas

**Analytical Techniques**:
5. **Five Whys** - Root cause analysis
6. **SWOT Analysis** - Strengths, Weaknesses, Opportunities, Threats
7. **Starbursting** - 5W1H questioning (Who, What, When, Where, Why, How)

**Reframing Techniques**:
8. **Reverse Brainstorming** - How to make problem worse → invert solutions
9. **SCAMPER** - 7 creativity prompts (Substitute, Combine, Adapt, Modify, Put to other use, Eliminate, Reverse)

#### **Process**

```
User: /brainstorming
    ↓
Load project-context-template.md (optional)
    ↓
Select technique(s):
- Single technique deep dive
- Multiple techniques combination
- Agent recommends based on problem type
    ↓
Facilitate session:
- Guide through technique steps
- Capture ideas
- Organize and synthesize
    ↓
Generate report:
- Ideas organized by category
- Recommendations
- Next steps
```

#### **When to Use**

- ✅ New product ideation
- ✅ Feature brainstorming
- ✅ Problem solving
- ✅ Strategic planning
- ✅ Creative exploration

#### **Output Structure**

```markdown
# Brainstorming Report: {Topic}

## Context
[Project context if provided]

## Technique(s) Used
- Mind Mapping
- Five Whys

## Ideas Generated

### Category 1
1. Idea 1 - Description
2. Idea 2 - Description

### Category 2
...

## Synthesis
[Patterns, themes, insights]

## Recommendations
[Top ideas with rationale]

## Next Steps
[Suggested actions]
```

---

### 2.2 Party Mode

**Location**: `_bmad/core/workflows/party-mode/`  
**Files**: 4  
**Purpose**: Orchestrated multi-agent discussions  
**Output**: Discussion summary with synthesized recommendations

#### **File Structure**

```
party-mode/
├── workflow.md                  # Main orchestration
├── agent-selection.md           # How to select agents
├── facilitation-guide.md        # Facilitation patterns
└── README.md
```

#### **How Party Mode Works**

**Concept**: Multiple specialized agents discuss and collaborate on a topic

**Process**:
```
User: /party-mode
    ↓
Define discussion topic
    ↓
Select agents (2-4 agents):
Examples:
- analyst + pm + architect → Requirements alignment
- architect + dev + tea → Technical design review
- pm + sm + dev → Sprint planning
- analyst + ux-designer → User research synthesis
    ↓
Facilitate discussion:
- Each agent contributes from their expertise
- Agent responds in their persona
- Build on each other's points
- Resolve conflicts through dialogue
    ↓
Synthesize outcomes:
- Key decisions
- Action items
- Recommendations
```

#### **Agent Combinations**

**Discovery & Planning**:
- `analyst` + `pm` → Product definition
- `analyst` + `ux-designer` → User research
- `pm` + `ux-designer` → Feature prioritization

**Technical Design**:
- `architect` + `dev` → Architecture review  
- `architect` + `tea` → Testability design
- `dev` + `tea` → Test strategy

**Implementation**:
- `sm` + `dev` → Sprint planning
- `dev` + `tea` → Code + test alignment
- `pm` + `sm` + `dev` → Story refinement

**Quality**:
- `architect` + `dev` + `tea` → ADVERSARIAL design review
- `pm` + `architect` → Implementation readiness

#### **When to Use**

- ✅ Complex decisions needing multiple perspectives
- ✅ Cross-functional alignment
- ✅ Resolving conflicts between perspectives
- ✅ Design reviews
- ✅ Strategic discussions

#### **Best Practices**

✅ **Do**:
- Clear discussion topic
- 2-4 agents (not too many)
- Choose agents with relevant expertise
- Let discussion evolve naturally
- Capture key decisions

❌ **Don't**:
- Too many agents (confusion)
- Agents without relevant expertise
- Force consensus prematurely
- Skip synthesis step

---

### 2.3 Advanced Elicitation

**Location**: `_bmad/core/workflows/advanced-elicitation/`  
**Files**: 2  
**Purpose**: Advanced requirement gathering techniques  
**Output**: Comprehensive requirements document

#### **File Structure**

```
advanced-elicitation/
├── workflow.md
└── techniques.md
```

#### **Elicitation Techniques**

**Interview Techniques**:
- Structured interviews
- Semi-structured exploration
- Contextual inquiry

**Workshop Techniques**:
- JAD (Joint Application Development)
- Focus groups
- Collaborative sketching

**Observational**:
- User shadowing
- Task analysis
- Ethnographic research

#### **When to Use**

- ✅ Complex requirements
- ✅ Multiple stakeholders
- ✅ Unclear needs
- ✅ Before PRD creation

---

## 3️⃣ Core Tasks

### 3.1 workflow.xml - THE EXECUTION ENGINE ⭐

**File**: `_bmad/core/tasks/workflow.xml`  
**Type**: XML-based workflow processor  
**Status**: **CRITICAL INFRASTRUCTURE**  
**Purpose**: Execute `.yaml` workflow configurations

#### **What is workflow.xml?**

**THE CORE OS** for BMAD workflow execution:
- All `.yaml` workflows are executed by workflow.xml
- Separation of concerns: stable engine vs flexible configs
- Handles step sequencing, state management, validation
- Used by ALL workflow handlers in agents

#### **Architecture**

```
Agent menu item:
workflow="path/to/workflow.yaml"
    ↓
Agent handler:
1. LOAD workflow.xml (THE ENGINE)
2. Pass workflow.yaml as config
3. workflow.xml processes the yaml
    ↓
workflow.xml:
- Parses workflow.yaml
- Executes steps sequentially
- Manages state
- Validates transitions
- Handles errors
    ↓
Output: Workflow execution complete
```

#### **Key Responsibilities**

1. **YAML Parsing**: Load and parse workflow.yaml files
2. **Step Execution**: Execute workflow steps in order
3. **State Management**: Track workflow progress
4. **Validation**: Ensure workflow integrity
5. **Error Handling**: Graceful failure recovery
6. **Output Management**: Save outputs per step

#### **Used By**

**ALL** workflows with `workflow` attribute:
- create-prd (workflow.yaml)
- create-architecture (workflow.yaml)
- dev-story (workflow.yaml)
- testarch-* (workflow.yaml)
- document-project (workflow.yaml)
- And more...

#### **Why XML?**

- Stable execution logic
- Clear instruction format for LLMs
- Separation from workflow configs (.yaml)
- Single source of truth for execution

#### **Critical Rules**

From workflow.xml instructions:
1. READ workflow.yaml completely
2. Execute steps sequentially
3. NEVER skip steps
4. Save outputs after EACH step
5. Update state in frontmatter
6. Handle errors gracefully

---

### 3.2 help.md - Intelligent Help System

**File**: `_bmad/core/tasks/help.md`  
**Purpose**: Intelligent routing and next-step suggestions  
**Input**: User question + current project state  
**Output**: Contextual recommendations

#### **How It Works**

```
User: /bmad-help [optional: context]
    ↓
Load help.md instructions
    ↓
Analyze:
- Current project phase (from bmad-help.csv)
- Existing artifacts in _bmad-output/
- User's question/context
    ↓
Load bmad-help.csv:
- Find relevant workflow sequences
- Identify current position
- Determine next recommended steps
    ↓
Provide:
- Current phase explanation
- Next recommended workflows
- Why those workflows
- Alternative paths
```

#### **Intelligence Sources**

1. **bmad-help.csv**: 40 workflow sequences with phase detection
2. **Project artifacts**: What's been created in `_bmad-output/`
3. **User context**: What user is asking about
4. **Agent manifest**: Available agents for task

#### **Example Interactions**

**Example 1**: No artifacts yet
```
User: /bmad-help
Assistant: 
You're at the start! No artifacts found.

Recommended paths:
1. Start with discovery: /create-product-brief or /research
2. Jump to planning: /create-prd
3. Fast path: /quick-dev

What's your goal?
```

**Example 2**: PRD exists, no architecture
```
User: /bmad-help
Assistant:
Found: prd.md ✓

Next step: Solutioning phase
Recommended: /create-architecture

Why? PRD defines WHAT, architecture defines HOW.
After architecture → /create-epics-and-stories
```

**Example 3**: With context
```
User: /bmad-help I need to add tests to my project
Assistant:
Recommended TestArch workflows:
1. /testarch-framework - Setup test infrastructure
2. /testarch-test-design - Plan test strategy
3. /testarch-atdd - Write tests before code

Current phase: Implementation
Agent: tea (Murat - Test Architect)
```

---

### 3.3 Utility Tasks

**Location**: `_bmad/core/tasks/`  
**Count**: 5 utility tasks

#### **3.3.1 bmad-editorial-review-prose.md**

**Purpose**: Clinical copy-editor for communication issues  
**Focus**: Grammar, clarity, tone, readability  
**Output**: Edited text with suggestions

#### **3.3.2 bmad-editorial-review-structure.md**

**Purpose**: Structural editor for organization  
**Focus**: Cuts, reorganization, simplification  
**Output**: Restructuring recommendations

#### **3.3.3 bmad-index-docs.md**

**Purpose**: Generate index.md for directory  
**Process**:
1. Scan directory for .md files
2. Extract titles/descriptions
3. Generate organized index.md
4. Add navigation links

#### **3.3.4 bmad-shard-doc.md**

**Purpose**: Split large markdown into smaller files  
**Input**: Large .md file  
**Output**: Multiple smaller .md files organized by sections  
**Default**: Split on level 2 headings (##)

**Example**:
```
large-doc.md (1000 lines)
    ↓
bmad-shard-doc
    ↓
Output:
├── 01-introduction.md
├── 02-architecture.md
├── 03-implementation.md
└── 04-testing.md
```

#### **3.3.5 bmad-review-adversarial-general.md**

**Purpose**: Cynical ADVERSARIAL review  
**Focus**: Find problems, challenge assumptions  
**Output**: Findings report (must find 3-10 issues)

---

## 4️⃣ Core Resources

**Location**: `_bmad/core/resources/`  
**Files**: 4

### **Templates**

- `template-workflow.yaml` - Workflow YAML template
- `template-step-file.md` - Step-file template
- `example-simple-workflow.md` - Simple workflow example
- `README.md` - Documentation

### **Usage**

For creating custom workflows:
1. Copy template-workflow.yaml
2. Define steps and configuration
3. Reference in agent menu
4. workflow.xml executes it

---

## 🎯 Core Module Integration

### **How Core Enables BMM**

```
BMM Workflows
    ↓
Use workflow.xml engine
    ↓
Reference bmad-help.csv
    ↓
Can trigger party-mode
    ↓
Use brainstorming for discovery
```

### **Universal Availability**

Core workflows accessible from **any agent**:
- All agents have brainstorming menu item
- All agents have party-mode menu item
- All agents can use /bmad-help

### **Execution Flow**

```
Agent Menu Selection
    ↓
Handler checks attribute type:
├── exec="*.md" → Read and follow
└── workflow="*.yaml" → Load workflow.xml → Execute
    ↓
workflow.xml:
- Parse YAML config
- Execute steps
- Save outputs
- Update state
```

---

## 📊 Summary

Core module provides **universal BMAD infrastructure**:

✅ **1 Agent**:
- bmad-master - Orchestrator and facilitator

✅ **3 Workflows** (17 files):
- brainstorming (11 files) - 9 creative techniques
- party-mode (4 files) - Multi-agent discussions
- advanced-elicitation (2 files) - Requirements gathering

✅ **7 Tasks**:
- **workflow.xml** ⭐ - THE EXECUTION ENGINE (CRITICAL)
- help.md - Intelligent routing
- 5 utilities (editorial, index, shard, review)

✅ **Resources**:
- Workflow templates
- Examples

**Key Insights**:
- **workflow.xml is CRITICAL** - All .yaml workflows depend on it
- **Universal tools** - Used across all BMAD modules
- **Orchestration focus** - party-mode, bmad-master enable multi-agent work
- **Stable foundation** - Rarely changes unlike BMM workflows

**Next**: Explore BMM module for specialized agile workflows

---

## 🔗 Related Documentation

- [../04-bmm/](../04-bmm/) - BMM module (specialized workflows)
- [../../02-config/01-manifest-hub.md](../../../02-config/01-manifest-hub.md) - Manifests
- [../README.md](../../README.md) - Advanced documentation navigation
