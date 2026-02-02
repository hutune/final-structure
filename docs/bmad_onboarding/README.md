---
clickup_workspace_id: "90182277854"
type: "doc"
title: "BMAD Onboarding"
---

# BMAD Method - Tài Liệu Hướng Dẫn

> **Tài liệu học tập về BMAD Method** - Framework phát triển phần mềm theo phương pháp Agile AI-Driven Development

---

## 📚 Hướng Dẫn Đọc

### **🎯 Bạn Là Ai?**

#### **👶 Người Mới Bắt Đầu** (Chưa biết gì về BMAD)
**Đọc theo thứ tự**:
```
1. 01-getting-started/01-bmad-quickstart.md     ← BẮT ĐẦU Ở ĐÂY
2. 02-core-concepts/01-folder-structure.md
3. 02-core-concepts/02-file-formats.md
4. 03-workflows/01-all-workflows.md
```

#### **💼 Developer** (Muốn sử dụng BMAD cho project)
**Đọc nhanh**:
```
1. 02-core-concepts/01-folder-structure.md      ← Hiểu cấu trúc
2. 03-workflows/01-all-workflows.md             ← Xem workflows available
3. 02-core-concepts/03-output-artifacts.md      ← Biết output ở đâu
```

#### **🔧 Advanced User** (Muốn customize hoặc hiểu sâu)
**Focus vào**:
```
1. 02-core-concepts/02-file-formats.md          ← Hiểu architecture
2. 04-advanced/ (khi có)                        ← Deep dive topics
```

---

## 📂 Cấu Trúc Tài Liệu

### **01-getting-started/** - Bắt Đầu Với BMAD
Dành cho người mới, giải thích BMAD là gì và cách bắt đầu.

| File | Mô Tả | Thời Gian Đọc |
|------|-------|---------------|
| `01-bmad-quickstart.md` | Giới thiệu tổng quan và quick start guide | 10 phút |

**Bạn sẽ học được**:
- BMAD Method là gì?
- Cài đặt như thế nào?
- Workflow đầu tiên
- Các khái niệm cơ bản

---

### **02-core-concepts/** - Kiến Thức Cơ Bản
Hiểu rõ về cấu trúc, file formats, và cách BMAD hoạt động.

| File | Mô Tả | Thời Gian Đọc |
|------|-------|---------------|
| `01-folder-structure.md` | Cấu trúc folder `.agent/`, `_bmad/`, `_bmad-output/` | 15 phút |
| `02-file-formats.md` | YAML, Markdown, CSV, XML - Tại sao dùng format nào? | 20 phút |
| `03-output-artifacts.md` | Output folder structure và workflow outputs | 15 phút |

**Bạn sẽ học được**:
- 3 thư mục chính: `.agent/`, `_bmad/`, `_bmad-output/`
- Tại sao có nhiều file formats khác nhau
- Mỗi workflow tạo output gì, ở đâu
- Core vs BMM module architecture

---

### **03-workflows/** - Workflows Chi Tiết
Comprehensive guide về tất cả 47 workflows available.

| File | Mô Tả | Thời Gian Đọc |
|------|-------|---------------|
| `01-all-workflows.md` | Chi tiết 47 workflows, phân loại theo category | 30-45 phút |

**Bạn sẽ học được**:
- 8 categories workflows
- Khi nào dùng workflow nào
- Quick Flow vs Full Planning Path
- Quality gates và best practices

**Categories**:
1. Universal Tools (7) - help, brainstorming, party-mode...
2. Agents (10) - pm, architect, dev, ux-designer...
3. Discovery (2) - product-brief, research
4. Planning (3) - prd, ux-design
5. Solutioning (3) - architecture, epics-stories
6. Implementation (7) - sprint-planning, dev-story, code-review
7. TestArch (8) - framework, atdd, automate, nfr
8. Excalidraw (4) - diagrams

---

### **04-advanced/** - Chủ Đề Nâng Cao
Deep dive vào BMAD internals, architecture, và customization.

| Category | Files | Description |
|----------|-------|-------------|
| **Overview** | 1 | High-level `_bmad/` structure |
| **Config** | 1 | Manifest hub (7 manifests, customization) |
| **Core** | 1 | ✅ Core module complete |
| **BMM** | 3 | ✅ BMM module complete |

**BMM Module Documentation**:
- [04-bmm/01-agents/01-agents-overview.md](04-advanced/04-bmm/01-agents/01-agents-overview.md) - All 9 agents (~30KB)
- [04-bmm/02-workflows/01-all-bmm-workflows.md](04-advanced/04-bmm/02-workflows/01-all-bmm-workflows.md) - 8 categories, 206 files (~50KB)
- [04-bmm/03-supporting-resources.md](04-advanced/04-bmm/03-supporting-resources.md) - Teams, TestArch knowledge, data

**Core Module Documentation**:
- [03-core/01-core-module-reference.md](04-advanced/03-core/01-core-module-reference.md) - bmad-master, workflows, workflow.xml engine, tasks (~25KB)

**Bạn sẽ học được**:

**Overview** (01-overview/):
- `_bmad/` structure: `_config/`, `core/`, `bmm/`
- Module comparison và statistics
- Architectural patterns overview

**Config** (02-config/):
- **7 Manifests chi tiết**:
  - `manifest.yaml` - Installation tracking
  - `agent-manifest.csv` - 11 agents with full personalities
  - `workflow-manifest.csv` - 32 workflows catalog
  - `task-manifest.csv` - 7 tasks including workflow.xml engine
  - **`bmad-help.csv`** - 40 workflow sequences, phase detection, intelligent routing
  - `files-manifest.csv` - 282 files integrity tracking
  - `tool-manifest.csv` - Tool integrations
- **Customization system**: 
  - `agents/` - Per-agent customization (memories, menu, persona override)
  - `custom/` - User extensions
- **Practical examples**: Custom workflows, agent personalities, multi-module projects

**Core Module** (03-core/):
- **bmad-master agent** - Master orchestrator and multi-agent facilitator
- **3 Core Workflows**:
  - brainstorming (11 files) - 9 creative techniques (Mind Mapping, SCAMPER, Five Whys, etc.)
  - party-mode (4 files) - Multi-agent orchestrated discussions
  - advanced-elicitation (2 files) - Advanced requirement gathering
- **⭐ workflow.xml** - THE EXECUTION ENGINE for all .yaml workflows (CRITICAL)
- **help.md** - Intelligent routing system using bmad-help.csv
- **5 Utility Tasks**: Editorial review, index generation, document sharding, ADVERSARIAL review

**BMM Module** (04-bmm/):
- **9 Agents** với complete personas:
  - analyst 📊 (Mary) - Treasure hunter discovery
  - architect 🏗️ (Winston) - Pragmatic system design
  - dev 💻 (Amelia) - Ultra-succinct TDD
  - pm 📋 (John) - Relentless "WHY?" questioner
  - sm 🏃 (Bob) - Checklist-driven scrum master
  - tea 🧪 (Murat) - Risk-based testing
  - ux-designer 🎨 (Sally) - Empathetic storyteller
  - tech-writer 📚 (Paige) - Patient educator
  - quick-flow-solo-dev 🚀 (Barry) - Minimal ceremony
- **8 Workflow Categories** (206 files total):
  - Analysis (30 files): brief, research
  - Planning (55 files): PRD (tri-modal), UX design
  - Solutioning (27 files): architecture, stories, readiness
  - Implementation (21 files): sprint, dev, review
  - Quick Flow (13 files): fast path
  - TestArch (33 files): complete testing suite
  - Excalidraw (14 files): visual docs
  - Document Project (13 files): brownfield
- **Supporting Resources**: Teams system, TestArch knowledge (35 files), templates


---

### **05-references/** - Tài Liệu Tham Khảo
Best practices và commands reference.

| File | Mô Tả | Thời Gian Đọc |
|------|-------|---------------|
| `01-best-practices-by-role.md` | Best practices cho từng role (PM, Dev, Architect, etc.) | 10 phút |
| `02-commands-reference.md` | Tất cả commands với phases và use cases | 15 phút |

**Bạn sẽ học được**:
- Best practices cho từng role trong team
- Danh sách đầy đủ tất cả commands
- Khi nào dùng command nào

---

## 🚀 Quick Start

### **Nếu Bạn Chỉ Có 5 Phút**

Đọc phần này để hiểu BMAD ở high level:

#### **BMAD Method là gì?**
- AI-driven agile development framework
- 47 workflows qua 4 phases: Discovery → Planning → Solutioning → Implementation
- 10 specialized AI agents (PM, Architect, Dev, UX, etc.)
- 100% free and open source

#### **Cấu trúc cơ bản**
```
Project/
├── .agent/           # AI IDE integration shortcuts
├── _bmad/            # Core framework (workflows, agents, config)
└── _bmad-output/     # All your project artifacts
```

#### **Workflow đầu tiên**
```bash
# Need help?
/bmad-help

# Quick feature development:
/quick-spec → /quick-dev → /code-review

# Full project planning:
/create-product-brief → /create-prd → /create-architecture
```

---

## 📖 Learning Paths

### **Path 1: Fast Track** (30 phút)
Nhanh chóng hiểu và bắt đầu dùng BMAD.

```
1. README.md (this file) - 5 min
2. 01-getting-started/01-bmad-quickstart.md - 10 min
3. 03-workflows/01-all-workflows.md (skim) - 15 min
```

**Outcome**: Biết BMAD workflow nào dùng cho task của bạn.

---

### **Path 2: Comprehensive** (90 phút)
Hiểu sâu về BMAD architecture và workflows.

```
1. 01-getting-started/01-bmad-quickstart.md - 10 min
2. 02-core-concepts/01-folder-structure.md - 15 min
3. 02-core-concepts/02-file-formats.md - 20 min
4. 02-core-concepts/03-output-artifacts.md - 15 min
5. 03-workflows/01-all-workflows.md - 30 min
```

**Outcome**: Hiểu rõ BMAD architecture và có thể customize.

---

### **Path 3: Just-in-Time** (Học khi cần)
Đọc từng phần khi gặp câu hỏi cụ thể.

**Questions → Files**:

| Câu Hỏi | Đọc File |
|---------|----------|
| "BMAD là gì?" | `01-getting-started/01-bmad-quickstart.md` |
| "Tại sao có folder `.agent/`, `_bmad/`?" | `02-core-concepts/01-folder-structure.md` |
| "Tại sao lúc YAML lúc Markdown?" | `02-core-concepts/02-file-formats.md` |
| "Output của workflow ở đâu?" | `02-core-concepts/03-output-artifacts.md` |
| "Có workflow nào cho X?" | `03-workflows/01-all-workflows.md` |
| "Tại sao core chỉ có 1 agent?" | `02-core-concepts/02-file-formats.md` |

---

## 🎓 Key Concepts Cheat Sheet

### **3 Thư Mục Chính**
- **`.agent/`** = Shortcuts cho AI IDE (47 files)
- **`_bmad/`** = Framework logic (core + modules)
- **`_bmad-output/`** = Your project artifacts

### **4 File Formats**
- **`.yaml`** = Configuration & structured workflows
- **`.md`** = Documentation & complex workflows
- **`.csv`** = Manifests & catalogs
- **XML** = Embedded trong .md cho agent config

### **4 Development Phases**
1. **Discovery** - Research, product brief
2. **Planning** - PRD, UX design
3. **Solutioning** - Architecture, epics/stories
4. **Implementation** - Dev, test, review

### **2 Development Paths**
- **Quick Flow**: `/quick-spec` → `/quick-dev` → `/code-review`
- **Full BMAD**: Product Brief → PRD → Architecture → Epics → Stories → Dev

---

## 🔗 External Resources

### **Official Documentation**
- [BMAD Docs](http://docs.bmad-method.org/) - Official documentation
- [GitHub](https://github.com/bmad-code-org/BMAD-METHOD/) - Source code
- [Discord](https://discord.gg/gk8jAdXWmj) - Community support
- [YouTube](https://www.youtube.com/@BMadCode) - Video tutorials

### **Getting Help**
1. **In-app**: Run `/bmad-help` trong AI IDE
2. **Community**: Discord server
3. **Issues**: GitHub Issues

---

## 📝 Cách Đóng Góp

Nếu bạn tìm thấy lỗi hoặc muốn improve documentation:

1. Tạo issue trên GitHub
2. Submit PR với updates
3. Hoặc liên hệ qua Discord

---

## 🗺️ Document Roadmap

### **✅ Hoàn Thành**
- [x] Folder structure guide
- [x] File formats explanation
- [x] Output artifacts guide
- [x] All workflows comprehensive guide
- [x] Quick start guide
- [x] `_bmad/` directory overview
- [x] `_config/` manifest hub deep dive
- [x] Core module complete (workflows, workflow.xml engine, tasks)
- [x] BMM module complete (agents, workflows, resources)

### **📋 Planned**
- [ ] Real project examples & case studies
- [ ] Custom workflow creation tutorial
- [ ] Advanced agent customization patterns

---

## 📊 Document Stats

| Category | Files | Total Pages (est) |
|----------|-------|-------------------|
| Getting Started | 1 | ~5 |
| Core Concepts | 3 | ~15 |
| Workflows | 1 | ~20 |
| Advanced - Overview | 1 | ~15 |
| Advanced - Config | 1 | ~20 |
| Advanced - Core | 1 | ~20 |
| Advanced - BMM | 3 | ~50 |
| **Total** | **11** | **~145** |

---

**Cập nhật lần cuối**: 2026-01-28  
**Version**: 1.0  
**Author**: Mazhnguyen

---

**🎯 BẮT ĐẦU NGAY**: Đọc [`01-getting-started/01-bmad-quickstart.md`](01-getting-started/01-bmad-quickstart.md)


