# 📺 Quy tắc Nghiệp vụ: Quản lý Thiết bị

**Phiên bản**: 1.0  
**Ngày**: 2026-01-23  
**Trạng thái**: Bản nháp  
**Chủ quản**: Product Team

---

## 📖 Mục lục

1. [Tổng quan](#-tổng-quan)
2. [Các thực thể Thiết bị](#-các-thực-thể-thiết-bị)
3. [Vòng đời Thiết bị](#-vòng-đời-thiết-bị)
4. [Quy tắc Sở hữu & Chuyển giao](#-quy-tắc-sở-hữu--chuyển-giao)
5. [Sức khỏe & Uptime](#-sức-khỏe--uptime)
6. [Heartbeat & Giám sát](#-heartbeat--giám-sát)
7. [Đồng bộ Nội dung](#-đồng-bộ-nội-dung)
8. [Quản lý Phát](#-quản-lý-phát)
9. [Cấu hình Thiết bị](#-cấu-hình-thiết-bị)
10. [Phát hiện Gian lận & Bảo mật](#-phát-hiện-gian-lận--bảo-mật)
11. [Các trường hợp đặc biệt](#-các-trường-hợp-đặc-biệt)
12. [Quy tắc Kiểm tra](#-quy-tắc-kiểm-tra)
13. [Công thức Tính toán](#-công-thức-tính-toán)

---

## 🎯 Tổng quan

### Mục đích

Tài liệu này định nghĩa **TẤT CẢ** quy tắc nghiệp vụ cho module Quản lý Thiết bị trong nền tảng RMN-Arms. Thiết bị là màn hình kỹ thuật số vật lý (digital signage) hiển thị nội dung quảng cáo tại các cửa hàng bán lẻ.

| Đối tượng | Mục đích sử dụng |
|-----------|------------------|
| 📋 **Product Team** | Hiểu quy trình thiết bị |
| 👨‍💻 **Developer** | Tham chiếu khi code |
| 🔧 **Supplier** | Quản lý thiết bị của mình |
| 🧪 **QA Team** | Tạo test case |

### Phạm vi

**Bao gồm:**
- ✅ Đăng ký và kích hoạt thiết bị
- ✅ Quản lý vòng đời thiết bị
- ✅ Giám sát sức khỏe & heartbeat
- ✅ Đồng bộ nội dung
- ✅ Lên lịch phát quảng cáo
- ✅ Cấu hình thiết bị
- ✅ Phát hiện gian lận & bảo mật
- ✅ Bảo trì và khắc phục sự cố

**KHÔNG bao gồm:**
- ❌ Quản lý chiến dịch (xem module Campaign)
- ❌ Tạo/upload nội dung (xem module CMS)
- ❌ Tính phí chi tiết (xem module Billing)
- ❌ Quản lý cửa hàng (xem module Supplier)

---

## 📦 Các thực thể Thiết bị

### 1. Device (Thiết bị)

> **Định nghĩa**: Một màn hình kỹ thuật số vật lý được lắp đặt tại cửa hàng bán lẻ để phát nội dung quảng cáo.

#### Các thuộc tính

| Trường | Kiểu dữ liệu | Bắt buộc | Mặc định | Quy tắc |
|--------|--------------|----------|----------|---------|
| `id` | UUID | Có | Tự động | Không thay đổi sau khi tạo |
| `device_code` | String(20) | Có | Tự động | Duy nhất toàn cầu, chữ & số |
| `device_name` | String(100) | Không | "Device {code}" | Tên dễ đọc |
| `store_id` | UUID | Có | - | Phải là cửa hàng đã đăng ký |
| `supplier_id` | UUID | Có | Từ store | Chỉ đọc, kế thừa từ CH |
| `device_type` | Enum | Có | DISPLAY | Xem [Loại Thiết bị](#loại-thiết-bị) |
| `status` | Enum | Có | REGISTERED | Xem [Vòng đời](#vòng-đời-trạng-thái) |
| `screen_size_inches` | Integer | Có | - | Từ 32-100 inch |
| `screen_resolution` | String(20) | Có | - | Định dạng: "WIDTHxHEIGHT" (vd: "1920x1080") |
| `screen_orientation` | Enum | Có | LANDSCAPE | LANDSCAPE / PORTRAIT |
| `hardware_model` | String(50) | Không | null | Model phần cứng |
| `os_type` | Enum | Có | - | ANDROID / WINDOWS / LINUX / WEBOS / TIZEN |
| `os_version` | String(20) | Không | null | Phiên bản hệ điều hành |
| `player_version` | String(20) | Không | null | Phiên bản app player |
| `mac_address` | String(17) | Không | null | Định dạng: XX:XX:XX:XX:XX:XX |
| `ip_address` | String(45) | Không | null | IPv4 hoặc IPv6 |
| `public_key` | Text | Có | Tự tạo | RSA 2048-bit cho chữ ký |
| `location` | GeoJSON | Không | null | Tọa độ GPS nếu có |
| `advertising_slots_per_hour` | Integer | Có | 12 | Từ 6-60 slot |
| `max_content_duration` | Integer | Có | 60 | Thời lượng tối đa (10-300 giây) |
| `operating_hours` | JSON | Có | 24/7 | Giờ hoạt động của CH |
| `timezone` | String(50) | Có | - | IANA timezone (vd: "Asia/Ho_Chi_Minh") |
| `last_heartbeat_at` | DateTime | Không | null | Lần heartbeat cuối |
| `last_sync_at` | DateTime | Không | null | Lần đồng bộ nội dung cuối |
| `last_impression_at` | DateTime | Không | null | Lần phát QC cuối |
| `total_uptime_minutes` | Integer | Có | 0 | Tổng thời gian online |
| `total_downtime_minutes` | Integer | Có | 0 | Tổng thời gian offline |
| `uptime_percentage` | Decimal(5,2) | Có | 0.00 | Tính: uptime / (uptime + downtime) × 100 |
| `total_impressions` | Integer | Có | 0 | Tổng lượt hiển thị trọn đời |
| `total_revenue_generated` | Decimal(10,2) | Có | 0.00 | Tổng doanh thu supplier |
| `health_score` | Integer | Có | 100 | Từ 0-100, chỉ số tổng hợp |
| `flags` | JSON | Có | {} | Cờ hệ thống: suspicious, needs_maintenance |
| `metadata` | JSON | Không | {} | Dữ liệu tùy chỉnh |
| `registered_at` | DateTime | Có | BÂY GIỜ | Không thay đổi |
| `activated_at` | DateTime | Không | null | Khi status = ACTIVE |
| `decommissioned_at` | DateTime | Không | null | Khi status = DECOMMISSIONED |
| `created_at` | DateTime | Có | BÂY GIỜ | Không thay đổi |
| `updated_at` | DateTime | Có | BÂY GIỜ | Tự động cập nhật |

#### Loại Thiết bị

```
DISPLAY         → Màn hình kỹ thuật số chuẩn
VIDEO_WALL      → Tường màn hình đa màn (tính là 1 thiết bị)
KIOSK           → Kiosk tương tác có màn cảm ứng
TABLET          → Máy tính bảng
SMART_TV        → Smart TV có player tích hợp
LED_BOARD       → Bảng LED quảng cáo
```

#### Vòng đời Trạng thái

```
REGISTERED → ACTIVE → OFFLINE → MAINTENANCE → ACTIVE
                                         ↓
                                  DECOMMISSIONED
```

**Mô tả trạng thái:**

| Trạng thái | Tiếng Việt | Giải thích |
|------------|------------|------------|
| `REGISTERED` | Đã đăng ký | Đăng ký nhưng chưa kích hoạt (trạng thái ban đầu) |
| `ACTIVE` | Đang hoạt động | Online và đang phát QC |
| `OFFLINE` | Mất kết nối | Không phản hồi heartbeat (tạm thời) |
| `MAINTENANCE` | Bảo trì | Đang bảo trì (downtime có kế hoạch) |
| `DECOMMISSIONED` | Ngừng hoạt động | Loại bỏ vĩnh viễn khỏi dịch vụ |

---

### 2. DeviceHeartbeat (Tín hiệu Sống)

> **Định nghĩa**: Bản ghi kiểm tra sức khỏe định kỳ do thiết bị gửi đến server.

**Heartbeat là gì?**  
Giống như nhịp tim con người, thiết bị cần "gửi tín hiệu sống" đều đặn cho server để báo rằng: "Tôi vẫn hoạt động tốt". Nếu thiết bị không gửi tín hiệu này, hệ thống hiểu rằng có sự cố.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc |
|--------|------|----------|---------|
| `id` | UUID | Có | Tự động |
| `device_id` | UUID | Có | Phải là thiết bị đã đăng ký |
| `timestamp` | DateTime | Có | Timestamp server (UTC) |
| `device_timestamp` | DateTime | Có | Giờ địa phương của thiết bị |
| `status` | Enum | Có | ONLINE / DEGRADED / ERROR |
| `cpu_usage` | Integer | Không | 0-100 (phần trăm) |
| `memory_usage` | Integer | Không | 0-100 (phần trăm) |
| `disk_usage` | Integer | Không | 0-100 (phần trăm) |
| `network_latency_ms` | Integer | Không | Độ trễ mạng (milliseconds) |
| `screen_on` | Boolean | Có | Màn hình có bật không |
| `content_playing` | Boolean | Có | Có đang phát nội dung không |
| `current_playlist_id` | UUID | Không | Playlist đang tải |
| `error_count` | Integer | Có | Số lỗi từ lần heartbeat trước |
| `error_messages` | JSON | Không | Danh sách thông báo lỗi |
| `location` | GeoJSON | Không | Tọa độ GPS tại thời điểm gửi |
| `ip_address` | String(45) | Có | Địa chỉ IP hiện tại |

---

### 3. DeviceContentSync (Đồng bộ Nội dung)

> **Định nghĩa**: Bản ghi quá trình đồng bộ nội dung giữa server và thiết bị.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc |
|--------|------|----------|---------|
| `id` | UUID | Có | Tự động |
| `device_id` | UUID | Có | Thiết bị đích |
| `sync_type` | Enum | Có | FULL / INCREMENTAL / FORCED |
| `status` | Enum | Có | PENDING / IN_PROGRESS / COMPLETED / FAILED |
| `total_files` | Integer | Có | Số file cần đồng bộ |
| `synced_files` | Integer | Có | Số file đã hoàn thành |
| `total_bytes` | BigInt | Có | Tổng dung lượng cần tải |
| `synced_bytes` | BigInt | Có | Dung lượng đã tải |
| `bandwidth_kbps` | Integer | Không | Tốc độ truyền |
| `started_at` | DateTime | Có | Bắt đầu đồng bộ |
| `completed_at` | DateTime | Không | Hoàn thành đồng bộ |
| `error_message` | Text | Không | Chi tiết lỗi nếu thất bại |
| `retry_count` | Integer | Có | Số lần thử lại (mặc định: 0) |

---

### 4. DevicePlaylist (Danh sách Phát)

> **Định nghĩa**: Hàng đợi nội dung đã lên lịch cho thiết bị.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc |
|--------|------|----------|---------|
| `id` | UUID | Có | Tự động |
| `device_id` | UUID | Có | Thiết bị đích |
| `campaign_id` | UUID | Có | Chiến dịch nguồn |
| `content_asset_id` | UUID | Có | Nội dung cần phát |
| `priority` | Integer | Có | 1-10 (10 = cao nhất) |
| `weight` | Integer | Có | Tần suất tương đối (1-100) |
| `start_date` | DateTime | Có | Bắt đầu hiển thị |
| `end_date` | DateTime | Có | Dừng hiển thị |
| `time_restrictions` | JSON | Không | Nhắm mục tiêu theo ngày/giờ |
| `play_count` | Integer | Có | Số lần đã phát (mặc định: 0) |
| `last_played_at` | DateTime | Không | Thời gian impression cuối |
| `status` | Enum | Có | PENDING / ACTIVE / COMPLETED / EXPIRED |
| `created_at` | DateTime | Có | Không thay đổi |

---

### 5. DeviceMaintenanceLog (Nhật ký Bảo trì)

> **Định nghĩa**: Bản ghi hoạt động bảo trì thiết bị.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc |
|--------|------|----------|---------|
| `id` | UUID | Có | Tự động |
| `device_id` | UUID | Có | Thiết bị được bảo trì |
| `maintenance_type` | Enum | Có | SCHEDULED / EMERGENCY / FIRMWARE_UPDATE |
| `performed_by` | UUID | Có | ID người dùng hoặc admin |
| `started_at` | DateTime | Có | Bắt đầu bảo trì |
| `completed_at` | DateTime | Không | Kết thúc bảo trì |
| `duration_minutes` | Integer | Không | Tính từ start/end |
| `description` | Text | Có | Công việc đã làm |
| `notes` | Text | Không | Ghi chú thêm |
| `parts_replaced` | JSON | Không | Linh kiện thay thế |
| `cost` | Decimal(10,2) | Không | Chi phí bảo trì |
| `status` | Enum | Có | SCHEDULED / IN_PROGRESS / COMPLETED / CANCELLED |

---

## 🔄 Vòng đời Thiết bị

### 1. Quy trình Đăng ký

```
┌─────────────────────────────────────────────────────────────────┐
│                  QUY TRÌNH ĐĂNG KÝ THIẾT BỊ                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bước 1: Tạo Mã Thiết bị                                       │
│  ────────────────────────                                       │
│  Người thực hiện: Supplier hoặc Hệ thống                       │
│  Kích hoạt: Cần đăng ký thiết bị mới                           │
│                                                                 │
│  Quy trình:                                                     │
│  1. Tạo device_code duy nhất:                                  │
│     code = tạo_mã_ngẫu_nhiên(16)                               │
│     Định dạng: "DVC-XXXX-XXXX-XXXX"                            │
│                                                                 │
│  2. Kiểm tra tính duy nhất:                                    │
│     WHILE TỒN TẠI(device_code):                                │
│       code = tạo_mã_mới()                                      │
│                                                                 │
│  3. Tạo cặp khóa RSA (2048-bit):                               │
│     (private_key, public_key) = tạo_rsa_keypair()              │
│     Lưu public_key vào database                                │
│     Trả private_key cho thiết bị (CHỈ 1 LẦN)                  │
│                                                                 │
│  4. Tạo bản ghi thiết bị:                                      │
│     Device {                                                    │
│       id: UUID,                                                 │
│       device_code: code,                                        │
│       status: REGISTERED,                                       │
│       store_id: null,                                           │
│       public_key: public_key,                                   │
│       created_at: BÂY GIỜ                                      │
│     }                                                            │
│                                                                 │
│  Quy tắc nghiệp vụ:                                            │
│  • Device code phải duy nhất toàn cầu                          │
│  • Private key chỉ hiển thị 1 lần (không thể khôi phục)       │
│  • Thiết bị bắt đầu ở trạng thái REGISTERED                    │
│  • Không thể sử dụng cho đến khi gán vào cửa hàng             │
│                                                                 │
│  Kết quả:                                                       │
│  • device_id                                                    │
│  • device_code (để tạo mã QR)                                  │
│  • private_key (QUAN TRỌNG: lưu an toàn)                       │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  Bước 2: Tạo Mã QR                                             │
│  ────────────────────                                           │
│  Người thực hiện: Hệ thống                                     │
│  Đầu vào: device_code                                          │
│                                                                 │
│  Quy trình:                                                     │
│  1. Tạo dữ liệu QR:                                            │
│     qr_data = {                                                 │
│       "device_code": device_code,                               │
│       "registration_url": "https://rmn-arms.com/device/...",   │
│       "activation_key": tạo_mã_kích_hoạt()                     │
│     }                                                            │
│                                                                 │
│  2. Mã hóa thành QR code:                                      │
│     qr_image = tạo_qr_code(json.stringify(qr_data))            │
│                                                                 │
│  3. Lưu activation key:                                        │
│     ActivationKey {                                             │
│       device_code: device_code,                                 │
│       activation_key: activation_key,                           │
│       expires_at: BÂY GIỜ + 30 ngày,                           │
│       status: UNUSED                                            │
│     }                                                            │
│                                                                 │
│  Quy tắc nghiệp vụ:                                            │
│  • Activation key hết hạn sau 30 ngày                          │
│  • QR code có thể in và gửi kèm thiết bị                       │
│  • Mã kích hoạt dùng 1 lần                                     │
│  • QR chứa hướng dẫn đăng ký                                   │
│                                                                 │
│  Kết quả:                                                       │
│  • Hình ảnh QR code (PNG/SVG)                                  │
│  • Activation key (để nhập thủ công)                           │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  Bước 3: Gán vào Cửa hàng                                      │
│  ──────────────────────────                                     │
│  Người thực hiện: Supplier                                     │
│  Kích hoạt: Supplier quét QR hoặc nhập device_code thủ công   │
│                                                                 │
│  Đầu vào:                                                       │
│  • device_code: String                                          │
│  • activation_key: String                                       │
│  • store_id: UUID                                               │
│                                                                 │
│  Kiểm tra:                                                      │
│  ✓ Device tồn tại và status = REGISTERED                       │
│  ✓ Activation key hợp lệ và chưa hết hạn                       │
│  ✓ Cửa hàng thuộc supplier hiện tại                            │
│  ✓ Cửa hàng ở trạng thái ACTIVE                                │
│                                                                 │
│  [Xem chi tiết code dưới đây]                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Bước 3: Gán vào Cửa hàng (Chi tiết)

**Quy trình**:

```python
def assign_device_to_store(device_code, activation_key, store_id):
    # 1. Kiểm tra thiết bị
    device = Device.find_by(device_code: device_code)

    IF device.status != REGISTERED:
        ERROR: "Thiết bị đã được gán hoặc không khả dụng"

    # 2. Kiểm tra activation key
    key = ActivationKey.find_by(
        device_code: device_code,
        activation_key: activation_key
    )

    IF key.expired OR key.status == USED:
        ERROR: "Mã kích hoạt không hợp lệ hoặc đã hết hạn"

    # 3. Kiểm tra quyền sở hữu cửa hàng
    store = Store.find(store_id)

    IF store.supplier_id != current_supplier.id:
        ERROR: "Cửa hàng không thuộc về bạn"

    # 4. Gán thiết bị vào cửa hàng
    device.update(
        store_id: store_id,
        supplier_id: store.supplier_id,
        status: REGISTERED  # Vẫn là REGISTERED, chờ kích hoạt
    )

    # 5. Đánh dấu activation key đã dùng
    key.update(status: USED, used_at: BÂY GIỜ)

    # 6. Khởi tạo cấu hình thiết bị
    device.update(
        operating_hours: store.operating_hours,
        timezone: store.timezone,
        advertising_slots_per_hour: 12  # Mặc định
    )

    # 7. Thông báo supplier
    send_notification(
        supplier,
        f"Thiết bị {device_code} đã gán vào {store.name}"
    )
```

**Quy tắc nghiệp vụ**:
- Thiết bị phải ở trạng thái REGISTERED
- Activation key chỉ dùng 1 lần
- Cửa hàng phải active và thuộc supplier
- Thiết bị kế thừa cấu hình cửa hàng

---

#### Bước 4: Kích hoạt Thiết bị

**Người thực hiện**: Thiết bị (heartbeat đầu tiên) hoặc Supplier (kích hoạt thủ công)  
**Kích hoạt**: Thiết bị bật nguồn và kết nối internet

**Quy trình**:

```
┌─────────────────────────────────────────────────────────────────┐
│              QUY TRÌNH KÍCH HOẠT THIẾT BỊ                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Thiết bị gửi heartbeat đầu tiên:                           │
│     POST /devices/:id/heartbeat                                 │
│     {                                                            │
│       "device_timestamp": "2026-01-23T10:00:00Z",               │
│       "status": "ONLINE",                                        │
│       "hardware_info": {                                         │
│         "screen_size": 55,                                       │
│         "resolution": "1920x1080",                               │
│         "os": "Android 12",                                      │
│         "player_version": "1.0.0"                                │
│       }                                                           │
│     }                                                             │
│                                                                 │
│  2. Server kiểm tra thiết bị:                                  │
│     ✓ Thiết bị tồn tại                                          │
│     ✓ Đã gán vào cửa hàng                                       │
│     ✓ Request có chữ ký hợp lệ (device private key)            │
│                                                                 │
│  3. Cập nhật bản ghi thiết bị:                                 │
│     device.update(                                               │
│       status: ACTIVE,                                            │
│       activated_at: BÂY GIỜ,                                    │
│       last_heartbeat_at: BÂY GIỜ,                               │
│       screen_size_inches: 55,                                    │
│       screen_resolution: "1920x1080",                            │
│       os_type: "ANDROID",                                        │
│       os_version: "12",                                          │
│       player_version: "1.0.0"                                    │
│     )                                                             │
│                                                                 │
│  4. Gửi cấu hình ban đầu:                                      │
│     Response: {                                                  │
│       "status": "ACTIVE",                                        │
│       "config": {                                                │
│         "heartbeat_interval": 300,  // 5 phút                   │
│         "sync_interval": 3600,      // 1 giờ                    │
│         "advertising_slots": 12,                                 │
│         "operating_hours": {...},                                │
│         "timezone": "Asia/Ho_Chi_Minh"                           │
│       },                                                          │
│       "playlist": []  // Rỗng ban đầu                           │
│     }                                                             │
│                                                                 │
│  5. Kích hoạt đồng bộ nội dung:                                │
│     • Lên lịch tải nội dung ban đầu                            │
│     • Tải chiến dịch active cho cửa hàng này                   │
│                                                                 │
│  6. Thông báo supplier:                                        │
│     "Thiết bị {device_code} tại {store.name} đã active"       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Quy tắc nghiệp vụ**:
- Heartbeat đầu tiên kích hoạt thiết bị
- Thiết bị phải cung cấp thông tin phần cứng
- Status chuyển từ REGISTERED → ACTIVE
- Playlist ban đầu rỗng cho đến khi có chiến dịch
- Thiết bị nhận cấu hình ngay lập tức

---

### 2. Quy trình Heartbeat (Tín hiệu Sống)

> **Heartbeat là gì?**  
> Giống như đo nhịp tim con người, thiết bị cần gửi "tín hiệu sống" đều đặn cho server. Nếu không gửi tín hiệu → hệ thống hiểu có sự cố.

**Lịch trình**: Mỗi 5 phút (có thể cấu hình)  
**Mục đích**: Giám sát sức khỏe, cập nhật trạng thái, duy trì kết nối

#### Phía Thiết bị

```
1. Thu thập chỉ số hệ thống:
   • Sử dụng CPU
   • Sử dụng bộ nhớ
   • Sử dụng ổ đĩa
   • Độ trễ mạng
   • Trạng thái hiện tại
   • Nhật ký lỗi

2. Ký tín hiệu heartbeat:
   signature = ký_bằng_private_key(heartbeat_data)

3. Gửi đến server:
   POST /devices/:id/heartbeat
   Headers:
     X-Device-Signature: {signature}
   Body: {
     "device_timestamp": "2026-01-23T10:05:00+07:00",
     "status": "ONLINE",
     "metrics": {
       "cpu_usage": 45,
       "memory_usage": 60,
       "disk_usage": 30,
       "network_latency_ms": 25
     },
     "playback": {
       "screen_on": true,
       "content_playing": true,
       "current_playlist_id": "uuid",
       "last_impression_id": "uuid"
     },
     "errors": []
   }
```

#### Phía Server

```
1. Xác minh chữ ký:
   verify_signature(heartbeat_data, signature, device.public_key)

2. Kiểm tra timestamp:
   time_diff = abs(server_time - device_timestamp)

   IF time_diff > 5 phút:
     CẢNH BÁO: "Đồng hồ thiết bị lệch: {time_diff}"

3. Cập nhật thiết bị:
   device.update(
     last_heartbeat_at: BÂY GIỜ,
     status: ACTIVE,
     cpu_usage: 45,
     memory_usage: 60,
     ip_address: request.ip
   )

4. Kiểm tra vấn đề:
   IF cpu_usage > 90 OR memory_usage > 90:
     GẮN CỜ thiết bị "high_resource_usage"

   IF errors.length > 0:
     GHI LOG errors
     IF errors.length > 10:
       GẮN CỜ thiết bị "frequent_errors"

5. Phản hồi cập nhật:
   Response: {
     "status": "OK",
     "server_time": "2026-01-23T10:05:15Z",
     "config_updated": false,
     "playlist_updated": true,
     "actions": [
       {"type": "sync_content", "playlist_id": "uuid"}
     ]
   }
```

**Quy tắc nghiệp vụ**:
- Heartbeat mỗi 5 phút (mặc định)
- Thiết bị offline nếu không heartbeat trong 10 phút (bỏ lỡ 2 lần)
- Chữ ký bắt buộc để xác thực
- Đồng hồ lệch > 5 phút kích hoạt cảnh báo
- Sử dụng tài nguyên cao (>90%) kích hoạt thông báo
- Server có thể đẩy hành động qua phản hồi heartbeat

---

### 3. Phát hiện Offline

**Kích hoạt**: Thiết bị bỏ lỡ heartbeat

**Quy trình**:

```
┌─────────────────────────────────────────────────────────────────┐
│               PHÁT HIỆN & XỬ LÝ THIẾT BỊ OFFLINE                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Job nền kiểm tra heartbeat:                                │
│     Lịch trình: Mỗi 2 phút                                     │
│                                                                 │
│     offline_devices = Devices.where(                            │
│       status: ACTIVE,                                            │
│       last_heartbeat_at < BÂY GIỜ - 10 phút                    │
│     )                                                            │
│                                                                 │
│  2. Với mỗi thiết bị offline:                                  │
│     device.update(                                               │
│       status: OFFLINE,                                           │
│       went_offline_at: BÂY GIỜ                                  │
│     )                                                            │
│                                                                 │
│  3. Tính downtime:                                             │
│     downtime_minutes = (BÂY GIỜ - went_offline_at) / 60        │
│     device.increment(total_downtime_minutes, downtime_minutes)  │
│                                                                 │
│  4. Thông báo supplier:                                        │
│     IF downtime_minutes >= 15:                                  │
│       Gửi thông báo: "Thiết bị offline 15+ phút"              │
│                                                                 │
│     IF downtime_minutes >= 60:                                  │
│       Gửi thông báo khẩn: "Thiết bị offline 1+ giờ"           │
│                                                                 │
│  5. Dừng phục vụ chiến dịch:                                   │
│     • Xóa thiết bị khỏi vòng xoay chiến dịch                   │
│     • Tạm dừng đếm impression                                   │
│     • Không tính phí trong thời gian offline                    │
│                                                                 │
│  6. Khi thiết bị online trở lại:                               │
│     • Status: OFFLINE → ACTIVE                                  │
│     • Tính tỷ lệ uptime/downtime                               │
│     • Cập nhật health score                                     │
│     • Tiếp tục phục vụ quảng cáo                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Quy tắc nghiệp vụ**:
- Offline sau 10 phút (bỏ lỡ 2 heartbeat)
- Thông báo tại 15 phút và 60 phút offline
- Không đếm impression khi offline
- Supplier không được trả tiền trong thời gian offline
- Thiết bị tự khôi phục khi heartbeat tiếp tục
- Downtime được theo dõi cho chỉ số hiệu suất

**Ngưỡng**:
- Thời gian gia hạn: 10 phút (2 lần bỏ lỡ heartbeat)
- Thông báo đầu: 15 phút
- Thông báo khẩn: 60 phút
- Thông báo nghiêm trọng: 4 giờ (có thể cần kiểm tra tại chỗ)

---

## 🏢 Quy tắc Sở hữu & Chuyển giao

### Quy tắc 1: Sở hữu Thiết bị

#### 1.1 Cấu trúc Sở hữu

```
Quy tắc: Thiết bị thuộc về supplier đã đăng ký
        Thiết bị gắn với cửa hàng cụ thể
        Một thiết bị không thể chia sẻ giữa nhiều cửa hàng

Cấu trúc Sở hữu:
Device → Store → Supplier
```

**Quy tắc nghiệp vụ**:
- `Device.supplier_id = Store.supplier_id` (luôn đồng bộ)
- Thiết bị không thể tồn tại mà không gán vào cửa hàng
- Thiết bị không thể gán vào cửa hàng từ supplier khác

---

#### 1.2 Chuyển Thiết bị giữa Cửa hàng

**Người thực hiện**: Supplier  
**Tình huống**: Di chuyển thiết bị từ Cửa hàng A sang Cửa hàng B (cùng supplier)

**Đầu vào**:
```javascript
{
  device_id: "uuid",
  target_store_id: "uuid"
}
```

**Kiểm tra**:
```
✓ Cả hai cửa hàng thuộc cùng supplier
✓ Device status = ACTIVE hoặc OFFLINE
✓ Cửa hàng đích ở trạng thái ACTIVE
✓ Không có chiến dịch active độc quyền với cửa hàng cũ
```

**Quy trình**:

```python
def transfer_device(device_id, target_store_id):
    # 1. Kiểm tra quyền sở hữu
    device = Device.find(device_id)
    old_store = Store.find(device.store_id)
    new_store = Store.find(target_store_id)

    IF old_store.supplier_id != new_store.supplier_id:
        ERROR: "Không thể chuyển thiết bị sang cửa hàng của supplier khác"

    # 2. Kiểm tra chiến dịch active
    active_campaigns = device.active_campaigns.where(
        store_exclusive: true
    )

    IF active_campaigns.count > 0:
        CẢNH BÁO: "Thiết bị có {count} chiến dịch độc quyền đang chạy"
        Yêu cầu xác nhận: "Chiến dịch sẽ bị tạm dừng"

    # 3. Thực hiện chuyển giao
    device.update(
        store_id: new_store.id,
        location: new_store.location,
        timezone: new_store.timezone,
        operating_hours: new_store.operating_hours
    )

    # 4. Cập nhật chiến dịch
    # Tạm dừng chiến dịch độc quyền với cửa hàng cũ
    # Tính toán lại chiến dịch hợp lệ cho cửa hàng mới
    # Kích hoạt đồng bộ nội dung

    # 5. Tạo nhật ký kiểm toán
    DeviceTransferLog.create(
        device_id: device_id,
        from_store_id: old_store.id,
        to_store_id: new_store.id,
        transferred_by: current_user.id,
        transferred_at: BÂY GIỜ,
        reason: "Chuyển địa điểm cửa hàng"
    )

    # 6. Thông báo
    send_notification(
        supplier,
        f"Thiết bị {device_code} chuyển từ {old_store.name} → {new_store.name}"
    )
```

**Quy tắc nghiệp vụ**:
- Chỉ cùng supplier (không chuyển đổi chéo supplier)
- Chiến dịch độc quyền bị tạm dừng trong quá trình chuyển
- Thiết bị kế thừa cấu hình cửa hàng mới
- Duy trì chuỗi kiểm toán
- Yêu cầu đồng bộ lại nội dung

---

#### 1.3 Ngừng hoạt động Thiết bị

**Người thực hiện**: Supplier hoặc Admin  
**Kích hoạt**: Thiết bị bị loại bỏ vĩnh viễn khỏi dịch vụ

**Đầu vào**:
```javascript
{
  device_id: "uuid",
  reason: String  // Lý do ngừng hoạt động
}
```

**Kiểm tra**:
```
✓ Thiết bị tồn tại
✓ Người dùng có quyền (supplier owner hoặc admin)
```

**Quy trình**:

```
1. Tạm dừng chiến dịch active:
   campaigns = device.active_campaigns

   FOR EACH campaign IN campaigns:
     Xóa thiết bị khỏi campaign.target_devices

     IF campaign.target_devices.empty:
       campaign.status = PAUSED
       Thông báo advertiser

2. Hoàn thành impression đang chờ:
   • Đợi 5 phút thời gian gia hạn
   • Xử lý impression đang phát
   • Hoàn tất billing

3. Cập nhật thiết bị:
   device.update(
     status: DECOMMISSIONED,
     decommissioned_at: BÂY GIỜ,
     decommission_reason: reason
   )

4. Lưu trữ dữ liệu:
   • Di chuyển nhật ký heartbeat sang kho lạnh (>90 ngày)
   • Giữ bản ghi impression (vĩnh viễn)
   • Lưu trữ cấu hình thiết bị

5. Thông báo:
   • Supplier: "Thiết bị {device_code} đã ngừng hoạt động"
   • Advertiser bị ảnh hưởng: "Thiết bị đã xóa khỏi chiến dịch"
```

**Quy tắc nghiệp vụ**:
- Thay đổi trạng thái là vĩnh viễn (không thể kích hoạt lại)
- Tất cả chiến dịch tự động bị xóa
- Impression được hoàn tất trước khi ngừng hoạt động
- Dữ liệu lịch sử được bảo toàn để báo cáo
- Device code có thể tái sử dụng sau 1 năm

---

## 💪 Sức khỏe & Uptime

### Quy tắc 2: Tính Chỉ số Sức khỏe (Health Score)

**Chỉ số Sức khỏe**: 0-100 (càng cao càng tốt)

#### Công thức Tổng hợp

```
health_score = (
  uptime_score × 0.40 +
  performance_score × 0.30 +
  reliability_score × 0.20 +
  compliance_score × 0.10
)
```

#### Thành phần Chi tiết

**1. Điểm Uptime (40%)**

```
uptime_ratio = total_uptime_minutes / (total_uptime + total_downtime)
uptime_score = uptime_ratio × 100

Mục tiêu: ≥ 95% uptime

Phân loại:
• Xuất sắc: ≥ 99%
• Tốt: 95-99%
• Khá: 90-95%
• Kém: < 90%
```

**2. Điểm Hiệu suất (30%)**

```
Các yếu tố:
• Sử dụng CPU (càng thấp càng tốt): tối đa 80%
• Sử dụng bộ nhớ (càng thấp càng tốt): tối đa 80%
• Độ trễ mạng (càng thấp càng tốt): tối đa 100ms
• Thời gian tải nội dung (càng nhanh càng tốt): tối đa 5s

performance_score = 100 - (
  cpu_penalty +
  memory_penalty +
  latency_penalty +
  load_time_penalty
)

Phạt điểm:
• CPU > 80%: -5 điểm mỗi 10% vượt
• Memory > 80%: -5 điểm mỗi 10% vượt
• Latency > 100ms: -10 điểm mỗi 50ms vượt
• Load time > 5s: -10 điểm mỗi 2s vượt
```

**3. Điểm Độ tin cậy (20%)**

```
Các yếu tố:
• Tỷ lệ thành công impression (mục tiêu: >99%)
• Tỷ lệ thành công đồng bộ (mục tiêu: >95%)
• Tần suất lỗi (mục tiêu: <5 lỗi/ngày)

impression_success = (impressions_recorded / impressions_attempted) × 100
sync_success = (syncs_completed / syncs_attempted) × 100
error_penalty = min(errors_per_day × 2, 50)  // Tối đa 50 điểm phạt

reliability_score = (
  impression_success × 0.5 +
  sync_success × 0.3
) - error_penalty
```

**4. Điểm Tuân thủ (10%)**

```
Các yếu tố:
• Tuân thủ phê duyệt nội dung (không phát nội dung chưa duyệt)
• Tuân thủ lịch phát (theo giờ hoạt động)
• Tuân thủ bảo mật (chữ ký hợp lệ, không có cờ giả mạo)

compliance_score = 100 NẾU all_checks_pass NGƯỢC LẠI 0

Vi phạm:
• Phát nội dung chưa duyệt: -100 (tức thời = 0)
• Thiếu chữ ký: -50
• Phát ngoài giờ: -30
```

#### Ví dụ Tính toán

```
Thiết bị A:
  - Uptime: 98% → uptime_score = 98 × 0.40 = 39.2
  - CPU: 60%, Memory: 70%, Latency: 50ms
    → performance_score = 100 × 0.30 = 30.0
  - Impressions: 99.5% thành công
    → reliability_score = 99.5 × 0.20 = 19.9
  - Tuân thủ: Tất cả đạt
    → compliance_score = 100 × 0.10 = 10.0

  Tổng: 39.2 + 30.0 + 19.9 + 10.0 = 99.1 (Xuất sắc)
```

**Quy tắc nghiệp vụ**:
- Health score tính toán lại mỗi giờ
- Điểm < 70 kích hoạt thông báo supplier
- Điểm < 50 kích hoạt đánh giá admin
- Điểm thấp liên tục có thể dẫn đến loại khỏi chiến dịch cao cấp
- Điểm cao (>95) đủ điều kiện nhận thưởng chia doanh thu

---

### Quy tắc 3: Yêu cầu Uptime

#### Tiêu chuẩn SLA Uptime Tối thiểu

**Thiết bị Chuẩn**:
```
• Mục tiêu: 95% uptime
• Đo lường: Cửa sổ trượt 30 ngày
• Phạt: Giảm doanh thu nếu < 95%
```

**Thiết bị Cao cấp** (cửa hàng lưu lượng cao):
```
• Mục tiêu: 98% uptime
• Đo lường: Cửa sổ trượt 30 ngày
• Phạt: Giảm doanh thu nghiêm ngặt hơn
```

#### Cấu trúc Phạt

```
NẾU uptime < 95%:
  revenue_multiplier = uptime_percentage / 95

  Ví dụ:
    90% uptime → 90/95 = 0.947 (giảm 5.3% doanh thu)
    85% uptime → 85/95 = 0.895 (giảm 10.5% doanh thu)

NẾU uptime < 80%:
  Thiết bị được gắn cờ để đánh giá
  Có thể bị loại khỏi chiến dịch giá trị cao
```

#### Downtime Được Miễn trừ

```
• Bảo trì có lịch (thông báo trước, tối đa 4 giờ/tháng)
• Đóng cửa hàng (ngày lễ, sửa chữa)
• Bất khả kháng (mất điện, thiên tai)
```

#### Công thức Tính

```
total_minutes_in_month = 30 × 24 × 60 = 43,200 phút
uptime_percentage = (total_uptime_minutes / total_minutes_in_month) × 100

Với thời gian miễn trừ:
uptime_percentage = total_uptime_minutes / (total_minutes - excused_minutes) × 100
```

**Quy tắc nghiệp vụ**:
- Uptime đo liên tục (24/7)
- Bảo trì có lịch phải thông báo trước (24 giờ)
- Downtime miễn trừ yêu cầu tài liệu
- Phạt áp dụng vào cuối tháng khi chi trả
- Thiết bị có vấn đề mãn tính có thể bị ngừng hoạt động

---

## 💓 Heartbeat & Giám sát

### Quy tắc 4: Giao thức Heartbeat

#### 4.1 Tần suất Heartbeat

**Tần suất Chuẩn**: Mỗi 5 phút (300 giây)

**Tần suất Thích ứng**:
```
• Thiết bị ACTIVE & khỏe mạnh: 5 phút
• Thiết bị DEGRADED (lỗi nhiều): 2 phút
• Thiết bị khôi phục sau OFFLINE: 1 phút (30 phút đầu)
• Thiết bị MAINTENANCE: 30 phút
```

**Có thể cấu hình theo thiết bị**:
```
device.heartbeat_interval = 300  // giây
```

**Dung sai Bỏ lỡ Heartbeat**:
```
• 1 lần bỏ lỡ (muộn 5 phút): Không hành động, có thể do mạng tạm thời
• 2 lần bỏ lỡ (muộn 10 phút): Đánh dấu OFFLINE
• 6 lần bỏ lỡ (muộn 30 phút): Thông báo khẩn cho supplier
• 24 lần bỏ lỡ (muộn 2 giờ): Thông báo nghiêm trọng, có thể cần đến tại chỗ
```

**Quy tắc nghiệp vụ**:
- Server mong đợi heartbeat mỗi N giây (được cấu hình)
- Server đánh dấu timestamp mỗi heartbeat (không tin đồng hồ thiết bị)
- Heartbeat phải được ký bằng device private key
- Bỏ lỡ heartbeat kích hoạt cảnh báo dần dần
- Thiết bị có thể yêu cầu thay đổi tần suất (vd: chế độ tiết kiệm điện)

---

#### 4.2 Đặc tả Payload Heartbeat

**Request Body**:
```json
{
  "device_id": "uuid",
  "device_timestamp": "2026-01-23T10:05:00+07:00",
  "server_timestamp": null,  // Server điền
  "sequence_number": 12345,  // Tăng đơn điệu
  "status": "ONLINE",  // ONLINE, DEGRADED, ERROR
  "metrics": {
    "cpu_usage_percent": 45,
    "memory_usage_percent": 60,
    "disk_usage_percent": 30,
    "disk_free_gb": 45.5,
    "network": {
      "latency_ms": 25,
      "bandwidth_kbps": 10240,
      "connection_type": "ETHERNET"  // ETHERNET, WIFI, 4G, 5G
    },
    "temperature_celsius": 42  // Tùy chọn, giám sát phần cứng
  },
  "playback": {
    "screen_on": true,
    "content_playing": true,
    "current_content_id": "uuid",
    "current_campaign_id": "uuid",
    "playlist_id": "uuid",
    "playlist_position": 3,  // Vị trí hiện tại
    "playlist_total": 10,    // Tổng items
    "last_impression_at": "2026-01-23T10:03:45+07:00"
  },
  "errors": [
    {
      "timestamp": "2026-01-23T10:02:15+07:00",
      "level": "ERROR",  // ERROR, WARN, INFO
      "code": "CONTENT_LOAD_FAILED",
      "message": "Không tải được content asset abc123",
      "details": "Network timeout sau 30s"
    }
  ],
  "location": {
    "latitude": 10.762622,
    "longitude": 106.660172,
    "accuracy_meters": 10
  },
  "software": {
    "player_version": "1.2.3",
    "os_version": "Android 12",
    "last_update_at": "2026-01-20T00:00:00Z"
  },
  "signature": "base64_encoded_signature"
}
```

**Quy tắc Kiểm tra**:
```
✓ device_id tồn tại trong database
✓ signature hợp lệ (được ký bằng device private key)
✓ sequence_number > last_sequence_number (ngăn replay attack)
✓ device_timestamp trong vòng ±10 phút server time
✓ status là giá trị enum hợp lệ
✓ metrics.cpu_usage_percent từ 0-100
✓ metrics.memory_usage_percent từ 0-100
✓ metrics.disk_usage_percent từ 0-100
✓ Tất cả UUID tồn tại trong database
```

**Response Format**:
```json
{
  "status": "OK",  // OK, CONFIG_UPDATE, ACTION_REQUIRED
  "server_timestamp": "2026-01-23T10:05:15Z",
  "next_heartbeat_interval": 300,  // Giây
  "config_version": "1.2.3",
  "config_updated": false,
  "playlist_updated": true,
  "actions": [
    {
      "type": "SYNC_CONTENT",
      "priority": "HIGH",
      "sync_id": "uuid",
      "content_ids": ["uuid1", "uuid2"]
    },
    {
      "type": "UPDATE_CONFIG",
      "priority": "NORMAL",
      "config": {
        "advertising_slots_per_hour": 15
      }
    }
  ],
  "messages": [
    {
      "type": "INFO",
      "text": "Bảo trì hệ thống dự kiến 24/01/2026 lúc 02:00 sáng"
    }
  ]
}
```

---

#### 4.3 Xử lý Lỗi Heartbeat

**Tình huống**: Thiết bị không gửi được heartbeat

**Phát hiện Phía Server**:

```
1. Job nền chạy mỗi 2 phút:

   check_missing_heartbeats():
     now = BÂY GIỜ

     // Tìm thiết bị đáng lẽ đã gửi heartbeat
     late_devices = Devices.where(
       status: ACTIVE,
       last_heartbeat_at < (now - heartbeat_interval - grace_period)
     )

     grace_period = 120 giây  // Dung sai 2 phút

     FOR EACH device IN late_devices:
       missed_count = (
         (now - device.last_heartbeat_at) / device.heartbeat_interval
       )

       IF missed_count >= 2:
         mark_device_offline(device, missed_count)

2. Đánh dấu thiết bị offline:

   mark_device_offline(device, missed_count):
     device.update(
       status: OFFLINE,
       went_offline_at: BÂY GIỜ,
       missed_heartbeats: missed_count
     )

     // Dừng phục vụ quảng cáo
     remove_from_campaign_rotation(device)

     // Thông báo supplier
     IF missed_count >= 2:
       send_notification(
         device.supplier,
         f"Thiết bị {device_code} offline (bỏ lỡ {missed_count} heartbeats)"
       )

     IF missed_count >= 6:  // 30 phút
       send_urgent_alert(
         device.supplier,
         f"Thiết bị {device_code} offline hơn 30 phút"
       )

     IF missed_count >= 24:  // 2 giờ
       send_critical_alert(
         device.supplier + admin,
         f"Thiết bị {device_code} offline hơn 2 giờ - cần điều tra"
       )

3. Khôi phục thiết bị:

   Khi thiết bị offline gửi heartbeat:

   IF device.status == OFFLINE:
     downtime_minutes = (BÂY GIỜ - went_offline_at) / 60

     device.update(
       status: ACTIVE,
       last_heartbeat_at: BÂY GIỜ,
       came_online_at: BÂY GIỜ,
       total_downtime_minutes += downtime_minutes
     )

     // Tính toán lại health score
     recalculate_health_score(device)

     // Tiếp tục phục vụ quảng cáo
     add_to_campaign_rotation(device)

     // Kích hoạt đồng bộ nội dung (có thể đã lỗi thời)
     trigger_content_sync(device, force: true)

     // Thông báo supplier
     send_notification(
       device.supplier,
       f"Thiết bị {device_code} trở lại online sau {downtime_minutes} phút"
     )

     // Tăng tần suất heartbeat tạm thời
     device.update(heartbeat_interval: 60)  // 1 phút trong 30 phút tới

     schedule_job(after: 30.minutes):
       device.update(heartbeat_interval: 300)  // Trở lại bình thường
```

**Quy tắc nghiệp vụ**:
- 2 lần bỏ lỡ heartbeat = offline (10 phút với khoảng 5 phút)
- Thiết bị offline tự động xóa khỏi vòng xoay quảng cáo
- Không có impression/billing trong thời gian offline
- Thiết bị tự khôi phục khi heartbeat tiếp theo thành công
- Tăng tần suất heartbeat sau khôi phục (giám sát)
- Supplier được thông báo tại: 10 phút, 30 phút, 2 giờ offline

---

## 📥 Đồng bộ Nội dung

### Quy tắc 5: Chiến lược Đồng bộ Nội dung

#### 5.1 Các loại Đồng bộ

**Ba loại đồng bộ nội dung:**

**1. FULL SYNC (Đồng bộ Đầy đủ)**
```
Khi nào: Kích hoạt thiết bị lần đầu hoặc thay đổi playlist hoàn toàn
Quy trình:
  • Tải toàn bộ playlist
  • Tất cả content assets
  • Xác minh checksum
  • Xóa cache cũ
Thời gian: 5-60 phút (tùy kích thước nội dung)
```

**2. INCREMENTAL SYNC (Đồng bộ Tăng dần)**
```
Khi nào: Kiểm tra định kỳ (mỗi giờ) hoặc cập nhật playlist
Quy trình:
  • So sánh manifest local với server manifest
  • Chỉ tải nội dung mới/thay đổi
  • Giữ nội dung đã cache
  • Xác minh checksum nội dung mới
Thời gian: 1-10 phút
```

**3. FORCED SYNC (Đồng bộ Cưỡng chế)**
```
Khi nào: Admin kích hoạt hoặc thiết bị báo lỗi
Quy trình:
  • Xóa tất cả nội dung local
  • Tải lại mọi thứ (như FULL SYNC)
  • Xây dựng lại cache
  • Xác minh toàn bộ playlist
Thời gian: 5-60 phút
```

---

#### 5.2 Tần suất Đồng bộ

**Lịch trình Mặc định**:
```
• Kiểm tra thường xuyên: Mỗi 1 giờ
• Kiểm tra nhanh: Sau heartbeat nếu cờ playlist_updated được set
• Ngay lập tức: Khi có thay đổi chiến dịch khẩn cấp
```

**Tần suất Thích ứng**:
```
• Thiết bị giá trị cao (cửa hàng cao cấp): Mỗi 30 phút
• Thiết bị chuẩn: Mỗi 1 giờ
• Thiết bị lưu lượng thấp: Mỗi 2 giờ
• Giờ đêm (ngoài giờ hoạt động): Mỗi 6 giờ
```

**Điều kiện Kích hoạt**:

```
1. Dựa theo lịch (time-based):
   CRON job mỗi giờ → kiểm tra cập nhật

2. Dựa theo sự kiện (immediate):
   • Chiến dịch mới kích hoạt cho thiết bị này
   • Chiến dịch bị tạm dừng/hủy
   • Nội dung cập nhật (phiên bản mới)
   • Admin buộc đồng bộ

3. Thiết bị khởi tạo:
   • Thiết bị phát hiện thiếu nội dung
   • Lỗi phát nội dung
   • Sau khôi phục offline
```

**Quy tắc nghiệp vụ**:
- Khoảng tối thiểu: 10 phút (tránh spam)
- Khoảng tối đa: 6 giờ (đảm bảo mới)
- Đồng bộ chỉ trong giờ hoạt động (ưu tiên)
- Đồng bộ khẩn cấp cho phép 24/7
- Nhận biết băng thông: giảm tốc trong giờ cao điểm

---

#### 5.3 Quy trình Đồng bộ

**Quy trình từng bước:**

```
┌─────────────────────────────────────────────────────────────────┐
│              QUY TRÌNH ĐỒNG BỘ NỘI DUNG CHI TIẾT               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bước 1: Thiết bị yêu cầu đồng bộ                              │
│  ───────────────────────────────                                │
│  GET /devices/:id/playlist/manifest                             │
│  Headers:                                                        │
│    X-Device-Signature: {signature}                              │
│    X-Current-Manifest-Version: "v1.2.3"                         │
│    X-Local-Content-Hashes: ["hash1", "hash2", ...]              │
│                                                                 │
│  Bước 2: Server tạo manifest                                   │
│  ──────────────────────────                                     │
│  manifest = {                                                    │
│    "version": "v1.2.5",                                          │
│    "updated_at": "2026-01-23T10:00:00Z",                        │
│    "playlist_id": "uuid",                                        │
│    "ttl_seconds": 3600,  // Cache trong 1 giờ                  │
│    "content_items": [                                            │
│      {                                                            │
│        "content_id": "uuid1",                                    │
│        "campaign_id": "uuid-campaign1",                          │
│        "url": "https://cdn.rmn-arms.com/.../uuid1.mp4",         │
│        "checksum": "sha256:abc123...",                           │
│        "size_bytes": 15728640,                                   │
│        "duration_seconds": 30,                                   │
│        "priority": 10,                                           │
│        "weight": 50,                                             │
│        "valid_from": "2026-01-23T00:00:00Z",                    │
│        "valid_until": "2026-02-23T23:59:59Z"                    │
│      },                                                           │
│      // ... items khác                                           │
│    ],                                                             │
│    "fallback_content": {                                         │
│      "content_id": "default-uuid",                               │
│      "url": "https://cdn.../fallback.mp4",                      │
│      "checksum": "sha256:def456...",                             │
│      "duration_seconds": 15                                      │
│    },                                                             │
│    "sync_required": true,  // hoặc false nếu không đổi         │
│    "changes": {                                                  │
│      "added": ["uuid1", "uuid3"],                                │
│      "removed": ["uuid5"],                                       │
│      "updated": ["uuid2"]                                        │
│    }                                                              │
│  }                                                                │
│                                                                 │
│  Bước 3: Server so sánh phiên bản                              │
│  ────────────────────────────────                                │
│  IF manifest.version == request.X-Current-Manifest-Version:     │
│    RETURN {sync_required: false}  // Đã mới nhất               │
│  ELSE:                                                           │
│    RETURN full manifest với changes                             │
│                                                                 │
│  Bước 4: Thiết bị tải nội dung mới                             │
│  ─────────────────────────────────                               │
│  FOR EACH content_id IN (changes.added + changes.updated):      │
│    download_content(content_id)                                  │
│    verify_checksum(content_id)                                   │
│                                                                 │
│    IF checksum_valid:                                            │
│      save_to_cache(content_id)                                   │
│    ELSE:                                                         │
│      retry_download(content_id, max_retries: 3)                 │
│                                                                 │
│  Bước 5: Thiết bị xóa nội dung cũ                              │
│  ────────────────────────────────                                │
│  FOR EACH content_id IN changes.removed:                        │
│    delete_from_cache(content_id)                                 │
│                                                                 │
│  Bước 6: Thiết bị xác nhận đồng bộ                             │
│  ─────────────────────────────────                               │
│  POST /devices/:id/playlist/sync-complete                       │
│  {                                                                │
│    "manifest_version": "v1.2.5",                                 │
│    "synced_content_ids": ["uuid1", "uuid2", "uuid3"],            │
│    "failed_content_ids": [],                                     │
│    "total_bytes_downloaded": 52428800,                           │
│    "sync_duration_seconds": 125,                                 │
│    "status": "COMPLETED"                                         │
│  }                                                                │
│                                                                 │
│  Bước 7: Server cập nhật bản ghi thiết bị                      │
│  ────────────────────────────────────────                        │
│  device.update(                                                  │
│    last_sync_at: BÂY GIỜ,                                       │
│    current_manifest_version: "v1.2.5",                           │
│    sync_status: "COMPLETED"                                      │
│  )                                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Quy tắc nghiệp vụ**:
- Xác minh checksum bắt buộc (tránh hỏng)
- Tải thất bại được thử lại 3 lần với exponential backoff
- Đồng bộ một phần chấp nhận được (thiết bị tiếp tục với nội dung có sẵn)
- Manifest được cache trong khoảng TTL (giảm tải server)
- Nội dung cũ bị xóa sau đồng bộ thành công (tiết kiệm dung lượng)
- Lỗi đồng bộ được log và cảnh báo nếu liên tục

---

#### 5.4 Quản lý Băng thông

**Vấn đề**: File video lớn có thể tiêu tốn băng thông đáng kể

**Chiến lược**:

```
1. Bitrate thích ứng:
   IF network_bandwidth < 1 Mbps:
     Dùng phiên bản chất lượng thấp (720p)
   ELSE IF network_bandwidth < 5 Mbps:
     Dùng phiên bản chất lượng trung bình (1080p)
   ELSE:
     Dùng phiên bản chất lượng cao (4K)

2. Giới hạn theo thời gian:
   IF giờ_hiện_tại BETWEEN 09:00 AND 18:00:  // Giờ làm việc
     max_bandwidth = 2 Mbps  // Giới hạn
   ELSE:  // Ngoài giờ
     max_bandwidth = 10 Mbps  // Tốc độ đầy đủ

3. Tải dần:
   • Tải nội dung ưu tiên cao trước
   • Nội dung ưu tiên thấp trong thời gian rảnh
   • Tạm dừng tải nếu thiết bị bận (đang phát nội dung)

4. Delta sync:
   • Chỉ truyền phần thay đổi của file (nếu hỗ trợ)
   • Giảm băng thông cho nội dung cập nhật

5. Tối ưu CDN:
   • CDN phân tán theo địa lý
   • Edge caching giảm độ trễ
   • Tự động chuyển đổi dự phòng sang CDN thay thế
```

**Mức độ Ưu tiên**:
```
• URGENT: Chiến dịch bắt đầu trong 1 giờ → băng thông tối đa
• HIGH: Chiến dịch bắt đầu trong 24 giờ → băng thông bình thường
• NORMAL: Chiến dịch bắt đầu >24 giờ → băng thông giới hạn
• LOW: Cập nhật nội dung dự phòng → chỉ ngoài giờ
```

**Quy tắc nghiệp vụ**:
- Băng thông tối đa có thể cấu hình theo thiết bị
- Đồng bộ tạm dừng nếu mạng không khả dụng
- Không cho phép phát nội dung một phần (phải hoàn chỉnh)
- Nội dung được cache vô thời hạn cho đến khi thay thế
- Chi phí CDN bao gồm trong phí platform

---

## 🎬 Quản lý Phát

### Quy tắc 6: Lên lịch Playlist

#### 6.1 Tạo Playlist

**Mục đích**: Tạo playlist quảng cáo tối ưu cho mỗi thiết bị

**Kích hoạt**:
```
• Chiến dịch mới kích hoạt
• Ngân sách chiến dịch cập nhật
• Thiết bị online
• Làm mới theo lịch (mỗi giờ)
```

**Quy trình**:

```python
def generate_playlist(device):
    # 1. Lấy chiến dịch hợp lệ
    eligible_campaigns = Campaigns.where(
        status: ACTIVE,
        remaining_budget > 0,
        start_date <= BÂY GIỜ,
        end_date >= BÂY GIỜ,
        target_stores.contains(device.store_id)
    ).where_not(
        blocked_stores.contains(device.store_id)
    )

    # 2. Tính trọng số
    FOR EACH campaign IN eligible_campaigns:
        weight = (
            campaign.priority ×
            campaign.remaining_budget_ratio ×
            campaign.performance_multiplier
        )

        remaining_budget_ratio = remaining_budget / total_budget
        performance_multiplier = campaign.ctr / average_ctr (nếu có)

    # 3. Phân bổ slot
    total_weight = SUM(all weights)
    slots_per_hour = device.advertising_slots_per_hour

    FOR EACH campaign:
        allocated_slots = (campaign.weight / total_weight) × slots_per_hour

        Ví dụ:
          Campaign A: weight = 10, nhận (10/20) × 12 = 6 slots/giờ
          Campaign B: weight = 7, nhận (7/20) × 12 = 4 slots/giờ
          Campaign C: weight = 3, nhận (3/20) × 12 = 2 slots/giờ

    # 4. Tạo playlist items
    FOR EACH campaign:
        FOR i IN 1..allocated_slots:
            DevicePlaylist.create(
                device_id: device.id,
                campaign_id: campaign.id,
                content_asset_id: select_content(campaign),
                priority: campaign.priority,
                weight: campaign.weight,
                start_date: BÂY GIỜ,
                end_date: campaign.end_date,
                status: ACTIVE
            )

    # 5. Xáo trộn playlist
    # Tránh cùng quảng cáo phát liên tiếp
    playlist = device.playlist_items.shuffle_with_constraints(
        min_gap_same_campaign: 2,  // Ít nhất 2 QC khác giữa cùng chiến dịch
        max_consecutive_high_priority: 3  // Tối đa 3 QC ưu tiên cao liên tiếp
    )

    # 6. Thêm nội dung dự phòng
    # Nếu playlist rỗng hoặc tất cả chiến dịch hết
    fallback_item = DevicePlaylist.create(
        device_id: device.id,
        campaign_id: nil,
        content_asset_id: default_fallback_content_id,
        priority: 0,
        weight: 1,
        status: ACTIVE
    )
```

**Quy tắc nghiệp vụ**:
- Playlist làm mới mỗi giờ (hoặc khi chiến dịch thay đổi)
- Chiến dịch ưu tiên cao nhận nhiều slot hơn
- Chiến dịch có nhiều ngân sách nhận nhiều slot hơn
- Không cùng chiến dịch liên tiếp (khoảng tối thiểu: 2 QC)
- Nội dung dự phòng khi không có chiến dịch
- Thiết bị cache playlist cục bộ (hoạt động offline tạm thời)

---

#### 6.2 Trình tự Phát

**Logic phát phía thiết bị:**

```
1. Tải playlist:

   playlist = load_from_cache("playlist.json")

   IF playlist.expired OR playlist.empty:
     trigger_sync()
     WAIT for sync complete
     playlist = load_from_cache("playlist.json")

2. Chọn nội dung tiếp theo:

   select_next_content():
     current_time = device_local_time()

     // Lọc items hợp lệ
     valid_items = playlist.filter(item =>
       item.valid_from <= current_time <= item.valid_until
       AND item.status == ACTIVE
       AND content_exists_locally(item.content_id)
     )

     IF valid_items.empty:
       RETURN fallback_content

     // Chọn ngẫu nhiên có trọng số
     total_weight = SUM(valid_items.weight)
     random_value = random(0, total_weight)

     cumulative = 0
     FOR EACH item IN valid_items:
       cumulative += item.weight
       IF random_value <= cumulative:
         RETURN item

     // Dự phòng (không nên đến đây)
     RETURN valid_items[0]

3. Phát nội dung:

   play_content(item):
     // Kiểm tra trước
     IF NOT is_operating_hours():
       SKIP  // Không phát ngoài giờ

     IF NOT content_file_exists(item.content_id):
       LOG error: "Nội dung thiếu"
       trigger_sync()
       RETURN fallback_content

     // Tải nội dung
     content = load_content_file(item.content_id)

     // Bắt đầu phát
     player.load(content)
     player.play()

     start_time = BÂY GIỜ

     // Giám sát phát
     player.on_progress(callback):
       progress_percent = (current_time / duration) × 100

       // Ghi impression tại 80% hoàn thành
       IF progress_percent >= 80 AND NOT impression_recorded:
         record_impression(item, start_time, progress_percent)
         impression_recorded = true

     player.on_complete(callback):
       // Nội dung phát xong
       item.play_count += 1
       item.last_played_at = BÂY GIỜ
       update_playlist_item(item)

       // Chọn nội dung tiếp theo
       next_item = select_next_content()
       play_content(next_item)

     player.on_error(callback):
       LOG error: "Phát thất bại"
       // Thử dự phòng
       play_content(fallback_content)

4. Timing slot:

   wait_for_next_slot():
     minutes_per_slot = 60 / device.advertising_slots_per_hour
     next_slot_time = calculate_next_slot_boundary(minutes_per_slot)
     sleep_duration = next_slot_time - BÂY GIỜ

     IF sleep_duration > 0:
       sleep(sleep_duration)

     Ví dụ (12 slots/giờ = 5 phút/slot):
       Giờ hiện tại: 10:03:30
       Slot tiếp: 10:05:00
       Ngủ: 90 giây

5. Vòng lặp chính:

   main_playback_loop():
     WHILE true:
       IF is_operating_hours():
         item = select_next_content()
         play_content(item)
         wait_for_next_slot()
       ELSE:
         // Ngoài giờ: chế độ ngủ
         turn_screen_off()
         sleep_until_next_operating_hour()
```

**Quy tắc nghiệp vụ**:
- Nội dung chọn ngẫu nhiên có trọng số theo ưu tiên
- Cùng chiến dịch tối thiểu cách 2 slot (tránh mệt mỏi)
- Impression ghi nhận tại 80% hoàn thành
- Nội dung thiếu kích hoạt đồng bộ
- Nội dung dự phòng dùng khi playlist rỗng
- Phát chỉ trong giờ hoạt động
- Slot phân bổ đều trong suốt giờ

---

## ⚙️ Cấu hình Thiết bị

### Quy tắc 7: Cài đặt Thiết bị

#### 7.1 Cấu hình Màn hình

**Kích thước Màn hình**:
```
• Phạm vi: 32-100 inch
• Kích thước phổ biến: 42", 55", 65", 75"
• Ảnh hưởng giá CPM (màn lớn hơn = giá cao hơn)
• Không thay đổi sau đăng ký (thông số phần cứng)
```

**Độ phân giải Màn hình**:
```
• Tối thiểu: 1920x1080 (Full HD)
• Khuyến nghị: 3840x2160 (4K)
• Các định dạng hỗ trợ:
  * 1920x1080 (1080p FHD)
  * 2560x1440 (1440p QHD)
  * 3840x2160 (4K UHD)
  * 7680x4320 (8K, tương lai)
• Ảnh hưởng yêu cầu chất lượng nội dung
• Độ phân giải cao hơn = phí cao cấp (+20% CPM)
```

**Hướng Màn hình**:
```
• LANDSCAPE (mặc định): Tỷ lệ 16:9
• PORTRAIT: Tỷ lệ 9:16
• Ảnh hưởng yêu cầu định dạng nội dung
• Không thể thay đổi (yêu cầu nội dung khác)
```

**Quy tắc nghiệp vụ**:
- Nội dung phải khớp độ phân giải thiết bị (hoặc cao hơn)
- Nội dung phải khớp hướng
- Kích thước màn xác minh khi kích hoạt
- Màn lớn hơn đủ điều kiện cho chiến dịch cao cấp
- Thiết bị 4K nhận thưởng +20% chia doanh thu

---

#### 7.2 Thông số Phần cứng

**Yêu cầu Thiết bị:**

**Phần cứng Tối thiểu**:
```
• CPU: Quad-core 1.5 GHz
• RAM: 2 GB
• Lưu trữ: 16 GB (tối thiểu 8 GB trống)
• Mạng: 10 Mbps download, 2 Mbps upload
• GPS: Tùy chọn nhưng khuyến nghị
• TPM/Secure Element: Bắt buộc để lưu khóa
```

**Phần cứng Khuyến nghị**:
```
• CPU: Octa-core 2.0 GHz
• RAM: 4 GB
• Lưu trữ: 32 GB SSD
• Mạng: 50 Mbps download, 10 Mbps upload
• GPS: Tích hợp
• 4G/5G: Kết nối dự phòng
```

**Hệ điều hành Hỗ trợ**:
```
• Android: 8.0+ (API level 26+)
• Windows: Windows 10/11 IoT Enterprise
• Linux: Ubuntu 20.04+ hoặc OS signage tùy chỉnh
• webOS: 4.0+ (LG Smart TV)
• Tizen: 5.0+ (Samsung Smart TV)
```

**Model Thiết bị (Được chứng nhận)**:
```
• Màn signage thương mại (Samsung, LG, Philips)
• Android TV box (các model được chứng nhận)
• Raspberry Pi 4+ (với player chính thức)
• Intel NUC + màn hình
• Build tùy chỉnh (yêu cầu chứng nhận)
```

**Quy tắc nghiệp vụ**:
- Thông số phần cứng xác minh khi kích hoạt
- Thông số dưới mức tối thiểu bị từ chối
- Thiết bị được chứng nhận nhận hỗ trợ ưu tiên
- Thiết bị chưa chứng nhận được phép nhưng không hỗ trợ
- Nâng cấp phần cứng yêu cầu kích hoạt lại

---

## 🔒 Phát hiện Gian lận & Bảo mật

### Quy tắc 8: Phòng chống Gian lận

#### 8.1 Phát hiện Hoạt động Đáng ngờ

**Các mẫu Gian lận:**

**1. Bất thường Tần suất Impression**:
```
Phát hiện:
impressions_per_hour = COUNT(impressions trong giờ qua)
expected_max = device.advertising_slots_per_hour

IF impressions_per_hour > expected_max × 1.2:
  GẮN CỜ "excessive_impressions"
  LÝ DO: "Thiết bị báo {actual} impressions/giờ, dự kiến tối đa {expected}"
```

**2. Bất thường Vị trí**:
```
Phát hiện:
IF device.location AND store.location:
  distance = haversine(device.location, store.location)

  IF distance > 1 km:
    GẮN CỜ "location_mismatch"
    LÝ DO: "Thiết bị cách {distance}km khỏi cửa hàng đăng ký"
```

**3. Thao túng Đồng hồ**:
```
Phát hiện:
time_diff = abs(device_timestamp - server_timestamp)

IF time_diff > 10 phút:
  GẮN CỜ "clock_skew"
  LÝ DO: "Đồng hồ thiết bị lệch {time_diff} phút"

// Phát hiện tấn công time travel
IF device_timestamp < last_device_timestamp:
  GẮN CỜ "time_reversal"
  LÝ DO: "Timestamp thiết bị di chuyển ngược"
```

**4. Impression Trùng lặp**:
```
Phát hiện:
recent_impressions = Impressions.where(
  device_id: X,
  campaign_id: Y,
  played_at: 5 PHÚT QUA
)

IF recent_impressions.count >= 2:
  GẮN CỜ "duplicate_impression"
  LÝ DO: "Nhiều impression cho cùng chiến dịch trong 5 phút"
```

**5. Lỗi Xác minh Chữ ký**:
```
Phát hiện:
IF NOT verify_signature(data, signature, device.public_key):
  GẮN CỜ "invalid_signature"
  LÝ DO: "Xác minh chữ ký request thất bại"

  consecutive_failures += 1
  IF consecutive_failures >= 3:
    GẮN CỜ "compromised_device"
    ĐÌNH CHỈ thiết bị
```

**6. Thiết bị Offline phát QC**:
```
Phát hiện:
IF device.status == OFFLINE:
  AND impression.played_at > device.last_heartbeat_at + 10 phút:
    GẮN CỜ "offline_impression"
    LÝ DO: "Impression báo trong khi thiết bị offline"
```

**7. Nội dung Hash không khớp**:
```
Phát hiện:
IF impression.proof_screenshot_hash NOT IN valid_content_hashes:
  GẮN CỜ "invalid_content"
  LÝ DO: "Screenshot không khớp nội dung đã duyệt"
```

**8. Đăng ký Thiết bị Hàng loạt**:
```
Phát hiện:
IF supplier.devices_registered_last_hour > 10:
  GẮN CỜ "mass_registration"
  LÝ DO: "Supplier đăng ký {count} thiết bị trong 1 giờ"
  Kích hoạt đánh giá thủ công
```

---

**Hành động khi Phát hiện Gian lận:**

```
Cấp 1 (Cảnh báo):
• Ghi hoạt động đáng ngờ
• Tiếp tục hoạt động
• Thông báo supplier để điều tra
• Ví dụ: Đồng hồ lệch nhẹ, vị trí hơi lệch

Cấp 2 (Giữ lại):
• Giữ impression để đánh giá
• Tiếp tục hoạt động nhưng không billing
• Đánh giá thủ công admin trong 24 giờ
• Ví dụ: Impression quá mức, bất thường vị trí

Cấp 3 (Đình chỉ):
• Đình chỉ thiết bị ngay lập tức
• Dừng tất cả phục vụ quảng cáo
• Đóng băng chi trả supplier
• Yêu cầu điều tra admin
• Ví dụ: Chữ ký không hợp lệ, thiết bị bị xâm nhập, gian lận đã chứng minh
```

**Quy tắc nghiệp vụ**:
- Hoạt động đáng ngờ được log vĩnh viễn
- Nhiều cờ tăng mức độ nghiêm trọng
- Supplier được thông báo tại mỗi cờ (minh bạch)
- False positive có thể kháng cáo
- Gian lận liên tục = cấm vĩnh viễn

---

#### 8.2 Biện pháp Bảo mật

**1. Xác thực Thiết bị**:
```
Mỗi API request phải bao gồm:
• Device ID (định danh công khai)
• Timestamp (ngăn replay attack)
• Chữ ký (được ký bằng device private key)

Thuật toán chữ ký: RSA-SHA256

signature = sign_with_private_key(
  SHA256(device_id + timestamp + request_body)
)

Server xác minh:
verified = verify_with_public_key(
  signature,
  SHA256(device_id + timestamp + request_body),
  device.public_key
)
```

**2. Phòng chống Replay Attack**:
```
• Request timestamp phải trong vòng ±5 phút server time
• Sequence number phải tăng đơn điệu
• Server cache hash request gần đây (TTL 5 phút)
• Request trùng lặp bị từ chối
```

**3. Phòng chống Man-in-the-Middle**:
```
• Tất cả giao tiếp qua TLS 1.3
• Certificate pinning trong player app
• Public key infrastructure (PKI)
• Xoay chứng chỉ thiết bị mỗi 90 ngày
```

**4. Toàn vẹn Nội dung**:
```
• Tất cả nội dung được ký bởi server
• Thiết bị xác minh chữ ký trước khi phát
• Xác minh checksum (SHA256)
• Nội dung bị giả mạo bị từ chối
```

**5. Bảo mật Proof-of-Play**:
```
• Yêu cầu screenshot hash
• Timestamp nhúng trong proof
• Yêu cầu chữ ký thiết bị
• Bao gồm vị trí (nếu có)
• Server xác minh tất cả trường
```

**6. Quản lý Khóa**:
```
• Private key lưu trong secure element (TPM/TEE)
• Khóa không bao giờ rời khỏi thiết bị
• Public key đăng ký khi kích hoạt
• Hỗ trợ xoay khóa (quy trình thủ công)
• Khóa bị xâm nhập thu hồi ngay lập tức
```

**7. Bảo mật Firmware**:
```
• Chỉ cập nhật firmware đã ký
• Xác minh trước khi cài đặt
• Bảo vệ rollback
• Secure boot bật
• Cập nhật OTA qua TLS
```

**Quy tắc nghiệp vụ**:
- Kiểm tra bảo mật trên mỗi API call
- Kiểm tra bảo mật thất bại = từ chối ngay lập tức
- 3 lỗi liên tiếp = đình chỉ thiết bị
- Sự cố bảo mật được log và cảnh báo
- Thiết bị bị xâm nhập cấm vĩnh viễn

---

## ⚠️ Các trường hợp đặc biệt

### Trường hợp 1: Thiết bị Mất Mạng trong khi Phát

**Tình huống**: Thiết bị đang phát nội dung, mạng ngắt kết nối giữa chừng

**Xử lý**:
```
1. Nội dung tiếp tục phát (đã cache cục bộ)
2. Impression ghi nhận cục bộ với timestamp
3. Thiết bị xếp hàng impression để gửi
4. Thiết bị tiếp tục nội dung tiếp trong playlist
5. Khi mạng khôi phục:
   • Gửi impression trong hàng đợi (với backfill timestamps)
   • Heartbeat gửi ngay lập tức
   • Kích hoạt đồng bộ để kiểm tra cập nhật
```

**Kiểm tra**:
```
Server chấp nhận backfill impression NẾU:
• Timestamp trong 4 giờ qua
• Thiết bị đã offline trong khoảng đó
• Chữ ký hợp lệ
• Không trùng impression
```

**Quy tắc nghiệp vụ**:
- Thiết bị có thể hoạt động offline lên đến 4 giờ
- Impression ghi nhận offline được đếm nếu xác minh
- Offline >4 giờ = impression bị từ chối (quá cũ)

---

### Trường hợp 2: Đồng hồ Thiết bị Reset về Mặc định

**Tình huống**: Thiết bị tắt nguồn hoàn toàn, đồng hồ reset về 1970-01-01

**Phát hiện**:
```
IF device_timestamp < "2020-01-01":
  TỪ CHỐI request
  RESPONSE: {
    error: "INVALID_TIMESTAMP",
    message: "Đồng hồ thiết bị dường như đã reset. Vui lòng đồng bộ với NTP.",
    server_time: "2026-01-23T10:00:00Z"
  }
```

**Hành động Thiết bị**:
```
1. Đồng bộ với NTP server ngay lập tức
2. Cập nhật đồng hồ cục bộ
3. Thử lại request
```

**Quy tắc nghiệp vụ**:
- Thiết bị phải đồng bộ thời gian khi khởi động
- Request với timestamp sai rõ ràng bị từ chối
- Thiết bị cung cấp server time trong từ chối (giúp debug)

---

### Trường hợp 3: Tất cả Chiến dịch Hết Ngân sách Giữa Ngày

**Tình huống**: Thiết bị có playlist rỗng, tất cả chiến dịch hết ngân sách

**Xử lý**:
```
1. Thiết bị yêu cầu cập nhật playlist
2. Server trả về playlist rỗng
3. Thiết bị phát nội dung dự phòng
4. Thiết bị kiểm tra chiến dịch mới mỗi 10 phút
5. Khi có chiến dịch mới:
   • Playlist cập nhật
   • Tiếp tục phục vụ quảng cáo bình thường
```

**Nội dung Dự phòng**:
```
• Thương hiệu cửa hàng
• Nội dung quảng cáo chung
• Thông báo "Vị trí quảng cáo có sẵn"
• Không billing (không phải impression)
```

**Quy tắc nghiệp vụ**:
- Nội dung dự phòng luôn có sẵn
- Không ghi impression cho dự phòng
- Thiết bị tiếp tục kiểm tra chiến dịch
- Supplier được thông báo về playlist rỗng (cơ hội bị mất)

---

### Trường hợp 4: Thiết bị Di chuyển sang Cửa hàng Khác

**Tình huống**: Supplier di chuyển thiết bị vật lý mà không cập nhật hệ thống

**Phát hiện**:
```
IF device.location AND store.location:
  distance = haversine(device.location, store.location)

  IF distance > 5 km:
    // Có khả năng đã di chuyển
    GẮN CỜ thiết bị để đánh giá

    // Kiểm tra nếu gần cửa hàng khác của cùng supplier
    nearby_stores = Stores.where(
      supplier_id: device.supplier_id,
      distance < 1 km from device.location
    )

    IF nearby_stores.count == 1:
      // Đề xuất chuyển giao
      send_notification(
        supplier,
        f"Thiết bị {device_code} dường như ở {nearby_store.name}. Chuyển giao?"
      )
```

**Quy trình Thủ công**:
```
1. Supplier xác nhận thiết bị đã di chuyển
2. Supplier khởi tạo chuyển giao (xem Quy tắc 1.2)
3. Thiết bị gán lại vào cửa hàng đúng
4. Chiến dịch tính toán lại
```

**Quy tắc nghiệp vụ**:
- Vị trí GPS giám sát liên tục
- Thay đổi vị trí lớn kích hoạt cảnh báo
- Không cho phép tự động chuyển giao (yêu cầu xác nhận)
- Ngăn billing nhầm vào cửa hàng sai

---

### Trường hợp 5: File Nội dung Bị Hỏng

**Tình huống**: File nội dung đã cache bị hỏng (lỗi đĩa, tải không hoàn chỉnh)

**Phát hiện (Phía Thiết bị)**:
```
1. Thiết bị tải nội dung để phát
2. Xác minh checksum thất bại
3. Hoặc: File không tìm thấy / không đọc được
```

**Hành động**:
```
// Xóa file hỏng
delete_from_cache(content_id)

// Yêu cầu tải lại
trigger_sync(
  type: INCREMENTAL,
  force_download: [content_id]
)

// Phát nội dung dự phòng trong khi đợi
play_content(fallback_content)

// Thử lại sau đồng bộ
IF sync_completed AND content_available(content_id):
  play_content(content_id)
```

**Phản hồi Server**:
```
// Trả về URL CDN mới (bypass cache)
{
  "content_id": "uuid",
  "url": "https://cdn.rmn-arms.com/content/uuid.mp4?nocache={timestamp}",
  "checksum": "sha256:...",
  "size_bytes": 15728640
}
```

**Quy tắc nghiệp vụ**:
- Nội dung hỏng kích hoạt tải lại tự động
- Checksum xác minh sau mỗi lần tải
- Tải thất bại được thử lại 3 lần
- Lỗi liên tục được gắn cờ để admin đánh giá
- Thiết bị tiếp tục hoạt động với nội dung còn lại

---

## ✅ Quy tắc Kiểm tra

### Ma trận Kiểm tra Thiết bị

| Trường | Quy tắc | Thông báo lỗi |
|--------|---------|---------------|
| `device_code` | Dài 16, chữ & số | "Định dạng device code không hợp lệ" |
| `device_code` | Duy nhất toàn cầu | "Device code đã tồn tại" |
| `store_id` | Phải là cửa hàng active | "Cửa hàng không tìm thấy hoặc inactive" |
| `screen_size_inches` | Từ 32-100 | "Kích thước màn phải 32-100 inch" |
| `screen_resolution` | Định dạng: "WIDTHxHEIGHT" | "Định dạng độ phân giải không hợp lệ" |
| `screen_resolution` | Tối thiểu 1920x1080 | "Độ phân giải tối thiểu 1920x1080" |
| `os_type` | Giá trị enum hợp lệ | "Loại OS không hỗ trợ" |
| `mac_address` | Định dạng: XX:XX:XX:XX:XX:XX | "Định dạng MAC address không hợp lệ" |
| `advertising_slots_per_hour` | Từ 6-60 | "Slot/giờ phải từ 6-60" |
| `max_content_duration` | Từ 10-300 | "Thời lượng tối đa phải 10-300 giây" |
| `timezone` | IANA timezone hợp lệ | "Timezone không hợp lệ" |
| `operating_hours` | Phạm vi thời gian hợp lệ | "Định dạng giờ hoạt động không hợp lệ" |

---

## 🧮 Công thức Tính toán

### Tổng hợp Công thức

#### 1. Tỷ lệ Uptime

```
uptime_percentage = (
  total_uptime_minutes /
  (total_uptime_minutes + total_downtime_minutes)
) × 100

Ví dụ:
  Uptime: 28,500 phút
  Downtime: 500 phút
  Tổng: 29,000 phút
  Uptime %: (28,500 / 29,000) × 100 = 98.28%
```

#### 2. Chỉ số Sức khỏe

```
health_score = (
  uptime_score × 0.40 +
  performance_score × 0.30 +
  reliability_score × 0.20 +
  compliance_score × 0.10
)

Phạm vi: 0-100 (càng cao càng tốt)
Mục tiêu: ≥ 80
Xuất sắc: ≥ 90
```

#### 3. Năng lực Quảng cáo / Ngày

```
capacity_per_day = (
  advertising_slots_per_hour ×
  operating_hours_per_day
)

Ví dụ:
  12 slots/giờ × 14 giờ/ngày = 168 impressions/ngày
```

#### 4. Ước tính Impression / Tháng

```
expected_impressions_per_month = (
  advertising_slots_per_hour ×
  average_operating_hours_per_day ×
  30 ngày ×
  expected_fill_rate
)

expected_fill_rate = 0.70 (70% slot lấp đầy, bảo thủ)

Ví dụ:
  12 slots/giờ × 14 giờ × 30 ngày × 0.70 = 3,528 impressions/tháng
```

#### 5. Tác động Downtime lên Doanh thu

```
lost_revenue = (
  downtime_minutes / 60 ×
  average_slots_per_hour ×
  average_cpm / 1000 ×
  supplier_share_percentage
)

Ví dụ:
  Downtime: 120 phút (2 giờ)
  Slots: 12/giờ
  CPM trung bình: $30
  Chia supplier: 80%

  Doanh thu mất: (120/60) × 12 × (30/1000) × 0.80 = $5.76
```

#### 6. ROI Thiết bị cho Supplier

```
device_roi = (
  (total_revenue_generated - device_cost - maintenance_cost) /
  device_cost
) × 100

Ví dụ:
  Doanh thu: $10,000 (trọn đời)
  Chi phí thiết bị: $2,000
  Bảo trì: $500

  ROI: ((10,000 - 2,000 - 500) / 2,000) × 100 = 375%
```

---

## 📚 Tham khảo

### Tài liệu liên quan

| Tài liệu | Mô tả |
|----------|-------|
| [Từ điển Thuật ngữ](./00-tu-dien-thuat-ngu.md) | Giải thích tất cả thuật ngữ |
| [Quy tắc Chiến dịch](./04-quy-tac-chien-dich.md) | Vòng đời chiến dịch & impression |
| [Quy tắc Supplier](./09-quy-tac-nha-cung-cap.md) | Quản lý supplier & đăng ký cửa hàng |
| [Quy tắc Nội dung](./10-quy-tac-noi-dung.md) | Upload & duyệt nội dung |

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team  
**Trạng thái**: Sẵn sàng để review