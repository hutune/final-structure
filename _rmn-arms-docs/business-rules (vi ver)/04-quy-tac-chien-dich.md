# 📢 Quy tắc Nghiệp vụ: Chiến dịch Quảng cáo

**Phiên bản**: 1.0  
**Ngày**: 2026-01-23  
**Trạng thái**: Bản nháp  
**Chủ quản**: Product Team

---

## 📖 Mục lục

1. [Tổng quan](#-tổng-quan)
2. [Các thực thể trong Chiến dịch](#-các-thực-thể-trong-chiến-dịch)
3. [Vòng đời Chiến dịch](#-vòng-đời-chiến-dịch)
4. [Quy tắc Quản lý Ngân sách](#-quy-tắc-quản-lý-ngân-sách)
5. [Quy tắc Ưu tiên & Lên lịch](#-quy-tắc-ưu-tiên--lên-lịch)
6. [Tạm dừng & Tiếp tục](#-tạm-dừng--tiếp-tục)
7. [Tính phí & Định giá](#-tính-phí--định-giá)
8. [Ghi nhận Lượt hiển thị](#-ghi-nhận-lượt-hiển-thị)
9. [Chặn Đối thủ Cạnh tranh](#-chặn-đối-thủ-cạnh-tranh)
10. [Các trường hợp đặc biệt](#-các-trường-hợp-đặc-biệt)
11. [Quy tắc Kiểm tra](#-quy-tắc-kiểm-tra)
12. [Công thức Tính toán](#-công-thức-tính-toán)

---

## 🎯 Tổng quan

### Mục đích

Tài liệu này định nghĩa **TẤT CẢ** quy tắc nghiệp vụ cho module Chiến dịch trong nền tảng RMN-Arms. Đây là nguồn chân lý duy nhất (single source of truth) cho:

| Đối tượng | Mục đích sử dụng |
|-----------|------------------|
| 📋 **Product Team** | Kiểm tra tính đúng đắn của yêu cầu |
| 👨‍💻 **Developer** | Tham chiếu khi code |
| 🧪 **QA Team** | Tạo test case |
| 💼 **Business** | Hiểu quy trình hoạt động |

### Phạm vi

**Bao gồm:**
- ✅ Tạo và quản lý chiến dịch
- ✅ Tính phí theo lượt hiển thị
- ✅ Quản lý ngân sách
- ✅ Phân phối nội dung
- ✅ Chặn đối thủ cạnh tranh
- ✅ Chia doanh thu với Supplier

**KHÔNG bao gồm:**
- ❌ Xác thực người dùng (xem module Auth)
- ❌ Upload/lưu trữ nội dung (xem module CMS)
- ❌ Quản lý thiết bị (xem module Device)

---

## 📦 Các thực thể trong Chiến dịch

### 1. Campaign (Chiến dịch)

> **Định nghĩa**: Một sáng kiến quảng cáo do Advertiser tạo ra để hiển thị nội dung trên mạng lưới màn hình bán lẻ.

#### Các thuộc tính

| Trường | Kiểu dữ liệu | Bắt buộc | Mặc định | Quy tắc |
|--------|--------------|----------|----------|---------|
| `id` | UUID | Có | Tự động | Không thay đổi sau khi tạo |
| `advertiser_id` | UUID | Có | User hiện tại | Phải là Advertiser đang hoạt động |
| `name` | String(100) | Có | - | Duy nhất cho mỗi Advertiser |
| `description` | Text | Không | null | Tối đa 500 ký tự |
| `brand_name` | String(50) | Có | - | Dùng cho chặn đối thủ |
| `category` | Enum | Có | - | Xem [Danh mục](#danh-mục-category) |
| `budget` | Decimal(10,2) | Có | - | Tối thiểu: $100, Tối đa: $1,000,000 |
| `spent` | Decimal(10,2) | Có | 0.00 | Tự động tính, chỉ đọc |
| `remaining_budget` | Decimal(10,2) | Có | = budget | Tính toán: budget - spent |
| `start_date` | DateTime | Có | - | Phải >= HÔM NAY + 24 giờ |
| `end_date` | DateTime | Có | - | Phải > start_date |
| `status` | Enum | Có | DRAFT | Xem [Vòng đời](#vòng-đời-trạng-thái) |
| `target_stores` | Array[UUID] | Có | [] | Tối thiểu: 1, Tối đa: 1000 cửa hàng |
| `blocked_stores` | Array[UUID] | Có | [] | Tự động từ quy tắc chặn |
| `content_assets` | Array[UUID] | Có | [] | Tối thiểu: 1 asset |
| `priority` | Integer | Có | 5 | Từ 1-10 (10 = cao nhất) |
| `daily_cap` | Decimal(10,2) | Không | null | Giới hạn chi tiêu hàng ngày |
| `impression_goal` | Integer | Không | null | Mục tiêu (chỉ tham khảo) |
| `created_at` | DateTime | Có | HÔM NAY | Không thay đổi |
| `updated_at` | DateTime | Có | HÔM NAY | Tự động cập nhật |
| `activated_at` | DateTime | Không | null | Khi status = ACTIVE |
| `completed_at` | DateTime | Không | null | Khi status = COMPLETED |

#### Danh mục (Category)

```
FOOD_BEVERAGE        → Thực phẩm & Đồ uống
ELECTRONICS          → Điện tử
FASHION_APPAREL      → Thời trang
HEALTH_BEAUTY        → Sức khỏe & Làm đẹp
HOME_GARDEN          → Nhà cửa & Vườn
AUTOMOTIVE           → Ô tô
ENTERTAINMENT        → Giải trí
FINANCIAL_SERVICES   → Dịch vụ tài chính
TELECOM              → Viễn thông
OTHER                → Khác
```

#### Vòng đời Trạng thái

```
DRAFT → PENDING_APPROVAL → SCHEDULED → ACTIVE → PAUSED → COMPLETED
  │              ↓                        ↓
  └──────────────┴────────────────────────┴────────→ CANCELLED
                 ↓
             REJECTED
```

**Mô tả các trạng thái:**

| Trạng thái | Tiếng Việt | Giải thích |
|------------|------------|------------|
| `DRAFT` | Nháp | Đang tạo, chưa gửi |
| `PENDING_APPROVAL` | Chờ duyệt | Đã gửi, đang chờ admin kiểm tra |
| `SCHEDULED` | Đã lên lịch | Đã duyệt, chờ đến ngày bắt đầu |
| `ACTIVE` | Đang chạy | Đang phát quảng cáo |
| `PAUSED` | Tạm dừng | Dừng tạm thời (có thể chạy lại) |
| `COMPLETED` | Hoàn thành | Kết thúc bình thường |
| `CANCELLED` | Đã hủy | Hủy bỏ trước khi hoàn thành |
| `REJECTED` | Bị từ chối | Admin không duyệt |

---

### 2. Impression (Lượt hiển thị)

> **Định nghĩa**: Một lần phát quảng cáo được xác minh trên thiết bị.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc |
|--------|------|----------|---------|
| `id` | UUID | Có | Tự động tạo |
| `campaign_id` | UUID | Có | Phải là campaign ACTIVE |
| `device_id` | UUID | Có | Thiết bị đã đăng ký |
| `store_id` | UUID | Có | Lấy từ device |
| `content_asset_id` | UUID | Có | Asset nào được phát |
| `played_at` | DateTime | Có | Timestamp từ server (UTC) |
| `duration_expected` | Integer | Có | Thời lượng nội dung (giây) |
| `duration_actual` | Integer | Có | Thời gian phát thực tế (giây) |
| `verified` | Boolean | Có | Mặc định: false |
| `proof_hash` | String(64) | Không | SHA256 của proof-of-play |
| `cost` | Decimal(10,4) | Có | Chi phí CPM đã tính |
| `cpm_rate` | Decimal(10,2) | Có | Giá CPM tại thời điểm phát |
| `is_peak_hour` | Boolean | Có | Dùng cho tính phí |
| `supplier_revenue` | Decimal(10,4) | Có | 80% của cost |
| `platform_revenue` | Decimal(10,4) | Có | 20% của cost |
| `status` | Enum | Có | PENDING/VERIFIED/REJECTED |
| `rejection_reason` | String(200) | Không | Nếu status = REJECTED |
| `created_at` | DateTime | Có | Không thay đổi |

---

### 3. BudgetTransaction (Giao dịch Ngân sách)

> **Định nghĩa**: Ghi lại mọi thay đổi ngân sách của chiến dịch để kiểm toán.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc |
|--------|------|----------|---------|
| `id` | UUID | Có | Tự động |
| `campaign_id` | UUID | Có | - |
| `transaction_type` | Enum | Có | DEBIT/CREDIT/HOLD/RELEASE/REFUND |
| `amount` | Decimal(10,2) | Có | Luôn là số dương |
| `balance_before` | Decimal(10,2) | Có | Ảnh chụp trước giao dịch |
| `balance_after` | Decimal(10,2) | Có | Ảnh chụp sau giao dịch |
| `reference_id` | UUID | Không | ID impression hoặc refund |
| `description` | String(200) | Có | Lý do dễ hiểu |
| `created_at` | DateTime | Có | Không thay đổi |

---

## 🔄 Vòng đời Chiến dịch

### 1. Quy trình Tạo Chiến dịch

```
┌─────────────────────────────────────────────────────────────────┐
│              QUY TRÌNH TẠO CHIẾN DỊCH CHI TIẾT                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bước 1: Khởi tạo Nháp                                         │
│  ────────────────────────                                       │
│  Người dùng nhấn "Tạo chiến dịch"                              │
│  → Hệ thống tạo record với status = DRAFT                      │
│  → Trả về campaign_id                                          │
│  → Chuyển đến màn hình soạn thảo                               │
│                                                                 │
│  Bước 2: Thông tin Cơ bản                                      │
│  ────────────────────────                                       │
│  Nhập:                                                          │
│  • Tên chiến dịch                                              │
│  • Mô tả (không bắt buộc)                                      │
│  • Tên thương hiệu                                             │
│  • Danh mục                                                     │
│  • Ngân sách                                                    │
│  • Thời gian (bắt đầu → kết thúc)                             │
│  • Giới hạn hàng ngày (không bắt buộc)                         │
│                                                                 │
│  Bước 3: Chọn Nội dung                                         │
│  ────────────────────────                                       │
│  • Upload mới HOẶC chọn từ thư viện                            │
│  • Tối thiểu 1 nội dung, tối đa 10                             │
│  • Tất cả phải có status = APPROVED                            │
│                                                                 │
│  Bước 4: Chọn Cửa hàng                                         │
│  ────────────────────────                                       │
│  • Chọn thủ công HOẶC theo tiêu chí                            │
│  • Hệ thống áp dụng quy tắc chặn đối thủ                       │
│  • Hiển thị: cửa hàng hợp lệ vs bị chặn                        │
│  • Ước tính: chi phí, số lượt hiển thị                         │
│                                                                 │
│  Bước 5: Xem lại & Gửi                                         │
│  ────────────────────────                                       │
│  • Kiểm tra tất cả thông tin                                   │
│  • Đồng ý điều khoản                                            │
│  • Xác nhận số dư ví đủ                                        │
│  • Gửi duyệt (nếu cần) HOẶC lên lịch ngay                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Bước 1: Khởi tạo Nháp

**Người thực hiện**: Advertiser  
**Kích hoạt**: Nhấn nút "Tạo chiến dịch mới"

**Quy trình**:
```
1. Tạo campaign mới:
   Campaign {
     id: UUID mới,
     advertiser_id: user_hiện_tại.id,
     status: DRAFT,
     created_at: BÂY GIỜ
   }

2. Trả về campaign_id cho frontend

3. Chuyển hướng đến màn hình soạn thảo
```

**Quy tắc nghiệp vụ**:
- ✅ Advertiser phải có email đã xác minh
- ✅ Tài khoản Advertiser phải ở trạng thái ACTIVE
- ✅ Không giới hạn số chiến dịch DRAFT

---

#### Bước 2: Thông tin Cơ bản

**Dữ liệu đầu vào**:

```javascript
{
  name: String,              // Tên chiến dịch
  description: String,       // Mô tả (không bắt buộc)
  brand_name: String,        // Tên thương hiệu
  category: Enum,            // Danh mục
  budget: Decimal,           // Ngân sách
  start_date: DateTime,      // Ngày bắt đầu
  end_date: DateTime,        // Ngày kết thúc
  daily_cap: Decimal         // Giới hạn hàng ngày (không bắt buộc)
}
```

**Quy tắc kiểm tra**:

| Trường | Quy tắc | Thông báo lỗi |
|--------|---------|---------------|
| `name` | Dài 3-100 ký tự, duy nhất cho Advertiser | "Tên chiến dịch đã tồn tại" |
| `brand_name` | Dài 2-50 ký tự, bắt buộc | "Cần tên thương hiệu để chặn đối thủ" |
| `category` | Phải là giá trị hợp lệ | "Danh mục không hợp lệ" |
| `budget` | >= $100 VÀ <= $1,000,000 | "Ngân sách tối thiểu $100" |
| `start_date` | >= BÂY GIỜ + 24 giờ | "Ngày bắt đầu phải cách ít nhất 24 giờ" |
| `end_date` | > start_date VÀ <= start_date + 365 ngày | "Thời gian không quá 1 năm" |
| `daily_cap` | Nếu có: >= $10 VÀ <= budget | "Giới hạn ngày tối thiểu $10" |

**Lý do 24 giờ lead time**:
- Cho phép phân phối nội dung trước
- Admin có thể duyệt
- CDN có thể cache

---

#### Bước 3: Chọn Nội dung

**Dữ liệu đầu vào**:
```javascript
{
  content_assets: [UUID, UUID, ...]  // Danh sách ID nội dung
}
```

**Quy tắc kiểm tra**:

```
✓ Số lượng: Tối thiểu 1, tối đa 10 assets
✓ Quyền sở hữu: Tất cả phải thuộc Advertiser hiện tại
✓ Trạng thái: Tất cả phải có status = APPROVED
✓ File hợp lệ: Có file media (video/hình ảnh) hợp lệ
```

**Yêu cầu kỹ thuật**:

| Loại | Yêu cầu |
|------|---------|
| **Video** | Thời lượng: 10-60 giây, Định dạng: MP4, Kích thước: ≤ 500MB |
| **Hình ảnh** | Thời lượng hiển thị: 10 giây (cấu hình theo thiết bị), Định dạng: JPG/PNG, Kích thước: ≤ 50MB |
| **Độ phân giải** | Tối thiểu: 1920x1080 (Full HD) |

**Quy tắc xoay vòng** (nếu có > 1 nội dung):
```
Hệ thống tự động xoay vòng đều các nội dung

Ví dụ: 3 nội dung A, B, C
→ Phát theo thứ tự: A → B → C → A → B → C ...
```

---

#### Bước 4: Chọn Cửa hàng Mục tiêu

**Hai cách chọn**:

##### Option A: Chọn thủ công
```
Advertiser chọn từng cửa hàng từ danh sách

Giới hạn: Tối thiểu 1, Tối đa 1000 cửa hàng
```

##### Option B: Chọn theo tiêu chí
```javascript
{
  regions: ["Miền Bắc", "Miền Nam"],
  categories: ["Siêu thị", "Trung tâm TM"],
  min_foot_traffic: 5000,              // Khách/ngày
  location: {
    lat: 21.0285,
    lng: 105.8542,
    radius_km: 50                      // Trong vòng 50km
  }
}
```

**Quy trình xử lý**:

```
┌─────────────────────────────────────────────────────────────────┐
│           XỬ LÝ CHỌN CỬA HÀNG & CHẶN ĐỐI THỦ                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bước 1: Lấy danh sách cửa hàng                                │
│  ────────────────────────────────                               │
│  • Theo lựa chọn thủ công hoặc tiêu chí                        │
│  • Lọc: status = ACTIVE, có ≥ 1 thiết bị ACTIVE               │
│                                                                 │
│  Bước 2: Áp dụng Quy tắc Chặn                                  │
│  ─────────────────────────────                                  │
│  FOREACH cửa hàng IN danh sách:                                │
│    IF cửa hàng có quy tắc chặn brand/category này:            │
│      → Thêm vào blocked_stores                                 │
│      → Loại khỏi danh sách hợp lệ                             │
│    ELSE:                                                        │
│      → Thêm vào eligible_stores                                │
│                                                                 │
│  Bước 3: Ước tính                                              │
│  ─────────────────                                              │
│  estimated_impressions = SUM(                                   │
│    store.daily_foot_traffic                                    │
│    × store.device_count                                        │
│    × store.avg_dwell_time_minutes / 60                         │
│    × campaign.duration_days                                    │
│  ) × 0.7  // Hệ số bảo thủ                                     │
│                                                                 │
│  estimated_cost = estimated_impressions × avg_CPM / 1000       │
│                                                                 │
│  Bước 4: Kiểm tra Cuối                                         │
│  ─────────────────────                                          │
│  ✓ eligible_stores.length >= 1 (phải có ít nhất 1 CH)        │
│  ✓ estimated_cost <= budget × 1.2 (cho phép sai số 20%)      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Thông báo lỗi**:

| Tình huống | Thông báo |
|------------|-----------|
| Tất cả CH bị chặn | "Tất cả cửa hàng đã chặn thương hiệu của bạn" |
| Chi phí > ngân sách | "Ước tính chi phí ($X) vượt ngân sách ($Y)" |
| Không tìm thấy CH | "Không có cửa hàng nào khớp với tiêu chí" |
| CH không có thiết bị | "Cửa hàng đã chọn không có thiết bị hoạt động" |

**Kết quả trả về**:
```javascript
{
  eligible_stores: [                  // Danh sách CH hợp lệ
    { id, name, location, ... }
  ],
  blocked_stores: [                   // Danh sách CH bị chặn
    { store_id, store_name, reason }
  ],
  estimated_impressions: 125000,      // Ước tính lượt hiển thị
  estimated_cost: 625.00,             // Ước tính chi phí ($)
  average_cpm: 5.00                   // CPM trung bình ($)
}
```

---

#### Bước 5: Xem lại & Gửi

**Hiển thị tổng hợp**:

```
┌─────────────────────────────────────────────────────────────────┐
│                   TÓM TẮT CHIẾN DỊCH                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📢 TÊN: Khuyến mãi Tết 2026                                    │
│  🏷️  THƯƠNG HIỆU: Coca-Cola                                     │
│  📅 THỜI GIAN: 01/02/2026 → 15/02/2026 (14 ngày)               │
│                                                                 │
│  💰 NGÂN SÁCH                                                   │
│  ─────────────                                                  │
│  • Tổng ngân sách: $5,000                                      │
│  • Ước tính chi phí: $4,800                                    │
│  • Ước tính hoàn lại: $200                                     │
│                                                                 │
│  📊 ƯỚC TÍNH                                                    │
│  ─────────                                                      │
│  • Số lượt hiển thị: ~125,000                                  │
│  • CPM trung bình: $5.00                                       │
│  • Số cửa hàng: 45                                             │
│  • Lượt hiển thị/ngày: ~8,929                                  │
│                                                                 │
│  🏪 CỬA HÀNG                                                    │
│  ─────────                                                      │
│  • Hợp lệ: 45 cửa hàng                                         │
│  • Bị chặn: 5 cửa hàng (xem chi tiết)                          │
│                                                                 │
│  📦 NỘI DUNG                                                    │
│  ─────────                                                      │
│  • Video 30 giây: "TVC Tết 2026"                               │
│  • Video 15 giây: "Khuyến mãi đặc biệt"                        │
│                                                                 │
│  ☑️  Tôi đồng ý với Điều khoản & Điều kiện                      │
│                                                                 │
│  [Quay lại]  [Lưu nháp]  [Gửi chiến dịch]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Quy trình gửi**:

```
1. Kiểm tra cuối cùng:
   ✓ Tất cả trường bắt buộc đã điền
   ✓ Đồng ý điều khoản = true
   ✓ Số dư ví >= ngân sách

2. Tạo giao dịch giữ ngân sách:
   BudgetTransaction {
     type: HOLD,
     amount: campaign.budget,
     description: "Giữ ngân sách cho: {tên}"
   }

3. Trừ tiền từ ví:
   wallet.available_balance -= campaign.budget
   wallet.held_balance += campaign.budget

4. Xác định trạng thái tiếp theo:
   IF nội dung nhạy cảm HOẶC ngân sách > $10,000:
     next_status = PENDING_APPROVAL
     → Tạo yêu cầu duyệt cho Admin
     → Gửi email cho Advertiser: "Chiến dịch chờ duyệt"
   ELSE:
     next_status = SCHEDULED
     → Lên lịch kích hoạt vào start_date
     → Gửi email: "Chiến dịch đã được lên lịch"

5. Cập nhật campaign:
   status = next_status
   updated_at = BÂY GIỜ
```

**Thông báo lỗi**:

| Tình huống | Thông báo |
|------------|-----------|
| Số dư không đủ | "Số dư khả dụng ($X) không đủ, cần $Y" |
| Chưa đồng ý điều khoản | "Vui lòng đồng ý Điều khoản & Điều kiện" |
| Thiếu thông tin | "Vui lòng hoàn thiện: {danh sách trường}" |

---

### 2. Quy trình Duyệt (nếu cần)

**Người thực hiện**: Admin  
**Kích hoạt**: Campaign có status = PENDING_APPROVAL

**Giao diện Admin**:

```
┌─────────────────────────────────────────────────────────────────┐
│               DUYỆT CHIẾN DỊCH - ADMIN PANEL                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📢 Chiến dịch: "Khuyến mãi Tết 2026"                          │
│  🏢 Advertiser: Coca-Cola Vietnam                              │
│  💰 Ngân sách: $5,000                                          │
│  📅 Thời gian: 01/02/2026 → 15/02/2026                         │
│                                                                 │
│  🎬 XEM TRƯỚC NỘI DUNG                                         │
│  ┌───────────────────────────────────────────────┐             │
│  │  [▶️ Video 1: TVC Tết 2026 - 30s]            │             │
│  │  [▶️ Video 2: Khuyến mãi - 15s]              │             │
│  └───────────────────────────────────────────────┘             │
│                                                                 │
│  🤖 KẾT QUẢ QUÉT TỰ ĐỘNG (AI)                                  │
│  ───────────────────────────                                    │
│  ✅ Không phát hiện nội dung nhạy cảm                          │
│  ✅ Không vi phạm chính sách                                   │
│  ⚠️  Chứa từ khóa: "rượu", "bia" (cần xem xét)               │
│                                                                 │
│  📊 LỊCH SỬ ADVERTISER                                         │
│  ─────────────────────                                          │
│  • Chiến dịch đã chạy: 12                                      │
│  • Tranh chấp: 0                                               │
│  • Độ tin cậy: ⭐⭐⭐⭐⭐                                        │
│                                                                 │
│  🗺️  BẢN ĐỒ CỬA HÀNG MỤC TIÊU                                  │
│  ─────────────────────────────                                  │
│  [Hiển thị bản đồ 45 cửa hàng]                                │
│                                                                 │
│  📝 GHI CHÚ CỦA ADMIN                                           │
│  ┌───────────────────────────────────────────────┐             │
│  │                                               │             │
│  └───────────────────────────────────────────────┘             │
│                                                                 │
│  [❌ TỪ CHỐI]  [💬 YÊU CẦU SỬA ĐỔI]  [✅ DUYỆT]              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Hành động: DUYỆT

**Quy trình**:
```
1. Cập nhật campaign:
   status = SCHEDULED
   updated_at = BÂY GIỜ

2. Lên lịch kích hoạt:
   • Tạo cron job cho start_date
   • Phân phối nội dung trước lên CDN

3. Thông báo Advertiser:
   • Email: "Chiến dịch đã được duyệt"
   • Push notification trên dashboard
```

#### Hành động: TỪ CHỐI

**Dữ liệu đầu vào**:
```javascript
{
  rejection_reason: String  // Bắt buộc
}
```

**Quy trình**:
```
1. Cập nhật campaign:
   status = REJECTED
   rejection_reason = lý_do
   updated_at = BÂY GIỜ

2. Hoàn tiền:
   BudgetTransaction {
     type: RELEASE,
     ...
   }
   wallet.held_balance -= campaign.budget
   wallet.available_balance += campaign.budget

3. Thông báo Advertiser:
   • Email: "Chiến dịch bị từ chối: {lý do}"
   • Cho phép chỉnh sửa và gửi lại
```

**Quy tắc nghiệp vụ**:
- Admin PHẢI cung cấp lý do từ chối
- Advertiser có thể sửa và gửi lại chiến dịch bị từ chối
- Ngân sách tự động được hoàn trả khi từ chối

---

### 3. Quy trình Kích hoạt

**Kích hoạt khi**:
- Thời gian hiện tại >= campaign.start_date
- Campaign có status = SCHEDULED

**Kiểm tra trước khi chạy**:

```
✓ Status = SCHEDULED
✓ Ngân sách còn lại > 0
✓ Ít nhất 1 thiết bị mục tiêu ONLINE
✓ Nội dung có thể truy cập trên CDN
```

**Quy trình**:

```
┌─────────────────────────────────────────────────────────────────┐
│                  QUY TRÌNH KÍCH HOẠT CHIẾN DỊCH                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bước 1: Kiểm tra Ngân sách                                    │
│  ────────────────────────────                                   │
│  IF remaining_budget < (avg_CPM / 1000):                       │
│    → HỦY kích hoạt                                             │
│    → Status = PAUSED                                           │
│    → Thông báo: "Ngân sách không đủ"                          │
│    → DỪNG                                                       │
│                                                                 │
│  Bước 2: Phân phối Nội dung                                    │
│  ────────────────────────                                       │
│  eligible_devices = thiết bị WHERE:                            │
│    • device.store_id IN campaign.target_stores                 │
│    • device.status = ACTIVE                                    │
│    • device.last_heartbeat > BÂY GIỜ - 5 phút                 │
│                                                                 │
│  FOREACH device IN eligible_devices:                           │
│    • Đẩy danh sách nội dung đến thiết bị                      │
│    • Bao gồm: campaign_id, asset_urls, priority               │
│    • Chờ ACK (timeout: 30 giây)                                │
│                                                                 │
│  Bước 3: Cập nhật Campaign                                     │
│  ────────────────────────                                       │
│  status = ACTIVE                                                │
│  activated_at = BÂY GIỜ                                        │
│  updated_at = BÂY GIỜ                                          │
│                                                                 │
│  Bước 4: Khởi động Theo dõi                                    │
│  ────────────────────────────                                   │
│  • Tạo bộ đếm impression (Redis)                               │
│  • Bắt đầu giám sát ngân sách real-time                       │
│  • Kích hoạt billing engine                                    │
│                                                                 │
│  Bước 5: Thông báo                                             │
│  ────────────────                                               │
│  • Email: "Chiến dịch đang chạy"                               │
│  • Dashboard: Hiển thị "ĐANG CHẠY"                             │
│  • Bật xem thống kê real-time                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💰 Quy tắc Quản lý Ngân sách

### Quy tắc 1: Phân bổ Ngân sách

**Khi nào**: Campaign được tạo  
**Quy tắc**: Ngân sách được giữ (escrowed) từ ví Advertiser

**Quy trình**:

```
1. Kiểm tra:
   wallet.available_balance >= campaign.budget

2. Thực hiện (ATOMIC):
   wallet.available_balance -= campaign.budget
   wallet.held_balance += campaign.budget
   campaign.remaining_budget = campaign.budget

3. Tạo ghi chép:
   BudgetTransaction {
     type: HOLD,
     amount: campaign.budget,
     balance_before: số dư trước,
     balance_after: số dư sau,
     description: "Giữ ngân sách cho: {tên}"
   }
```

**Quy tắc nghiệp vụ**:
- Ngân sách phải có đủ tại thời điểm gửi
- KHÔNG cho phép phân bổ một phần
- Việc giữ ngân sách là ngay lập tức và atomic
- Nếu giữ thất bại → tạo chiến dịch thất bại

---

### Quy tắc 2: Theo dõi Ngân sách Real-time

**Khi nào**: Mỗi impression được ghi nhận  
**Quy tắc**: Trừ chi phí ngay lập tức khỏi ngân sách

**Quy trình**:

```
1. Tính chi phí impression (xem phần 7)

2. Kiểm tra:
   campaign.remaining_budget >= impression.cost

3. Thực hiện (ATOMIC):
   campaign.spent += impression.cost
   campaign.remaining_budget -= impression.cost

4. Tạo giao dịch:
   BudgetTransaction {
     type: DEBIT,
     amount: impression.cost,
     reference_id: impression.id,
     description: "Chi phí impression: Thiết bị {device_id}"
   }

5. Kiểm tra ngưỡng:
   IF remaining_budget < (campaign.budget × 0.1):
     → Gửi thông báo: "Ngân sách còn 10%"

   IF remaining_budget < (avg_CPM / 1000):
     → Kích hoạt tự động tạm dừng
```

**Quy tắc nghiệp vụ**:
- Cập nhật ngân sách real-time (< 500ms)
- Sử dụng database transaction đảm bảo tính nguyên tử
- Xử lý impression đồng thời bằng row-level locking
- Ngân sách không bao giờ âm (kiểm tra trước khi ghi)

---

### Quy tắc 3: Tự động Tạm dừng khi Hết Ngân sách

**Điều kiện kích hoạt**:

```
A) remaining_budget < (current_CPM_rate / 1000)
   Lý do: Không đủ tiền cho impression tiếp theo

B) remaining_budget <= 0
   Lý do: Đã chi hết ngân sách
```

**Quy trình**:

```
1. Cập nhật campaign:
   status = PAUSED
   pause_reason = "BUDGET_EXHAUSTED"
   updated_at = BÂY GIỜ

2. Dừng phát quảng cáo:
   • Xóa campaign khỏi playlist thiết bị
   • Gửi lệnh STOP đến tất cả thiết bị
   • Chờ impression đang phát (5 phút)

3. Đối soát cuối:
   • Xử lý impression đang chờ
   • Tính tổng cuối cùng
   • Hoàn lại số dư (nếu có do làm tròn)

4. Thông báo Advertiser:
   Email & Push:
   "Chiến dịch tạm dừng - hết ngân sách"

   Hiển thị:
   • Tổng chi: $X
   • Tổng impression: Y
   • CPM thực tế: $Z
   • Tùy chọn nạp thêm và tiếp tục
```

**Thời gian gia hạn**:
- Cho phép 5 phút cho impression đang phát
- Nếu impression bắt đầu TRƯỚC khi dừng → vẫn tính
- Nếu impression bắt đầu SAU khi dừng → từ chối

---

### Quy tắc 4: Nạp thêm Ngân sách (Tiếp tục Chiến dịch)

**Người thực hiện**: Advertiser  
**Kích hoạt**: Người dùng nạp thêm ngân sách cho chiến dịch PAUSED

**Dữ liệu đầu vào**:
```javascript
{
  additional_budget: Decimal  // Số tiền thêm
}
```

**Kiểm tra**:
```
✓ additional_budget >= $50 (tối thiểu)
✓ wallet.available_balance >= additional_budget
✓ campaign.status IN [PAUSED, ACTIVE]
✓ campaign.end_date > BÂY GIỜ (chưa hết hạn)
```

**Quy trình**:

```
1. Giữ ngân sách thêm:
   wallet.available_balance -= additional_budget
   wallet.held_balance += additional_budget

2. Cập nhật campaign:
   campaign.budget += additional_budget
   campaign.remaining_budget += additional_budget

3. Tạo giao dịch:
   BudgetTransaction {
     type: CREDIT,
     amount: additional_budget,
     description: "Advertiser nạp thêm"
   }

4. Nếu đang PAUSED:
   IF pause_reason = "BUDGET_EXHAUSTED":
     status = ACTIVE
     Bật lại phát quảng cáo
     Thông báo: "Chiến dịch đã tiếp tục"
```

**Quy tắc nghiệp vụ**:
- Không giới hạn số lần nạp
- Nạp thêm kéo dài thời gian chạy (KHÔNG đổi ngày)
- end_date không thay đổi
- Nếu đã quá end_date → từ chối nạp thêm

---

### Quy tắc 5: Hoàn tiền (Khi Chiến dịch Kết thúc)

**Kích hoạt**: Chiến dịch kết thúc (COMPLETED hoặc CANCELLED)

**Tính toán**:
```
refund_amount = campaign.remaining_budget
```

**Quy trình**:

```
IF refund_amount > 0:

  1. Giải phóng giữ:
     wallet.held_balance -= campaign.budget

  2. Hoàn lại chưa dùng:
     wallet.available_balance += refund_amount

  3. Tạo giao dịch:
     BudgetTransaction {
       type: REFUND,
       amount: refund_amount,
       description: "Hoàn ngân sách chưa dùng"
     }

  4. Thông báo:
     "Chiến dịch kết thúc. Hoàn lại: ${refund_amount}"
```

**Quy tắc nghiệp vụ**:
- Hoàn tiền ngay lập tức khi chiến dịch kết thúc
- Không có phí hoặc phạt hoàn tiền
- Làm tròn 2 chữ số thập phân
- Lịch sử giao dịch được giữ để kiểm toán

---

## ⚖️ Quy tắc Ưu tiên & Lên lịch

### Quy tắc 6: Mức Ưu tiên

**Thang điểm**: 1-10 (10 = cao nhất)

**Ưu tiên mặc định theo Ngân sách**:

```
Ngân sách < $500        → Ưu tiên = 3
Ngân sách $500-$2,000   → Ưu tiên = 5
Ngân sách $2,000-$10,000 → Ưu tiên = 7
Ngân sách > $10,000     → Ưu tiên = 9
```

**Advertiser có thể điều chỉnh** (±2 cấp)

**Quy tắc nghiệp vụ**:
- Ưu tiên cao = được phát thường xuyên hơn
- Ưu tiên ẢNH HƯỞNG phân bổ slot, KHÔNG ảnh hưởng giá
- Thiết bị phát quảng cáo theo thứ tự ưu tiên

---

### Quy tắc 7: Phân bổ Slot Quảng cáo

**Khi nào**: Thiết bị yêu cầu quảng cáo tiếp theo  
**Dữ liệu đầu vào**: device_id, current_time

**Quy trình**:

```
┌─────────────────────────────────────────────────────────────────┐
│              THUẬT TOÁN CHỌN QUẢNG CÁO                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bước 1: Lấy chiến dịch hợp lệ                                 │
│  ────────────────────────────                                   │
│  eligible = campaigns WHERE:                                    │
│    • status = ACTIVE                                           │
│    • remaining_budget > 0                                      │
│    • target_stores CHỨA device.store_id                        │
│    • start_date <= BÂY GIỜ <= end_date                         │
│                                                                 │
│  Bước 2: Sắp xếp                                               │
│  ──────────────                                                 │
│  • Theo priority (giảm dần)                                    │
│  • Sau đó theo created_at (tăng dần)                           │
│                                                                 │
│  Bước 3: Chọn theo Trọng số                                    │
│  ────────────────────────────                                   │
│  weight = priority × remaining_budget_ratio                     │
│                                                                 │
│  remaining_budget_ratio = remaining / budget                    │
│                                                                 │
│  Ví dụ:                                                         │
│  Campaign A: priority=10, ratio=0.9 → weight=9.0              │
│  Campaign B: priority=7,  ratio=0.5 → weight=3.5              │
│  Campaign C: priority=5,  ratio=1.0 → weight=5.0              │
│                                                                 │
│  Tổng weight = 17.5                                            │
│  Chọn ngẫu nhiên có trọng số theo các giá trị này             │
│                                                                 │
│  Bước 4: Trả về                                                │
│  ──────────────                                                 │
│  Trả về campaign đã chọn cho thiết bị                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Quy tắc nghiệp vụ**:
- Campaign còn nhiều ngân sách → phát nhiều hơn
- Campaign ưu tiên cao → phát thường xuyên hơn
- Ngẫu nhiên hóa tránh "impression fatigue"
- Cùng 1 campaign tối đa 2 lần/giờ/thiết bị

---

### Quy tắc 8: Giới hạn Chi tiêu Hàng ngày

**Khi nào**: campaign.daily_cap được thiết lập  
**Quy tắc**: Dừng phát quảng cáo khi chi tiêu trong ngày đạt giới hạn

**Quy trình**:

```
1. Theo dõi chi tiêu hàng ngày (reset lúc 00:00 UTC):
   daily_spent = SUM(impressions.cost) WHERE:
     • campaign_id = X
     • played_at >= HÔM NAY 00:00:00 UTC

2. Trước khi phát quảng cáo:
   IF daily_spent >= campaign.daily_cap:
     → Bỏ qua campaign này
     → Ghi log: "Đã đạt giới hạn ngày"

3. Lúc 00:00 UTC:
   → Reset bộ đếm daily_spent
   → Tiếp tục phát nếu status = ACTIVE
```

**Quy tắc nghiệp vụ**:
- Giới hạn ngày KHÔNG giảm tổng ngân sách
- Hữu ích để phân bổ ngân sách đều qua thời gian chiến dịch
- Chiến dịch có thể kết thúc với ngân sách chưa dùng nếu daily_cap quá thấp
- Có thể điều chỉnh daily_cap bất cứ lúc nào

---

## ⏸️ Tạm dừng & Tiếp tục

### Quy tắc 9: Tạm dừng Thủ công (Advertiser)

**Người thực hiện**: Advertiser  
**Hành động**: Nhấn nút "Tạm dừng Chiến dịch"

**Kiểm tra**:
```
✓ campaign.status = ACTIVE
✓ Người dùng là chủ sở hữu
```

**Quy trình**:

```
1. Cập nhật campaign:
   status = PAUSED
   pause_reason = "USER_REQUESTED"
   paused_at = BÂY GIỜ

2. Dừng phát quảng cáo:
   • Xóa khỏi playlist thiết bị
   • Hoàn thành impression đang phát (5 phút)

3. Thông báo:
   "Chiến dịch đã tạm dừng thành công"
```

**Quy tắc nghiệp vụ**:
- Ngân sách vẫn được giữ
- Có thể tiếp tục bất cứ lúc nào trước end_date
- Impression trong thời gian gia hạn vẫn được tính
- Không có phí phạt

---

### Quy tắc 10: Tiếp tục Thủ công (Advertiser)

**Người thực hiện**: Advertiser  
**Hành động**: Nhấn nút "Tiếp tục Chiến dịch"

**Kiểm tra**:
```
✓ campaign.status = PAUSED
✓ campaign.end_date > BÂY GIỜ
✓ campaign.remaining_budget > 0
✓ Người dùng là chủ sở hữu
```

**Quy trình**:

```
1. Cập nhật campaign:
   status = ACTIVE
   pause_reason = null
   resumed_at = BÂY GIỜ

2. Phân phối lại nội dung:
   • Đẩy vào playlist thiết bị
   • Tiếp tục theo dõi impression

3. Thông báo:
   "Chiến dịch đã tiếp tục thành công"
```

**Quy tắc nghiệp vụ**:
- Không thể tiếp tục chiến dịch đã hết hạn
- Không thể tiếp tục nếu ngân sách = 0
- Phân phối lại nội dung mất tới 5 phút

---

### Quy tắc 11: Tự động Tạm dừng (Hệ thống)

**Kích hoạt**:

```
A) Hết ngân sách (xem Quy tắc 3)
B) Tất cả thiết bị mục tiêu offline > 24 giờ
C) Chiến dịch bị gắn cờ vi phạm chính sách
D) Tài khoản Advertiser bị đình chỉ
```

**Quy trình**:

```
1. Cập nhật campaign:
   status = PAUSED
   pause_reason = {trigger}
   auto_paused_at = BÂY GIỜ

2. Thông báo Advertiser:
   Email: "Chiến dịch tự động tạm dừng: {lý do}"
   Hành động cần thiết: {các bước giải quyết}

3. Cách giải quyết:
   • Hết ngân sách → Nạp thêm
   • Thiết bị offline → Chờ kết nối lại
   • Vi phạm chính sách → Liên hệ support
   • Tài khoản đình chỉ → Giải quyết vấn đề tài khoản
```

**Quy tắc nghiệp vụ**:
- Tự động tạm dừng là ngay lập tức
- Advertiser KHÔNG thể tự tiếp tục nếu vi phạm chính sách/tài khoản
- Admin phải duyệt tiếp tục cho vi phạm chính sách

---

## 💵 Tính phí & Định giá

### Quy tắc 12: Tính CPM

#### Bảng giá CPM Cơ bản theo Loại Cửa hàng

| Loại cửa hàng | CPM Giờ cao điểm | CPM Giờ thường | Hệ số Premium |
|---------------|------------------|----------------|---------------|
| Trung tâm TM cao cấp | $50.00 | $30.00 | 2.0x |
| Trung tâm TM | $40.00 | $25.00 | 1.6x |
| Siêu thị | $35.00 | $20.00 | 1.4x |
| Cửa hàng bách hóa | $30.00 | $18.00 | 1.2x |
| Cửa hàng tiện lợi | $25.00 | $15.00 | 1.0x |
| Trạm xăng | $20.00 | $12.00 | 0.8x |
| Nhà hàng | $18.00 | $12.00 | 0.7x |
| Khác | $15.00 | $10.00 | 0.6x |

#### Định nghĩa Giờ cao điểm

```
Ngày thường (Thứ 2-6):
  Giờ cao điểm: 11:00-14:00, 17:00-21:00
  Giờ thường: Tất cả các giờ khác

Cuối tuần (Thứ 7-CN):
  Giờ cao điểm: 10:00-22:00
  Giờ thường: Tất cả các giờ khác

Ngày lễ:
  Được coi là giờ cao điểm cuối tuần
```

#### Công thức Tính CPM

```python
def calculate_cpm(store, timestamp):
    # 1. Lấy giá cơ bản
    base_rate = get_base_rate(store.category, timestamp)

    # 2. Áp dụng hệ số lượng khách
    if store.daily_foot_traffic >= 10000:
        traffic_multiplier = 1.5
    elif store.daily_foot_traffic >= 5000:
        traffic_multiplier = 1.2
    elif store.daily_foot_traffic >= 2000:
        traffic_multiplier = 1.0
    else:
        traffic_multiplier = 0.8

    # 3. Áp dụng hệ số chất lượng thiết bị
    if device.screen_size >= 55 and device.resolution == "4K":
        quality_multiplier = 1.3
    elif device.screen_size >= 42:
        quality_multiplier = 1.0
    else:
        quality_multiplier = 0.9

    # 4. Tính CPM cuối cùng
    final_cpm = base_rate × traffic_multiplier × quality_multiplier

    # 5. Làm tròn 2 chữ số
    return round(final_cpm, 2)
```

**Ví dụ Tính toán**:

```
Cửa hàng: Trung tâm TM cao cấp
Lượng khách: 8,000/ngày
Thiết bị: Màn 55" 4K
Thời gian: Thứ 6 18:30 (giờ cao điểm)

Bước 1: Giá cơ bản = $50.00 (giờ cao điểm TM cao cấp)
Bước 2: Hệ số lượng khách = 1.2 (5000-10000)
Bước 3: Hệ số chất lượng = 1.3 (55" 4K)
Bước 4: CPM cuối = $50.00 × 1.2 × 1.3 = $78.00

→ Chi phí/impression = $78.00 / 1000 = $0.078
```

---

### Quy tắc 13: Tính Chi phí Impression

```python
def calculate_impression_cost(campaign, device, store, timestamp):
    # 1. Lấy giá CPM
    cpm_rate = calculate_cpm(store, timestamp)

    # 2. Tính chi phí cơ bản
    base_cost = cpm_rate / 1000

    # 3. Điều chỉnh theo thời lượng (nếu video < 15s)
    if content.type == "VIDEO" and content.duration < 15:
        duration_discount = content.duration / 15
        base_cost = base_cost × duration_discount

    # 4. Điều chỉnh theo ưu tiên (±10%)
    if campaign.priority >= 9:
        priority_premium = 1.10
    elif campaign.priority <= 3:
        priority_premium = 0.90
    else:
        priority_premium = 1.00

    final_cost = base_cost × priority_premium

    # 5. Làm tròn 4 chữ số
    return round(final_cost, 4)
```

**Ví dụ**:

```
CPM: $78.00
Nội dung: Video 10 giây
Ưu tiên: 5 (bình thường)

Bước 1: Chi phí cơ bản = $78.00 / 1000 = $0.0780
Bước 2: Giảm thời lượng = 10/15 = 0.6667
Bước 3: Chi phí điều chỉnh = $0.0780 × 0.6667 = $0.0520
Bước 4: Điều chỉnh ưu tiên = 1.00 (bình thường)
Bước 5: Chi phí cuối = $0.0520
```

---

### Quy tắc 14: Chia Doanh thu

#### Tỷ lệ chia

```
Phí Platform: 20%
Phần Supplier: 80%

Với mỗi impression:
  impression.cost = $0.0780
  platform_revenue = $0.0780 × 0.20 = $0.0156
  supplier_revenue = $0.0780 × 0.80 = $0.0624
```

#### Quy trình Chi trả Supplier

**Lịch trình**: Hàng ngày lúc 00:00 UTC  
**Thời gian giữ**: 7 ngày (chống gian lận)

**Quy trình**:

```
1. Tính doanh thu hàng ngày:
   daily_revenue = SUM(impressions.supplier_revenue) WHERE:
     • store.supplier_id = X
     • played_at BETWEEN (HÔM NAY - 7 ngày) AND (HÔM NAY - 6 ngày)
     • status = VERIFIED
     • KHÔNG bị tranh chấp

2. Ngưỡng chi trả tối thiểu:
   IF daily_revenue < $50.00:
     → Tích lũy cho ngày mai
   ELSE:
     → Xử lý chi trả

3. Tạo bản ghi chi trả:
   SupplierPayout {
     supplier_id: X,
     amount: daily_revenue,
     period_start: HÔM NAY - 7 ngày,
     period_end: HÔM NAY - 6 ngày,
     impression_count: Y,
     status: PENDING
   }

4. Chuyển tiền:
   supplier.wallet.available_balance += daily_revenue

5. Cập nhật:
   status = COMPLETED
   completed_at = BÂY GIỜ

6. Thông báo:
   Email: "Chi trả hàng ngày: ${daily_revenue}"
```

**Quy tắc nghiệp vụ**:
- Giữ 7 ngày ngăn chặn tổn thất từ chargeback
- Tối thiểu $50 giảm phí giao dịch
- Impression bị tranh chấp loại trừ đến khi giải quyết
- Supplier có thể rút bất cứ lúc nào sau khi nhận

---

## 📊 Ghi nhận Lượt hiển thị

### Quy tắc 15: Tiêu chí Impression Hợp lệ

Một impression được coi là **HỢP LỆ** nếu ĐÁP ỨNG TẤT CẢ điều kiện:

```
✓ Campaign status = ACTIVE
✓ Campaign remaining_budget >= chi phí impression
✓ Device status = ACTIVE
✓ Device thuộc cửa hàng mục tiêu
✓ Cửa hàng KHÔNG trong blocked_stores
✓ Thời lượng phát >= 80% thời lượng nội dung
✓ Có proof-of-play hợp lệ
✓ Không trùng trong 5 phút
✓ Timestamp trong khoảng thời gian chiến dịch
✓ Device heartbeat trong 5 phút gần nhất
```

---

### Quy tắc 16: API Gửi Impression

**Endpoint**: `POST /api/v1/impressions`

**Request Body**:
```json
{
  "campaign_id": "uuid",
  "device_id": "uuid",
  "content_asset_id": "uuid",
  "played_at": "2026-01-23T14:30:00Z",
  "duration_actual": 28,
  "proof": {
    "screenshot_hash": "sha256...",
    "device_signature": "base64...",
    "location": {
      "lat": 10.762622,
      "lng": 106.660172
    }
  }
}
```

**Kiểm tra**:

```
1. Xác thực thiết bị (JWT hoặc device token)
2. Kiểm tra campaign tồn tại và ACTIVE
3. Kiểm tra device thuộc cửa hàng mục tiêu
4. Kiểm tra trùng (campaign + device + time trong 5 phút)
5. Kiểm tra thời lượng (>= 80% mong đợi)
6. Xác minh chữ ký proof
```

**Response Thành công (201)**:
```json
{
  "impression_id": "uuid",
  "status": "VERIFIED",
  "cost": 0.0780,
  "campaign_remaining_budget": 245.32
}
```

**Response Lỗi (400/422)**:
```json
{
  "error": "INVALID_DURATION",
  "message": "Phát 20s < yêu cầu 24s (80% của 30s)",
  "required_duration": 24,
  "actual_duration": 20
}
```

**Mã lỗi**:

| Mã | Ý nghĩa |
|----|---------|
| `CAMPAIGN_NOT_ACTIVE` | Chiến dịch không chạy |
| `INSUFFICIENT_BUDGET` | Hết ngân sách |
| `DUPLICATE_IMPRESSION` | Đã ghi trong 5 phút |
| `INVALID_DURATION` | Phát quá ngắn |
| `INVALID_PROOF` | Chữ ký không hợp lệ |
| `DEVICE_NOT_AUTHORIZED` | Thiết bị không trong mục tiêu |
| `STORE_BLOCKED` | Cửa hàng bị chặn |

---

## 🚫 Chặn Đối thủ Cạnh tranh

### Quy tắc 17: Định nghĩa Quy tắc Chặn

**Entity**: `StoreBlockingRule`

**Cấu trúc**:

| Trường | Kiểu | Mô tả |
|--------|------|-------|
| `id` | UUID | ID duy nhất |
| `store_id` | UUID | Cửa hàng áp dụng |
| `rule_type` | Enum | BRAND / CATEGORY / KEYWORD |
| `blocked_value` | String | Tên brand, category, keyword |
| `reason` | String | Tại sao chặn (không bắt buộc) |
| `created_by` | UUID | Supplier tạo |
| `is_active` | Boolean | Có thể tắt tạm thời |

**Ví dụ Quy tắc**:

```javascript
// 1. Chặn theo Thương hiệu
{
  store_id: "store-123",
  rule_type: "BRAND",
  blocked_value: "Coca-Cola",
  reason: "Hợp tác độc quyền với Pepsi"
}

// 2. Chặn theo Danh mục
{
  store_id: "store-456",
  rule_type: "CATEGORY",
  blocked_value: "ALCOHOL",
  reason: "Địa điểm thân thiện gia đình"
}

// 3. Chặn theo Từ khóa
{
  store_id: "store-789",
  rule_type: "KEYWORD",
  blocked_value: "nước tăng lực",
  reason: "Không bán sản phẩm kích thích"
}
```

---

### Quy tắc 18: Logic Kiểm tra Chặn

**Hàm**: `is_campaign_blocked(campaign, store)`

**Dữ liệu đầu vào**:
- campaign: Đối tượng Campaign
- store: Đối tượng Store có blocking_rules

**Đầu ra**:
- blocked: Boolean
- reason: String (nếu bị chặn)

**Thuật toán**:

```python
def is_campaign_blocked(campaign, store):
    # 1. Lấy tất cả quy tắc active của cửa hàng
    rules = StoreBlockingRule.where(
        store_id = store.id,
        is_active = true
    )

    # 2. Kiểm tra từng quy tắc
    for rule in rules:
        if rule.rule_type == "BRAND":
            if campaign.brand_name.lower() == rule.blocked_value.lower():
                return (True, f"Thương hiệu bị chặn: {rule.blocked_value}")

        elif rule.rule_type == "CATEGORY":
            if campaign.category == rule.blocked_value:
                return (True, f"Danh mục bị chặn: {rule.blocked_value}")

        elif rule.rule_type == "KEYWORD":
            keywords = [campaign.name, campaign.description, campaign.brand_name]
            combined = " ".join(keywords).lower()
            if rule.blocked_value.lower() in combined:
                return (True, f"Từ khóa bị chặn: {rule.blocked_value}")

    # 3. Không khớp → không bị chặn
    return (False, None)
```

**Ví dụ**:

```
Campaign: {
  brand_name: "Coca-Cola",
  category: "FOOD_BEVERAGE"
}

Store: Có quy tắc chặn "Coca-Cola"

→ Kết quả: (True, "Thương hiệu bị chặn: Coca-Cola")
```

---

### Quy tắc 19: Áp dụng Chặn

#### Khi Tạo Chiến dịch (Bước 4)

```
Khi Advertiser chọn cửa hàng mục tiêu:

FOREACH cửa hàng IN selected_stores:
  (blocked, reason) = is_campaign_blocked(campaign, cửa hàng)

  IF blocked:
    blocked_stores.append({
      store_id: cửa hàng.id,
      store_name: cửa hàng.name,
      reason: reason
    })
  ELSE:
    eligible_stores.append(cửa hàng)

→ Trả về: eligible_stores, blocked_stores

Kiểm tra:
IF eligible_stores.length == 0:
  ERROR: "Tất cả cửa hàng đã chặn chiến dịch của bạn"
```

#### Khi Kích hoạt Chiến dịch

```
Khi phân phối nội dung đến thiết bị:

eligible_devices = devices.filter(device =>
  device.store_id IN campaign.target_stores
  AND device.store_id NOT IN campaign.blocked_stores
)

→ Chỉ đẩy nội dung đến eligible_devices
```

**Quy tắc nghiệp vụ**:
- Cửa hàng bị chặn KHÔNG BAO GIỜ nhận nội dung chiến dịch
- Nếu cửa hàng thêm quy tắc SAU khi chiến dịch active:
  * Ngay lập tức loại khỏi cửa hàng đó
  * Thông báo Advertiser về thay đổi

---

## ⚠️ Các trường hợp đặc biệt

### Trường hợp 1: Thiết bị Offline giữa Chiến dịch

**Tình huống**: Thiết bị online khi chiến dịch bắt đầu, sau đó offline

**Xử lý**:
- Chiến dịch vẫn ACTIVE
- Thiết bị ngừng nhận cập nhật nội dung
- Không ghi nhận impression khi offline
- Không tính phí trong thời gian offline

**Khi thiết bị online trở lại**:
- Thiết bị đồng bộ với server
- Tải manifest chiến dịch mới nhất
- Tiếp tục phát quảng cáo
- Impression tiếp tục được ghi nhận

---

### Trường hợp 2: Impression đồng thời Vượt Ngân sách

**Tình huống**:
```
• Ngân sách còn: $0.10
• Chi phí impression: $0.08
• 3 thiết bị gửi impression đồng thời
```

**Ngăn chặn Race Condition**:

```sql
BEGIN TRANSACTION;

-- Lock row để đảm bảo atomic
SELECT remaining_budget 
FROM campaigns
WHERE id = X 
FOR UPDATE;

-- Impression 1:
✓ remaining_budget ($0.10) >= cost ($0.08)
→ Ghi nhận
→ remaining_budget = $0.02
COMMIT;

-- Impression 2:
✗ remaining_budget ($0.02) < cost ($0.08)
→ Từ chối
→ Status = PAUSED
ROLLBACK;

-- Impression 3:
✗ Campaign status = PAUSED
→ Từ chối
```

**Quy tắc nghiệp vụ**:
- Kiểm tra ngân sách atomic ngăn chi vượt
- Impression cuối có thể bị từ chối không công bằng (chấp nhận được)
- Ngân sách không bao giờ âm

---

### Trường hợp 3: Đồng hồ Thiết bị Sai (Timestamp Tương lai)

**Tình huống**: Thiết bị báo impression với played_at ở tương lai

**Ví dụ**:
```
Thời gian server: 2026-01-23 14:30:00
Thời gian thiết bị: 2026-01-23 14:37:00 (chênh 7 phút)
```

**Kiểm tra**:
```
IF played_at > server_time + 5 phút:
  → TỪ CHỐI với "INVALID_TIMESTAMP_FUTURE"
  → Log cảnh báo: "Đồng hồ thiết bị {device_id} nhanh {diff}"
  → Đề xuất: "Đồng bộ đồng hồ với NTP"
```

**Quy tắc nghiệp vụ**:
- Cho phép sai lệch tối đa 5 phút (khoan dung)
- Vượt 5 phút → rõ ràng có vấn đề → từ chối
- Theo dõi thiết bị có vấn đề thời gian mãn tính
- Admin có thể gắn cờ cần bảo trì

---

## ✅ Quy tắc Kiểm tra

### Ma trận Kiểm tra Campaign

| Trường | Quy tắc | Thông báo lỗi |
|--------|---------|---------------|
| `name` | 3-100 ký tự | "Tên phải 3-100 ký tự" |
| `name` | Duy nhất/Advertiser | "Tên chiến dịch đã tồn tại" |
| `brand_name` | 2-50 ký tự | "Tên thương hiệu 2-50 ký tự" |
| `brand_name` | Không rỗng | "Cần tên thương hiệu" |
| `budget` | >= 100.00 | "Ngân sách tối thiểu $100" |
| `budget` | <= 1000000.00 | "Ngân sách tối đa $1,000,000" |
| `budget` | Tối đa 2 số thập phân | "Ngân sách tối đa 2 chữ số sau dấu phẩy" |
| `start_date` | >= BÂY GIỜ + 24h | "Phải cách ít nhất 24 giờ" |
| `start_date` | < end_date | "Phải trước ngày kết thúc" |
| `end_date` | <= start_date + 365d | "Không quá 1 năm" |
| `target_stores` | >= 1 | "Cần ít nhất 1 cửa hàng" |
| `target_stores` | <= 1000 | "Tối đa 1000 cửa hàng" |
| `content_assets` | >= 1 | "Cần ít nhất 1 nội dung" |
| `content_assets` | <= 10 | "Tối đa 10 nội dung" |
| `daily_cap` | >= 10.00 nếu có | "Giới hạn ngày tối thiểu $10" |
| `daily_cap` | <= budget nếu có | "Không vượt tổng ngân sách" |

---

## 🧮 Công thức Tính toán

### Tổng hợp Công thức

#### 1. Chi phí Impression

```
impression_cost = (CPM_rate / 1000)
                  × duration_adjustment
                  × priority_premium
                  × quality_multiplier

Trong đó:
• CPM_rate: Dựa trên loại CH + thời gian + lượng khách
• duration_adjustment: 1.0 cho >=15s, còn lại (thực/15)
• priority_premium: 0.90-1.10 dựa trên ưu tiên
• quality_multiplier: 0.9-1.3 dựa trên thông số thiết bị
```

#### 2. Ước tính Chi phí Chiến dịch

```
estimated_cost = estimated_impressions × avg_CPM / 1000

estimated_impressions = SUM(
  store.daily_foot_traffic
  × store.device_count
  × store.avg_dwell_time_minutes / 60
  × campaign.duration_days
) × 0.7  // Hệ số bảo thủ
```

#### 3. Chia Doanh thu

```
platform_revenue = impression_cost × 0.20
supplier_revenue = impression_cost × 0.80
```

#### 4. Ngân sách còn lại

```
remaining_budget = campaign.budget - campaign.spent

// Kiểm tra (audit):
remaining_budget = campaign.budget
                   - SUM(impressions.cost WHERE status = VERIFIED)
```

#### 5. Tỷ lệ Hoàn thành

```
completion_pct = (campaign.spent / campaign.budget) × 100

// Hoàn thành theo thời gian:
time_completion_pct = (
  (BÂY GIỜ - start_date) / (end_date - start_date)
) × 100

// Đánh giá:
IF completion_pct > time_completion_pct + 20:
  status = "CHI NHANH QUÁ"
ELSE IF completion_pct < time_completion_pct - 20:
  status = "PHÁT CHẬM"
ELSE:
  status = "ĐÚNG KẾ HOẠCH"
```

#### 6. CPM Thực tế (Hiệu suất)

```
effective_CPM = (campaign.spent / total_impressions) × 1000

// So với ước tính:
CPM_variance = (effective_CPM - estimated_CPM) / estimated_CPM × 100

Ví dụ:
  Chi: $500
  Impression: 10,000
  CPM thực: ($500 / 10,000) × 1000 = $50.00

  Nếu CPM ước tính $45:
  Chênh lệch: (50 - 45) / 45 × 100 = +11.1% (cao hơn)
```

---

## 📚 Tham khảo

### Tài liệu liên quan

| Tài liệu | Mô tả |
|----------|-------|
| [Từ điển Thuật ngữ](./00-tu-dien-thuat-ngu.md) | Giải thích tất cả thuật ngữ |
| [Mô hình Thanh toán](./02-mo-hinh-thanh-toan.md) | Chi tiết các mô hình tính phí |
| [Quy tắc Thiết bị](./05-quy-tac-thiet-bi.md) | Quản lý thiết bị |
| [Quy tắc Lượt hiển thị](./06-quy-tac-luot-hien-thi.md) | Chi tiết impression |
| [Quy tắc Ví](./07-quy-tac-vi-thanh-toan.md) | Chi tiết ví & thanh toán |

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team  
**Trạng thái**: Sẵn sàng để review
