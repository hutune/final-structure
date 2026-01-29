---
clickup_workspace_id: "90182277854"
clickup_doc_id: "2kzmgppy-1378"
clickup_page_id: "2kzmgppy-2198"
title: "Developer Setup Guide"
---

# Team Onboarding Guide - RMN Platform Setup

> **Mục đích**: Hướng dẫn setup môi trường cho team members khi clone project từ GitHub hoặc Google Drive

---

## 📋 Tổng Quan

Project này sử dụng:
- **BMAD Method** - AI-driven development framework với 47 workflows và 10 agents
- **Everything Claude Code** - Automation tools với learning system
- **GitHub Actions** - Tự động sync với ClickUp
- **Google Drive Sync** - Backup và collaboration

## 🔑 Điều Kiện Tiên Quyết

### 1. Công Cụ Cần Cài

```bash
# macOS
brew install git gh node python3

# Kiểm tra versions
git --version      # >= 2.30
node --version     # >= 18
python3 --version  # >= 3.9
gh --version       # >= 2.0
```

### 2. VS Code Extensions

**Bắt buộc:**
- Anthropic Claude for Code
- (Hoặc) Claude AI hoặc tương tự có hỗ trợ `.agent/` và `.claude/` folders

**Khuyến nghị:**
- YAML
- Markdown All in One
- GitLens

---

## 🚀 Setup Từ GitHub

### Bước 1: Clone Repository

```bash
cd ~/Projects  # hoặc folder bạn muốn
git clone https://github.com/hutune/demo-structure.git
cd demo-structure
```

### Bước 2: Kiểm Tra Cấu Trúc

```bash
ls -la

# Bạn sẽ thấy:
# .agent/              ← 47 BMAD workflows
# .claude/             ← ECC agents, skills, commands, hooks
# .github/workflows/   ← ClickUp sync automation
# _bmad/               ← BMAD framework (303 files)
# _bmad-output/        ← Epics, stories, artifacts
# docs/                ← Documentation
# README.md
```

### Bước 3: Git Configuration

```bash
# Cấu hình git user (dùng company email)
git config user.name "Your Name"
git config user.email "your.email@kwayvina.com"

# Test
git config user.name
git config user.email
```

**⚠️ QUAN TRỌNG**: Email này phải khớp với email trong ClickUp để auto-assign hoạt động!

---

## 🔐 Setup GitHub Credentials

### Bước 1: Tạo Personal Access Token (PAT)

1. Truy cập: https://github.com/settings/tokens
2. Click **Generate new token** → **Generate new token (classic)**
3. Settings:
   - **Note**: `RMN Platform Development`
   - **Expiration**: 90 days (hoặc theo policy công ty)
   - **Scopes**: Chọn:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Actions workflows)
4. Click **Generate token**
5. **Copy token ngay** (chỉ hiện 1 lần): `ghp_xxxxxxxxxxxx...`

### Bước 2: Authenticate GitHub CLI

```bash
# Login với token
gh auth login

# Chọn:
# ? What account do you want to log into? → GitHub.com
# ? What is your preferred protocol? → HTTPS
# ? Authenticate Git with your GitHub credentials? → Yes
# ? How would you like to authenticate? → Paste an authentication token
# → Paste token vừa copy

# Verify
gh auth status
```

---

## 🔐 Setup ClickUp Integration

### ⚠️ QUAN TRỌNG: Credentials Không Được Push Lên GitHub!

File `.github/workflows/sync-clickup.yml` sử dụng GitHub Secrets. Bạn **KHÔNG CẦN** và **KHÔNG NÊN** lưu ClickUp API key vào code.

### Cho Admin/Owner (Setup 1 lần cho cả team):

**1. Lấy ClickUp API Key:**
- Truy cập: https://app.clickup.com/90182277854/settings/apps
- Scroll xuống **API Token**
- Click **Generate** (nếu chưa có)
- Copy token: `pk_xxxxxxxxxxxxx...`

**2. Thêm vào GitHub Secrets:**
```bash
# Cách 1: Qua GitHub CLI (khuyến nghị)
gh secret set CLICKUP_API_KEY

# Paste token khi được hỏi
# ✓ Set secret CLICKUP_API_KEY

# Cách 2: Qua Web UI
# 1. https://github.com/hutune/demo-structure/settings/secrets/actions
# 2. New repository secret
# 3. Name: CLICKUP_API_KEY
# 4. Value: pk_xxxxx...
# 5. Add secret
```

**3. Verify Secret:**
```bash
gh secret list

# Output:
# CLICKUP_API_KEY  Updated YYYY-MM-DD
```

### Cho Team Members (Không cần làm gì):

✅ **Bạn KHÔNG CẦN ClickUp API key!**  
✅ GitHub Actions tự động chạy khi bạn push code  
✅ Chỉ cần đảm bảo email git của bạn đã được config trong workflow

### Thêm Email Mới Vào Auto-Assign

**Admin cần làm:**

1. Lấy ClickUp User ID của member:
```bash
curl -H "Authorization: pk_xxxxx" \
  "https://api.clickup.com/api/v2/team" | \
  jq '.teams[0].members[] | {email: .user.email, id: .user.id}'
```

2. Update workflow file `.github/workflows/sync-clickup.yml`:
```yaml
env:
  EMAIL_TO_CLICKUP_ID: "work.huutrung@gmail.com:300697285,mazhnguyen@kwayvina.com:300697285,NEW_EMAIL:NEW_ID"
```

3. Commit và push:
```bash
git add .github/workflows/sync-clickup.yml
git commit -m "feat: Add new team member to ClickUp sync"
git push
```

---

## 🧪 Test Setup

### Test 1: Git & GitHub

```bash
# Kiểm tra remote
git remote -v

# Output:
# origin  https://github.com/hutune/demo-structure.git (fetch)
# origin  https://github.com/hutune/demo-structure.git (push)

# Test push (dry-run)
git push --dry-run
```

### Test 2: BMAD Workflows

1. Mở VS Code trong folder project
2. Open Command Palette (Cmd+Shift+P)
3. Gõ: `@bmad-help`
4. Bạn sẽ thấy danh sách 47 workflows

**Thử workflow đơn giản:**
```
@bmad-brainstorming
```

### Test 3: Everything CC Commands

Trong VS Code chat hoặc Claude Code:
```
/instinct-status
```

Output sẽ hiện danh sách learned patterns (hoặc empty nếu mới setup).

### Test 4: ClickUp Sync (E2E Test)

**Tạo Epic mới:**

1. Tạo file: `_bmad-output/epics/test-epic.md`
```yaml
---
id: "EPIC-TEST-001"
title: "Test Epic for Onboarding"
status: "to-do"
assigned_to: "your.email@kwayvina.com"
clickup_task_id: null
---

## Description
This is a test epic to verify ClickUp integration.

## Goals
- [ ] Verify GitHub Action triggers
- [ ] Verify task created in ClickUp
- [ ] Verify ID written back to file
```

2. Commit và push:
```bash
git add _bmad-output/epics/test-epic.md
git commit -m "test: Create test epic for onboarding"
git push
```

3. Kiểm tra GitHub Actions:
```bash
gh run list --limit 1
# Hoặc: https://github.com/hutune/demo-structure/actions
```

4. Đợi ~30 giây, sau đó pull về:
```bash
git pull
```

5. Kiểm tra file `_bmad-output/epics/test-epic.md`:
```yaml
clickup_task_id: "xxxxx"  # ← Đã có ID!
```

6. Kiểm tra ClickUp:
- https://app.clickup.com/90182277854/v/li/901815396322
- Tìm task `[epic] Test Epic for Onboarding`
- Verify assignee là bạn

**✅ Nếu thấy task → Setup thành công!**

---

## 📚 Daily Workflow

### Tạo Epic Mới

```bash
# 1. Pull latest
git pull

# 2. Tạo file trong _bmad-output/epics/
cat > _bmad-output/epics/my-epic.md << 'EOF'
---
id: "EPIC-XXX"
title: "Your Epic Name"
status: "to-do"
assigned_to: "your.email@kwayvina.com"
clickup_task_id: null
---

## Description
...
EOF

# 3. Commit & push
git add _bmad-output/epics/my-epic.md
git commit -m "feat: Add Epic XXX"
git push

# 4. Wait 30s, then pull
git pull
```

### Tạo User Story

```bash
cat > _bmad-output/stories/story-1-1.md << 'EOF'
---
id: "STORY-1.1"
epic_id: "EPIC-XXX"
title: "Your Story Name"
status: "to-do"
assigned_to: "your.email@kwayvina.com"
clickup_task_id: null
---

## Acceptance Criteria
- [ ] ...
EOF

git add _bmad-output/stories/story-1-1.md
git commit -m "feat: Add Story 1.1"
git push && sleep 30 && git pull
```

### Sử Dụng BMAD Workflows

**Planning:**
```
@bmad-bmm-pm                # Project Manager workflows
@bmad-bmm-create-prd        # Create Product Requirements
@bmad-bmm-create-epics-and-stories  # Break down epics
```

**Development:**
```
@bmad-bmm-architect         # System architecture
@bmad-bmm-dev-story         # Implement a story
@bmad-bmm-code-review       # Code review
```

**Documentation:**
```
@bmad-bmm-document-project  # Generate documentation
@bmad-bmm-create-excalidraw-diagram  # Create diagrams
```

### Sử Dụng ECC Commands

```
/instinct-status    # Check learned patterns
/tdd                # TDD workflow
/build-fix          # Fix build errors
/refactor-clean     # Code refactoring
/security-scan      # Security analysis
/verify             # Verification loop
```

---

## 🔧 Troubleshooting

### Issue: Git push bị từ chối

```
error: failed to push some refs
```

**Fix:**
```bash
git pull --rebase
git push
```

### Issue: GitHub Action không trigger

**Check:**
```bash
# 1. Verify file path
ls -la _bmad-output/epics/
ls -la _bmad-output/stories/

# 2. Check workflow file tồn tại
ls -la .github/workflows/sync-clickup.yml

# 3. Check Actions enabled
gh workflow list
```

**Enable workflow nếu disabled:**
```bash
gh workflow enable "Sync BMAD Artifacts to ClickUp"
```

### Issue: ClickUp task không được tạo

**Debug:**

1. Check GitHub Actions logs:
```bash
gh run view --log
# Hoặc: https://github.com/hutune/demo-structure/actions
```

2. Common errors:
   - `API Error`: Check CLICKUP_API_KEY secret
   - `401 Unauthorized`: Token expired, regenerate
   - `File not changed`: Workflow chỉ trigger khi file thay đổi

3. Manual sync test:
```bash
# Clone và test locally
export CLICKUP_API_KEY="pk_xxxxx"
export EPICS_LIST="901815396322"
export STORIES_LIST="901815396340"

# Run script từ workflow
bash .github/workflows/sync-clickup.yml  # (needs extraction)
```

### Issue: Email không auto-assign

**Check:**

1. Git email config:
```bash
git config user.email
# Must match email in ClickUp
```

2. Email mapping trong workflow:
```bash
grep "EMAIL_TO_CLICKUP_ID" .github/workflows/sync-clickup.yml
```

3. Nếu email chưa có → Liên hệ admin để thêm vào mapping.

### Issue: BMAD commands không hoạt động

**Check:**

1. Folder structure:
```bash
ls -la .agent/workflows/  # 47 workflows phải có
ls -la _bmad/             # Framework files
```

2. VS Code extension:
- Kiểm tra Claude extension đã cài
- Restart VS Code
- Check extension logs

---

## 📖 Documentation Links

**Local Docs:**
- [Quick Start](../docs-chua-sap-xep/QUICK-START.md)
- [Setup Complete](../docs-chua-sap-xep/SETUP-COMPLETE.md)
- [Commands Architecture](../docs-chua-sap-xep/COMMANDS-ARCHITECTURE.md)
- [Hooks & Scripts Guide](../docs-chua-sap-xep/HOOKS-SCRIPTS-GUIDE.md)
- [ClickUp Integration](./CLICKUP-INTEGRATION-SETUP.md)

**External Resources:**
- [BMAD Method](https://github.com/affaan-m/bmad-method)
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code)
- [GitHub CLI Docs](https://cli.github.com/manual/)
- [ClickUp API](https://clickup.com/api)

---

## 🆘 Getting Help

**Team Chat:** [Your Slack/Discord/Teams channel]  
**Issues:** https://github.com/hutune/demo-structure/issues  
**Admin Contact:** work.huutrung@gmail.com

**Checklist trước khi hỏi:**
- [ ] Đã đọc docs trên
- [ ] Đã check GitHub Actions logs
- [ ] Đã verify git config
- [ ] Đã pull latest code
- [ ] Provide error messages/screenshots

---

## ✅ Setup Checklist

Copy checklist này và gửi cho lead khi hoàn thành:

```
Setup Checklist - [Your Name]

Prerequisites:
- [ ] Git installed (version: ___)
- [ ] GitHub CLI installed (version: ___)
- [ ] Node.js installed (version: ___)
- [ ] Python installed (version: ___)
- [ ] VS Code with Claude extension

GitHub Setup:
- [ ] Cloned repository
- [ ] Git user.name configured
- [ ] Git user.email configured (email: ___)
- [ ] GitHub PAT created and saved securely
- [ ] `gh auth login` successful
- [ ] Test push successful

ClickUp Setup:
- [ ] Email added to EMAIL_TO_CLICKUP_ID mapping
- [ ] ClickUp account created (email: ___)
- [ ] Test epic created and synced
- [ ] Verified task appears in ClickUp

Verification:
- [ ] BMAD commands working (@bmad-help)
- [ ] ECC commands working (/instinct-status)
- [ ] GitHub Actions triggering successfully
- [ ] Can create and sync tasks

Ready to work: [ ] YES / [ ] NO (issues: ___)
```

---

**Last Updated**: January 29, 2026  
**Version**: 1.0  
**Maintainer**: work.huutrung@gmail.com

---

**Last Updated:** 2026-01-29 16:51:45
