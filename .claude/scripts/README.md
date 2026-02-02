# Scripts

Thư mục này chứa các helper scripts cho Claude Code.

## Scripts có sẵn

| Script | Mô tả |
|--------|-------|
| `setup.sh` | Setup môi trường development |
| `validate.sh` | Validate project structure |

## Cách sử dụng

Scripts có thể được gọi từ commands hoặc hooks:

```bash
# Từ terminal
./scripts/setup.sh

# Từ Claude Code command
bash scripts/validate.sh
```

## Thêm Script mới

1. Tạo file script trong thư mục này
2. Chmod +x để có quyền execute
3. Document trong README này
