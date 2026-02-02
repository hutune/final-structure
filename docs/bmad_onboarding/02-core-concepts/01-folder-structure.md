---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "Folder Structure Guide"
---

# Hướng Dẫn Cấu Trúc BMAD Method

## 📁 Tổng Quan Cấu Trúc Folder

Sau khi cài đặt, dự án RMN của bạn sẽ có 3 thư mục chính:

```
RMN/
├── .agent/           # Workflows shortcuts cho AI IDE
├── _bmad/            # Core framework và modules
└── _bmad-output/     # Thư mục output cho tài liệu và artifacts
```

---

## 1️⃣ `.agent/` - AI IDE Integration Layer

**Mục đích**: Chứa các workflow shortcuts mà AI IDE (như Google Antigravity) có thể nhận diện và thực thi

**Cấu trúc**:
```
.agent/
└── workflows/        # 47 workflow files
    ├── bmad-help.md
    ├── bmad-bmm-create-prd.md
    ├── bmad-bmm-create-architecture.md
    └── ...
```

**Cách hoạt động**:
- Mỗi file `.md` trong `.agent/workflows/` là một **shortcut** (lối tắt)
- Khi bạn gọi `/create-prd`, AI sẽ đọc file `bmad-bmm-create-prd.md`
- File này chứa **pointer** trỏ đến workflow thực sự trong `_bmad/`

**Ví dụ**: File `.agent/workflows/bmad-bmm-create-prd.md`
```markdown
---
name: 'create-prd'
description: 'PRD tri-modal workflow - Create, Validate, or Edit comprehensive PRDs'
---

LOAD @{project-root}/_bmad/bmm/workflows/2-plan-workflows/create-prd/workflow.md
```

> ⚠️ **Lưu ý**: Đây chỉ là layer tích hợp, logic thực sự nằm trong `_bmad/`

---

## 2️⃣ `_bmad/` - Core Framework Directory

**Mục đích**: Chứa toàn bộ logic, templates, và configuration của BMAD Method

**Cấu trúc chính**:
```
_bmad/
├── _config/          # Manifest và configuration files
├── core/             # Core module (built-in workflows & agents)
└── bmm/              # BMad Method Module (agile workflows)
```

### 2.1 `_bmad/_config/` - Configuration Hub

Chứa các file manifest và configuration tổng hợp từ tất cả modules:

| File | Mục đích |
|------|----------|
| `manifest.yaml` | Danh sách modules đã cài, version, ngày cài đặt |
| `agent-manifest.csv` | Tổng hợp tất cả agents có sẵn |
| `workflow-manifest.csv` | Tổng hợp tất cả workflows có sẵn |
| `task-manifest.csv` | Tổng hợp tất cả tasks |
| `bmad-help.csv` | Database cho `/bmad-help` workflow |
| `agents/` | Agent configuration files |

**Vai trò**: Đây là "bảng điều khiển trung tâm" - nơi BMAD biết modules nào đã cài, workflows nào có sẵn, và cách định tuyến commands.

### 2.2 `_bmad/core/` - Core Module

**Module built-in** cung cấp các công cụ cơ bản, không phụ thuộc vào phương pháp phát triển cụ thể.

```
core/
├── config.yaml           # User preferences (name, language, output folder)
├── module-help.csv       # Help catalog cho core module
├── agents/               # 1 core agent
│   └── bmad-master/
├── tasks/                # 7 core tasks
│   ├── help.md
│   └── ...
├── workflows/            # 17 core workflows
│   ├── help/
│   ├── brainstorming/
│   ├── editorial-review-prose/
│   ├── party-mode/
│   └── ...
└── resources/            # Shared resources
```

**Ví dụ workflow trong core**:
- `/bmad-help` - AI-guided help system
- `/brainstorming` - Creative ideation
- `/editorial-review-prose` - Document editing
- `/party-mode` - Multi-agent discussions

### 2.3 `_bmad/bmm/` - BMad Method Module (Agile-AI Development)

**Module chính** cho agile development workflow. Chứa 31 workflows qua 4 phases.

```
bmm/
├── config.yaml           # Module config
├── module-help.csv       # Help catalog
├── agents/               # 9 specialized agents
│   ├── analyst/          # 📊 Business Analyst
│   ├── architect/        # 🏗️ Software Architect
│   ├── dev/              # 💻 Developer
│   ├── pm/               # 📋 Product Manager
│   ├── sm/               # 🎯 Scrum Master
│   ├── tea/              # ✅ Test Engineer
│   ├── tech-writer/      # 📝 Technical Writer
│   ├── ux-designer/      # 🎨 UX Designer
│   └── quick-flow-solo-dev/
├── workflows/            # 206 files organized by phase
│   ├── 1-discover-workflows/
│   ├── 2-plan-workflows/
│   ├── 3-build-workflows/
│   └── 4-ship-workflows/
├── testarch/             # Test Architecture workflows (35 files)
├── teams/                # Team collaboration configs
└── data/                 # Module data
```

---

## 3️⃣ `_bmad-output/` - Output Directory

**Mục đích**: Nơi lưu trữ tất cả artifacts được tạo ra trong quá trình phát triển

**Cấu trúc** (sẽ được tạo tự động khi bạn chạy workflows):
```
_bmad-output/
├── product-brief/
├── prd/
├── architecture/
├── epics/
├── stories/
├── tech-specs/
└── ...
```

> 💡 **Ghi chú**: Thư mục này ban đầu rỗng, sẽ được populate khi bạn chạy các workflows.

---

## 🔄 Luồng Hoạt Động (Workflow Execution Flow)

Khi bạn gọi một workflow, ví dụ `/create-prd`:

```
1. AI IDE nhận command: /create-prd
   ↓
2. AI đọc: .agent/workflows/bmad-bmm-create-prd.md
   ↓
3. File này chỉ đường đến: _bmad/bmm/workflows/2-plan-workflows/create-prd/workflow.md
   ↓
4. AI đọc workflow.md đầy đủ và thực thi từng bước
   ↓
5. Output được lưu vào: _bmad-output/prd/
```

---

## 📋 Các Định Nghĩa Quan Trọng

### 1. **Module**
- Một package chức năng độc lập trong BMAD
- **Ví dụ**: `core`, `bmm` (BMad Method), `bmgd` (Game Dev), `cis` (Creative Intelligence Suite)
- Mỗi module có: `config.yaml`, `agents/`, `workflows/`, `tasks/`

### 2. **Workflow**
- Một quy trình từng bước để hoàn thành một nhiệm vụ cụ thể
- **Ví dụ**: `/create-prd`, `/create-architecture`, `/dev-story`
- Workflow có thể có nhiều modes (create, validate, edit)

### 3. **Agent**
- Một "expert persona" với kiến thức chuyên môn về domain cụ thể
- **Ví dụ**: PM Agent (Product Manager), Architect Agent, UX Designer Agent
- Agent có thể được load trực tiếp: `/pm`, `/architect`, `/dev`

### 4. **Task**
- Một đơn vị công việc nhỏ hơn workflow, thường được gọi từ bên trong workflow
- **Ví dụ**: `help.md` task được gọi bởi `/bmad-help` workflow

### 5. **Artifact**
- Sản phẩm đầu ra của workflow (document, diagram, code, etc.)
- **Ví dụ**: `product-brief.md`, `architecture.md`, `epic-01.md`
- Được lưu trong `_bmad-output/`

### 6. **Manifest**
- File CSV/YAML liệt kê tất cả components có sẵn
- **Role**: BMAD dùng manifest để biết workflows nào có thể chạy

### 7. **Phase**
- Giai đoạn trong development lifecycle
- **BMM Module có 4 phases**:
  1. **Discover** - Khám phá và nghiên cứu
  2. **Plan** - Lập kế hoạch và thiết kế
  3. **Build** - Xây dựng và implement
  4. **Ship** - Deploy và deliver

### 8. **Slash Command**
- Command bắt đầu bằng `/` để gọi workflow hoặc agent
- **Ví dụ**: `/create-prd`, `/bmad-help`, `/party-mode`

---

## 🎯 Workflows Quan Trọng Nên Biết

### Core Workflows (Universal)
- `/bmad-help` - Hệ thống trợ giúp AI-guided
- `/brainstorming` - Phiên brainstorming sáng tạo
- `/party-mode` - Thảo luận đa-agent

### BMM Phase 1: Discover
- `/research` - Nghiên cứu market/technical/domain
- `/create-product-brief` - Tạo product brief đầu tiên

### BMM Phase 2: Plan
- `/create-prd` - Product Requirements Document
- `/create-architecture` - Architecture decisions
- `/create-ux-design` - UX patterns và design
- `/create-epics-and-stories` - Break down thành stories

### BMM Phase 3: Build
- `/sprint-planning` - Khởi tạo sprint tracking
- `/sprint-status` - Xem tình trạng sprint
- `/create-story` - Tạo story tiếp theo
- `/quick-spec` - Tạo tech-spec nhanh
- `/dev-story` - Implement một story
- `/code-review` - Review code quality

### BMM Phase 4: Ship  
- `/testarch-*` - Các workflow về testing và quality

---

## 💡 Tips Sử Dụng

### 1. Bắt đầu từ đâu?
```bash
# Nếu chưa biết làm gì:
/bmad-help

# Nếu có ý tưởng mới:
/create-product-brief

# Nếu đã có requirements rõ ràng:
/create-prd
```

### 2. Hiểu flow của bạn
- **Simple Path** (bug fixes, small features): `/quick-spec` → `/dev-story` → `/code-review`
- **Full Planning Path** (products, platforms): Product Brief → PRD → Architecture → Epics → Stories → Dev

### 3. Config Personalization
File quan trọng: `_bmad/core/config.yaml`
```yaml
user_name: Mazhnguyen
communication_language: Vietnamese
document_output_language: Vietnamese
output_folder: "{project-root}/_bmad-output"
```

Bạn có thể edit file này để thay đổi preferences.

### 4. Đọc Workflow Trước Khi Chạy
Mỗi workflow trong `_bmad/bmm/workflows/` đều có documentation. Bạn có thể đọc để hiểu nó làm gì.

---

## 🔍 Ví Dụ Thực Tế

### Scenario: Bạn muốn tạo một feature mới

**Bước 1**: Xác định scope
```
/bmad-help   # Hỏi BMAD nên làm gì tiếp theo
```

**Bước 2**: Nếu feature đơn giản
```
/quick-spec  # Tạo tech spec
→ Output: _bmad-output/tech-specs/feature-name.md
```

**Bước 3**: Implement
```
/dev-story   # Implement theo spec
→ AI sẽ code, test, và update story file
```

**Bước 4**: Review
```
/code-review # Adversarial review
→ AI sẽ tìm 3-10 vấn đề và suggest fixes
```

### Scenario: Bạn muốn build product lớn

**Phase 1 - Discover**:
```
/create-product-brief  # Define problem, users, MVP
→ _bmad-output/product-brief/product-brief.md
```

**Phase 2 - Plan**:
```
/create-prd           # Full requirements
→ _bmad-output/prd/prd.md

/create-architecture  # Tech decisions
→ _bmad-output/architecture/architecture.md

/create-epics-and-stories  # Break into stories
→ _bmad-output/epics/*.md
```

**Phase 3 - Build**:
```
/sprint-planning      # Init sprint tracking
→ _bmad-output/sprint/sprint-status.yaml

# Lặp lại cho mỗi story:
/create-story  →  /dev-story  →  /code-review
```

---

## ❓ FAQs

**Q: Tôi có thể tự tạo workflow riêng không?**  
A: Có! Dùng module `BMad Builder` để tạo custom agents, workflows, và modules.

**Q: Tôi có thể xóa các workflow không dùng không?**  
A: Không nên. BMAD workflows có dependencies. Nếu muốn customize, tốt nhất là dùng BMad Builder.

**Q: Output folder có thể thay đổi không?**  
A: Có, edit `_bmad/core/config.yaml` → `output_folder`

**Q: Tôi muốn dùng tiếng Anh thay vì tiếng Việt?**  
A: Edit `_bmad/core/config.yaml`:
```yaml
communication_language: English
document_output_language: English
```

**Q: BMAD có hỗ trợ team collaboration không?**  
A: Có, xem `_bmad/bmm/teams/` để biết cấu hình team workflows.

---

## 📚 Tài Liệu Tham Khảo

- **Official Docs**: http://docs.bmad-method.org/
- **GitHub**: https://github.com/bmad-code-org/BMAD-METHOD/
- **Discord Community**: https://discord.gg/gk8jAdXWmj
- **YouTube Tutorials**: https://www.youtube.com/@BMadCode

---

**Tóm tắt**: BMAD Method là một framework với 3 layers:
1. **`.agent/`** - Integration layer cho AI IDE
2. **`_bmad/`** - Core framework chứa logic và templates
3. **`_bmad-output/`** - Nơi lưu trữ artifacts

Bạn tương tác thông qua **slash commands** (`/workflow-name`), AI sẽ load workflow từ `_bmad/`, thực thi, và lưu output vào `_bmad-output/`.
