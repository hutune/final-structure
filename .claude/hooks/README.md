# Hooks

Thư mục này chứa các hooks cho Claude Code.

## Hooks là gì?

Hooks là scripts tự động chạy khi có events nhất định trong Claude Code:
- `pre-commit` - Trước khi commit
- `post-session` - Sau khi kết thúc session
- `on-error` - Khi có lỗi

## Cấu trúc

```
hooks/
├── pre-commit.js     # Chạy trước commit
├── post-session.js   # Chạy sau session
└── evaluate-session.js # Đánh giá session
```

## Ví dụ Hook

```javascript
// pre-commit.js
export default async function preCommit({ files, message }) {
  // Validate commit message
  if (!message.match(/^(feat|fix|docs|test|refactor):/)) {
    throw new Error('Commit message phải theo conventional commits');
  }
  return { proceed: true };
}
```
