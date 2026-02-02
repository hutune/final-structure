---
title: "Hướng Dẫn Sử Dụng BMAD Cho Team"
---

# Hướng Dẫn Sử Dụng BMAD Cho Team RMN

## 📌 Tổng Quan

BMAD (Breakthrough Method of Agile AI-Driven Development) là framework giúp team làm việc hiệu quả với AI. Commands được tổ chức theo **role** để dễ sử dụng.

---

## 🎯 Commands Theo Role

### BA (Business Analyst)
```
/ba-create-brief   - Tạo product brief
/ba-research       - Research workflow
/ba-brainstorm     - Brainstorming
/ba-create-stories - Tạo epics và stories
```

### PM (Product Manager)
```
/pm-create-prd      - Tạo PRD
/pm-sprint-planning - Lập kế hoạch sprint
/pm-sprint-status   - Xem trạng thái sprint
/pm-retro           - Retrospective
/pm-correct-course  - Điều chỉnh hướng đi
```

### Architect
```
/arch-create          - Tạo architecture
/arch-diagram         - Tạo diagram
/arch-dataflow        - Data flow diagram
/arch-flowchart       - Flowchart
/arch-context         - Generate project context
/arch-check-readiness - Kiểm tra sẵn sàng implement
```

### Dev Backend
```
/dev-be-story        - Implement story
/dev-be-review       - Code review
/dev-be-quick        - Quick dev
/dev-be-create-story - Tạo story (dev)
/dev-be-docs         - Document project
```

### Dev Frontend
```
/dev-fe-ux        - Tạo UX design
/dev-fe-wireframe - Tạo wireframe
/dev-fe-spec      - Quick spec
```

### QA
```
/qa-automate - QA automation
```

---

## 🤖 Agents

Load agent để có context phù hợp với role:
```
/bmad-agent-ba     - Business Analyst
/bmad-agent-arch   - Architect
/bmad-agent-dev    - Developer
/bmad-agent-pm     - Product Manager
/bmad-agent-sm     - Scrum Master
/bmad-agent-ux     - UX Designer
/bmad-agent-writer - Tech Writer
/bmad-agent-quinn  - Quality Engineer
/bmad-agent-solo   - Solo Dev (full-stack)
```

---

## 🚀 Quick Start Cho Từng Role

### Nếu bạn là BA:
1. Mở Claude Code trong `demo-structure`
2. Gõ `/bmad-agent-ba` để load BA agent
3. Gõ `/ba-create-brief` để bắt đầu tạo product brief

### Nếu bạn là PM:
1. Gõ `/bmad-agent-pm` để load PM agent
2. Gõ `/pm-create-prd` để tạo PRD
3. Gõ `/pm-sprint-planning` để lập kế hoạch sprint

### Nếu bạn là Developer:
1. Gõ `/bmad-agent-dev` để load Dev agent
2. Gõ `/dev-be-story` để implement story
3. Gõ `/dev-be-review` để code review

### Nếu bạn là Architect:
1. Gõ `/bmad-agent-arch` để load Architect agent
2. Gõ `/arch-create` để tạo architecture
3. Gõ `/arch-diagram` để tạo diagrams

---

## 📁 Cấu Trúc Thư Mục

```
demo-structure/
├── .claude/
│   ├── commands/      ← Slash commands (41 files)
│   ├── agents/        ← Custom agents
│   ├── hooks/         ← Automation hooks
│   ├── scripts/       ← Helper scripts
│   └── skills/        ← Skills (ui-ux-pro-max)
├── _bmad/
│   ├── core/          ← BMAD core framework
│   └── bmm/           ← BMM module (workflows, agents)
├── _bmad-output/      ← Generated artifacts
├── docs/              ← Documentation
└── README.md
```

---

## ❓ Cần Trợ Giúp?

- Gõ `/bmad-help` để được hướng dẫn
- Đọc thêm tại `docs/bmad_onboarding/`
