# 🏪 Quy tắc Nghiệp vụ: Module Nhà cung cấp (Supplier)

**Phiên bản**: 1.0  
**Ngày**: 2026-01-23  
**Trạng thái**: Bản nháp  
**Chủ quản**: Product Team

---

## 📖 Mục lục

1. [Tổng quan](#-tổng-quan)
2. [Các thực thể Domain](#-các-thực-thể-domain)
3. [Vòng đời Supplier](#-vòng-đời-supplier)
4. [Đăng ký & Onboarding](#-đăng-ký--onboarding)
5. [Quản lý Cửa hàng](#-quản-lý-cửa-hàng)
6. [Quản lý Thiết bị](#-quản-lý-thiết-bị)
7. [Theo dõi Doanh thu & Thanh toán](#-theo-dõi-doanh-thu--thanh-toán)
8. [Quy tắc Chặn Đối thủ](#-quy-tắc-chặn-đối-thủ)
9. [Chỉ số Hiệu suất Supplier](#-chỉ-số-hiệu-suất-supplier)
10. [Cấp Tài khoản & Giới hạn](#-cấp-tài-khoản--giới-hạn)
11. [Tuân thủ & Xác minh](#-tuân-thủ--xác-minh)
12. [Quản lý Trạng thái Tài khoản](#-quản-lý-trạng-thái-tài-khoản)
13. [Các trường hợp đặc biệt](#-các-trường-hợp-đặc-biệt)
14. [Công thức Nghiệp vụ](#-công-thức-nghiệp-vụ)

---

## 🎯 Tổng quan

### Mục đích

Tài liệu này định nghĩa TẤT CẢ quy tắc nghiệp vụ cho module Supplier, bao gồm onboarding, quản lý cửa hàng, quản lý thiết bị, theo dõi doanh thu và tuân thủ.

### Vai trò Supplier

**Supplier** là chủ doanh nghiệp bán lẻ:
- ✅ Cung cấp địa điểm cửa hàng để hiển thị quảng cáo
- ✅ Lắp đặt và duy trì thiết bị signage kỹ thuật số
- ✅ **Kiếm 80% doanh thu** từ chi phí impression
- ✅ Kiểm soát đối thủ nào có thể quảng cáo ở vị trí của họ

### Phạm vi

**Bao gồm:**
- ✅ Đăng ký và xác minh supplier
- ✅ Quản lý cửa hàng và thiết bị
- ✅ Tính toán doanh thu và thanh toán
- ✅ Quy tắc chặn đối thủ
- ✅ Theo dõi hiệu suất và chất lượng
- ✅ Cấp tài khoản và giới hạn
- ✅ Tuân thủ và trường hợp đặc biệt

**KHÔNG bao gồm:**
- ❌ Tạo chiến dịch (xem module Campaign)
- ❌ Quản lý nội dung quảng cáo (xem module Content)
- ❌ Chi tiết heartbeat thiết bị (xem module Device)

---

## 📦 Các thực thể Domain

### 1. Supplier (Nhà cung cấp)

> **Định nghĩa**: Chủ doanh nghiệp bán lẻ cung cấp cửa hàng và thiết bị để hiển thị quảng cáo.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Mặc định | Quy tắc nghiệp vụ |
|--------|------|----------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo | Không thay đổi |
| `user_id` | UUID | Có | - | Tài khoản chủ sở hữu |
| `business_name` | String(100) | Có | - | Tên doanh nghiệp đã đăng ký |
| `business_type` | Enum | Có | - | Xem [Loại Doanh nghiệp](#loại-doanh-nghiệp) |
| `business_registration_number` | String(50) | Có | - | EIN/Số đăng ký doanh nghiệp |
| `tax_id` | String(50) | Có | - | EIN hoặc SSN (mã hóa) |
| `industry_category` | Enum | Có | - | Xem [Danh mục Ngành](#danh-mục-ngành) |
| `website_url` | String(200) | Không | null | URL doanh nghiệp |
| `description` | Text | Không | null | Mô tả doanh nghiệp |
| `total_stores` | Integer | Có | 0 | Số cửa hàng active |
| `total_devices` | Integer | Có | 0 | Số thiết bị active |
| `verification_status` | Enum | Có | UNVERIFIED | Xem [Trạng thái Xác minh](#trạng-thái-xác-minh) |
| `verified_at` | DateTime | Không | null | Khi hoàn thành KYC |
| `tier` | Enum | Có | STARTER | STARTER/PROFESSIONAL/ENTERPRISE |
| `payment_schedule` | Enum | Có | MONTHLY | WEEKLY/BIWEEKLY/MONTHLY |
| `minimum_payout_threshold` | Decimal(10,2) | Có | Dựa vào cấp | Dựa vào cấp |
| `revenue_share_percentage` | Decimal(5,4) | Có | 0.8000 | Mặc định 80% |
| `total_revenue_earned` | Decimal(12,2) | Có | 0.00 | Doanh thu từ trước đến nay |
| `total_impressions_served` | BigInt | Có | 0 | Impression từ trước đến nay |
| `quality_score` | Integer | Có | 100 | 0-100, ảnh hưởng ưu tiên |
| `status` | Enum | Có | - | Xem [Trạng thái](#trạng-thái-supplier) |
| `suspended_at` | DateTime | Không | null | Khi bị đình chỉ |
| `suspension_reason` | String(200) | Không | null | Lý do đình chỉ |
| `banned_at` | DateTime | Không | null | Khi bị cấm vĩnh viễn |
| `ban_reason` | String(200) | Không | null | Lý do cấm |
| `account_manager_id` | UUID | Không | null | Quản lý TK được gán (Enterprise) |
| `created_at` | DateTime | Có | BÂY GIỜ() | Không thay đổi |
| `updated_at` | DateTime | Có | BÂY GIỜ() | Tự động cập nhật |

#### Loại Doanh nghiệp

```
• SOLE_PROPRIETORSHIP: Tư nhân/sole proprietor
• LLC: Công ty trách nhiệm hữu hạn
• CORPORATION: Công ty cổ phần
• PARTNERSHIP: Công ty hợp danh
• FRANCHISE: Nhượng quyền thương mại
• NON_PROFIT: Tổ chức phi lợi nhuận
```

#### Danh mục Ngành

```
• GROCERY: Cửa hàng tạp hóa
• CONVENIENCE_STORE: Cửa hàng tiện lợi
• RESTAURANT: Nhà hàng & cafe
• RETAIL_CLOTHING: Cửa hàng quần áo
• RETAIL_ELECTRONICS: Cửa hàng điện tử
• PHARMACY: Hiệu thuốc
• GAS_STATION: Trạm xăng
• MALL: Trung tâm thương mại
• GYM_FITNESS: Phòng gym & fitness
• SALON_SPA: Salon & spa
• HOTEL: Khách sạn
• OTHER: Ngành nghề khác
```

#### Trạng thái Xác minh

```
• UNVERIFIED: Chưa nộp tài liệu
• PENDING: Tài liệu đang xem xét
• VERIFIED: Đã phê duyệt
• REJECTED: Bị từ chối
• EXPIRED: Hết hạn (cần xác minh lại)
```

#### Trạng thái Supplier

```
• PENDING_REGISTRATION: Đang onboarding
• ACTIVE: Hoạt động bình thường
• INACTIVE: Tạm dừng tự nguyện
• SUSPENDED: Vô hiệu hóa tạm thời
• PERMANENTLY_BANNED: Vô hiệu hóa vĩnh viễn
```

---

### 2. SupplierVerification (Xác minh Supplier)

> **Định nghĩa**: Bản ghi xác minh KYC cho supplier.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `supplier_id` | UUID | Có | Đối tượng xác minh |
| `submitted_at` | DateTime | Có | Khi nộp tài liệu |
| `reviewed_at` | DateTime | Không | Khi admin xem xét |
| `reviewed_by` | UUID | Không | Admin đánh giá |
| `status` | Enum | Có | PENDING/APPROVED/REJECTED |
| `documents` | JSON | Có | Mảng metadata tài liệu |
| `rejection_reason` | String(200) | Không | Lý do từ chối |
| `notes` | Text | Không | Ghi chú admin |

---

### 3. Store (Cửa hàng)

> **Định nghĩa**: Địa điểm bán lẻ vật lý của supplier nơi lắp đặt thiết bị.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `supplier_id` | UUID | Có | Supplier sở hữu |
| `store_name` | String(100) | Có | "Nike Store Downtown" |
| `store_type` | Enum | Có | Xem [Loại Cửa hàng](#loại-cửa-hàng) |
| `address_street` | String(200) | Có | Địa chỉ đường |
| `address_city` | String(100) | Có | Thành phố |
| `address_state` | String(50) | Có | Bang/Tỉnh |
| `address_zip` | String(20) | Có | Mã bưu điện |
| `address_country` | String(50) | Có | Mã quốc gia (ISO) |
| `latitude` | Decimal(10,8) | Có | Tọa độ GPS |
| `longitude` | Decimal(11,8) | Có | Tọa độ GPS |
| `square_footage` | Integer | Có | Diện tích (sqft) |
| `total_devices` | Integer | Có | Số thiết bị tại cửa hàng |
| `max_devices_allowed` | Integer | Có | Dựa vào diện tích |
| `operating_hours` | JSON | Có | Giờ mở cửa mỗi ngày |
| `foot_traffic_tier` | Enum | Có | LOW/MEDIUM/HIGH/VERY_HIGH |
| `verification_status` | Enum | Có | PENDING/VERIFIED/REJECTED |
| `status` | Enum | Có | ACTIVE/INACTIVE/CLOSED |
| `created_at` | DateTime | Có | BÂY GIỜ() |
| `updated_at` | DateTime | Có | BÂY GIỜ() |

#### Loại Cửa hàng

```
• FLAGSHIP: Cửa hàng chủ lực
• STANDARD: Cửa hàng tiêu chuẩn
• EXPRESS: Cửa hàng nhỏ/express
• OUTLET: Cửa hàng outlet
• POP_UP: Cửa hàng tạm thời
• KIOSK: Gian hàng
```

---

### 4. SupplierSettings (Cài đặt Supplier)

> **Định nghĩa**: Cấu hình và tùy chọn cho supplier.

#### Các thuộc tính

| Trường | Kiểu | Mặc định | Mô tả |
|--------|------|----------|-------|
| `supplier_id` | UUID | - | Supplier liên kết |
| `allow_own_brand_ads` | Boolean | false | Cho phép quảng cáo thương hiệu riêng |
| `auto_approve_campaigns` | Boolean | false | Tự động phê duyệt chiến dịch |
| `notification_email` | String | - | Email thông báo |
| `notification_sms` | String | null | SMS thông báo |
| `device_offline_alert_threshold` | Integer | 30 | Phút offline trước cảnh báo |
| `low_revenue_alert_threshold` | Decimal(10,2) | 0 | Doanh thu hàng ngày tối thiểu |
| `preferred_payment_method` | Enum | - | ACH/PAYPAL/STRIPE |

---

## 🔄 Vòng đời Supplier

### Luồng Trạng thái

```
PENDING_REGISTRATION
  ↓
  → (Đăng ký hoàn thành) → ACTIVE
                             ↓
  ┌──────────────────────────┼──────────────────────────┐
  ↓                          ↓                          ↓
INACTIVE                 SUSPENDED              (Hoạt động)
(tự nguyện)             (bị buộc)
  ↓                          ↓                          ↓
  → (Kích hoạt lại) ← ── ← (Giải quyết) ← ──        PERMANENTLY_BANNED
                                                       (không đảo ngược)
```

### 5 Trạng thái chính

**1. PENDING_REGISTRATION**:
- Tài khoản mới được tạo
- Đang hoàn thành onboarding
- Không thể thêm thiết bị hay nhận doanh thu

**2. ACTIVE**:
- Xác minh hoàn thành
- Thiết bị phục vụ quảng cáo
- Doanh thu tích lũy

**3. INACTIVE**:
- Tạm dừng tự nguyện (vd: đóng cửa theo mùa)
- Không phục vụ quảng cáo
- Có thể kích hoạt lại bất cứ lúc nào

**4. SUSPENDED**:
- Bị đình chỉ tạm thời do vi phạm
- Không phục vụ quảng cáo
- Yêu cầu giải quyết vấn đề

**5. PERMANENTLY_BANNED**:
- Cấm vĩnh viễn do vi phạm nghiêm trọng
- Tất cả thiết bị vô hiệu hóa
- Không thể đăng ký lại

---

## 📝 Đăng ký & Onboarding

### 4.1 Quy trình Đăng ký

```
Bước 1: Đăng ký Tài khoản
  User cung cấp:
    • Email + Mật khẩu
    • Tên doanh nghiệp
    • Loại doanh nghiệp

  Hệ thống tạo:
    • Bản ghi Supplier (trạng thái: PENDING_REGISTRATION)
    • Gửi email xác minh

Bước 2: Thiết lập Hồ sơ Doanh nghiệp
  User nộp:
    • Số đăng ký doanh nghiệp
    • Mã số thuế (EIN hoặc SSN)
    • Danh mục ngành
    • Mô tả doanh nghiệp
    • Địa chỉ doanh nghiệp

Bước 3: Nộp Tài liệu
  DOANH NGHIỆP NHỎ (< 10 cửa hàng):
    • Giấy phép kinh doanh
    • Mã số thuế
    • ID chính phủ của chủ sở hữu
    • Chứng minh địa chỉ doanh nghiệp

  DOANH NGHIỆP LỚN (10+ cửa hàng):
    • Giấy chứng nhận đăng ký doanh nghiệp
    • Điều lệ công ty
    • EIN letter từ IRS
    • Tuyên bố sở hữu thụ hưởng
    • Sao kê ngân hàng doanh nghiệp
    • Bảo hiểm trách nhiệm (nếu áp dụng)

Bước 4: Đăng ký Cửa hàng
  Supplier thêm cửa hàng đầu tiên:
    • Tên cửa hàng
    • Địa chỉ đầy đủ
    • Loại cửa hàng
    • Diện tích (square footage)
    • Giờ hoạt động

  Hệ thống xác minh:
    • Geocode địa chỉ (latitude/longitude)
    • Xác minh địa điểm qua Google Maps
    • Tính toán giới hạn thiết bị dựa vào diện tích

Bước 5: Thiết lập Thiết bị
  Supplier đăng ký thiết bị:
    • Device ID (từ phần cứng)
    • Vị trí thiết bị trong cửa hàng
    • Tọa độ GPS (xác minh vị trí)

  Hệ thống kiểm tra:
    • GPS trong geofence cửa hàng (bán kính 100m)
    • Cửa hàng có chỗ khả dụng
    • Không trùng Device ID

Bước 6: Xem xét Xác minh
  KIỂM TRA TỰ ĐỘNG:
    • Xác thực mã số thuế (IRS Taxpayer ID Matching)
    • Xác minh email/điện thoại
    • Xác thực địa chỉ (USPS)
    • Xác minh tài khoản ngân hàng (Plaid)

  ĐÁNH GIÁ THỦ CÔNG (nếu gắn cờ):
    • Tính xác thực tài liệu
    • Xác minh đăng ký doanh nghiệp
    • Kiểm tra lý lịch (nếu cần)
    • Xác minh địa điểm cửa hàng

  SLA:
    • Tiêu chuẩn: 3-5 ngày làm việc
    • Express: 1 ngày (Enterprise)
    • Nhanh: Cùng ngày (có phí)

Bước 7: Phê duyệt & Kích hoạt
  NẾU được phê duyệt:
    supplier.status = ACTIVE
    supplier.verification_status = VERIFIED
    supplier.verified_at = BÂY GIỜ()

    • Tạo ví (số dư: $0)
    • Thiết bị bắt đầu phục vụ quảng cáo
    • Email chào mừng với hướng dẫn tiếp theo

  NẾU bị từ chối:
    supplier.verification_status = REJECTED

    • Email với lý do từ chối
    • Cho phép nộp lại sau khi giải quyết vấn đề
```

### 4.2 Ma trận Yêu cầu Tài liệu

| Loại Doanh nghiệp | Tài liệu Bắt buộc |
|-------------------|-------------------|
| **Sole Proprietorship** | • ID chính phủ<br>• Giấy phép kinh doanh (nếu áp dụng)<br>• Chứng minh địa chỉ doanh nghiệp<br>• SSN hoặc EIN |
| **LLC** | • Điều lệ công ty<br>• Giấy chứng nhận đăng ký<br>• EIN letter<br>• ID thành viên quản lý<br>• Sao kê ngân hàng doanh nghiệp |
| **Corporation** | • Điều lệ công ty<br>• Giấy chứng nhận đăng ký<br>• EIN letter<br>• Sở hữu thụ hưởng<br>• Sao kê ngân hàng doanh nghiệp<br>• ID người ký có thẩm quyền |
| **Partnership** | • Thỏa thuận hợp danh<br>• Giấy chứng nhận đăng ký<br>• EIN letter<br>• ID tất cả đối tác<br>• Sao kê ngân hàng doanh nghiệp |
| **Franchise** | | • Thỏa thuận nhượng quyền<br>• Giấy phép nhượng quyền<br>• EIN letter<br>• ID chủ nhượng quyền<br>• Sao kê ngân hàng doanh nghiệp |
| **Non-Profit** | • Giấy phép 501(c)<br>• IRS determination letter<br>• Điều lệ<br>• EIN letter<br>• Sao kê ngân hàng |

---

## 🏬 Quản lý Cửa hàng

### 5.1 Đăng ký Cửa hàng

#### Quy tắc 5.1.1: Kiểm tra Cửa hàng

```
Khi supplier đăng ký cửa hàng mới:

1. Kiểm tra giới hạn cấp:
   NẾU supplier.total_stores >= tier_max_stores:
     LỖI: "Đã đạt giới hạn cửa hàng cho cấp {tier}"
     Đề xuất nâng cấp

2. Kiểm tra tên cửa hàng:
   • Độ dài: 5-100 ký tự
   • Duy nhất trong supplier

3. Xác thực địa chỉ:
   • Tất cả trường bắt buộc đã điền
   • Sử dụng API geocoding để lấy GPS
   • Xác minh địa chỉ tồn tại

4. Xác minh địa điểm:
   • So sánh với Google Maps API
   • Kiểm tra là địa điểm kinh doanh hợp lệ
   • Gắn cờ nếu địa chỉ nhà hoặc PO Box

5. Tính toán giới hạn thiết bị:
   max_devices = TÍNH DỰA VÀO square_footage:
     < 1000 sqft: 1 thiết bị
     1000-2999 sqft: 2 thiết bị
     3000-4999 sqft: 3 thiết bị
     5000-9999 sqft: 5 thiết bị
     ≥10000 sqft: 10 thiết bị

   ENTERPRISE: Giới hạn tùy chỉnh đã thỏa thuận

6. Thiết lập giờ hoạt động:
   {
     "monday": {"open": "09:00", "close": "21:00"},
     "tuesday": {"open": "09:00", "close": "21:00"},
     // ... các ngày khác
     "sunday": {"open": "10:00", "close": "18:00"}
   }

   • Ảnh hưởng phục vụ quảng cáo (quảng cáo chỉ hiển thị trong giờ mở cửa)
```

#### Quy tắc 5.1.2: Xác minh Cửa hàng

```
PHƯƠNG PHÁP XÁC MINH:

Xác minh Tự động:
  • Geocoding (Google Maps API)
  • Kiểm tra địa điểm tồn tại
  • Xác minh loại doanh nghiệp (khớp với supplier.industry_category)

Xác minh Thủ công (nếu gắn cờ):
  • Admin xem xét tài liệu
  • Có thể yêu cầu ảnh storefront
  • Gọi điện xác nhận địa điểm

THỜI GIAN XÁC MINH:
  • Tự động: Ngay lập tức
  • Thủ công: 1-2 ngày làm việc
```

---

### 5.2 Quy tắc Giờ Hoạt động

```
Giờ hoạt động ảnh hưởng phục vụ quảng cáo:

TRONG GIỜ HOẠT ĐỘNG:
  • Thiết bị phục vụ quảng cáo bình thường
  • Ghi lại impression
  • Doanh thu tích lũy

NGOÀI GIỜ HOẠT ĐỘNG:
  • Thiết bị không phục vụ quảng cáo chiến dịch
  • Hiển thị "Store Closed" hoặc nội dung branded
  • Không ghi lại impression (không tính phí advertiser)
  • Không tính vào uptime score (loại trừ)

NGOẠI LỆ:
  • Cửa hàng 24/7: Đặt tất cả ngày "00:00-23:59"
  • Cửa hàng theo mùa: Sử dụng tính năng "seasonal schedule"
```

---

## 🖥️ Quản lý Thiết bị

### 5.1 Đăng ký Thiết bị

#### Quy tắc 5.1.1: Kiểm tra Thiết bị

```
Khi supplier đăng ký thiết bị mới:

1. Kiểm tra giới hạn cấp:
   NẾU supplier.total_devices >= tier_max_devices:
     LỖI: "Đã đạt giới hạn thiết bị cho cấp {tier}"

2. Kiểm tra giới hạn cửa hàng:
   NẾU store.total_devices >= store.max_devices_allowed:
     LỖI: "Đã đạt giới hạn thiết bị cho cửa hàng này"
     Gợi ý: Mở rộng diện tích hoặc thêm cửa hàng khác

3. Kiểm tra Device ID:
   • Phải duy nhất toàn cầu
   • Định dạng: UUID hoặc hardware ID
   • Không trùng trong hệ thống

4. Xác minh Vị trí:
   • Yêu cầu tọa độ GPS từ thiết bị
   • Tính khoảng cách đến địa chỉ cửa hàng đã đăng ký
   • NẾU distance > 100m (geofence):
     - TỪ CHỐI đăng ký
     - THÔNG BÁO supplier: "Thiết bị phải ở vị trí cửa hàng"
     - Cung cấp bản đồ hiển thị vị trí dự kiến vs thực tế
```

#### Quy tắc 5.1.2: Quy ước Đặt tên Thiết bị

```
Tên thiết bị PHẢI tuân theo mẫu:
  "{tên_cửa_hàng} - {vị_trí_thiết_bị}"

VÍ DỤ:
  - "Whole Foods Downtown - Checkout Lane 1"
  - "Nike Store - Window Display"
  - "Starbucks 5th Ave - Menu Board"

KIỂM TRA:
  • Độ dài device_name: 5-100 ký tự
  • Phải duy nhất trong cửa hàng
```

#### Quy tắc 5.1.3: Phê duyệt Thiết bị

```
Thiết bị MỚI yêu cầu phê duyệt:

PHÊ DUYỆT TỰ ĐỘNG (nếu tất cả kiểm tra đạt):
  • Vị trí trong geofence ✓
  • Cửa hàng có chỗ khả dụng ✓
  • Thông số thiết bị đáp ứng yêu cầu tối thiểu ✓
  • Không trùng device_id ✓

PHÊ DUYỆT THỦ CÔNG (nếu có lỗi):
  • Admin xem xét chi tiết thiết bị
  • Supplier có thể cần cung cấp ảnh hoặc tài liệu
  • Phê duyệt trong 24 giờ
```

### 5.2 Giám sát Thiết bị

#### 5.2.1 Giám sát Sức khỏe Thiết bị

Supplier có dashboard để giám sát sức khỏe thiết bị:

**Chỉ số Hiển thị**:
- Trạng thái thiết bị (ONLINE, OFFLINE, ERROR)
- Phần trăm uptime (24h, 7d, 30d gần nhất)
- Timestamp heartbeat cuối
- Nội dung đang phát hiện tại
- Impression đã phục vụ hôm nay
- Doanh thu tạo ra hôm nay

**Cảnh báo** (có thể cấu hình):
- Thiết bị offline > 30 phút → Cảnh báo Email/SMS
- Thiết bị trạng thái lỗi → Cảnh báo ngay lập tức
- Doanh thu thấp (< $X mỗi ngày) → Tóm tắt hàng ngày
- Đồng bộ nội dung bị lỡ → Cảnh báo

#### 5.2.2 Bảo trì Thiết bị

**Quy tắc 5.2.2.1: Chế độ Bảo trì Theo lịch**
```
Supplier có thể đặt thiết bị vào chế độ MAINTENANCE:
  • Không phục vụ quảng cáo trong cửa sổ bảo trì
  • Thiết bị hiển thị thông báo "Device Under Maintenance"
  • Không ảnh hưởng điểm uptime trong thời gian này
  • Cửa sổ bảo trì tối đa: 4 giờ mỗi phiên

KHI bảo trì vượt 4 giờ:
  • Tính là downtime
  • Ảnh hưởng điểm uptime thiết bị
```

**Quy tắc 5.2.2.2: Di chuyển Thiết bị**
```
NẾU thiết bị cần di chuyển sang vị trí khác:
  • Supplier PHẢI cập nhật vị trí thiết bị trong nền tảng
  • Thiết bị phải xác minh lại vị trí (kiểm tra GPS)
  • Nếu di chuyển sang cửa hàng khác: Phải hủy ghép và ghép lại

HÌNH PHẠT cho di chuyển trái phép:
  • Nếu phát hiện thiết bị ở vị trí sai (>500m từ địa chỉ đã đăng ký):
    - Đình chỉ thiết bị ngay lập tức
    - Tất cả impression gắn cờ để xem xét
    - Doanh thu giữ lại chờ điều tra
```

### 5.3 Xóa Thiết bị

**Quy tắc 5.3.1: Ngừng hoạt động Thiết bị**
```
Supplier có thể ngừng hoạt động thiết bị:
  • ĐẶT trạng thái thiết bị = "DECOMMISSIONED"
  • Thiết bị ngừng phục vụ quảng cáo
  • Doanh thu cuối cùng tính toán và thêm vào ví
  • Thiết bị có thể đăng ký lại sau (tại cùng hoặc cửa hàng khác)

HIỆU ỨNG:
  • total_devices của cửa hàng giảm
  • Thiết bị không còn tính vào giới hạn cấp
  • Dữ liệu lịch sử giữ lại để báo cáo
```

---

## 💰 Theo dõi Doanh thu & Thanh toán

### 6.1 Mô hình Doanh thu

**Chia sẻ Doanh thu**:
- **Supplier**: 80% doanh thu impression
- **Nền tảng**: 20% doanh thu impression

**Công thức**:
```
impression_cost = campaign.cpm × (1 / 1000)
supplier_revenue = impression_cost × 0.80
platform_revenue = impression_cost × 0.20
```

### 6.2 Tính toán Doanh thu

#### 6.2.1 Doanh thu Mỗi Impression

**Quy tắc 6.2.1.1: Ghi lại Doanh thu**
```
KHI impression được xác minh (status = VERIFIED):
  1. TÍNH impression_cost = campaign.cpm / 1000
  2. TÍNH supplier_revenue = impression_cost × 0.80
  3. TÍNH platform_revenue = impression_cost × 0.20

  4. CẬP NHẬT supplier.wallet:
     • pending_balance += supplier_revenue

  5. CẬP NHẬT campaign.wallet:
     • held_balance -= impression_cost
     (chi phí impression đã khấu trừ khi khởi chạy chiến dịch)

  6. TẠO WalletTransaction:
     • type = "IMPRESSION_REVENUE"
     • amount = supplier_revenue
     • reference_id = impression_id
     • status = "PENDING"
```

**Quy tắc 6.2.1.2: Thời gian Giữ Doanh thu**
```
Doanh thu impression được GIỮ 7 ngày:
  • Trạng thái: PENDING trong ví
  • Cho phép tranh chấp/hoàn tiền
  • Sau 7 ngày (không tranh chấp): Chuyển PENDING → AVAILABLE

CÔNG THỨC:
  available_date = impression.verified_at + 7 ngày

CÔNG VIỆC TỰ ĐỘNG chạy hàng ngày:
  SELECT * FROM wallet_transactions
  WHERE type = 'IMPRESSION_REVENUE'
    AND status = 'PENDING'
    AND available_date <= BÂY GIỜ()

  CHO MỖI transaction:
    • ĐẶT status = 'COMPLETED'
    • CHUYỂN wallet.pending_balance → wallet.available_balance
```

#### 6.2.2 Tổng hợp Doanh thu

**Tính toán Doanh thu Hàng ngày**:
```sql
-- Tính doanh thu hàng ngày của supplier
SELECT
  supplier_id,
  DATE(verified_at) as revenue_date,
  COUNT(*) as total_impressions,
  SUM(supplier_revenue) as total_revenue,
  AVG(cpm) as average_cpm
FROM impressions
WHERE status = 'VERIFIED'
  AND supplier_id = :supplier_id
  AND verified_at >= :start_date
  AND verified_at < :end_date
GROUP BY supplier_id, DATE(verified_at)
```

**Doanh thu theo Thiết bị**:
```sql
SELECT
  device_id,
  device_name,
  store_name,
  COUNT(*) as impressions,
  SUM(supplier_revenue) as revenue,
  AVG(supplier_revenue) as avg_revenue_per_impression
FROM impressions i
JOIN devices d ON i.device_id = d.device_id
JOIN stores s ON d.store_id = s.store_id
WHERE i.supplier_id = :supplier_id
  AND i.status = 'VERIFIED'
  AND i.verified_at >= :start_date
GROUP BY device_id, device_name, store_name
ORDER BY revenue DESC
```

### 6.3 Quy trình Thanh toán

#### 6.3.1 Lịch Thanh toán

**Tần suất Thanh toán**:
- **WEEKLY**: Mỗi thứ Hai (cho doanh thu tuần trước Thứ Hai-Chủ Nhật)
- **BIWEEKLY**: Mỗi thứ Hai cách tuần (chu kỳ 2 tuần)
- **MONTHLY**: Ngày 1 mỗi tháng (cho tháng dương lịch trước)

**Đủ điều kiện Thanh toán**:
```
Thanh toán xảy ra NẾU:
  • wallet.available_balance >= minimum_payout_threshold
  • payment_method được cấu hình và xác minh
  • supplier.status = "ACTIVE"
  • Không có tranh chấp hoặc vấn đề tuân thủ đang chờ
```

#### 6.3.2 Thực thi Thanh toán

**Quy tắc 6.3.2.1: Thanh toán Tự động**
```
VÀO ngày thanh toán theo lịch (vd: Thứ Hai cho WEEKLY):
  CHO MỖI supplier WHERE payment_schedule = "WEEKLY":
    NẾU wallet.available_balance >= minimum_payout_threshold:
      1. TẠO WithdrawalRequest:
         • amount = wallet.available_balance
         • status = "PENDING"
         • scheduled_date = HÔM NAY

      2. KHẤU TRỪ từ ví:
         • available_balance -= amount
         • Thêm vào số dư "in_transit"

      3. KHỞI TẠO thanh toán qua payment processor:
         • ACH transfer (3-5 ngày làm việc)
         • PayPal transfer (ngay lập tức đến 1 ngày)
         • Stripe Connect payout (2-3 ngày làm việc)

      4. KHI thanh toán thành công:
         • ĐẶT withdrawal_request.status = "COMPLETED"
         • in_transit_balance = 0
         • TẠO WalletTransaction (type = "PAYOUT")

      5. KHI thanh toán thất bại:
         • ĐẶT withdrawal_request.status = "FAILED"
         • HOÀN tiền vào available_balance
         • THÔNG BÁO supplier cập nhật phương thức thanh toán
```

**Quy tắc 6.3.2.2: Ngưỡng Thanh toán Tối thiểu**
```
NGƯỠNG minimum_payout_threshold MẶC ĐỊNH = $50

LÝ DO:
  • Giảm phí giao dịch cho số tiền nhỏ
  • Cân bằng dòng tiền supplier với hiệu quả nền tảng

NGOẠI LỆ:
  • Supplier có thể yêu cầu thanh toán thủ công nếu số dư < $50 (một lần/tháng)
  • Tính phí: $5 cho thanh toán thủ công dưới ngưỡng
```

**Quy tắc 6.3.2.3: Giữ Thanh toán**
```
Thanh toán có thể bị GIỮ nếu:
  • Tranh chấp active về impression (tổng số tiền tranh chấp > $100)
  • Supplier đang điều tra gian lận
  • Số dư nợ nền tảng chưa thanh toán (vd: hoàn tiền)
  • Biểu mẫu thuế chưa nộp (W-9/W-8)

THỜI GIAN GIỮ:
  • Cho đến khi vấn đề được giải quyết
  • Giữ tối đa: 90 ngày (sau đó giải phóng trừ khi giữ pháp lý)

THÔNG BÁO SUPPLIER:
  • Email gửi ngay khi thanh toán bị giữ
  • Lý do và hành động cần thiết nêu rõ
  • Liên hệ hỗ trợ được cung cấp
```

#### 6.3.3 Xử lý Thuế

**Quy tắc 6.3.3.1: Khấu trừ Thuế**
```
ÁP DỤNG KHẤU TRỪ THUẾ:
  • Supplier Mỹ: Không khấu trừ (phát hành 1099-K nếu >$20k doanh thu VÀ >200 giao dịch)
  • Supplier ngoài Mỹ: Khấu trừ 30% (trừ khi có hiệp ước thuế)

CÔNG THỨC cho supplier ngoài Mỹ:
  gross_payout = wallet.available_balance
  withholding_amount = gross_payout × 0.30
  net_payout = gross_payout - withholding_amount

  TẠO WalletTransaction:
    • type = "TAX_WITHHOLDING"
    • amount = withholding_amount
    • description = "US tax withholding (30%)"
```

**Quy tắc 6.3.3.2: Yêu cầu Biểu mẫu Thuế**
```
Supplier Mỹ:
  • Phải nộp biểu mẫu W-9
  • Nhận 1099-K nếu đáp ứng ngưỡng

Supplier ngoài Mỹ:
  • Phải nộp W-8BEN hoặc W-8BEN-E
  • Có thể yêu cầu lợi ích hiệp ước thuế (giảm khấu trừ)

THỰC THI:
  • NẾU không nộp biểu mẫu thuế:
    - Sau $600 doanh thu: Chặn thanh toán cho đến khi nộp biểu mẫu
    - Sau $1000 doanh thu: Đình chỉ tài khoản cho đến khi tuân thủ
```

### 6.4 Báo cáo Doanh thu

**Dashboard Doanh thu Supplier** bao gồm:

**Chỉ số Thời gian Thực**:
- Doanh thu hôm nay (live)
- Doanh thu hôm qua
- Doanh thu tuần này
- Doanh thu tháng này
- Doanh thu từ trước đến nay

**Phân tích Doanh thu**:
- Doanh thu theo cửa hàng
- Doanh thu theo thiết bị
- Doanh thu theo giờ trong ngày (heatmap)
- Doanh thu theo advertiser
- Doanh thu theo danh mục chiến dịch

**Lịch sử Thanh toán**:
- Tất cả thanh toán trước (ngày, số tiền, trạng thái)
- Thanh toán đang chờ
- Thanh toán theo lịch tiếp theo
- Số tiền thanh toán ước tính

**Báo cáo Tải xuống**:
- Xuất CSV impression
- Tóm tắt doanh thu hàng tháng (PDF)
- Tài liệu thuế (1099-K, v.v.)

---

## 🚫 Quy tắc Chặn Đối thủ

### 7.1 Tổng quan

Supplier có thể định nghĩa **Quy tắc Chặn Đối thủ** để ngăn đối thủ trực tiếp quảng cáo trên thiết bị của họ.

**Ví dụ**: Cửa hàng Nike có thể chặn quảng cáo từ Adidas, Reebok và các thương hiệu giày thể thao khác.

### 7.2 Thực thể Quy tắc Chặn

```typescript
interface CompetitorBlockingRule {
  rule_id: string                        // UUID
  supplier_id: string                    // FK đến supplier
  store_id: string | null                // FK đến store (null = áp dụng tất cả cửa hàng)

  // Cấu hình Quy tắc
  rule_name: string                      // "Block Athletic Competitors"
  rule_type: BlockingRuleType            // ADVERTISER | INDUSTRY | KEYWORD | CUSTOM
  is_active: boolean

  // Tiêu chí Chặn
  blocked_advertiser_ids: string[]       // ID advertiser cụ thể để chặn
  blocked_industry_categories: string[]  // ["Athletic Footwear", "Sportswear"]
  blocked_keywords: string[]             // ["Adidas", "Reebok", "Puma"]

  // Phạm vi
  applies_to_all_stores: boolean         // Nếu true, quy tắc áp dụng tất cả cửa hàng supplier
  specific_store_ids: string[]           // Nếu applies_to_all_stores = false, danh sách store ID

  // Metadata
  created_at: Date
  updated_at: Date
  created_by_user_id: string
}

enum BlockingRuleType {
  ADVERTISER = "ADVERTISER",       // Chặn advertiser cụ thể
  INDUSTRY = "INDUSTRY",           // Chặn toàn bộ danh mục ngành
  KEYWORD = "KEYWORD",             // Chặn dựa vào từ khóa trong chiến dịch/nội dung
  CUSTOM = "CUSTOM"                // Quy tắc tùy chỉnh (nâng cao)
}
```

### 7.3 Áp dụng Quy tắc Chặn

#### 7.3.1 Khớp Chiến dịch

**Quy tắc 7.3.1.1: Bộ lọc Trước khớp**
```
KHI chiến dịch đang được khớp với thiết bị:
  CHO MỖI device trong matching pool:
    1. LẤY supplier_id từ device
    2. LẤY tất cả quy tắc chặn active cho supplier

    3. CHO MỖI blocking rule:
       • NẾU rule áp dụng cho cửa hàng của device:
         - KIỂM TRA nếu chiến dịch vi phạm quy tắc:
           - advertiser_id trong blocked_advertiser_ids
           - campaign.industry_category trong blocked_industry_categories
           - campaign.name hoặc content chứa blocked_keywords

       • NẾU phát hiện vi phạm:
         - LOẠI device khỏi campaign matching pool
         - GHI LẠI lý do loại
```

**Quy tắc 7.3.1.2: Khớp Từ khóa**
```
Chặn từ khóa sử dụng khớp một phần không phân biệt chữ hoa chữ thường:

VÍ DỤ:
  blocked_keywords = ["Adidas", "Nike"]

  BỊ CHẶN:
    • Tên chiến dịch: "Adidas Spring Sale"
    • Tên chiến dịch: "New Nike Shoes"
    • Tên file nội dung: "adidas_banner.png"
    • Tên advertiser: "Nike Inc."

  KHÔNG BỊ CHẶN:
    • Tên chiến dịch: "Athletic Shoe Sale" (không khớp từ khóa)
```

**Quy tắc 7.3.1.3: Chặn Danh mục Ngành**
```
Danh mục ngành theo cấu trúc phân cấp:

VÍ DỤ:
  blocked_industry_categories = ["Athletic Footwear"]

  BỊ CHẶN:
    • Chiến dịch với industry = "Athletic Footwear"
    • Chiến dịch với subcategory thuộc Athletic Footwear

  KHÔNG BỊ CHẶN:
    • Chiến dịch với industry = "Footwear" (danh mục rộng hơn)
    • Chiến dịch với industry = "Sportswear" (danh mục anh chị em)
```

### 7.4 Quy tắc Chặn Mặc định

**Quy tắc 7.4.1: Phát hiện Đối thủ Tự động**
```
Nền tảng gợi ý quy tắc chặn mặc định:

KHI supplier đăng ký:
  • PHÂN TÍCH supplier.business_name và store.primary_category
  • XÁC ĐỊNH đối thủ có khả năng từ cơ sở dữ liệu advertiser
  • GỢI Ý quy tắc chặn (supplier có thể chấp nhận/từ chối)

VÍ DỤ:
  Supplier: "Whole Foods Market"
  Danh mục cửa hàng: "Grocery - Organic"

  QUY TẮC GỢI Ý:
    • Chặn advertiser: Trader Joe's, Sprouts, Fresh Market
    • Chặn ngành: Grocery Stores (đối thủ trực tiếp)
    • Cho phép: Thương hiệu thực phẩm (không cạnh tranh)
```

**Quy tắc 7.4.2: Bảo vệ Cùng Thương hiệu**
```
QUY TẮC TỰ ĐỘNG (không thể vô hiệu hóa):
  • Thương hiệu riêng supplier tự động bị chặn
  • Ngăn quảng cáo cửa hàng riêng cho khách cửa hàng riêng

VÍ DỤ:
  Supplier: Starbucks
  • Tất cả chiến dịch từ advertiser "Starbucks" bị chặn trên thiết bị Starbucks

NGOẠI LỆ:
  • Supplier có thể cho phép chiến dịch riêng nếu yêu cầu rõ ràng
  • Yêu cầu cài đặt "ALLOW_OWN_BRAND" được bật
```

### 7.5 Quản lý Quy tắc

**Quy tắc 7.5.1: Ưu tiên Quy tắc**
```
Nếu nhiều quy tắc áp dụng, sử dụng QUY TẮC NGHIÊM NGẶT NHẤT:

VÍ DỤ:
  Quy tắc 1: Chặn ngành "Athletic Footwear"
  Quy tắc 2: Cho phép advertiser "Nike" (allowlist rõ ràng)

  KẾT QUẢ: Nike bị CHẶN (quy tắc ngành nghiêm ngặt hơn)

GHI ĐÈ bằng ALLOWLIST:
  • Supplier có thể tạo allowlist rõ ràng
  • Quy tắc allowlist ghi đè quy tắc chặn
```

**Quy tắc 7.5.2: Thay đổi Quy tắc**
```
KHI supplier tạo hoặc cập nhật quy tắc chặn:
  • Thay đổi có hiệu lực NGAY LẬP TỨC
  • Chiến dịch hiện đang phục vụ cho thiết bị KHÔNG bị gián đoạn
  • Khớp impression trong tương lai sử dụng quy tắc mới

THÔNG BÁO advertiser bị ảnh hưởng:
  • NẾU chiến dịch trước đó đã khớp với thiết bị supplier
  • VÀ quy tắc mới chặn chiến dịch đó
  • THÔNG BÁO advertiser: "Chiến dịch của bạn không còn đủ điều kiện cho [Store Name]"
```

**Quy tắc 7.5.3: Giới hạn Quy tắc**
```
Giới hạn dựa vào cấp cho quy tắc chặn:

Cấp STARTER:
  • Tối đa 5 quy tắc chặn mỗi supplier
  • Tối đa 10 advertiser bị chặn tổng cộng
  • Tối đa 20 từ khóa bị chặn tổng cộng

Cấp PROFESSIONAL:
  • Tối đa 20 quy tắc chặn mỗi supplier
  • Tối đa 50 advertiser bị chặn tổng cộng
  • Tối đa 100 từ khóa bị chặn tổng cộng

Cấp ENTERPRISE:
  • Quy tắc chặn không giới hạn
  • Advertiser bị chặn không giới hạn
  • Từ khóa bị chặn không giới hạn
  • Logic quy tắc tùy chỉnh nâng cao
```

---

## 📊 Chỉ số Hiệu suất Supplier

### 8.1 Tính toán Điểm Hiệu suất

**Điểm Chất lượng Supplier**: Điểm 0-100 phản ánh hiệu suất tổng thể.

**Công thức**:
```
quality_score = (
  device_uptime_score × 0.35 +
  revenue_performance_score × 0.25 +
  compliance_score × 0.20 +
  customer_rating_score × 0.10 +
  growth_score × 0.10
)
```

### 8.2 Điểm Thành phần

#### 8.2.1 Điểm Uptime Thiết bị

**Công thức**:
```
device_uptime_score = average_device_uptime (%)

TRONG ĐÓ:
  average_device_uptime = (
    SUM(device_uptime_percentage cho tất cả thiết bị) / total_devices
  )

  device_uptime_percentage = (
    (total_minutes_online / total_minutes_in_period) × 100
  )

THỜI GIAN: 30 ngày gần nhất
```

**Chấm điểm**:
- Uptime ≥98%: Điểm = 100
- Uptime 95-97%: Điểm = 90
- Uptime 90-94%: Điểm = 75
- Uptime 85-89%: Điểm = 60
- Uptime <85%: Điểm = 40

#### 8.2.2 Điểm Hiệu suất Doanh thu

**Công thức**:
```
revenue_performance_score = (
  (actual_revenue / expected_revenue) × 100
)

TRONG ĐÓ:
  expected_revenue = (
    total_devices ×
    average_daily_visitors ×
    platform_average_cpm ×
    30 ngày
  )

  actual_revenue = supplier.total_revenue_last_30_days
```

**Chấm điểm**:
- Thực tế ≥ Dự kiến: Điểm = 100
- Thực tế 80-99% Dự kiến: Điểm = 80
- Thực tế 60-79% Dự kiến: Điểm = 60
- Thực tế <60% Dự kiến: Điểm = 40

#### 8.2.3 Điểm Tuân thủ

**Công thức**:
```
compliance_score = 100 - (violations × 10)

TRONG ĐÓ:
  violations = SỐ vấn đề tuân thủ trong 90 ngày gần nhất

VẤN ĐỀ TUÂN THỦ:
  • Di chuyển thiết bị không cập nhật
  • Can thiệp thiết bị
  • Báo cáo impression gian lận
  • Vi phạm chính sách nội dung
  • Nộp tài liệu muộn
```

**Chấm điểm**:
- 0 vi phạm: Điểm = 100
- 1 vi phạm: Điểm = 90
- 2 vi phạm: Điểm = 80
- 3+ vi phạm: Điểm = 70 hoặc thấp hơn

#### 8.2.4 Điểm Đánh giá Khách hàng

Advertiser có thể đánh giá chất lượng supplier (nếu chạy chiến dịch trên thiết bị supplier):

**Danh mục Đánh giá**:
- Chất lượng thiết bị (độ phân giải màn hình, độ rõ)
- Môi trường cửa hàng (sạch sẽ, ánh sáng)
- Hiển thị nội dung (thời gian đúng, không lỗi)
- Độ chính xác vị trí (thiết bị ở vị trí đã đăng ký)

**Công thức**:
```
customer_rating_score = (
  AVG(advertiser_ratings cho supplier) × 20
)

TRONG ĐÓ:
  advertiser_ratings = 1-5 sao

VÍ DỤ:
  Đánh giá trung bình = 4.5 sao
  Điểm = 4.5 × 20 = 90
```

#### 8.2.5 Điểm Tăng trưởng

**Công thức**:
```
growth_score = MIN(100, (
  (current_month_revenue / previous_month_revenue - 1) × 200
))

VÍ DỤ:
  • Tăng trưởng 50%: Điểm = 100
  • Tăng trưởng 25%: Điểm = 50
  • Tăng trưởng 0%: Điểm = 0
  • Tăng trưởng âm: Điểm = 0
```

### 8.3 Cấp Hiệu suất

**Phân cấp** dựa vào quality_score:

| Cấp | Khoảng Điểm | Lợi ích |
|-----|-------------|---------|
| ⭐⭐⭐⭐⭐ Platinum | 90-100 | Hỗ trợ ưu tiên, chia sẻ doanh thu cao hơn (85%), truy cập sớm tính năng |
| ⭐⭐⭐⭐ Gold | 80-89 | Hỗ trợ ưu tiên, chia sẻ doanh thu tiêu chuẩn (80%) |
| ⭐⭐⭐ Silver | 70-79 | Hỗ trợ tiêu chuẩn, chia sẻ doanh thu tiêu chuẩn (80%) |
| ⭐⭐ Bronze | 60-69 | Hỗ trợ tiêu chuẩn, chia sẻ doanh thu tiêu chuẩn (80%), yêu cầu kế hoạch cải thiện |
| ⭐ Poor | <60 | Tài khoản đang xem xét, có thể đình chỉ |

**Quy tắc 8.3.1: Thưởng Cấp Platinum**
```
Supplier với quality_score ≥ 90 trong 3 tháng liên tiếp:
  • TĂNG revenue_share_percentage lên 85%
  • Tăng doanh thu thêm 5%

DUY TRÌ trạng thái Platinum:
  • NẾU điểm giảm dưới 90: Thời gian ân hạn 30 ngày
  • NẾU điểm < 90 sau thời gian ân hạn: Quay về chia sẻ 80% tiêu chuẩn
```

**Quy tắc 8.3.2: Hành động Hiệu suất Kém**
```
NẾU quality_score < 60 trong 2 tháng liên tiếp:
  1. GỬI email cảnh báo cho supplier
  2. YÊU CẦU nộp kế hoạch cải thiện trong 7 ngày
  3. Phân công hỗ trợ chuyên biệt để giúp cải thiện

NẾU không cải thiện sau 30 ngày:
  4. ĐÌNH CHỈ đăng ký thiết bị mới
  5. Giảm ưu tiên trong khớp chiến dịch

NẾU không cải thiện sau 60 ngày:
  6. ĐÌNH CHỈ tài khoản supplier
  7. Doanh thu giữ lại chờ giải quyết
```

---

## 🎚️ Cấp Tài khoản & Giới hạn

### 9.1 Cấu trúc Cấp

| Tính năng | STARTER | PROFESSIONAL | ENTERPRISE |
|-----------|---------|--------------|------------|
| **Giá** | Miễn phí | $99/tháng | Tùy chỉnh (từ $499/tháng) |
| **Thiết bị Tối đa** | 1-5 | 6-50 | 51+ (không giới hạn) |
| **Cửa hàng Tối đa** | 1-3 | 4-20 | Không giới hạn |
| **Chia sẻ Doanh thu** | 80% | 80% (85% nếu Platinum) | 85% cơ bản (90% nếu Platinum) |
| **Lịch Thanh toán** | Hàng tháng | Hàng tuần/Hai tuần/Hàng tháng | Hàng tuần/Hàng ngày (tùy chỉnh) |
| **Thanh toán Tối thiểu** | $100 | $50 | $25 |
| **Quy tắc Chặn** | 5 quy tắc | 20 quy tắc | Không giới hạn |
| **Hỗ trợ** | Email (SLA 48h) | Email + Chat (SLA 24h) | Quản lý tài khoản chuyên biệt (SLA 4h) |
| **Phân tích** | Cơ bản (lịch sử 30 ngày) | Nâng cao (lịch sử 1 năm) | Cao cấp (lịch sử không giới hạn, báo cáo tùy chỉnh) |
| **Truy cập API** | Không | Có (giới hạn tốc độ) | Có (giới hạn cao hơn) |
| **Tích hợp Tùy chỉnh** | Không | Không | Có |

### 9.2 Thực thi Giới hạn Cấp

**Quy tắc 9.2.1: Giới hạn Thiết bị**
```
KHI supplier thử đăng ký thiết bị mới:
  NẾU total_devices >= max_devices_for_tier:
    • TỪ CHỐI đăng ký
    • NHẮC: "Bạn đã đạt giới hạn thiết bị cho cấp {tier}.
             Nâng cấp lên {next_tier} để thêm thiết bị."
    • HIỂN THỊ tùy chọn nâng cấp
```

**Quy tắc 9.2.2: Giới hạn Cửa hàng**
```
KHI supplier thử đăng ký cửa hàng mới:
  NẾU total_stores >= max_stores_for_tier:
    • TỪ CHỐI đăng ký
    • NHẮC: "Bạn đã đạt giới hạn cửa hàng cho cấp {tier}.
             Nâng cấp lên {next_tier} để thêm cửa hàng."
```

**Quy tắc 9.2.3: Gợi ý Nâng cấp Tự động**
```
KHI supplier đạt 80% giới hạn cấp:
  • THÔNG BÁO supplier: "Bạn đang đến gần giới hạn {tier}.
                         Xem xét nâng cấp lên {next_tier}."
  • HIỂN THỊ tính toán ROI:
    - Doanh thu hiện tại
    - Doanh thu tiềm năng với nhiều thiết bị hơn
    - Chi phí nâng cấp
    - Lợi ích ròng
```

### 9.3 Chuyển đổi Cấp

**Quy tắc 9.3.1: Quy trình Nâng cấp**
```
KHI supplier nâng cấp cấp:
  1. TÍNH PHÍ số tiền tỷ lệ cho kỳ thanh toán hiện tại
  2. CẬP NHẬT supplier.tier = new_tier
  3. ÁP DỤNG giới hạn mới ngay lập tức
  4. GỬI email xác nhận với lợi ích cấp mới

VÍ DỤ (Nâng cấp giữa tháng):
  • Cấp hiện tại: STARTER ($0/tháng)
  • Cấp mới: PROFESSIONAL ($99/tháng)
  • Ngày nâng cấp: Ngày 15 của tháng
  • Phí tỷ lệ: $99 × (15 ngày / 30 ngày) = $49.50
```

**Quy tắc 9.3.2: Quy trình Hạ cấp**
```
KHI supplier hạ cấp:
  1. LÊN LỊCH hạ cấp cho cuối kỳ thanh toán hiện tại
  2. NẾU supplier vượt giới hạn cấp mới:
     • THÔNG BÁO: "Bạn có {X} thiết bị nhưng cấp mới cho phép {Y}.
                  Vui lòng vô hiệu hóa {X-Y} thiết bị trước khi hạ cấp."
     • NGĂN hạ cấp cho đến khi tuân thủ
  3. VÀO ngày hạ cấp:
     • CẬP NHẬT supplier.tier = new_tier
     • ÁP DỤNG giới hạn mới
     • HOÀN số tiền tỷ lệ (nếu áp dụng)
```

**Quy tắc 9.3.3: Onboarding Cấp Enterprise**
```
Cấp Enterprise yêu cầu quy trình sales:
  • Supplier nộp biểu mẫu yêu cầu
  • Cuộc gọi sales được lên lịch trong 2 ngày làm việc
  • Giá tùy chỉnh thỏa thuận dựa vào:
    - Số thiết bị
    - Số cửa hàng
    - Doanh thu hàng tháng dự kiến
    - Yêu cầu đặc biệt (tích hợp tùy chỉnh, SLA)
  • Ký hợp đồng
  • Tài khoản nâng cấp thủ công bởi admin
```

---

## ✅ Tuân thủ & Xác minh

### 10.1 Yêu cầu Tuân thủ Liên tục

**Quy tắc 10.1.1: Xác minh lại Hàng năm**
```
TẤT CẢ supplier phải xác minh lại hàng năm:
  • Nộp tài liệu doanh nghiệp cập nhật
  • Xác nhận tài khoản ngân hàng vẫn hợp lệ
  • Cập nhật biểu mẫu thuế (W-9/W-8)
  • Xác minh địa điểm cửa hàng vẫn hoạt động

THỜI GIAN:
  • Thông báo gửi 30 ngày trước verification_anniversary
  • Thời gian ân hạn: 14 ngày sau anniversary
  • NẾU không hoàn thành: Đình chỉ thanh toán cho đến khi tuân thủ
```

**Quy tắc 10.1.2: Hết hạn Tài liệu**
```
Một số tài liệu có ngày hết hạn:
  • Giấy phép kinh doanh: Hết hạn theo quy định bang
  • Giấy chứng nhận bảo hiểm: Hàng năm hoặc hai năm
  • Giấy phép dịch vụ thực phẩm (nhà hàng): Hàng năm

THEO DÕI HỆ THỐNG:
  • Giám sát ngày hết hạn tài liệu
  • Gửi nhắc nhở 30 ngày trước hết hạn
  • Yêu cầu upload tài liệu gia hạn
  • NẾU hết hạn: Gắn cờ tài khoản để xem xét (có thể đình chỉ)
```

### 10.2 Phát hiện Gian lận

**Quy tắc 10.2.1: Giám sát Hoạt động Đáng ngờ**
```
Nền tảng giám sát chỉ báo gian lận:

CỜ ĐỎ:
  • Tăng đột ngột impression (>3x tỷ lệ bình thường)
  • Thiết bị báo cáo impression ngoài giờ hoạt động
  • Mẫu impression bất thường (vd: số lượng giống hệt mỗi giờ)
  • Vị trí thiết bị không khớp địa điểm cửa hàng đã đăng ký
  • Nhiều thiết bị từ cùng địa chỉ IP (trừ khi dự kiến)
  • Tỷ lệ impression bị tranh chấp cao

PHẢN ỨNG TỰ ĐỘNG:
  • Gắn cờ tài khoản để đánh giá thủ công
  • Giữ thanh toán tạm thời
  • Yêu cầu xác minh (ảnh thiết bị, chứng minh vị trí)
  • Nếu xác nhận gian lận: Cấm vĩnh viễn + thu hồi doanh thu gian lận
```

**Quy tắc 10.2.2: Kiểm tra Ngẫu nhiên Xác minh Vị trí**
```
Kiểm tra ngẫu nhiên RANDOM trên 5% thiết bị mỗi tháng:
  • Yêu cầu vị trí GPS từ thiết bị
  • So sánh với địa điểm cửa hàng đã đăng ký
  • NẾU không khớp > 500 mét:
    - Đình chỉ thiết bị
    - Yêu cầu giải thích supplier + bằng chứng (ảnh)
    - Xem xét 30 ngày impression cuối để tìm gian lận
```

**Quy tắc 10.2.3: Xác minh Chất lượng**
```
Kiểm tra chất lượng ngẫu nhiên:
  • Yêu cầu screenshot nội dung hiện đang hiển thị
  • Xác minh nội dung khớp bản ghi impression
  • Kiểm tra chất lượng màn hình (độ phân giải, độ sáng)

TIÊU CHÍ THẤT BẠI:
  • Màn hình không hiển thị quảng cáo (hiển thị nội dung khác)
  • Chất lượng màn hình dưới tiêu chuẩn tối thiểu (hư hỏng, mờ)
  • Nội dung không khớp log impression

HÌNH PHẠT:
  • Giảm điểm chất lượng
  • Giữ thanh toán chờ điều tra
  • Có thể đình chỉ thiết bị
```

### 10.3 Hoạt động Bị cấm

**Supplier BỊ CẤM**:
- Can thiệp thiết bị hoặc báo cáo impression
- Di chuyển thiết bị không cập nhật nền tảng
- Tạo impression giả (gian lận)
- Chia sẻ quyền truy cập tài khoản với bên không được phép
- Hiển thị nội dung không phù hợp trên thiết bị
- Can thiệp quy tắc chặn đối thủ (vd: nhận thanh toán từ advertiser bị chặn để bỏ qua quy tắc)

**Hậu quả**:
- Vi phạm lần đầu: Cảnh báo + giảm điểm chất lượng
- Vi phạm lần hai: Đình chỉ (14-30 ngày) + giữ doanh thu
- Vi phạm lần ba: Cấm vĩnh viễn + tịch thu doanh thu

---

## 🔄 Quản lý Trạng thái Tài khoản

### 11.1 Chuyển đổi Trạng thái

```
PENDING_REGISTRATION → ACTIVE
                          ↓
                      INACTIVE (tự nguyện)
                          ↓
                      SUSPENDED (tạm thời)
                          ↓
                  PERMANENTLY_BANNED
```

### 11.2 Đình chỉ

**Quy tắc 11.2.1: Kích hoạt Đình chỉ**
```
Supplier có thể bị ĐÌNH CHỈ vì:
  • Điểm chất lượng < 60 trong 60+ ngày (không cải thiện)
  • Vi phạm tuân thủ (2+ vi phạm trong 90 ngày)
  • Hoạt động gian lận (nghi ngờ hoặc xác nhận)
  • Không thanh toán phí nền tảng (nếu áp dụng)
  • Tranh chấp pháp lý hoặc điều tra
  • Không nộp tài liệu bắt buộc (xác minh lại hàng năm)

TRONG KHI ĐÌNH CHỈ:
  • Tất cả thiết bị ngừng phục vụ quảng cáo
  • Không ghi lại impression mới
  • Giữ thanh toán (available_balance bị đóng băng)
  • Supplier không thể đăng nhập hoặc thay đổi

THÔNG BÁO:
  • Email gửi ngay với lý do đình chỉ
  • Bước rõ ràng để giải quyết
  • Thông tin liên hệ hỗ trợ
```

**Quy tắc 11.2.2: Giải quyết Đình chỉ**
```
ĐỂ BÃII đình chỉ:
  1. Supplier giải quyết vấn đề (nộp tài liệu, cải thiện chất lượng, v.v.)
  2. Supplier nộp yêu cầu khôi phục
  3. Nền tảng xem xét (1-3 ngày làm việc)
  4. NẾU được phê duyệt:
     • Kích hoạt lại tài khoản
     • Tiếp tục phục vụ quảng cáo
     • Giải phóng tiền giữ (nếu không có tranh chấp chưa giải quyết)
  5. NẾU bị từ chối:
     • Cung cấp yêu cầu bổ sung
     • Leo thang lên cấm vĩnh viễn nếu không thể giải quyết
```

### 11.3 Vô hiệu hóa Tự nguyện

**Quy tắc 11.3.1: Tạm dừng Tài khoản**
```
Supplier có thể tự nguyện đặt tài khoản thành INACTIVE:
  • Tất cả thiết bị ngừng phục vụ quảng cáo
  • Không có impression mới
  • Thanh toán tiếp tục cho pending_balance hiện có
  • Dữ liệu tài khoản giữ lại

TRƯỜNG HỢP SỬ DỤNG:
  • Đóng cửa theo mùa (vd: nhà hàng đóng cửa để cải tạo)
  • Tạm dừng doanh nghiệp
  • Kiểm tra/khắc phục sự cố

KÍCH HOẠT LẠI:
  • Supplier click "Reactivate" trong dashboard
  • Thiết bị tiếp tục phục vụ quảng cáo ngay lập tức
  • Không yêu cầu xác minh lại (trừ khi >1 năm inactive)
```

### 11.4 Cấm Vĩnh viễn

**Quy tắc 11.4.1: Lý do Cấm**
```
Supplier bị CẤM VĨNH VIỄN vì:
  • Gian lận xác nhận (impression giả, thiết bị can thiệp)
  • Vi phạm tuân thủ nghiêm trọng (3+ vi phạm)
  • Vi phạm pháp luật (hiển thị nội dung bất hợp pháp, v.v.)
  • Thất bại chất lượng lặp lại (3+ lần đình chỉ không cải thiện)
  • Thử vượt qua kiểm soát nền tảng

HIỆU ỨNG:
  • Tài khoản đóng vĩnh viễn
  • Tất cả thiết bị ngừng hoạt động
  • Doanh thu bị tịch thu (nếu liên quan gian lận)
  • Supplier thêm vào danh sách cấm toàn cầu (không thể đăng ký lại)
```

**Quy tắc 11.4.2: Quy trình Kháng cáo**
```
Supplier bị cấm có thể kháng cáo MỘT LẦN:
  • Nộp kháng cáo trong 30 ngày kể từ khi cấm
  • Cung cấp bằng chứng/giải thích
  • Nền tảng xem xét kháng cáo (5-10 ngày làm việc)
  • Quyết định cuối cùng (không kháng cáo thêm)

HIẾM KHI được lật lại (chỉ khi lỗi rõ ràng hoặc hoàn cảnh giảm nhẹ)
```

---

## ⚠️ Các trường hợp đặc biệt

### 13.1 Nhượng quyền Nhiều Địa điểm

**Tình huống**: Chủ nhượng quyền vận hành nhiều địa điểm cùng thương hiệu.

**Quy tắc**:
```
XỬ LÝ NHƯỢNG QUYỀN:
  • Một tài khoản supplier cho tất cả địa điểm nhượng quyền
  • Mỗi địa điểm đăng ký là cửa hàng riêng
  • Quy tắc chặn chung trên tất cả cửa hàng (mặc định)
  • Thanh toán hợp nhất (một ví cho tất cả địa điểm)

LỢI ÍCH:
  • Quản lý tập trung
  • Cấp dựa vào số lượng (tổng thiết bị trên tất cả địa điểm)
  • Thanh toán đơn cho tất cả địa điểm

VÍ DỤ:
  • Supplier: "John's Pizza Franchises Inc."
  • Cửa hàng:
    - "John's Pizza - Downtown" (3 thiết bị)
    - "John's Pizza - Westside" (2 thiết bị)
    - "John's Pizza - Airport" (4 thiết bị)
  • Tổng: 9 thiết bị → cấp PROFESSIONAL
```

### 13.2 Doanh nghiệp Theo mùa

**Tình huống**: Doanh nghiệp chỉ hoạt động một phần trong năm (vd: khu nghỉ dưỡng trượt tuyết, trại hè).

**Quy tắc**:
```
XỬ LÝ THEO MÙA:
  • Supplier có thể đặt "seasonal schedule" cho cửa hàng
  • Trong ngoài mùa:
    - Cửa hàng đánh dấu INACTIVE
    - Thiết bị ngừng phục vụ quảng cáo
    - Không ảnh hưởng điểm chất lượng (loại khỏi tính toán uptime)
    - Miễn phí thuê bao tối thiểu (cho PROFESSIONAL/ENTERPRISE)

  • Trong mùa:
    - Cửa hàng kích hoạt lại
    - Thiết bị tiếp tục phục vụ quảng cáo
    - Truy cập nền tảng đầy đủ

CẤU HÌNH:
  • Đặt operating_season:
    - start_month, end_month
    - VÍ DỤ: Tháng 6-8 cho trại hè
```

### 13.3 Thay đổi Quyền sở hữu Thiết bị

**Tình huống**: Supplier bán doanh nghiệp hoặc chuyển quyền sở hữu thiết bị.

**Quy tắc**:
```
CHUYỂN QUYỀN SỞ HỮU:
  1. Supplier hiện tại khởi tạo yêu cầu chuyển
  2. Supplier mới (phải có tài khoản active) chấp nhận chuyển
  3. Thiết bị ghép lại với tài khoản supplier mới:
     • Device_id giữ nguyên (bảo tồn danh tính thiết bị)
     • supplier_id cập nhật
     • Dữ liệu lịch sử giữ lại nhưng chủ mới không truy cập được
  4. Giải quyết doanh thu:
     • Thanh toán cuối cùng phát hành cho supplier gốc
     • Supplier mới bắt đầu kiếm từ ngày chuyển

HẠN CHẾ:
  • Không thể chuyển thiết bị nếu chiến dịch active đang chạy (đợi hoàn thành)
  • Cả hai bên phải có tài khoản đã xác minh
  • Nền tảng tính phí chuyển $25
```

### 13.4 Đóng cửa hoặc Di chuyển Cửa hàng

**Tình huống**: Cửa hàng đóng cửa vĩnh viễn hoặc di chuyển sang vị trí mới.

#### 13.4.1 Đóng cửa Vĩnh viễn
```
KHI cửa hàng đóng cửa vĩnh viễn:
  1. Supplier đánh dấu cửa hàng là "CLOSED"
  2. Tất cả thiết bị tại cửa hàng ngừng hoạt động
  3. Doanh thu cuối cùng tính toán và thanh toán
  4. Dữ liệu cửa hàng lưu trữ (không thể kích hoạt lại)

HIỆU ỨNG:
  • total_devices giảm
  • Có thể ảnh hưởng cấp (nếu thiết bị giảm dưới ngưỡng)
  • Dữ liệu lịch sử giữ lại để báo cáo
```

#### 13.4.2 Di chuyển
```
KHI cửa hàng di chuyển:
  1. Supplier cập nhật địa chỉ cửa hàng
  2. Thiết bị phải xác minh lại vị trí (kiểm tra GPS)
  3. NẾU địa chỉ mới khác đáng kể (>5 dặm):
     • Quy tắc chặn có thể cần xem xét (địa hình đối thủ khác)
     • Khớp chiến dịch đánh giá lại (tiêu chí nhắm mục tiêu)
  4. Thiết bị tiếp tục hoạt động bình thường khi đã xác minh

KHÔNG GIÁN ĐOẠN doanh thu nếu cập nhật đúng
```

### 13.5 Impression Bị tranh chấp

**Tình huống**: Advertiser tranh chấp impression, tuyên bố thiết bị không hiển thị quảng cáo.

**Quy tắc**:
```
KHI tranh chấp impression được nộp:
  1. TẠO bản ghi ImpressionDispute
  2. GIỮ doanh thu supplier cho impression bị tranh chấp (chuyển sang held_balance)
  3. YÊU CẦU bằng chứng từ supplier:
     • Screenshot thiết bị tại timestamp impression
     • Dữ liệu vị trí thiết bị
     • Log heartbeat
  4. ĐIỀU TRA:
     • So sánh bằng chứng với bản ghi impression
     • Kiểm tra trạng thái sức khỏe thiết bị tại thời điểm impression
     • Xem xét bằng chứng tuyên bố advertiser
  5. GIẢI QUYẾT:
     • NẾU supplier thắng: Giải phóng doanh thu giữ
     • NẾU advertiser thắng: Hoàn tiền advertiser, doanh thu bị tịch thu
     • NẾU không kết luận: Chia 50/50

THỜI GIAN:
  • Mục tiêu giải quyết: 14 ngày
  • Supplier có 7 ngày để nộp bằng chứng
```

### 13.6 Thu hồi Doanh thu

**Tình huống**: Nền tảng phát hiện impression gian lận sau thanh toán.

**Quy tắc**:
```
KHI xác nhận gian lận SAU thanh toán:
  1. TÍNH tổng doanh thu gian lận
  2. TẠO WalletTransaction âm (CHARGEBACK)
  3. KHẤU TRỪ từ available_balance supplier
  4. NẾU available_balance không đủ:
     • Tạo số dư âm (supplier nợ nền tảng)
     • CHẶN thanh toán tương lai cho đến khi số dư dương
     • GỬI hóa đơn cho số tiền nợ
  5. NẾU supplier từ chối thanh toán hoặc tranh chấp:
     • ĐÌNH CHỈ tài khoản
     • Có thể theo đuổi hành động pháp lý
     • Cấm vĩnh viễn nếu không giải quyết

PHÒNG NGỪA:
  • Phát hiện gian lận trong thời gian giữ doanh thu 7 ngày
  • Thu hồi giảm nhưng không loại bỏ rủi ro
```

### 13.7 Nhiều Tài khoản Ngân hàng

**Tình huống**: Supplier muốn chia thanh toán qua nhiều tài khoản ngân hàng.

**Quy tắc**:
```
Cấp PROFESSIONAL và ENTERPRISE có thể cấu hình chia thanh toán:
  • Thêm nhiều phương thức thanh toán
  • Đặt tỷ lệ phần trăm chia:
    - Tài khoản Ngân hàng A: 70%
    - Tài khoản Ngân hàng B: 30%
  • Tối thiểu mỗi tài khoản: $25

VÍ DỤ:
  Tổng thanh toán: $1,000
  • $700 → Ngân hàng A
  • $300 → Ngân hàng B

NẾU một tài khoản thất bại:
  • Chuyển hướng toàn bộ số tiền sang tài khoản hoạt động
  • Thông báo supplier sửa tài khoản thất bại
```

### 13.8 Supplier Quốc tế

**Tình huống**: Supplier hoạt động ngoài Hoa Kỳ.

**Quy tắc**:
```
SUPPLIER QUỐC TẾ:
  • Tất cả doanh thu tính bằng USD
  • Thanh toán bằng USD (ngân hàng supplier xử lý chuyển đổi tiền tệ)
  • Khấu trừ thuế: 30% (trừ khi có hiệp ước thuế)
  • Yêu cầu xác minh bổ sung:
    - Chứng minh đăng ký kinh doanh tại quốc gia
    - Tài liệu dịch (tiếng Anh) với bản dịch có chứng nhận
    - Biểu mẫu W-8BEN hoặc W-8BEN-E
  • Phương thức thanh toán:
    - Wire transfer (có phí)
    - PayPal (phí cao hơn nhưng nhanh hơn)
    - Stripe Connect (nếu có ở quốc gia)

HẠN CHẾ QUỐC GIA:
  • Nền tảng có thể hạn chế hoạt động ở một số quốc gia (trừng phạt, rủi ro gian lận cao)
  • Quốc gia hạn chế hiện tại: [Danh sách duy trì bởi đội tuân thủ]
```

---

## 📐 Công thức Nghiệp vụ

### 14.1 Tính toán Doanh thu

**Doanh thu Mỗi Impression** (Phần của Supplier):
```
impression_cost = campaign.cpm / 1000
supplier_revenue = impression_cost × 0.80
platform_revenue = impression_cost × 0.20

VÍ DỤ:
  campaign.cpm = $5.00
  impression_cost = $5.00 / 1000 = $0.005
  supplier_revenue = $0.005 × 0.80 = $0.004
  platform_revenue = $0.005 × 0.20 = $0.001
```

**Ước tính Doanh thu Hàng ngày**:
```
estimated_daily_revenue_per_device = (
  average_hourly_impressions ×
  operating_hours_per_day ×
  average_cpm ×
  0.80
) / 1000

VÍ DỤ:
  average_hourly_impressions = 50
  operating_hours_per_day = 12
  average_cpm = $4.00

  estimated_daily_revenue = (50 × 12 × $4.00 × 0.80) / 1000
                          = (2400 × 0.80) / 1000
                          = 1920 / 1000
                          = $1.92 mỗi thiết bị mỗi ngày
```

**Dự báo Doanh thu Hàng tháng**:
```
estimated_monthly_revenue = (
  total_devices ×
  estimated_daily_revenue_per_device ×
  30
)

VÍ DỤ:
  total_devices = 10
  estimated_daily_revenue_per_device = $1.92

  estimated_monthly_revenue = 10 × $1.92 × 30 = $576
```

### 14.2 Công thức Điểm Chất lượng

```
quality_score = (
  device_uptime_score × 0.35 +
  revenue_performance_score × 0.25 +
  compliance_score × 0.20 +
  customer_rating_score × 0.10 +
  growth_score × 0.10
)

TRONG ĐÓ:
  device_uptime_score = 0-100 (dựa vào % uptime)
  revenue_performance_score = 0-100 (doanh thu thực tế vs dự kiến)
  compliance_score = 0-100 (100 - violations × 10)
  customer_rating_score = 0-100 (avg_rating × 20)
  growth_score = 0-100 (tăng trưởng doanh thu × 200)
```

### 14.3 Tính toán Thanh toán

**Thanh toán Ròng** (sau khấu trừ thuế):
```
gross_payout = wallet.available_balance

NẾU supplier.tax_withholding_required:
  withholding_rate = 0.30  // 30% cho ngoài Mỹ
  withholding_amount = gross_payout × withholding_rate
  net_payout = gross_payout - withholding_amount
NGƯỢC LẠI:
  net_payout = gross_payout

VÍ DỤ (Supplier Mỹ):
  gross_payout = $1,000
  withholding = $0
  net_payout = $1,000

VÍ DỤ (Supplier ngoài Mỹ, không có hiệp ước):
  gross_payout = $1,000
  withholding = $1,000 × 0.30 = $300
  net_payout = $700
```

**Thanh toán với Phí** (thanh toán thủ công dưới ngưỡng):
```
NẾU manual_payout VÀ gross_payout < minimum_payout_threshold:
  fee = $5.00
  net_payout = gross_payout - fee

VÍ DỤ:
  gross_payout = $40 (dưới ngưỡng $50)
  fee = $5
  net_payout = $35
```

### 14.4 Giới hạn Thiết bị Dựa vào Kích thước Cửa hàng

```
max_devices_allowed = TÍNH DỰA VÀO square_footage:

NẾU square_footage < 1000:
  max = 1
NẾU KHÔNG NẾU square_footage < 3000:
  max = 2
NẾU KHÔNG NẾU square_footage < 5000:
  max = 3
NẾU KHÔNG NẾU square_footage < 10000:
  max = 5
NGƯỢC LẠI:
  max = 10

GHI ĐÈ cho cấp ENTERPRISE: Giới hạn tùy chỉnh đã thỏa thuận
```

### 14.5 Điều chỉnh Chia sẻ Doanh thu (Cấp Platinum)

```
NẾU supplier.quality_score >= 90 TRONG 3_consecutive_months:
  revenue_share_percentage = 0.85
NGƯỢC LẠI:
  revenue_share_percentage = 0.80

TÍNH LẠI:
  • Kiểm tra hàng tháng vào ngày 1
  • Có hiệu lực ngay lập tức cho impression mới
  • KHÔNG điều chỉnh lại doanh thu trước
```

### 14.6 Tính toán Điểm Uptime

```
CHO MỖI thiết bị:
  uptime_percentage = (
    total_minutes_online / total_minutes_in_period
  ) × 100

average_device_uptime = (
  SUM(uptime_percentage cho tất cả thiết bị) / total_devices
)

device_uptime_score = ÁNH XẠ average_device_uptime:
  ≥98%: 100
  95-97%: 90
  90-94%: 75
  85-89%: 60
  <85%: 40

THỜI GIAN: 30 ngày gần nhất
LOẠI TRỪ: Thời gian trong chế độ MAINTENANCE
LOẠI TRỪ: Cửa hàng theo mùa trong ngoài mùa
```

---

## 📚 Bảng thuật ngữ

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Supplier** | Nhà cung cấp - chủ doanh nghiệp bán lẻ cung cấp cửa hàng và thiết bị |
| **Store** | Cửa hàng - địa điểm bán lẻ vật lý |
| **Device** | Thiết bị - phần cứng signage kỹ thuật số hiển thị quảng cáo |
| **Revenue Share** | Chia sẻ doanh thu (80% supplier, 20% nền tảng) |
| **Quality Score** | Điểm chất lượng 0-100 phản ánh hiệu suất |
| **Blocking Rule** | Quy tắc chặn đối thủ quảng cáo |
| **Payout** | Thanh toán - chuyển doanh thu từ ví sang ngân hàng |
| **Verification** | Xác minh - xác thực tài liệu và danh tính |
| **Tier** | Cấp tài khoản (STARTER/PROFESSIONAL/ENTERPRISE) |
| **Uptime** | Thời gian online - phần trăm thời gian thiết bị hoạt động |

---

## 📚 Tham khảo

### Tài liệu liên quan

| Tài liệu | Mô tả |
|----------|-------|
| [Từ điển Thuật ngữ](./00-tu-dien-thuat-ngu.md) | Giải thích tất cả thuật ngữ |
| [Quy tắc Chiến dịch](./04-quy-tac-chien-dich.md) | Chiến dịch khớp với cửa hàng supplier |
| [Quy tắc Thiết bị](./05-quy-tac-thiet-bi.md) | Chi tiết quản lý thiết bị |
| [Quy tắc Impression](./06-quy-tac-luot-hien-thi.md) | Ghi lại impression từ thiết bị |
| [Quy tắc Ví](./07-quy-tac-vi-thanh-toan.md) | Ví supplier và thanh toán |

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team  
**Trạng thái**: Sẵn sàng để review

**Bước tiếp theo**:
1. Đánh giá với stakeholder
2. Xác nhận đội product
3. Đầu vào đội supplier operations
4. Lập kế hoạch triển khai