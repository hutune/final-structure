---
clickup_workspace_id: "90182277854"
clickup_doc_id: "2kzmgppy-1918"
clickup_root_page_id: "2kzmgppy-2218"
type: "doc"
title: "RMN Platform Overview"
---

# RMN Platform

> **AI-Driven Development Platform with BMAD Method & ClickUp Integration**

A modern development platform combining AI-assisted workflows, automated project management, and comprehensive documentation practices for building scalable web and mobile applications.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Development Workflow](#-development-workflow)
- [Documentation](#-documentation)
- [Key Features](#-key-features)
- [Team](#-team)
- [Contributing](#-contributing)
- [Support](#-support)

---

## 🎯 Overview

**RMN Platform** is an enterprise-ready development environment designed for **efficient, AI-assisted software development** using the **BMAD Method** (Breakthrough Method of Agile AI-Driven Development). 

The platform integrates:
- ✅ **47 AI-powered workflows** for end-to-end SDLC
- ✅ **Automated ClickUp synchronization** for tasks and documentation
- ✅ **Multi-agent AI system** with specialized roles (PM, Architect, Dev, QA, UX)
- ✅ **Structured documentation** with auto-sync to knowledge base
- ✅ **CI/CD automation** via GitHub Actions

**Key Benefits:**
- Reduce planning overhead by 70% with AI-guided workflows
- Maintain single source of truth across GitHub and ClickUp
- Accelerate development with context-aware AI assistance
- Ensure quality with automated review and testing workflows

---

## 📊 Tech Stack

| Category | Technologies |
|----------|-------------|
| **Frontend** | Flutter Web |
| **Backend** | Golang, Kubernetes, OpenAPI |
| **AI/Automation** | BMAD Method (47 workflows), Claude Code, 10 Specialized Agents |
| **Project Management** | ClickUp (Task & Doc Sync) |
| **CI/CD** | GitHub Actions |
| **Development** | Node.js ≥18, Python ≥3.9 |
| **Collaboration** | Google Drive, GitHub, VS Code |

---

## 🚀 Quick Start

### Prerequisites
- VS Code with [Claude Code](https://marketplace.visualstudio.com/items?itemName=Anthropic.claude) extension
- Git configured with your credentials
- Node.js ≥18 and Python ≥3.9
- Access to ClickUp workspace (ID: `90182277854`)

### For New Team Members

**Step 1: Clone and Configure**
```bash
# Clone repository
git clone https://github.com/hutune/demo-structure.git
cd demo-structure

# Configure Git
git config user.name "Your Name"
git config user.email "your.email@kwayvina.com"
```

**Step 2: Read Essential Docs**
1. 📖 [Developer Setup Guide](docs/team-processes/developer-setup-guide.md) - Complete onboarding
2. 🔄 [ClickUp Workflow Guide](docs/team-processes/clickup-workflow-guide.md) - ClickUp integration
3. 🏗️ [Tech Specs](docs/tech-specs/) - Architecture decisions
4. 🤖 [BMAD Onboarding](docs/bmad_onboarding/) - AI workflow deep dive

**Step 3: Verify Setup**
```bash
# Test BMAD commands (in VS Code)
# Type '@bmad-' in command palette to see all 47 workflows
```

### For Existing Team Members

Start working immediately with BMAD workflows:
```bash
# Planning
@bmad-bmm-create-prd           # Create Product Requirements
@bmad-bmm-create-architecture  # Design Architecture

# Development
@bmad-bmm-dev-story            # Implement user story
@bmad-bmm-code-review          # AI code review

# Quality
@testarch-test-design          # Test planning
@testarch-trace                # Coverage analysis
```

---

## 📂 Project Structure

```
RMN/
│
├── .agent/                         # BMAD Method Infrastructure
│   └── workflows/                  # 47 development workflows
│       ├── bmad-bmm-*.md           # Core BMAD workflows
│       ├── create-*.md             # Creation workflows (PRD, Architecture, etc.)
│       ├── dev-*.md                # Development workflows
│       └── testarch-*.md           # Testing & quality workflows
│
├── .claude/                        # Claude Code Configuration
│   ├── PROJECT-CONFIG.md           # Project context for AI
│   ├── agents/                     # Specialized AI agents (1)
│   ├── commands/                   # Custom commands
│   ├── hooks/                      # Automation hooks
│   ├── scripts/                    # Helper scripts
│   └── skills/                     # Reusable AI skills
│
├── .github/                        # GitHub Configuration
│   ├── workflows/                  # CI/CD Automation
│   │   ├── sync-clickup-docs.yml   # Auto-sync docs to ClickUp
│   │   └── sync-clickup-tasks.yml  # Auto-sync tasks to ClickUp
│   └── scripts/                    # CI helper scripts
│       └── sync-docs.sh            # Doc sync script
│
├── _bmad/                          # BMAD Framework Core (303 files)
│   ├── agents/                     # 10 specialized agents
│   ├── workflows/                  # Workflow implementations
│   ├── templates/                  # Document templates
│   └── skills/                     # Reusable capabilities
│
├── _bmad-output/                   # Generated Artifacts
│   ├── epics/                      # Product epics (auto-synced)
│   ├── stories/                    # User stories (auto-synced)
│   ├── planning-artifacts/         # Architecture docs, PRDs
│   ├── implementation-artifacts/   # Tech specs, designs
│   ├── reports/                    # Quality reports, retrospectives
│   └── templates/                  # Output templates (3 files)
│       ├── epic-template.md
│       ├── story-template.md
│       └── report-template.md
│
├── docs/                           # Project Documentation
│   ├── team-processes/             # Process & Workflow Guides (5 docs)
│   │   ├── developer-setup-guide.md
│   │   ├── clickup-workflow-guide.md
│   │   ├── clickup-api-reference.md
│   │   ├── tasks-api-examples.md
│   │   └── test-automation-guide.md
│   │
│   ├── tech-specs/                 # Technical Specifications
│   │   └── [Architecture decisions, API specs, etc.]
│   │
│   └── bmad_onboarding/            # BMAD Framework Docs (13 docs)
│       └── [Deep dive into BMAD workflows and agents]
│
├── src/                            # Source Code (Future)
│   ├── backend/                    # Golang backend
│   ├── frontend/                   # Flutter web
│   └── shared/                     # Shared libraries
│
├── .gitignore                      # Git ignore rules
└── README.md                       # This file
```

### Key Directories Explained

| Directory | Purpose | Auto-Generated | Synced to ClickUp |
|-----------|---------|----------------|-------------------|
| `.agent/workflows/` | BMAD workflow definitions | ❌ | ❌ |
| `.claude/` | AI configuration & context | ❌ | ❌ |
| `.github/workflows/` | CI/CD automation | ❌ | ❌ |
| `_bmad/` | BMAD framework core | ❌ | ❌ |
| `_bmad-output/epics/` | Product epics | ✅ | ✅ (Tasks) |
| `_bmad-output/stories/` | User stories | ✅ | ✅ (Tasks) |
| `_bmad-output/planning-artifacts/` | PRDs, Architecture | ✅ | ❌ |
| `_bmad-output/implementation-artifacts/` | Tech specs, designs | ✅ | ❌ |
| `docs/team-processes/` | Process guides | ❌ | ✅ (Docs) |
| `docs/tech-specs/` | Technical specs | ❌ | ✅ (Docs) |
| `docs/bmad_onboarding/` | BMAD learning | ❌ | ❌ |

---

## 🔄 Development Workflow

### Phase 1: Planning & Design

```bash
# 1. Create Product Requirements Document
@bmad-bmm-create-prd
# → Generates: _bmad-output/planning-artifacts/prd.md

# 2. Design System Architecture
@bmad-bmm-create-architecture
# → Generates: _bmad-output/planning-artifacts/architecture.md

# 3. Create UX Design (if UI exists)
@bmad-bmm-create-ux-design
# → Generates: _bmad-output/planning-artifacts/ux-design.md

# 4. Break Down into Epics & Stories
@bmad-bmm-create-epics-and-stories
# → Generates: _bmad-output/epics/*.md, _bmad-output/stories/*.md
```

### Phase 2: Implementation

```bash
# 1. Implement a User Story
@bmad-bmm-dev-story
# → Follows story acceptance criteria
# → Creates code, tests, documentation

# 2. Run AI Code Review
@bmad-bmm-code-review
# → Adversarial review finding 3-10 issues
# → Can auto-fix with approval

# 3. Test Planning & Execution
@testarch-test-design          # Design test strategy
@testarch-atdd                 # Create acceptance tests
@testarch-automate             # Expand test coverage
```

### Phase 3: Quality & Release

```bash
# 1. Coverage Analysis
@testarch-trace
# → Generates traceability matrix
# → Quality gate decision (PASS/FAIL)

# 2. Non-Functional Testing
@testarch-nfr
# → Performance, security, reliability checks

# 3. CI/CD Quality Pipeline
@testarch-ci
# → Configure automated testing in CI/CD
```

### Phase 4: Continuous Sync (Automatic)

```bash
# Commit and push changes
git add .
git commit -m "feat: Add user authentication module"
git push origin main

# GitHub Actions automatically:
# ✅ Syncs tasks (_bmad-output/epics/*.md, stories/*.md) to ClickUp
# ✅ Syncs docs (README.md, docs/**/*.md) to ClickUp Docs
# ✅ Updates status, assignees, tags, dates
# ✅ Writes back doc IDs to frontmatter
```

**Sync Details:**
- **Tasks Sync** (`.github/workflows/sync-clickup-tasks.yml`)
  - Epic/Story files → ClickUp Tasks
  - Full field mapping: status, priority, dates, tags, assignees
  - Comments → Activity panel
  - Attachments & checklists supported
  
- **Docs Sync** (`.github/workflows/sync-clickup-docs.yml`)
  - `README.md` → Standalone Doc "RMN Platform Overview"
  - `docs/team-processes/*.md` → Pages in "Team Processes" Doc
  - `docs/tech-specs/*.md` → Pages in "Tech Specs & Architecture" Doc
  - Nested pages with unlimited hierarchy

---

## 📖 Documentation

### Core Documentation

| Document | Purpose | Location | Synced to ClickUp |
|----------|---------|----------|-------------------|
| **Project Overview** | This file, high-level intro | [README.md](README.md) | ✅ Standalone Doc |
| **Developer Setup** | Complete onboarding guide | [developer-setup-guide.md](docs/team-processes/developer-setup-guide.md) | ✅ Team Processes |
| **ClickUp Workflow** | ClickUp integration guide | [clickup-workflow-guide.md](docs/team-processes/clickup-workflow-guide.md) | ✅ Team Processes |
| **ClickUp API Reference** | API endpoints & examples | [clickup-api-reference.md](docs/team-processes/clickup-api-reference.md) | ✅ Team Processes |
| **Task API Examples** | Task sync examples | [tasks-api-examples.md](docs/team-processes/tasks-api-examples.md) | ✅ Team Processes |
| **Test Automation Guide** | Testing best practices | [test-automation-guide.md](docs/team-processes/test-automation-guide.md) | ✅ Team Processes |

### Technical Specifications

| Category | Location | Description |
|----------|----------|-------------|
| **Architecture Decisions** | [docs/tech-specs/](docs/tech-specs/) | System architecture, design patterns |
| **API Specifications** | [docs/tech-specs/](docs/tech-specs/) | OpenAPI specs, API contracts |
| **Planning Artifacts** | [_bmad-output/planning-artifacts/](/_bmad-output/planning-artifacts/) | PRDs, architecture docs, UX designs |
| **Implementation Specs** | [_bmad-output/implementation-artifacts/](/_bmad-output/implementation-artifacts/) | Tech specs, detailed designs |

### BMAD Framework Docs

| Resource | Location | Description |
|----------|----------|-------------|
| **BMAD Onboarding** | [docs/bmad_onboarding/](docs/bmad_onboarding/) | 13 guides on BMAD workflows |
| **Workflow Catalog** | [.agent/workflows/](.agent/workflows/) | All 47 workflow definitions |
| **Agent Specifications** | [_bmad/agents/](_bmad/agents/) | 10 specialized AI agents |

---

## 🔑 Key Features

### 1. Automated ClickUp Integration

#### 📋 Tasks Sync
Automatically syncs epics and stories from GitHub to ClickUp.

**Features:**
- ✅ **Bidirectional sync** - Changes in Git reflect in ClickUp
- ✅ **Full field mapping** - Status, priority, dates, tags, assignees, custom fields
- ✅ **Smart comments** - Sync to Activity panel (not description)
- ✅ **Checklists & attachments** - Full support
- ✅ **Zero manual work** - Runs on every push

**Workflow:**
```
1. Create/update epic or story in _bmad-output/epics/ or stories/
2. Commit and push to GitHub
3. GitHub Action runs sync-clickup-tasks.yml
4. Epic/Story appears/updates in ClickUp automatically
```

#### 📚 Docs Sync
Automatically syncs markdown documentation to ClickUp Docs.

**Features:**
- ✅ **Standalone docs** - README.md → Project Overview Doc
- ✅ **Nested pages** - Directory structure → ClickUp page hierarchy
- ✅ **Unlimited depth** - Support for deep nesting
- ✅ **Auto ID management** - Page IDs written back to frontmatter
- ✅ **Content conversion** - Markdown → ClickUp format

**Workflow:**
```
1. Edit documentation in docs/team-processes/ or docs/tech-specs/
2. Commit and push to GitHub
3. GitHub Action runs sync-clickup-docs.yml
4. Documentation updates in ClickUp automatically
```

**Synced Documentation Map:**
```
GitHub                              ClickUp
──────────────────────────────────────────────────────────────
README.md                     →     Standalone Doc "RMN Platform Overview"
docs/team-processes/*.md      →     Pages in "Team Processes" Doc
docs/tech-specs/*.md          →     Pages in "Tech Specs & Architecture" Doc
```

### 2. AI-Powered Development

#### 47 BMAD Workflows
Comprehensive AI workflows covering the entire SDLC:

**Category Breakdown:**
- **Planning** (8 workflows): PRD, Architecture, UX Design, Epics/Stories
- **Development** (12 workflows): Story implementation, code review, technical specs
- **Testing** (10 workflows): Test design, ATDD, automation, coverage analysis
- **Quality** (7 workflows): NFR testing, CI/CD setup, traceability
- **Collaboration** (6 workflows): Retrospectives, documentation, research
- **Utilities** (4 workflows): Party mode, quick flows, course correction

#### 10 Specialized Agents
Each agent has domain expertise:

| Agent | Role | Key Capabilities |
|-------|------|------------------|
| `@analyst` | Business Analyst | Requirements gathering, PRD creation |
| `@architect` | Solution Architect | System design, architecture decisions |
| `@pm` | Product Manager | Roadmap planning, prioritization |
| `@sm` | Scrum Master | Sprint planning, retrospectives |
| `@dev` | Senior Developer | Code implementation, architecture |
| `@ux-designer` | UX Designer | UI/UX design, user flows |
| `@tea` | Test Engineer | Test strategy, quality assurance |
| `@tech-writer` | Technical Writer | Documentation, API specs |
| `@bmad-master` | BMAD Expert | Framework guidance, workflow selection |
| `@quick-flow-solo-dev` | Full-Stack Dev | Rapid prototyping, quick implementations |

#### Continuous Learning
- Context accumulation across conversations
- Project-specific knowledge base
- Pattern recognition from past work

### 3. Structured Documentation

**Three-Tier Documentation Architecture:**
1. **Team Processes** - How we work (workflows, guides)
2. **Tech Specs** - What we build (architecture, APIs)
3. **BMAD Framework** - How AI assists (workflow guides)

**Benefits:**
- Single source of truth in Git
- Auto-sync to ClickUp for visibility
- Version controlled documentation
- Easy onboarding for new team members

### 4. Quality Automation

**Built-in Quality Gates:**
- ✅ Automated code review (adversarial, finds 3-10 issues)
- ✅ Test coverage tracking with traceability matrix
- ✅ NFR validation (performance, security, reliability)
- ✅ CI/CD quality pipelines
- ✅ Pre-implementation readiness checks

---

## 🤝 Team

### Current Team Members

| Name | Role | Email | ClickUp ID | GitHub |
|------|------|-------|------------|--------|
| **Mazh Nguyen** | BA/PM/SM | work.huutrung@gmail.com | 300697285 | - |
| **Leo** | Developer | leonkenzo1997@gmail.com | 107577458 | - |
| **Eric Bae** | Owner/Manager | eric@devcrane.com | 55771542 | - |

### Roles & Responsibilities

**Mazh Nguyen** (BA/PM/SM)
- Product requirements and backlog management
- Sprint planning and facilitation
- Stakeholder communication
- ClickUp workspace administration

**Leo** (Developer)
- Feature implementation
- Code reviews
- Technical documentation
- Testing and quality assurance

**Eric Bae** (Owner/Manager)
- Strategic direction
- Resource allocation
- Final approvals
- External partnerships

---

## 🛠️ Tools & Technologies

### Development Environment
- **IDE**: VS Code with Claude Code extension
- **Languages**: Go (backend), Dart/Flutter (frontend)
- **Version Control**: Git, GitHub CLI
- **Runtime**: Node.js ≥18, Python ≥3.9

### Project Management
- **Task Management**: ClickUp (Workspace: `90182277854`)
- **Documentation**: ClickUp Docs (auto-synced from Git)
- **Collaboration**: Google Drive, GitHub Discussions

### Automation & CI/CD
- **CI/CD**: GitHub Actions
- **Task Sync**: `.github/workflows/sync-clickup-tasks.yml`
- **Docs Sync**: `.github/workflows/sync-clickup-docs.yml`

### AI & Development Acceleration
- **BMAD Method**: 47 workflows, 10 specialized agents
- **Claude Code**: Context-aware AI assistance
- **Custom Skills**: Reusable AI capabilities in `.claude/skills/`

---

## 🤝 Contributing

### Workflow for Team Members

1. **Pick a Story**
   - Review sprint backlog in ClickUp
   - Assign story to yourself
   - Move to "In Progress"

2. **Implement with AI**
   ```bash
   @bmad-bmm-dev-story
   # Follow workflow prompts
   ```

3. **Code Review**
   ```bash
   @bmad-bmm-code-review
   # Address findings, auto-fix if approved
   ```

4. **Commit & Sync**
   ```bash
   git add .
   git commit -m "feat: [Story title]"
   git push origin main
   # Auto-syncs to ClickUp
   ```

5. **Update Story**
   - Mark as "Complete" in ClickUp
   - Add completion notes

### Coding Standards
- Follow [Tech Specs](docs/tech-specs/) architecture decisions
- Write tests for all new features (see [test-automation-guide.md](docs/team-processes/test-automation-guide.md))
- Document public APIs with OpenAPI specs
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`

### Documentation Standards
- All docs in markdown with YAML frontmatter
- Update relevant docs when changing code
- Sync docs by committing to `docs/` directory
- Use clear headers, tables, and examples

---

## 📞 Support

### Getting Help

**For Technical Issues:**
- 📝 [GitHub Issues](https://github.com/hutune/demo-structure/issues)
- 📖 [Developer Setup Guide](docs/team-processes/developer-setup-guide.md)
- 🤖 Ask `@bmad-master` for workflow guidance

**For Project Questions:**
- 💬 Team Chat: [Your communication channel]
- 📧 Email: work.huutrung@gmail.com
- 📋 ClickUp: [Workspace 90182277854](https://app.clickup.com/90182277854)

**For BMAD Framework:**
- 📚 [BMAD Onboarding](docs/bmad_onboarding/)
- 🔍 Use `@bmad-help` workflow for context-specific guidance
- 💡 Ask any AI agent with `@agent-name`

### Emergency Contacts
- **Admin**: Mazh Nguyen (work.huutrung@gmail.com)
- **Owner**: Eric Bae (eric@devcrane.com)

---

## 📄 License

**Proprietary** - All Rights Reserved  
© 2026 KwayVina - RMN Platform

---

## 📌 Project Metadata

| Property | Value |
|----------|-------|
| **Project Name** | RMN Platform |
| **Version** | 1.0.0 |
| **Status** | Active Development |
| **Created** | January 2026 |
| **Last Updated** | January 29, 2026 |
| **Maintainer** | Mazh Nguyen (work.huutrung@gmail.com) |
| **ClickUp Workspace** | 90182277854 |
| **Repository** | [hutune/demo-structure](https://github.com/hutune/demo-structure) |
| **BMAD Version** | 6.0.0-alpha.23 |

---

**Made with 🤖 AI-Powered Development** | **Managed with ClickUp** | **Built with BMAD Method**
