---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "BMAD Quickstart Guide"
---

# BMAD Method - Quick Start Guide

> **5-10 phút** để hiểu và bắt đầu với BMAD Method

---

## 🎯 BMAD Method Là Gì?

**BMAD** (Breakthrough Method of Agile AI-Driven Development) là một **AI-driven development framework** giúp bạn xây dựng phần mềm theo phương pháp agile với sự hỗ trợ của AI agents.

### **Tại Sao Dùng BMAD?**

❌ **Traditional AI tools**: AI làm hết, kết quả average  
✅ **BMAD Method**: AI là expert collaborator, guide bạn qua structured process

**Kết quả**: Tốt hơn, organized hơn, repeatable hơn.

---

## 🚀 Cài Đặt Nhanh

### **Prerequisites**
- Node.js v20+
- AI IDE (Google Antigravity, Claude Code, Cursor, Windsurf, etc.)

### **Installation**
```bash
cd your-project
npx bmad-method install
```

Installer sẽ hỏi:
1. ✅ Install directory (confirm)
2. 📦 Modules to install (chọn **BMad Method** ít nhất)
3. 🛠️ AI IDE tool (chọn tool bạn đang dùng, ví dụ: Google Antigravity)
4. 👤 Configuration (tên, ngôn ngữ, output folder)

**Xong!** BMAD đã được cài vào project của bạn.

---

## 📁 Cấu Trúc Sau Khi Cài

```
your-project/
├── .agent/           # 47 workflow shortcuts cho AI IDE
├── _bmad/            # Framework logic (workflows, agents, config)
│   ├── _config/      # Manifests
│   ├── core/         # Core module
│   └── bmm/          # BMad Method module
└── _bmad-output/     # Nơi lưu project artifacts
    ├── planning-artifacts/
    └── implementation-artifacts/
```

**3 folders quan trọng**:
1. **`.agent/`** - AI IDE tìm workflows ở đây
2. **`_bmad/`** - Framework code (DON'T EDIT)
3. **`_bmad-output/`** - Your outputs (GIT COMMIT này!)

---

## 🎮 Workflow Đầu Tiên

### **Option 1: Cần Help?**
```
/bmad-help
```
AI sẽ analyze context và suggest next steps.

### **Option 2: Quick Feature Development**
Cho bug fixes, small features:
```
/quick-spec    # Tạo tech spec
↓
/quick-dev     # Implement
↓
/code-review   # ADVERSARIAL review
```

### **Option 3: Full Project Planning**
Cho products, platforms, complex features:
```
/create-product-brief    # Define problem, users, MVP
↓
/create-prd             # Full requirements
↓
/create-architecture    # Tech decisions
↓
/create-epics-and-stories  # Break into stories
↓
/sprint-planning        # Initialize sprint
↓
Loop: /create-story → /dev-story → /code-review
```

---

## 🤖 Meet The Agents

BMAD có **10 specialized AI agents**, mỗi agent có persona riêng:

| Agent | Icon | Specialty | Use When |
|-------|------|-----------|----------|
| `/pm` | 📋 | Product Manager | PRD creation, requirements |
| `/architect` | 🏗️ | Software Architect | Architecture decisions |
| `/dev` | 💻 | Senior Developer | Code implementation |
| `/ux-designer` | 🎨 | UX Designer | UI/UX patterns |
| `/tea` | ✅ | Test Engineer | Testing, QA |
| `/sm` | 🎯 | Scrum Master | Agile facilitation |
| `/analyst` | 📊 | Business Analyst | Requirements gathering |
| `/tech-writer` | 📝 | Technical Writer | Documentation |

**Bonus**: `/party-mode` - Gọi nhiều agents cùng lúc để thảo luận!

---

## 📊 4 Development Phases

BMAD organize work theo **4 phases**:

```
1. DISCOVERY        2. PLANNING         3. SOLUTIONING       4. IMPLEMENTATION
   Research            PRD                 Architecture          Sprint Planning
   Product Brief       UX Design           Epics & Stories       Dev Stories
                                                                 Code Review
                                                                 Testing
```

**Artifacts** từ mỗi phase được lưu trong `_bmad-output/`.

---

## 💡 Các Khái Niệm Quan Trọng

### **Workflow**
Một quy trình có steps để hoàn thành task cụ thể.  
**Ví dụ**: `/create-prd`, `/dev-story`, `/code-review`

### **Agent**
AI persona với expertise về một domain.  
**Ví dụ**: PM agent asks "WHY?", Dev agent focuses on code quality

### **Artifact**
Output file từ workflow.  
**Ví dụ**: `prd.md`, `architecture.md`, `story-001.md`

### **Slash Command**
Cách gọi workflow hoặc agent.  
**Format**: `/command-name`

### **Module**
Package of workflows + agents.  
**Ví dụ**: Core (universal tools), BMM (agile workflows)

---

## 🎓 Learning Path

### **Bước 1: Hiểu Cấu Trúc** (15 phút)
Đọc: [`02-core-concepts/01-folder-structure.md`](../02-core-concepts/01-folder-structure.md)

**Bạn sẽ hiểu**:
- 3 folders chính
- `.agent/` vs `_bmad/` vs `_bmad-output/`
- Core module vs BMM module

---

### **Bước 2: Hiểu File Formats** (20 phút)
Đọc: [`02-core-concepts/02-file-formats.md`](../02-core-concepts/02-file-formats.md)

**Bạn sẽ hiểu**:
- Tại sao YAML, Markdown, CSV, XML?
- Mỗi format dùng khi nào?
- Core có 1 agent, BMM có 9 agents (WHY?)

---

### **Bước 3: Explore Workflows** (30 phút)
Đọc: [`03-workflows/01-all-workflows.md`](../03-workflows/01-all-workflows.md)

**Bạn sẽ biết**:
- 47 workflows là gì
- 8 categories
- Khi nào dùng workflow nào

---

## 🔧 Configuration

### **User Config**: `_bmad/core/config.yaml`
```yaml
user_name: YourName
communication_language: Vietnamese  # or English
document_output_language: Vietnamese
output_folder: "{project-root}/_bmad-output"
```

**Customization**:
- Thay đổi language
- Customize output folder
- Adjust user preferences

---

## 🆘 Getting Help

### **In-App**
```bash
/bmad-help                           # General help
/bmad-help what should I do next?    # Contextual help
```

### **Community**
- [Discord](https://discord.gg/gk8jAdXWmj) - Real-time support
- [GitHub Issues](https://github.com/bmad-code-org/BMAD-METHOD/issues) - Bug reports
- [Docs](http://docs.bmad-method.org/) - Official documentation

---

## 📝 Ví Dụ Thực Tế

### **Scenario 1: Build New Feature**
```
You: /quick-spec
AI: [Asks questions about feature]
You: [Answers]
AI: [Creates tech-spec in _bmad-output/tech-specs/]

You: /quick-dev
AI: [Implements based on spec]
AI: [Writes tests]
AI: [Updates story file]

You: /code-review
AI: [ADVERSARIAL review - finds 3-10 issues]
AI: [Proposes fixes]
You: [Approve fixes]
AI: [Auto-fixes]
```

---

### **Scenario 2: Start New Project**
```
You: /create-product-brief
AI (as BA): [Collaborative discovery session]
AI: [Creates product-brief.md]

You: /create-prd
AI (as PM): [Tri-modal: Create/Validate/Edit]
You: [Choose Create]
AI: [Step-by-step PRD creation]
AI: [Saves prd.md]

You: /create-architecture
AI (as Architect): [Collaborative architecture decisions]
AI: [Creates architecture.md]

You: /create-epics-and-stories
AI: [Reads PRD + Architecture]
AI: [Creates epic-01.md, epic-02.md, ...]

You: /sprint-planning
AI: [Generates sprint-status.yaml]

Loop:
  You: /create-story
  AI: [Creates story-001.md]
  
  You: /dev-story
  AI: [Implements story]
  
  You: /code-review
  AI: [Reviews, finds issues, fixes]
```

---

## ✅ Next Steps

Sau khi đọc guide này, bạn có thể:

1. **Try Quick Flow**
   ```
   /quick-spec → /quick-dev → /code-review
   ```

2. **Explore Workflows**  
   Đọc [`03-workflows/01-all-workflows.md`](../03-workflows/01-all-workflows.md)

3. **Deep Dive**  
   Đọc [`02-core-concepts/`](../02-core-concepts/) folder

4. **Get Help**  
   `/bmad-help` hoặc join Discord

---

## 🎯 Key Takeaways

✅ BMAD = AI-driven agile framework  
✅ 47 workflows, 10 agents, 4 phases  
✅ Structured approach > ad-hoc AI  
✅ Artifacts tracked in `_bmad-output/`  
✅ 2 paths: Quick Flow vs Full BMAD Method  

---

**Ready?** [Explore All Workflows →](../03-workflows/01-all-workflows.md)  
**Need Help?** Run `/bmad-help` in your AI IDE
