---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "BMM Supporting Resources"
---

# BMM Supporting Resources

> **Module**: BMM (BMAD Method Module)  
> **Location**: `_bmad/bmm/`  
> **Categories**: 3 resource types  
> **Purpose**: Supporting files for workflows and agents

---

## 📋 Overview

BMM includes supporting resources beyond agents and workflows:

1. **teams/** - Multi-team configurations (2 files)
2. **testarch/** - TestArch knowledge base (35 files)
3. **data/** - Templates and reference data (1 file)

---

## 1️⃣ Teams System

**Location**: `_bmad/bmm/teams/`  
**Files**: 2  
**Purpose**: Multi-team project configurations

### **Files**

| File | Purpose |
|------|---------|
| `teams.template.yaml` | Team configuration template |
| `README.md` | Documentation |

### **Use Case**

For projects with multiple teams (frontend, backend, QA, etc.):
- Define team structure
- Assign responsibilities
- Configure workflows per team
- Team-specific artifacts output

### **Example Structure**

```yaml
# teams.yaml
teams:
  - id: frontend
    name: Frontend Team
    lead: John
    workflows:
      - create-prd
      - create-ux-design
      - dev-story
    output: _bmad-output/teams/frontend/
    
  - id: backend
    name: Backend Team
    lead: Alice
    workflows:
      - create-architecture
      - dev-story
      - testarch-ci
    output: _bmad-output/teams/backend/
```

### **When to Use**

- ✅ Large projects with specialized teams
- ✅ Frontend/Backend separation
- ✅ Microservices architecture
- ✅ Team-specific workflows

---

## 2️⃣ TestArch Knowledge Base

**Location**: `_bmad/bmm/testarch/`  
**Files**: 35  
**Purpose**: Complete testing knowledge for TestArch workflows

### **Categories**

#### **Core Patterns** (~15 files)

**Test Design Patterns**:
- `fixtures.md` - Test fixture patterns
- `data-factories.md` - Test data generation
- `page-objects.md` - Page Object Model
- `test-helpers.md` - Utility functions
- `test-organization.md` - File structure

**Test Types**:
- `unit-testing.md` - Unit test best practices
- `integration-testing.md` - Integration patterns
- `e2e-testing.md` - End-to-end strategies
- `api-testing.md` - API test patterns
- `visual-testing.md` - Visual regression

#### **Advanced Patterns** (~10 files)

**Performance & Reliability**:
- `performance-testing.md` - Load/stress testing
- `flakiness-mitigation.md` - Anti-flake strategies
- `retry-strategies.md` - Smart retry logic
- `parallel-execution.md` - Parallel test execution

**Debugging & Observability**:
- `debugging-techniques.md` - Debug failed tests
- `network-mocking.md` - Network interception
- `timing-strategies.md` - Wait strategies
- `visual-debugging.md` - Screenshots, videos

#### **CI/CD & Quality** (~10 files)

**CI/CD Integration**:
- `ci-pipeline.md` - Pipeline setup
- `test-reporting.md` - Report generation
- `coverage-tracking.md` - Code coverage
- `quality-gates.md` - Pass/fail criteria

**Best Practices**:
- `test-naming.md` - Naming conventions
- `assertion-best-practices.md` - Better assertions
- `test-data-management.md` - Data lifecycle
- `security-testing.md` - Security patterns

### **Usage in Workflows**

TestArch workflows reference these knowledge files:

```
Workflow: testarch-framework
    ↓
References:
- fixtures.md
- page-objects.md
- test-organization.md
    ↓
Generates: Test framework scaffold
```

### **Knowledge Structure**

Each knowledge file follows pattern:
```markdown
# {Pattern Name}

## Overview
[What this pattern does]

## When to Use
[Use cases]

## Implementation
[Code examples]

## Best Practices
[Dos and don'ts]

## Anti-Patterns
[What to avoid]

## Examples
[Real-world examples]
```

### **Key Knowledge Areas**

**For Framework Setup**:
- fixtures.md
- page-objects.md
- test-helpers.md
- test-organization.md

**For Test Design**:
- test-naming.md
- assertion-best-practices.md
- test-data-management.md

**For Reliability**:
- flakiness-mitigation.md
- retry-strategies.md
- timing-strategies.md
- network-mocking.md

**For CI/CD**:
- ci-pipeline.md
- test-reporting.md
- coverage-tracking.md
- quality-gates.md

---

## 3️⃣ Data & Templates

**Location**: `_bmad/bmm/data/`  
**Files**: 1  
**Purpose**: Reference templates and data for workflows

### **Files**

| File | Purpose |
|------|---------|
| `project-context-template.md` | Project context template for brainstorming |

### **Usage**

Used by workflows to gather context:

```
Workflow: brainstorming
    ↓
Load: project-context-template.md
    ↓
User fills:
- Project overview
- Goals
- Constraints
- Stakeholders
    ↓
Context passed to brainstorming session
```

### **Template Structure**

```markdown
# Project Context

## Overview
[Project description]

## Goals
- Goal 1
- Goal 2

## Constraints
- Constraint 1
- Constraint 2

## Stakeholders
- Stakeholder 1: Role
- Stakeholder 2: Role

## Timeline
[Timeline info]

## Additional Context
[Any other relevant info]
```

---

## 🎯 Integration with Workflows

### **Teams + Workflows**

```
Multi-team project:
    ↓
Configure teams.yaml
    ↓
Each team runs workflows:
├── Frontend Team
│   ├── /create-ux-design
│   ├── /dev-story
│   └── Output: teams/frontend/
│
└── Backend Team
    ├── /create-architecture
    ├── /dev-story
    └── Output: teams/backend/
```

### **TestArch Knowledge + Workflows**

```
/testarch-framework
    ↓
Agent loads knowledge:
├── fixtures.md
├── page-objects.md
├── test-organization.md
    ↓
Generates framework:
├── tests/fixtures/
├── tests/pages/
├── tests/helpers/
└── tests/config/
```

### **Data Templates + Workflows**

```
/brainstorming
    ↓
Load: project-context-template.md
    ↓
User provides context
    ↓
Brainstorming session uses context
```

---

## 📊 Statistics

| Resource Type | Files | Purpose |
|---------------|-------|---------|
| **teams/** | 2 | Multi-team configs |
| **testarch/** | 35 | Testing knowledge base |
| **data/** | 1 | Project templates |
| **Total** | 38 | Supporting resources |

---

## 🔗 Related Documentation

- [../01-agents/01-agents-overview.md](../01-agents/01-agents-overview.md) - BMM agents
- [../02-workflows/01-all-bmm-workflows.md](../02-workflows/01-all-bmm-workflows.md) - All workflows
- [../../02-config/01-manifest-hub.md](../../../02-config/01-manifest-hub.md) - Manifests

---

## 📝 Summary

BMM supporting resources provide:

✅ **Teams System** (2 files):
- Multi-team project support
- Team-specific workflows
- Separate output paths

✅ **TestArch Knowledge** (35 files):
- Complete testing patterns
- Framework setup guides
- CI/CD best practices
- Anti-flake strategies

✅ **Data Templates** (1 file):
- Project context template
- Workflow input data

**Key Insight**: These resources enable BMM workflows to be:
- **Scalable** - Teams system supports large projects
- **Knowledge-driven** - TestArch uses 35 knowledge files
- **Structured** - Templates ensure consistency

**Next**: Explore Core module internals
