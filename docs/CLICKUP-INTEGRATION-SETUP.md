# ClickUp Rules & Integration Configuration

> **Đọc kỹ trước khi làm việc với ClickUp!**  
> Tài liệu này mô tả cấu trúc workspace, statuses, và cách sync từ GitHub.

---

## 1. Cấu Trúc Workspace

### Space: Development Team
**ID**: `90189438827`

### Folders

| Folder | ID | Mục đích |
|--------|-----|----------|
| **Planning & Backlog** | `901811729589` | Quản lý Epics, Product Backlog, Bug Triage |
| **Sprint** | `901811698066` | Sprint hiện tại và kế tiếp |
| **Knowledge Base** | `901811729668` | Tài liệu, Tech Specs |

---

## 2. Lists & Statuses

### 📋 Epics / Initiatives
**ID**: `901815396322`  
**Sync từ**: `_bmad-output/epics/*.md`

| Order | Status | Type | Markdown Value |
|-------|--------|------|----------------|
| 0 | `to do` | open | `to-do` |
| 1 | `in progress` | custom | `in-progress` |
| 2 | `complete` | done | `done` |
| 3 | `cancelled` | closed | `cancelled` |

**Rule**: Epics không bao giờ di chuyển vào Sprint. Chúng chỉ là container cho User Stories.

---

### 📝 Product Backlog
**ID**: `901815396340`  
**Sync từ**: `_bmad-output/stories/*.md`

| Order | Status | Type | Markdown Value |
|-------|--------|------|----------------|
| 0 | `Open` | open | `to-do` |
| 1 | `scoping` | custom | `scoping` |
| 2 | `in design` | custom | `in-design` |
| 3 | `ready for dev` | custom | `ready-for-dev` |
| 4 | `cancelled` | closed | `cancelled` |

**Rule**: Chỉ tasks có status `ready for dev` (đã có Spec, Design, Estimate) mới được move vào Sprint.

---

### 🐛 Bug Triage
**ID**: `901815396345`  
**Sync từ**: `_bmad-output/bugs/*.md` *(chưa implement)*

| Order | Status | Type | Markdown Value |
|-------|--------|------|----------------|
| 0 | `new` | open | `new` |
| 1 | `checking` | custom | `checking` |
| 2 | `fixing` | custom | `fixing` |
| 3 | `verified` | done | `verified` |
| 4 | `won't fix` | closed | `wont-fix` |

**Rule**: PM review weekly để quyết định Hotfix ngay hay đưa vào Backlog.

---

### 🏃 Sprint Lists
**Sprint 1 ID**: `901815360889` (1/26 - 2/8)  
**Sprint 2 ID**: `901815360910` (2/9 - 2/22)

| Order | Status | Type | Markdown Value |
|-------|--------|------|----------------|
| 0 | `to do` | open | `to-do` |
| 1 | `in development` | custom | `in-development` |
| 2 | `in review` | custom | `in-review` |
| 3 | `testing` | custom | `testing` |
| 4 | `shipped` | done | `shipped` |
| 5 | `cancelled` | closed | `cancelled` |

**Rule**: User Stories chỉ chuyển sang `shipped` khi tất cả subtasks hoàn thành. Real-time update bắt buộc.

---

## 3. Task Standards

### Time Estimate
- **Bắt buộc** trước khi bắt đầu
- Đơn vị: Hours
- Maximum: 8h/task (nếu lớn hơn → tách subtasks)

### Time Tracking
- Sử dụng **Play/Stop** để tracking
- Mục đích: calibration, không phải policing

### Dates
- `Start Date` và `Due Date` **bắt buộc**
- Để tính toán workload chính xác

### Priority

| Priority | Ý nghĩa |
|----------|---------|
| `Urgent` | Immediate action |
| `High` | Core Sprint features |
| `Normal` | Default |
| `Low` | Nice to have |

### Tags (kebab-case)

**Technical Domain**: `frontend`, `backend`, `mobile`, `devops`  
**Functional Modules**: `auth`, `payment`, `dashboard`, `user`  
**Maintenance**: `tech-debt`, `refactor`, `hotfix`

---

## 4. GitHub Integration

### Workflow File
`.github/workflows/sync-clickup.yml`

### Required Secret
**Name**: `CLICKUP_API_KEY`  
**Value**: `pk_xxx...` (ClickUp API token)

### Cách hoạt động

```
Developer tạo/sửa file trong _bmad-output/
        ↓
git push to main
        ↓
GitHub Action triggers
        ↓
Workflow parse frontmatter
        ↓
IF clickup_task_id == null:
   → CREATE task mới
   → Commit ID về repo
ELSE:
   → UPDATE task hiện có
```

### Frontmatter Format

**Epic**:
```yaml
---
id: "EPIC-001"
title: "User Authentication"
status: "to-do"
clickup_task_id: null
---
```

**Story**:
```yaml
---
id: "STORY-1.1"
epic_id: "EPIC-001"
title: "Login Page"
status: "to-do"
assigned_to: "email@example.com"  # or ["email1", "email2"] for multiple
clickup_task_id: null
---
```

---

## 6. Assignee Support

### Email-to-ClickUp-ID Mapping

Workflow tự động map email sang ClickUp User ID. Cấu hình trong workflow file:

```yaml
EMAIL_TO_CLICKUP_ID: "email1:clickup_id1,email2:clickup_id2"
```

**Hiện tại đã config:**

| Email | ClickUp User ID |
|-------|-----------------|
| `work.huutrung@gmail.com` | `300697285` |
| `mazhnguyen@kwayvina.com` | `300697285` |

### Auto-Assign (Git Commit Author)

Nếu `assigned_to` trống → tự động gán cho người commit:
- Git commit author email → ClickUp User ID → Assignee

### Manual Assign (Frontmatter)

**Single assignee:**
```yaml
assigned_to: "work.huutrung@gmail.com"
```

**Multiple assignees** (khi một người nghỉ, người khác làm giúp):
```yaml
assigned_to: ["email1@example.com", "email2@example.com"]
```

### Thêm Team Member Mới

1. Lấy ClickUp User ID từ API:
   ```bash
   curl -H "Authorization: pk_xxx" "https://api.clickup.com/api/v2/team" | jq '.teams[0].members'
   ```

2. Thêm vào `EMAIL_TO_CLICKUP_ID` trong `.github/workflows/sync-clickup.yml`:
   ```yaml
   EMAIL_TO_CLICKUP_ID: "existing_mapping,new_email:new_id"
   ```

---

## 7. Admin Links

- **GitHub Actions**: https://github.com/hutune/demo-structure/actions
- **ClickUp Space**: https://app.clickup.com/90182277854/v/s/90189438827
- **Epics List**: https://app.clickup.com/90182277854/v/li/901815396322
- **Product Backlog**: https://app.clickup.com/90182277854/v/li/901815396340
- **Bug Triage**: https://app.clickup.com/90182277854/v/li/901815396345
- **ClickUp Rules Doc**: https://app.clickup.com/90182277854/v/dc/2kzmgppy-1258/2kzmgppy-1278
