---
clickup_workspace_id: "90182277854"
type: "page"
clickup_parent_doc_id: "2kzmgppy-2038"
title: "Output Artifacts Guide"
---

# Tài Liệu Chi Tiết: `_bmad-output/` Folder

## 📋 Tổng Quan

`_bmad-output/` là **artifact repository** - nơi lưu trữ TẤT CẢ outputs được tạo ra bởi workflows trong quá trình development.

### **Định Nghĩa**
- **Path**: `{project-root}/_bmad-output/`  
- **Configured in**: `_bmad/core/config.yaml`
- **Purpose**: Centralized location cho tất cả BMAD artifacts
- **User-configurable**: Có thể thay đổi trong config.yaml

---

## 🗂️ Cấu Trúc Hiện Tại

Sau khi cài đặt, BMAD đã tạo sẵn **2 subdirectories**:

```
_bmad-output/
├── planning-artifacts/     # Artifacts từ Discovery + Planning + Solutioning
└── implementation-artifacts/   # Artifacts từ Implementation phase
```

### **Tại Sao 2 Folders?**

BMAD phân tách artifacts theo **lifecycle stage**:

| Folder | Phase | Contents |
|--------|-------|----------|
| **`planning-artifacts/`** | Discovery, Planning, Solutioning | PRDs, Architecture, Epics, Stories, UX Design, Research |
| **`implementation-artifacts/`** | Implementation | Sprint status, Stories in progress, Tech specs, Code artifacts |

---

## 📂 Planning Artifacts (`planning-artifacts/`)

Chứa artifacts từ **3 phases đầu** của development lifecycle.

### **Expected Structure** (Sau khi chạy workflows)

```
planning-artifacts/
├── product-brief/
│   └── product-brief.md          # From /create-product-brief
│
├── research/
│   ├── market-research.md         # From /research
│   ├── technical-research.md
│   └── competitor-analysis.md
│
├── prd/
│   └── prd.md                     # From /create-prd
│
├── ux-design/
│   ├── ux-patterns.md             # From /create-ux-design
│   ├── wireframes/
│   └── user-flows/
│
├── architecture/
│   ├── architecture.md            # From /create-architecture
│   └── decision-records/
│       ├── adr-001.md
│       └── adr-002.md
│
├── epics/
│   ├── epic-01-user-auth.md      # From /create-epics-and-stories
│   ├── epic-02-dashboard.md
│   └── epic-03-reports.md
│
├── diagrams/
│   ├── system-architecture.excalidraw  # From /create-excalidraw-*
│   ├── dataflow.excalidraw
│   └── wireframes.excalidraw
│
└── project-documentation/
    └── project-overview.md        # From /document-project
```

---

## 📂 Implementation Artifacts (`implementation-artifacts/`)

Chứa artifacts từ **Implementation phase**.

### **Expected Structure** (Sau khi chạy workflows)

```
implementation-artifacts/
├── sprint-status.yaml             # From /sprint-planning
│
├── stories/
│   ├── story-001-login.md         # From /create-story
│   ├── story-002-signup.md
│   ├── story-003-dashboard.md
│   └── ...
│
├── tech-specs/
│   ├── feature-payment.md         # From /quick-spec
│   ├── feature-notifications.md
│   └── ...
│
├── code-reviews/
│   ├── review-story-001.md        # From /code-review
│   ├── review-story-002.md
│   └── ...
│
├── retrospectives/
│   ├── retro-epic-01.md           # From /retrospective
│   └── retro-epic-02.md
│
└── test-artifacts/
    ├── test-plan.md               # From /testarch-* workflows
    ├── test-framework/
    ├── acceptance-tests/
    ├── coverage-reports/
    └── nfr-assessment.md
```

---

## ⚙️ Configuration

### **Config File**: `_bmad/core/config.yaml`

```yaml
user_name: Mazhnguyen
communication_language: Vietnamese
document_output_language: Vietnamese
output_folder: "{project-root}/_bmad-output"
```

### **Thay Đổi Output Location**

Bạn có thể customize output folder bằng cách edit config:

```yaml
output_folder: "{project-root}/docs/bmad"
# Hoặc
output_folder: "/absolute/path/to/custom/output"
```

**⚠️ Lưu ý**: Sau khi thay đổi, cần re-run installer hoặc manually update references trong workflow configs.

---

## 🔍 Workflow → Output Mapping

Bảng chi tiết: Mỗi workflow tạo file gì ở đâu?

### **Phase 1: Discovery**

| Workflow | Output Location | File(s) Created |
|----------|----------------|-----------------|
| `/create-product-brief` | `planning-artifacts/product-brief/` | `product-brief.md` |
| `/research` | `planning-artifacts/research/` | `{research-type}-research.md` |

---

### **Phase 2: Planning**

| Workflow | Output Location | File(s) Created |
|----------|----------------|-----------------|
| `/create-prd` | `planning-artifacts/prd/` | `prd.md` |
| `/create-ux-design` | `planning-artifacts/ux-design/` | `ux-patterns.md`, wireframes |
| `/document-project` | `planning-artifacts/project-documentation/` | Various docs |

---

### **Phase 3: Solutioning**

| Workflow | Output Location | File(s) Created |
|----------|----------------|-----------------|
| `/create-architecture` | `planning-artifacts/architecture/` | `architecture.md`, ADRs |
| `/create-epics-and-stories` | `planning-artifacts/epics/` | `epic-{number}-{name}.md` |
| `/check-implementation-readiness` | `planning-artifacts/` | `readiness-report.md` |
| `/create-excalidraw-diagram` | `planning-artifacts/diagrams/` | `{name}.excalidraw` |
| `/create-excalidraw-dataflow` | `planning-artifacts/diagrams/` | `dataflow.excalidraw` |
| `/create-excalidraw-flowchart` | `planning-artifacts/diagrams/` | `flowchart.excalidraw` |
| `/create-excalidraw-wireframe` | `planning-artifacts/diagrams/` | `wireframe.excalidraw` |

---

### **Phase 4: Implementation**

| Workflow | Output Location | File(s) Created |
|----------|----------------|-----------------|
| `/sprint-planning` | `implementation-artifacts/` | `sprint-status.yaml` |
| `/sprint-status` | N/A | Read-only (displays status) |
| `/create-story` | `implementation-artifacts/stories/` | `story-{number}-{name}.md` |
| `/quick-spec` | `implementation-artifacts/tech-specs/` | `{feature-name}.md` |
| `/dev-story` | Updates story file | Story file + code changes |
| `/quick-dev` | Implementation code | Code + tests |
| `/code-review` | `implementation-artifacts/code-reviews/` | `review-{story}.md` |
| `/correct-course` | `implementation-artifacts/` | `course-correction.md` |
| `/retrospective` | `implementation-artifacts/retrospectives/` | `retro-epic-{number}.md` |

---

### **TestArch Workflows**

| Workflow | Output Location | File(s) Created |
|----------|----------------|-----------------|
| `/testarch-framework` | `implementation-artifacts/test-artifacts/` | Test framework scaffolding |
| `/testarch-test-design` | `implementation-artifacts/test-artifacts/` | `test-plan.md` |
| `/testarch-atdd` | `implementation-artifacts/test-artifacts/acceptance-tests/` | Failing acceptance tests |
| `/testarch-automate` | `implementation-artifacts/test-artifacts/` | Automated test suite |
| `/testarch-test-review` | `implementation-artifacts/test-artifacts/` | `test-review.md` |
| `/testarch-trace` | `implementation-artifacts/test-artifacts/` | `traceability-matrix.md` |
| `/testarch-nfr` | `implementation-artifacts/test-artifacts/` | `nfr-assessment.md` |
| `/testarch-ci` | `implementation-artifacts/test-artifacts/` | CI/CD config files |

---

## 📊 Ví Dụ: Full Project Lifecycle

Sau khi hoàn thành FULL BMAD workflow cho một project, `_bmad-output/` sẽ trông như thế này:

```
_bmad-output/
│
├── planning-artifacts/
│   ├── product-brief/
│   │   └── product-brief.md          (✅ Discovery done)
│   │
│   ├── research/
│   │   ├── market-research.md
│   │   └── technical-research.md     (✅ Research done)
│   │
│   ├── prd/
│   │   └── prd.md                    (✅ Requirements documented)
│   │
│   ├── ux-design/
│   │   ├── ux-patterns.md
│   │   └── wireframes/               (✅ UX planned)
│   │
│   ├── architecture/
│   │   ├── architecture.md
│   │   └── decision-records/         (✅ Architecture decided)
│   │
│   ├── epics/
│   │   ├── epic-01-authentication.md
│   │   ├── epic-02-core-features.md
│   │   └── epic-03-reporting.md      (✅ Work broken down)
│   │
│   └── diagrams/
│       ├── system-architecture.excalidraw
│       └── dataflow.excalidraw       (✅ Diagrams created)
│
└── implementation-artifacts/
    ├── sprint-status.yaml            (✅ Sprint initialized)
    │
    ├── stories/
    │   ├── story-001-user-login.md      [DONE]
    │   ├── story-002-user-signup.md     [DONE]
    │   ├── story-003-dashboard.md       [IN_PROGRESS]
    │   └── story-004-reports.md         [TODO]
    │
    ├── tech-specs/
    │   ├── login-flow.md
    │   └── dashboard-impl.md         (✅ Specs written)
    │
    ├── code-reviews/
    │   ├── review-001.md
    │   └── review-002.md             (✅ Code reviewed)
    │
    ├── retrospectives/
    │   └── retro-epic-01.md          (✅ Learnings captured)
    │
    └── test-artifacts/
        ├── test-framework/           (✅ Tests setup)
        ├── acceptance-tests/
        ├── traceability-matrix.md
        └── nfr-assessment.md         (✅ Quality validated)
```

**Total Artifacts**: ~30+ files cho một mid-sized project

---

## 🎯 Best Practices

### 1. **Không Edit Artifacts Manually**
- BMAD workflows manage artifacts
- Manual edits có thể break workflow state tracking
- Exception: Nếu workflow hỗ trợ "Edit mode" (như `/create-prd`)

### 2. **Version Control**
- **COMMIT** toàn bộ `_bmad-output/` vào Git
- Artifacts = project documentation
- Traceability qua Git history

### 3. **Gitignore Recommendations**
```gitignore
# Có thể ignore temporary artifacts
_bmad-output/**/tmp/
_bmad-output/**/.temp/

# Nhưng KHÔNG ignore core artifacts
!_bmad-output/planning-artifacts/
!_bmad-output/implementation-artifacts/
```

### 4. **Folder Organization**
- BMAD tự động tạo subdirectories khi cần
- Không cần manually create folders
- Workflows handle path resolution

### 5. **Backup**
- `_bmad-output/` chứa toàn bộ project artifacts
- Nếu mất folder này = mất toàn bộ BMAD context
- Backup regularly hoặc commit vào Git

---

## 🔧 Technical Details

### **Variable Resolution**

Workflows reference output folder qua variables:

```yaml
# In workflow.yaml
config_source: "{project-root}/_bmad/bmm/config.yaml"
output_folder: "{config_source}:output_folder"
planning_artifacts: "{config_source}:planning_artifacts"
implementation_artifacts: "{config_source}:implementation_artifacts"
```

**Resolution Process**:
1. `{project-root}` → Absolute project path
2. `{config_source}:output_folder` → Read from config.yaml
3. Final path: `/absolute/path/to/RMN/_bmad-output/`

### **Config Variables** (từ `_bmad/bmm/config.yaml`)

```yaml
output_folder: "{project-root}/_bmad-output"
planning_artifacts: "{output_folder}/planning-artifacts"
implementation_artifacts: "{output_folder}/implementation-artifacts"
```

### **Auto-Creation**
- BMAD workflows tự động create directories khi write files
- Không cần pre-create structure
- Empty directories (`planning-artifacts/`, `implementation-artifacts/`) được tạo bởi installer

---

## 📋 Artifact File Formats

### **PRD / Architecture / Epics**
- **Format**: Markdown (`.md`)
- **Structure**: 
  - YAML frontmatter cho metadata
  - Markdown body cho content
  
**Example**: `prd.md`
```markdown
---
title: Product Requirements Document
version: 1.0
author: Mazhnguyen
date: 2026-01-28
stepsCompleted: [step-01, step-02, step-03]
---

# Product Requirements Document

## Executive Summary
...
```

### **Sprint Status**
- **Format**: YAML (`.yaml`)
- **Purpose**: Machine-readable sprint tracking

**Example**: `sprint-status.yaml`
```yaml
sprint:
  name: Sprint 1
  start_date: 2026-01-28
  end_date: 2026-02-11
epics:
  - id: epic-01
    status: IN_PROGRESS
    stories:
      - id: story-001
        status: DONE
      - id: story-002
        status: IN_PROGRESS
```

### **Diagrams**
- **Format**: Excalidraw (`.excalidraw`)
- **Purpose**: Visual diagrams
- **Tools**: Open với Excalidraw editor

---

## 🚀 Workflow Execution Flow

### **Example**: Creating PRD

```
User runs: /create-prd
    ↓
AI loads: _bmad/bmm/workflows/2-plan-workflows/create-prd/workflow.md
    ↓
AI reads config: _bmad/bmm/config.yaml
    ↓
Resolve output_folder: _bmad-output/
Resolve planning_artifacts: _bmad-output/planning-artifacts/
    ↓
Execute PRD creation workflow (multi-step)
    ↓
Write output: _bmad-output/planning-artifacts/prd/prd.md
    ↓
Update frontmatter: stepsCompleted: [...]
    ↓
Workflow complete
```

---

## 📊 Summary

### **Key Points**

1. **Centralized Storage**: Tất cả BMAD artifacts ở một chỗ
2. **Phase Separation**: Planning vs Implementation artifacts
3. **Auto-Managed**: Workflows tự động create/update files
4. **Git-Friendly**: Markdown + YAML, dễ version control
5. **Configurable**: Có thể customize output location

### **Folder Counts** (After Full Project)

| Category | Typical Count |
|----------|--------------|
| Planning artifacts | 10-20 files |
| Implementation artifacts | 20-50+ files |
| Diagrams | 3-10 files |
| Test artifacts | 5-15 files |
| **Total** | **~40-100 files** |

### **Size Estimate**

- Small project: ~5-10 MB
- Medium project: ~10-50 MB  
- Large project: ~50-200 MB

(Mostly text files, very manageable)

---

**Kết Luận**: `_bmad-output/` là **living documentation repository** - tất cả artifacts từ Discovery đến Ship đều ở đây, organized và tracked bởi BMAD workflows.
