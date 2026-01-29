---
clickup_workspace_id: "90182277854"
clickup_doc_id: "2kzmgppy-1378"
clickup_page_id: null
title: "ClickUp Workflow Guide"
---

# ClickUp Rules & Integration Guide

> **Đọc kỹ trước khi làm việc với ClickUp!**

---

## 1. Cấu Trúc Workspace

### Space: Development Team (`90189438827`)

| Folder | ID | Mục đích |
|--------|-----|----------|
| **Planning & Backlog** | `901811729589` | Epics, Product Backlog, Bug Triage |
| **Sprint** | `901811698066` | Sprint Lists |
| **Knowledge Base** | `901811729668` | Tài liệu |

---

## 2. Team Members

| Name | Email | ClickUp ID |
|------|-------|------------|
| Mazh Nguyen | work.huutrung@gmail.com | 300697285 |
| Leo | leonkenzo1997@gmail.com | 107577458 |
| Eric Bae | eric@devcrane.com | 55771542 |

---

## 3. Tags (CHỈ DÙNG TAGS CÓ SẴN)

### Technical
`frontend` `backend` `mobile` `devops` `database`

### Functional
`auth` `payment` `reporting` `notification` `settings` `integration`

### Maintenance
`hotfix` `bug-prod` `bug-staging` `tech-debt` `refactor` `performance` `security` `accessibility`

### Special
`bmad` `epic` `story` `design` `customer-report`

> ⚠️ **KHÔNG tự tạo tags mới.** Workflow chỉ dùng tags từ frontmatter.

---

## 4. PM Workflow (Natural Language)

### Tạo Epic/Story

PM nói:
> "Tạo epic mới: User Notification System, priority high, assign cho Eric, tags notification backend"

### Gán Task

PM nói:
> "Gán STORY-3.5 cho Leo, deadline 10/2, priority urgent, tags frontend auth"

AI sẽ update frontmatter:
```yaml
assigned_to: "leonkenzo1997@gmail.com"
due_date: "2026-02-10"
priority: "urgent"
tags: ["frontend", "auth"]
```

### Review Tiến Độ

PM nói:
> "Tổng hợp tiến độ sprint hiện tại"

→ AI generate report từ template `_bmad-output/templates/sprint-report-template.md`

---

## 5. Dev Workflow

### Update Status + Comment

Dev nói:
> "Update STORY-4.1: Đã xong API endpoint. Đang test. Status in-progress"

AI sẽ:
1. Update `status: "in-progress"` trong frontmatter
2. Thêm vào `## Updates` section:
   ```
   **2026-01-29 14:35** - @Leo: Đã xong API endpoint. Đang test.
   ```
3. Push → Workflow sync comment to **ClickUp Activity** (không phải Description)

### Thêm Subtask/Checklist/Attachment

> ⚠️ **Lưu ý:** Do giới hạn API, những tính năng sau cần thao tác trực tiếp trên ClickUp:

#### Subtasks
Dev nói:
> "Thêm subtask cho STORY-4.1: Implement form validation"

AI sẽ tạo subtask trực tiếp qua ClickUp API:
```bash
POST /api/v2/list/{list_id}/task
{ "name": "Implement form validation", "parent": "{task_id}" }
```

#### Checklists
Dev nói:
> "Thêm checklist cho STORY-4.1: Unit tests, Integration tests, E2E tests"

AI sẽ tạo checklist qua ClickUp API:
```bash
POST /api/v2/task/{task_id}/checklist
{ "name": "Test Checklist" }
POST /api/v2/checklist/{checklist_id}/checklist_item
{ "name": "Unit tests" }
```

#### Attachments
Dev nói:
> "Đính kèm file design.png vào STORY-4.1"

**Cách 1:** Upload trực tiếp trên ClickUp UI

**Cách 2:** Nếu file ở GitHub, AI sẽ thêm link vào comment:
> "📎 Attachment: [design.png](https://github.com/repo/path/to/design.png)"

---

## 6. Frontmatter Fields

| Field | Type | Example | Sync to ClickUp |
|-------|------|---------|-----------------|
| `id` | string | "STORY-4.1" | Task name |
| `title` | string | "Profile View" | Task name |
| `status` | string | "in-progress" | ✅ Status |
| `priority` | string | "high" | ✅ Priority |
| `assigned_to` | string/array | "leo@email.com" | ✅ Assignees |
| `tags` | array | ["frontend"] | ✅ Tags |
| `start_date` | date | "2026-02-01" | ✅ Start Date |
| `due_date` | date | "2026-02-10" | ✅ Due Date |
| `time_estimate` | number | 16 (hours) | ✅ Time Estimate |
| `epic_id` | string | "EPIC-004" | ✅ Link to Epic |
| `clickup_task_id` | string | "86ewdmdjr" | Task ID (auto) |

---

## 7. Comment Format

Comments trong `## Updates` section sẽ tự động sync đến ClickUp Activity:

```markdown
## Updates

**2026-01-29 10:00** - @Leo: Bắt đầu implement API endpoint.
**2026-01-29 14:30** - @Leo: Xong GET/PUT. Cần confirm validation với PM.
**2026-01-30 09:00** - @Mazh: Đã review code, approve.
```

→ Mỗi dòng sẽ trở thành 1 comment trong ClickUp Activity.

---

## 8. Templates

| Template | Path |
|----------|------|
| Story | `_bmad-output/templates/story-template.md` |
| Epic | `_bmad-output/templates/epic-template.md` |
| Sprint Report | `_bmad-output/templates/sprint-report-template.md` |

---

## 9. Admin Links

- [GitHub Actions](https://github.com/hutune/demo-structure/actions)
- [ClickUp Space](https://app.clickup.com/90182277854/v/s/90189438827)
- [Product Backlog](https://app.clickup.com/90182277854/v/li/901815396340)

