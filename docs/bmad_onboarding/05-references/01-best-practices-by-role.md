---
clickup_workspace_id: "90182277854"
type: "page"
title: "Best Practices by Role"
clickup_parent_doc_id: "2kzmgppy-2038"
---

# 🎯 Best Practices Theo Từng Role

Hướng dẫn sử dụng BMAD hiệu quả cho từng vai trò trong team.

---

## 📊 Mary - Business Analyst

**Khi nào dùng:** Giai đoạn Analysis, research và tạo product brief

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Dùng `/research` trước khi tạo brief | Skip research, tạo brief từ assumption |
| Validate brief với `/brainstorming` | Làm solo không hỏi stakeholder |
| Document findings trong `planning_artifacts/` | Để thông tin rời rạc nhiều nơi |

### Workflow Thường Dùng

```
/research → /create-product-brief → /brainstorming
```

### Nguyên Tắc Vàng
> *"Every business challenge has root causes waiting to be discovered. Ground findings in verifiable evidence."*

---

## 📋 John - Product Manager

**Khi nào dùng:** Giai đoạn Planning, tạo PRD và quản lý requirements

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Hỏi "WHY?" cho mọi requirement | Accept vague requirements |
| Làm PRD từ user interviews | Copy-paste từ template |
| Ship smallest thing first | Over-engineering từ đầu |

### Workflow Thường Dùng

```
/create-prd → validate → /create-epics-and-stories
```

### Nguyên Tắc Vàng
> *"PRDs emerge from user interviews, not template filling. Technical feasibility is a constraint, not the driver."*

---

## 🏗️ Winston - Architect

**Khi nào dùng:** Giai đoạn Solutioning, thiết kế hệ thống

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Connect mọi quyết định với business value | Over-architect từ đầu |
| Embrace boring technology | Chọn tech vì "cool" |
| Design simple, scale when needed | Premature optimization |

### Workflow Thường Dùng

```
/create-architecture → /check-implementation-readiness
```

### Nguyên Tắc Vàng
> *"User journeys drive technical decisions. Developer productivity is architecture."*

---

## 💻 Amelia - Developer

**Khi nào dùng:** Giai đoạn Implementation, code và test

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Follow story details strictly | Improvise ngoài AC |
| Write tests BEFORE marking task complete | Skip tests "để sau" |
| Ultra-succinct commits | Vague commit messages |

### Workflow Thường Dùng

```
/dev-story → /code-review → fix → repeat
```

### Nguyên Tắc Vàng
> *"All tests must pass 100% before story is ready for review. Every task must be covered by comprehensive unit tests."*

---

## 🏃 Bob - Scrum Master

**Khi nào dùng:** Sprint planning, story management, retrospectives

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Crystal clear story definition | Vague acceptance criteria |
| Checklist-driven approach | Ad-hoc task management |
| Run retrospective sau mỗi epic | Skip retro "vì bận" |

### Workflow Thường Dùng

```
/sprint-planning → /create-story → /sprint-status → /retrospective
```

### Nguyên Tắc Vàng
> *"Zero tolerance for ambiguity. Every word has a purpose, every requirement crystal clear."*

---

## 🧪 Murat - Test Architect

**Khi nào dùng:** Test strategy, automation, quality gates

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Risk-based testing | Test everything equally |
| Prefer unit > integration > E2E | Only E2E tests |
| Treat flakiness as critical debt | Ignore flaky tests |

### Workflow Thường Dùng

```
/testarch-test-design → /testarch-framework → /testarch-automate
```

### Nguyên Tắc Vàng
> *"Quality gates backed by data. Calculate risk vs value for every testing decision."*

---

## 🎨 Sally - UX Designer

**Khi nào dùng:** UI/UX design, wireframes, user research

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Start simple, evolve through feedback | Perfect từ đầu |
| Every decision serves user needs | Design vì "đẹp" |
| Use Excalidraw cho wireframes | Heavy mockup tools |

### Workflow Thường Dùng

```
/create-ux-design → /create-excalidraw-wireframe
```

### Nguyên Tắc Vàng
> *"Data-informed but always creative. Balance empathy with edge case attention."*

---

## 🚀 Barry - Quick Flow Solo Dev

**Khi nào dùng:** Quick tasks, small changes, utilities - KHÔNG dùng cho complex projects

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Dùng cho 1-off tasks | Dùng cho complex features |
| Follow `project-context.md` nếu có | Ignore existing context |
| Minimum ceremony | Over-document small tasks |

### Workflow Thường Dùng

```
/quick-spec → /quick-dev
```

### Nguyên Tắc Vàng
> *"Specs are for building, not bureaucracy. Code that ships is better than perfect code that doesn't."*

---

## 📚 Paige - Technical Writer

**Khi nào dùng:** Documentation, knowledge curation

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Clarity above all | Overly wordy text |
| Diagrams > 1000 words | Walls of text |
| Know your audience | One-size-fits-all docs |

### Nguyên Tắc Vàng
> *"Every document helps someone accomplish a task. A picture/diagram is worth 1000 words."*

---

## 🧙 BMad Master

**Khi nào dùng:** Orchestration, runtime resource management, workflow guidance

### Best Practices

| ✅ Nên Làm | ❌ Không Nên |
|-----------|-------------|
| Dùng `/bmad-help` khi stuck | Guess next steps |
| Load resources at runtime | Pre-load everything |
| Follow numbered lists | Skip suggested steps |

### Workflow Hub

```
/bmad-help → shows available workflows → pick appropriate one
```

### Nguyên Tắc Vàng
> *"Load resources at runtime, never pre-load. Always present numbered lists for choices."*
