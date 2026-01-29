---
clickup_workspace_id: "90182277854"
clickup_doc_id: "2kzmgppy-1378"
clickup_page_id: "2kzmgppy-2178"
parent_page_id: null
title: "Tasks API Examples"
---

# Tasks API Examples

> **Level 3 nested page** - Con của ClickUp API Reference

---

## 📋 Create Task

```bash
curl -X POST "https://api.clickup.com/api/v2/list/LIST_ID/task" \
  -H "Authorization: pk_..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Task",
    "description": "Task description",
    "status": "Open"
  }'
```

---

## 📝 Update Task

```bash
curl -X PUT "https://api.clickup.com/api/v2/task/TASK_ID" \
  -H "Authorization: pk_..." \
  -H "Content-Type: application/json" \
  -d '{"status": "In Progress"}'
```

---

**Hierarchy:**
- Team Processes (Doc)
  - ClickUp Workflow Guide (Level 1)
    - ClickUp API Reference (Level 2)
      - **Tasks API Examples** (Level 3) ← You are here!
