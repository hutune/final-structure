---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "Advanced BMAD Internals"
---

# Advanced BMAD Internals

**Deep dive into BMAD framework architecture, execution engine, and workflows.**

> **Prerequisites**: Complete getting started and core concepts first  
> **Target audience**: Power users, framework developers, workflow customizers

---

## 📚 Reading Order

### **Level 1: Overview** (Start Here)
- [01-overview/01-bmad-directory-internals.md](01-overview/01-bmad-directory-internals.md) - High-level `_bmad/` structure

### **Level 2: Core Systems**
- [02-config/01-manifest-hub.md](02-config/01-manifest-hub.md) - Manifests, discovery, customization
- 03-core/ - Core module (Coming soon)
- 04-bmm/ - BMM module  (Coming soon)

### **Level 3: Deep Dives**

#### **Core Module** (Coming soon)
**Agents**:
- 03-core/01-agents/01-bmad-master.md - Master orchestrator deep dive

**Workflows**:
- 03-core/02-workflows/01-brainstorming.md - Creative facilitation (11 files)
- 03-core/02-workflows/02-party-mode.md - Multi-agent orchestration (4 files)
- 03-core/02-workflows/03-advanced-elicitation.md - Requirement gathering (2 files)

**Tasks**:
- 03-core/03-tasks/01-workflow-engine.md - ⭐ **workflow.xml execution engine** (CRITICAL)
- 03-core/03-tasks/02-help-system.md - Intelligent routing system
- 03-core/03-tasks/03-utility-tasks.md - Editorial, index, shard, review

**Resources**:
- 03-core/04-resources/01-templates-examples.md

---

#### **BMM Module** (In progress)

**Agents** (10 files):
- 04-bmm/01-agents/01-agents-overview.md - Compare all 9 agents
- 04-bmm/01-agents/02-analyst.md - Mary (Business Analyst)
- 04-bmm/01-agents/03-architect.md - Winston (System Architect)
- 04-bmm/01-agents/04-dev.md - Amelia (Developer)
- 04-bmm/01-agents/05-pm.md - John (Product Manager)
- 04-bmm/01-agents/06-sm.md - Bob (Scrum Master)
- 04-bmm/01-agents/07-tea.md - Murat (Test Architect)
- 04-bmm/01-agents/08-ux-designer.md - Sally (UX Designer)
- 04-bmm/01-agents/09-tech-writer.md - Paige (Technical Writer)
- 04-bmm/01-agents/10-quick-flow-solo-dev.md - Barry (Quick Flow Dev)

**Workflows by Phase**:

*Phase 1: Analysis*
- 04-bmm/02-workflows/01-analysis/01-create-product-brief.md
- 04-bmm/02-workflows/01-analysis/02-research.md - Market/Technical/Domain

*Phase 2: Planning*
- 04-bmm/02-workflows/02-planning/01-create-prd.md - Tri-modal, step-file architecture
- 04-bmm/02-workflows/02-planning/02-create-ux-design.md

*Phase 3: Solutioning*
- 04-bmm/02-workflows/03-solutioning/01-create-architecture.md
- 04-bmm/02-workflows/03-solutioning/02-create-epics-stories.md
- 04-bmm/02-workflows/03-solutioning/03-check-readiness.md - ADVERSARIAL quality gate

*Phase 4: Implementation*
- 04-bmm/02-workflows/04-implementation/01-sprint-planning.md
- 04-bmm/02-workflows/04-implementation/02-create-story.md
- 04-bmm/02-workflows/04-implementation/03-dev-story.md
- 04-bmm/02-workflows/04-implementation/04-code-review.md - ADVERSARIAL review
- 04-bmm/02-workflows/04-implementation/05-sprint-status.md
- 04-bmm/02-workflows/04-implementation/06-correct-course.md
- 04-bmm/02-workflows/04-implementation/07-retrospective.md

*Specialized Workflows*:
- 04-bmm/02-workflows/05-quick-flow/ - Fast path (2 files)
- 04-bmm/02-workflows/06-testarch/ - Complete TestArch guide (8 files)
- 04-bmm/02-workflows/07-excalidraw/ - Visual documentation (4 files)
- 04-bmm/02-workflows/08-document-project/ - Brownfield onboarding (2 files)

**Supporting Resources**:
- 04-bmm/03-teams/01-team-system.md - Multi-team configurations
- 04-bmm/04-testarch-knowledge/ - TestArch patterns (3 files)
- 04-bmm/05-data-templates/01-templates-data.md

---

## 🗺️ Navigation Map

Maps `_bmad/` directory structure to documentation:

```
_bmad/
├── _config/         → 02-config/01-manifest-hub.md
│
├── core/
│   ├── agents/      → 03-core/01-agents/
│   ├── workflows/   → 03-core/02-workflows/
│   ├── tasks/       → 03-core/03-tasks/
│   └── resources/   → 03-core/04-resources/
│
└── bmm/
    ├── agents/      → 04-bmm/01-agents/
    ├── workflows/   → 04-bmm/02-workflows/
    ├── teams/       → 04-bmm/03-teams/
    ├── testarch/    → 04-bmm/04-testarch-knowledge/
    └── data/        → 04-bmm/05-data-templates/
```

---

## 🎯 Quick Access

**Want to understand**:
- **How workflows execute?** → 03-core/03-tasks/01-workflow-engine.md
- **How agents work?** → 04-bmm/01-agents/01-agents-overview.md
- **How help system routes?** → 03-core/03-tasks/02-help-system.md
- **How PRD workflow works?** → 04-bmm/02-workflows/02-planning/01-create-prd.md
- **How testing works?** → 04-bmm/02-workflows/06-testarch/
- **All manifests?** → 02-config/01-manifest-hub.md

---

## 📊 Documentation Stats

| Module | Files | Status |
|--------|-------|--------|
| Overview | 1 | ✅ Complete |
| Config | 1 | ✅ Complete |
| Core | 1 | ✅ Complete |
| BMM | 3 | ✅ Complete |

**Total**: 6 documentation files

---

## 🔗 Related Documentation

- [../README.md](../README.md) - Main documentation index
- [../01-getting-started/01-bmad-quickstart.md](../01-getting-started/01-bmad-quickstart.md) - Start here if new
- [../02-core-concepts/](../02-core-concepts/) - Core concepts
- [../03-workflows/01-all-workflows.md](../03-workflows/01-all-workflows.md) - User-facing workflow guide
