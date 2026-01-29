---
clickup_workspace_id: "90182277854"
clickup_doc_id: "2kzmgppy-1378"
clickup_page_id: "2kzmgppy-2118"
title: "ClickUp API Reference"
---

# ClickUp API Reference

> **Nested page** của ClickUp Workflow Guide - Chi tiết kỹ thuật về API integration

---

## 📡 API Endpoints

### ClickUp Docs API v3

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/workspaces/{id}/docs` | Create standalone Doc |
| `PUT` | `/workspaces/{id}/docs/{doc_id}` | Update Doc |
| `POST` | `/workspaces/{id}/docs/{doc_id}/pages` | Create page |
| `PUT` | `/workspaces/{id}/docs/{doc_id}/pages/{page_id}` | Update page |

---

## 🔐 Authentication

```bash
# Header format
Authorization: pk_YOUR_API_KEY

# Example
curl -X POST "https://api.clickup.com/api/v3/workspaces/90182277854/docs" \
  -H "Authorization: pk_84371566_..." \
  -H "Content-Type: application/json" \
  -d '{"name": "Doc Name", "content": "..."}'
```

---

## 📋 Request/Response Examples

### Create Page Request

```json
{
  "name": "Page Title",
  "content": "# Markdown content...",
  "content_format": "text/md",
  "parent_page_id": "2kzmgppy-1818"  // Optional: for nested pages
}
```

### Create Page Response

```json
{
  "id": "2kzmgppy-1858",
  "name": "Page Title",
  "date_created": "2026-01-29T10:15:00Z"
}
```

---

## 🔗 Related

- Parent: [ClickUp Workflow Guide](../clickup-workflow-guide.md)
- Sibling: [Developer Setup Guide](../developer-setup-guide.md)

---

**Last Updated:** 2026-01-29
**Test Nested Page:** 2026-01-29 17:41
