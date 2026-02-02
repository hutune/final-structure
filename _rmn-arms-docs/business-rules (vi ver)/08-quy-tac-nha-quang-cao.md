# 🏢 Quy tắc Nghiệp vụ: Module Nhà quảng cáo (Advertiser)

**Phiên bản**: 1.0  
**Ngày**: 2026-01-23  
**Trạng thái**: Bản nháp  
**Chủ quản**: Product Team

---

## 📖 Mục lục

1. [Tổng quan](#-tổng-quan)
2. [Các thực thể Domain](#-các-thực-thể-domain)
3. [Vòng đời Advertiser](#-vòng-đời-advertiser)
4. [Quy tắc Nghiệp vụ](#-quy-tắc-nghiệp-vụ)
5. [Đăng ký & Onboarding](#-đăng-ký--onboarding)
6. [Cấp tài khoản & Giới hạn](#-cấp-tài-khoản--giới-hạn)
7. [Xác minh & KYC](#-xác-minh--kyc)
8. [Quản lý Nhóm](#-quản-lý-nhóm)
9. [Tuân thủ & Hạn chế](#-tuân-thủ--hạn-chế)
10. [Quản lý Trạng thái Tài khoản](#-quản-lý-trạng-thái-tài-khoản)
11. [Các trường hợp đặc biệt](#-các-trường-hợp-đặc-biệt)
12. [Quy tắc Kiểm tra](#-quy-tắc-kiểm-tra)

---

## 🎯 Tổng quan

### Mục đích

Tài liệu này định nghĩa TẤT CẢ quy tắc nghiệp vụ cho module Advertiser, bao gồm quản lý tài khoản, onboarding, xác minh, cộng tác nhóm và tuân thủ.

### Phạm vi

**Bao gồm:**
- ✅ Tạo và onboarding tài khoản advertiser
- ✅ Xác minh tài khoản và KYC
- ✅ Hệ thống cấp tài khoản và giới hạn
- ✅ Quản lý thành viên nhóm
- ✅ Tuân thủ và hạn chế nội dung
- ✅ Vòng đời trạng thái tài khoản
- ✅ Quy trình đình chỉ và cấm

**KHÔNG bao gồm:**
- ❌ Tạo chiến dịch (xem module Campaign)
- ❌ Quản lý ví (xem module Wallet)
- ❌ Upload nội dung (xem module Content)

### Khái niệm Chủ chốt

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Advertiser** | Doanh nghiệp hoặc cá nhân chạy chiến dịch quảng cáo |
| **Account Tier (Cấp TK)** | Mức dịch vụ (Free, Basic, Premium, Enterprise) |
| **Verification (Xác minh)** | Quy trình KYC cho giới hạn cao hơn |
| **Team Member** | Người dùng được ủy quyền truy cập tài khoản advertiser |
| **Compliance (Tuân thủ)** | Hạn chế nội dung và ngành nghề |

---

## 📦 Các thực thể Domain

### 1. Advertiser (Nhà quảng cáo)

> **Định nghĩa**: Tài khoản doanh nghiệp hoặc cá nhân để chạy chiến dịch quảng cáo.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Mặc định | Quy tắc nghiệp vụ |
|--------|------|----------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo | Không thay đổi |
| `user_id` | UUID | Có | - | Tài khoản chủ sở hữu |
| `company_name` | String(100) | Không | null | Tùy chọn cho cá nhân |
| `business_type` | Enum | Có | INDIVIDUAL | Xem [Loại Doanh nghiệp](#loại-doanh-nghiệp) |
| `industry` | Enum | Có | - | Xem [Ngành nghề](#ngành-nghề) |
| `website_url` | String(200) | Không | null | Phải là URL hợp lệ |
| `description` | Text | Không | null | Tối đa 500 ký tự |
| `brand_name` | String(100) | Có | - | Dùng cho chặn đối thủ |
| `account_tier` | Enum | Có | FREE | FREE/BASIC/PREMIUM/ENTERPRISE |
| `verification_status` | Enum | Có | UNVERIFIED | Xem [Trạng thái Xác minh](#trạng-thái-xác-minh) |
| `verified_at` | DateTime | Không | null | Khi hoàn thành KYC |
| `tax_id` | String(50) | Không | null | EIN/VAT (mã hóa) |
| `billing_address` | JSON | Có | - | Bắt buộc cho thuế |
| `billing_contact_name` | String(100) | Có | - | Người nhận hóa đơn |
| `billing_contact_email` | String(100) | Có | - | Gửi hóa đơn |
| `billing_contact_phone` | String(20) | Không | null | Tùy chọn |
| `payment_terms` | Enum | Có | PREPAID | PREPAID/NET30/NET60 |
| `credit_limit` | Decimal(12,2) | Có | 0.00 | Cho điều khoản thanh toán NET |
| `total_spent` | Decimal(12,2) | Có | 0.00 | Chi tiêu chiến dịch từ trước đến nay |
| `total_impressions` | BigInt | Có | 0 | Impression từ trước đến nay |
| `active_campaigns_count` | Integer | Có | 0 | Chiến dịch active hiện tại |
| `status` | Enum | Có | ACTIVE | Xem [Trạng thái TK](#trạng-thái-tài-khoản) |
| `suspended_at` | DateTime | Không | null | Khi bị đình chỉ |
| `suspension_reason` | String(200) | Không | null | Lý do đình chỉ |
| `banned_at` | DateTime | Không | null | Khi bị cấm vĩnh viễn |
| `ban_reason` | String(200) | Không | null | Lý do cấm |
| `account_manager_id` | UUID | Không | null | Quản lý TK được gán (Enterprise) |
| `referral_code` | String(20) | Có | Tự động tạo | Mã giới thiệu duy nhất |
| `referred_by` | UUID | Không | null | ID advertiser giới thiệu |
| `created_at` | DateTime | Có | BÂY GIỜ() | Không thay đổi |
| `updated_at` | DateTime | Có | BÂY GIỜ() | Tự động cập nhật |

#### Loại Doanh nghiệp

```
• INDIVIDUAL: Tài khoản cá nhân
• SMALL_BUSINESS: < 10 nhân viên
• MEDIUM_BUSINESS: 10-100 nhân viên
• LARGE_BUSINESS: 100-1000 nhân viên
• ENTERPRISE: > 1000 nhân viên
• AGENCY: Agency marketing quản lý nhiều thương hiệu
```

#### Ngành nghề

```
• RETAIL: Cửa hàng bán lẻ
• FOOD_BEVERAGE: Nhà hàng, thương hiệu thực phẩm
• ELECTRONICS: Thương hiệu điện tử
• FASHION: Thời trang & may mặc
• HEALTH_BEAUTY: Sản phẩm sức khỏe & làm đẹp
• HOME_GARDEN: Sản phẩm nhà & vườn
• AUTOMOTIVE: Thương hiệu ô tô
• ENTERTAINMENT: Giải trí & truyền thông
• FINANCIAL_SERVICES: Ngân hàng, bảo hiểm, fintech
• TELECOM: Nhà cung cấp viễn thông
• REAL_ESTATE: Đại lý bất động sản
• EDUCATION: Tổ chức giáo dục
• TRAVEL: Du lịch & khách sạn
• OTHER: Ngành nghề khác
```

#### Trạng thái Xác minh

```
• UNVERIFIED: Chưa nộp KYC
• PENDING: Tài liệu đã nộp, đang xem xét
• VERIFIED: KYC được chấp thuận
• REJECTED: KYC bị từ chối
• EXPIRED: Xác minh hết hạn (cần xác minh lại)
```

#### Trạng thái Tài khoản

```
• ACTIVE: Hoạt động bình thường
• SUSPENDED: Tạm thời vô hiệu hóa
• BANNED: Vô hiệu hóa vĩnh viễn
• CLOSED: Đóng do user khởi tạo
```

---

### 2. AdvertiserVerification (Xác minh Advertiser)

> **Định nghĩa**: Bản ghi xác minh KYC cho advertiser.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `advertiser_id` | UUID | Có | Đối tượng xác minh |
| `verification_type` | Enum | Có | INDIVIDUAL/BUSINESS |
| `submitted_at` | DateTime | Có | Khi nộp |
| `reviewed_at` | DateTime | Không | Khi admin xem xét |
| `reviewed_by` | UUID | Không | Admin đánh giá |
| `status` | Enum | Có | PENDING/APPROVED/REJECTED |
| `rejection_reason` | String(200) | Không | Lý do từ chối |
| `documents` | JSON | Có | Mảng metadata tài liệu |
| `verification_provider` | Enum | Không | STRIPE_IDENTITY/MANUAL |
| `provider_verification_id` | String(100) | Không | ID xác minh bên ngoài |
| `risk_score` | Integer | Không | 0-100 (cao hơn = rủi ro hơn) |
| `expires_at` | DateTime | Không | Khi cần xác minh lại |
| `notes` | Text | Không | Ghi chú admin |

---

### 3. TeamMember (Thành viên Nhóm)

> **Định nghĩa**: Người dùng được cấp quyền truy cập tài khoản advertiser.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `advertiser_id` | UUID | Có | Advertiser cha |
| `user_id` | UUID | Có | User thành viên nhóm |
| `role` | Enum | Có | Xem [Vai trò Nhóm](#vai-trò-nhóm) |
| `permissions` | JSON | Có | Quyền chi tiết |
| `invited_by` | UUID | Có | Ai gửi lời mời |
| `invited_at` | DateTime | Có | Khi được mời |
| `accepted_at` | DateTime | Không | Khi chấp nhận lời mời |
| `status` | Enum | Có | PENDING/ACTIVE/REVOKED |
| `last_access_at` | DateTime | Không | Đăng nhập lần cuối |

#### Vai trò Nhóm

```
• OWNER: Toàn quyền (người tạo tài khoản)
• ADMIN: Toàn quyền trừ billing
• CAMPAIGN_MANAGER: Tạo/quản lý chiến dịch
• CONTENT_MANAGER: Upload/quản lý nội dung
• ANALYST: Chỉ đọc báo cáo
• VIEWER: Chỉ đọc (không chỉnh sửa)
```

---

### 4. AccountTierConfig (Cấu hình Cấp Tài khoản)

> **Định nghĩa**: Cấu hình giới hạn cho cấp tài khoản.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `tier` | Enum | Có | FREE/BASIC/PREMIUM/ENTERPRISE |
| `max_campaigns_concurrent` | Integer | Có | Số chiến dịch active tối đa |
| `max_budget_per_campaign` | Decimal(12,2) | Có | Giới hạn ngân sách mỗi chiến dịch |
| `max_daily_spend` | Decimal(12,2) | Có | Giới hạn chi tiêu hàng ngày |
| `max_monthly_spend` | Decimal(12,2) | Có | Giới hạn chi tiêu hàng tháng |
| `max_content_assets` | Integer | Có | Số nội dung upload tối đa |
| `max_team_members` | Integer | Có | Kích thước nhóm tối đa |
| `support_level` | Enum | Có | COMMUNITY/EMAIL/PRIORITY/DEDICATED |
| `api_access` | Boolean | Có | API được bật |
| `advanced_analytics` | Boolean | Có | Báo cáo nâng cao |
| `white_label` | Boolean | Có | Tùy chọn white-label |
| `monthly_fee` | Decimal(10,2) | Có | Phí thuê bao (0 cho FREE) |

---

## 🔄 Vòng đời Advertiser

### Luồng Đăng ký & Onboarding

```
Bước 1: Đăng ký Email
  User nhập: Email + Mật khẩu
  Hệ thống gửi email xác minh
  Trạng thái: UNVERIFIED

Bước 2: Xác minh Email
  User click link trong email
  Email được đánh dấu đã xác minh
  Chuyển hướng đến onboarding

Bước 3: Thiết lập Hồ sơ Cơ bản
  User cung cấp:
    • Tên công ty/Thương hiệu
    • Loại doanh nghiệp
    • Ngành nghề
    • Địa chỉ thanh toán

  Hệ thống tạo:
    • Bản ghi Advertiser (cấp: FREE)
    • Ví (số dư: 0)
    • Quyền mặc định

  Trạng thái: ACTIVE (cấp FREE)

Bước 4: KYC Tùy chọn (cho giới hạn cao hơn)
  User nộp:
    • ID chính phủ (cá nhân)
    • Đăng ký kinh doanh (công ty)
    • Mã số thuế

  Admin xem xét
  Nếu chấp thuận: verification_status = VERIFIED
  Mở khóa: Giới hạn chi tiêu cao hơn

Bước 5: Thiết lập Phương thức Thanh toán
  User thêm thẻ tín dụng hoặc tài khoản ngân hàng
  Bật nạp tiền

Bước 6: Chiến dịch Đầu tiên
  Tạo chiến dịch có hướng dẫn
  Tutorial/tooltips
  Đề xuất template

Trạng thái: ACTIVE, sẵn sàng quảng cáo
```

---

## 📋 Quy tắc Nghiệp vụ

### Quy tắc 1: Hệ thống Cấp Tài khoản

#### 1.1 Giới hạn Cấp

**Cấp FREE**:
```
Giới hạn:
• Số chiến dịch đồng thời tối đa: 2
• Ngân sách tối đa mỗi chiến dịch: $500
• Chi tiêu hàng ngày tối đa: $100
• Chi tiêu hàng tháng tối đa: $1,000
• Tài sản nội dung tối đa: 10
• Thành viên nhóm tối đa: 1 (chỉ chủ)
• Hỗ trợ: Diễn đàn cộng đồng
• Truy cập API: Không
• Phân tích nâng cao: Không

Phí hàng tháng: $0

Mục tiêu: Doanh nghiệp nhỏ, testing
```

**Cấp BASIC**:
```
Giới hạn:
• Số chiến dịch đồng thời tối đa: 5
• Ngân sách tối đa mỗi chiến dịch: $2,000
• Chi tiêu hàng ngày tối đa: $500
• Chi tiêu hàng tháng tối đa: $5,000
• Tài sản nội dung tối đa: 50
• Thành viên nhóm tối đa: 3
• Hỗ trợ: Email (phản hồi 48h)
• Truy cập API: Không
• Phân tích nâng cao: Có

Phí hàng tháng: $99

Mục tiêu: Doanh nghiệp đang phát triển
```

**Cấp PREMIUM**:
```
Giới hạn:
• Số chiến dịch đồng thời tối đa: 20
• Ngân sách tối đa mỗi chiến dịch: $10,000
• Chi tiêu hàng ngày tối đa: $2,000
• Chi tiêu hàng tháng tối đa: $50,000
• Tài sản nội dung tối đa: 200
• Thành viên nhóm tối đa: 10
• Hỗ trợ: Email ưu tiên (phản hồi 24h)
• Truy cập API: Có
• Phân tích nâng cao: Có

Phí hàng tháng: $499

Mục tiêu: Doanh nghiệp đã thành lập
```

**Cấp ENTERPRISE**:
```
Giới hạn:
• Số chiến dịch đồng thời tối đa: Không giới hạn
• Ngân sách tối đa mỗi chiến dịch: Tùy chỉnh
• Chi tiêu hàng ngày tối đa: Tùy chỉnh
• Chi tiêu hàng tháng tối đa: Tùy chỉnh
• Tài sản nội dung tối đa: Không giới hạn
• Thành viên nhóm tối đa: Không giới hạn
• Hỗ trợ: Quản lý tài khoản chuyên biệt
• Truy cập API: Có
• Phân tích nâng cao: Có
• White-label: Có

Phí hàng tháng: Tùy chỉnh (từ $2,000)

Mục tiêu: Doanh nghiệp lớn, agency
```

#### 1.2 Quy trình Nâng cấp Cấp

```
Người thực hiện: Advertiser
Kích hoạt: User click "Nâng cấp Tài khoản"

Quy trình:
1. Hiển thị so sánh cấp:
   • Lợi ích cấp hiện tại
   • Lợi ích cấp mục tiêu
   • Giá
   • Khác biệt tính năng

2. User chọn cấp mục tiêu:
   POST /account/upgrade
   {
     "target_tier": "PREMIUM",
     "billing_cycle": "MONTHLY" // hoặc ANNUAL (giảm 10%)
   }

3. Kiểm tra:
   ✓ target_tier > current_tier
   ✓ payment_method có trong hồ sơ
   ✓ trạng thái tài khoản = ACTIVE

4. Tính giá:
   NẾU billing_cycle = "ANNUAL":
     annual_price = monthly_fee × 12 × 0.90
     charge_amount = annual_price
   NGƯỢC LẠI:
     charge_amount = monthly_fee

5. Xử lý thanh toán:
   charge = process_subscription_payment(
     amount: charge_amount,
     interval: billing_cycle
   )

6. Cập nhật tài khoản:
   advertiser.account_tier = target_tier
   advertiser.updated_at = BÂY GIỜ()

   // Áp dụng giới hạn mới ngay lập tức
   apply_tier_limits(advertiser, target_tier)

7. Thông báo user:
   Email: "Tài khoản nâng cấp lên {target_tier}"
   Lợi ích: Danh sách tính năng mới mở khóa

Quy tắc nghiệp vụ:
• Nâng cấp có hiệu lực ngay lập tức
• Tính phí tỷ lệ cho nâng cấp giữa chu kỳ
• Hạ cấp yêu cầu ticket hỗ trợ (ngăn lạm dụng)
• Cấp Enterprise yêu cầu liên hệ sales (giá tùy chỉnh)
• Thanh toán hàng năm được giảm 10%
```

#### 1.3 Thực thi Giới hạn Cấp

```
Khi: User thử hành động có thể vượt giới hạn

Kiểm tra: Trước khi cho phép hành động
campaign_count = active_campaigns.count
tier_limit = get_tier_config(advertiser.account_tier).max_campaigns_concurrent

NẾU campaign_count >= tier_limit:
  LỖI: "Đã đạt giới hạn chiến dịch ({tier_limit} cho cấp {tier})"
  Đề xuất: "Nâng cấp lên {next_tier} cho {next_limit} chiến dịch"

Ví dụ Kiểm tra:
• Tạo chiến dịch: Kiểm tra giới hạn chiến dịch đồng thời
• Đặt ngân sách chiến dịch: Kiểm tra giới hạn ngân sách mỗi chiến dịch
• Chi tiêu hàng ngày: Kiểm tra giới hạn chi tiêu hàng ngày (24h lăn)
• Upload nội dung: Kiểm tra giới hạn tài sản nội dung
• Mời thành viên nhóm: Kiểm tra giới hạn thành viên nhóm

Giới hạn Mềm vs Giới hạn Cứng:
• Giới hạn cứng: Không thể vượt (bắt buộc)
  * Chiến dịch đồng thời
  * Ngân sách mỗi chiến dịch
  * Thành viên nhóm

• Giới hạn mềm: Có thể vượt với cảnh báo
  * Chi tiêu hàng ngày (cảnh báo ở 80%, từ chối ở 100%)
  * Chi tiêu hàng tháng (tương tự)

Quy tắc nghiệp vụ:
• Giới hạn kiểm tra theo thời gian thực
• User được cảnh báo ở 80% giới hạn
• Nhắc nâng cấp khi đạt giới hạn
• Cho phép vượt tạm thời cho Enterprise (lên đến 10%)
```

---

### Quy tắc 2: Xác minh & KYC

#### 2.1 Yêu cầu Xác minh

**Advertiser Cá nhân**:
```
Tài liệu Bắt buộc:
1. ID do chính phủ cấp:
   • Hộ chiếu, HOẶC
   • Bằng lái xe, HOẶC
   • Thẻ ID quốc gia

2. Selfie (để khớp khuôn mặt)

3. Chứng minh địa chỉ (nếu > $10k/tháng):
   • Hóa đơn tiện ích
   • Sao kê ngân hàng
   • Thư chính phủ
   (Phải < 3 tháng tuổi)

Quy trình:
• Upload tài liệu qua Stripe Identity hoặc thủ công
• Kiểm tra tự động (tính xác thực tài liệu, khớp khuôn mặt)
• Đánh giá thủ công nếu gắn cờ
• Phê duyệt trong 24-48 giờ

Lợi ích:
• Tăng giới hạn hàng ngày: $500 → $10,000
• Tăng giới hạn hàng tháng: $1,000 → $100,000
• Truy cập cấp Premium
```

**Advertiser Doanh nghiệp**:
```
Tài liệu Bắt buộc:
1. Giấy chứng nhận đăng ký kinh doanh

2. Mã số thuế (EIN/VAT)

3. Điều lệ công ty

4. Tuyên bố sở hữu thụ hưởng (nếu áp dụng)

5. Sao kê ngân hàng doanh nghiệp

6. ID người ký có thẩm quyền (ID chính phủ)

7. Chứng minh địa chỉ doanh nghiệp

Quy trình:
• Upload tài liệu qua cổng bảo mật
• Dịch vụ xác minh doanh nghiệp (vd: Stripe, LexisNexis)
• Đánh giá thủ công bởi đội tuân thủ
• Phê duyệt trong 3-5 ngày làm việc

Lợi ích:
• Tất cả lợi ích cá nhân
• Đủ điều kiện điều khoản thanh toán NET
• Giới hạn tín dụng cao hơn
• Đủ điều kiện cấp Enterprise
```

#### 2.2 Quy trình Xác minh

```
Người thực hiện: Advertiser
Kích hoạt: User click "Xác minh Tài khoản"

Bước 1: Chọn loại xác minh
  • Cá nhân: Nhanh hơn (24-48h)
  • Doanh nghiệp: Toàn diện hơn (3-5 ngày)

Bước 2: Upload tài liệu
  POST /account/verify
  {
    "verification_type": "BUSINESS",
    "documents": [
      {
        "type": "BUSINESS_REGISTRATION",
        "file_id": "uploaded_file_id",
        "issue_date": "2020-01-15",
        "expiry_date": null
      },
      {
        "type": "TAX_ID",
        "value": "12-3456789",
        "country": "US"
      }
      // ... thêm tài liệu
    ],
    "business_info": {
      "legal_name": "Acme Corp Inc.",
      "registration_number": "123456789",
      "registration_country": "US",
      "business_address": {...}
    }
  }

Bước 3: Kiểm tra tự động (Stripe Identity)
  • Tính xác thực tài liệu
  • Kiểm tra ngày hết hạn
  • Trích xuất dữ liệu (OCR)
  • Sàng lọc danh sách theo dõi (trừng phạt, PEP)

  NẾU all_checks_pass:
    auto_approve() // Cho trường hợp rủi ro thấp
  NGƯỢC LẠI:
    flag_for_manual_review()

Bước 4: Đánh giá thủ công (nếu gắn cờ)
  Đội tuân thủ xem xét:
  • Chất lượng tài liệu
  • Tính nhất quán thông tin
  • Chỉ số rủi ro
  • Tính hợp pháp doanh nghiệp

  Quyết định: APPROVE / REJECT / REQUEST_MORE_INFO

Bước 5: Kết quả
  Chấp thuận:
    advertiser.verification_status = VERIFIED
    advertiser.verified_at = BÂY GIỜ()
    apply_verified_limits()

    Thông báo: "Xác minh được chấp thuận! Giới hạn cao hơn đã mở khóa"

  Từ chối:
    advertiser.verification_status = REJECTED

    AdvertiserVerification.update(
      status: REJECTED,
      rejection_reason: reason,
      reviewed_by: admin_id
    )

    Thông báo: "Xác minh bị từ chối: {reason}"
    Cho phép: Nộp lại sau khi giải quyết vấn đề

  Cần Thêm Thông tin:
    Yêu cầu tài liệu/làm rõ cụ thể
    Trạng thái vẫn PENDING

Bước 6: Xác minh lại (mỗi 2 năm)
  NẾU verified_at < BÂY GIỜ - 2 năm:
    advertiser.verification_status = EXPIRED
    Yêu cầu xác minh lại
    Quay về giới hạn chưa xác minh

Quy tắc nghiệp vụ:
• Xác minh bắt buộc cho chi tiêu > $10k/tháng
• Tài liệu phải rõ ràng, đọc được, chưa hết hạn
• Thông tin phải khớp giữa các tài liệu
• Sàng lọc PEP/trừng phạt tự động
• Xác minh lại mỗi 2 năm
• Từ chối cho phép nộp lại (giải quyết vấn đề)
• Cấp Enterprise yêu cầu xác minh doanh nghiệp
```

---

### Quy tắc 3: Quản lý Nhóm

#### 3.1 Mời Thành viên Nhóm

```
Người thực hiện: OWNER hoặc ADMIN của Advertiser
Hành động: Mời thành viên nhóm

Yêu cầu:
✓ User hiện tại có vai trò OWNER hoặc ADMIN
✓ Kích thước nhóm < giới hạn cấp
✓ Email người được mời chưa là thành viên nhóm
✓ Trạng thái tài khoản = ACTIVE

Quy trình:
1. Gửi lời mời:
   POST /account/team/invite
   {
     "email": "colleague@example.com",
     "role": "CAMPAIGN_MANAGER",
     "message": "Tham gia nhóm quảng cáo của chúng tôi"
   }

2. Kiểm tra:
   team_count = advertiser.team_members.active.count
   tier_limit = get_tier_config(advertiser.account_tier).max_team_members

   NẾU team_count >= tier_limit:
     LỖI: "Đã đạt giới hạn thành viên nhóm"
     Đề xuất nâng cấp

3. Tạo lời mời:
   TeamMember.create(
     advertiser_id: advertiser.id,
     user_id: null, // Chưa chấp nhận
     email: "colleague@example.com",
     role: role,
     invited_by: current_user.id,
     invited_at: BÂY GIỜ(),
     status: PENDING
   )

4. Gửi email mời:
   To: colleague@example.com
   Subject: "Bạn được mời tham gia {company_name}"
   Body:
     • Tên người mời
     • Tên công ty/thương hiệu
     • Vai trò được đề nghị
     • Link chấp nhận (hết hạn trong 7 ngày)

5. Người được mời chấp nhận:
   GET /team/invitation/accept?token={token}

   • Nếu user chưa tồn tại: Chuyển hướng đến đăng ký
   • Nếu user tồn tại: Xác nhận chấp nhận

   TeamMember.update(
     user_id: invitee_user.id,
     accepted_at: BÂY GIỜ(),
     status: ACTIVE
   )

6. Cấp quyền truy cập:
   Người được mời giờ có thể:
   • Đăng nhập vào tài khoản advertiser
   • Thực hiện hành động theo quyền vai trò
   • Chuyển đổi giữa tài khoản riêng và tài khoản nhóm

Quy tắc nghiệp vụ:
• Chỉ OWNER và ADMIN mới mời được
• Lời mời hết hạn sau 7 ngày
• Một user có thể là thành viên của nhiều advertiser
• Không thể mời thành viên nhóm hiện tại (email trùng)
• Người được mời phải chấp nhận để có quyền truy cập
• Không thể xóa Owner (chuyển quyền sở hữu trước)
```

#### 3.2 Ma trận Quyền Vai trò

```
Quyền theo Vai trò:

OWNER:
  campaigns: create, read, update, delete, activate, pause
  content: upload, read, update, delete, approve
  wallet: topup, view_balance, view_transactions
  billing: update_payment_method, view_invoices
  reports: view_all, export
  settings: update_profile, update_billing, manage_team
  team: invite, remove, change_roles, transfer_ownership

ADMIN:
  campaigns: create, read, update, delete, activate, pause
  content: upload, read, update, delete, approve
  wallet: view_balance, view_transactions (không topup)
  billing: view_invoices (không update)
  reports: view_all, export
  settings: update_profile (không billing)
  team: invite, remove, change_roles (không owner)

CAMPAIGN_MANAGER:
  campaigns: create, read, update, activate, pause (không delete)
  content: upload, read, update (không delete)
  wallet: view_balance (không transactions)
  billing: không có
  reports: view_campaigns, export
  settings: không có
  team: không có

CONTENT_MANAGER:
  campaigns: read
  content: upload, read, update, delete
  wallet: không có
  billing: không có
  reports: view_content_performance
  settings: không có
  team: không có

ANALYST:
  campaigns: read
  content: read
  wallet: không có
  billing: không có
  reports: view_all, export
  settings: không có
  team: không có

VIEWER:
  campaigns: read
  content: read
  wallet: không có
  billing: không có
  reports: view_basic
  settings: không có
  team: không có

Triển khai:
check_permission(user, advertiser, action):
  team_member = TeamMember.find_by(
    user_id: user.id,
    advertiser_id: advertiser.id,
    status: ACTIVE
  )

  NẾU KHÔNG team_member:
    RETURN false // Không phải thành viên nhóm

  permissions = ROLE_PERMISSIONS[team_member.role]
  RETURN action TRONG permissions[resource]

Ví dụ:
  NẾU KHÔNG check_permission(user, advertiser, "campaigns.delete"):
    LỖI: "Quyền không đủ"
```

#### 3.3 Xóa Thành viên Nhóm

```
Người thực hiện: OWNER hoặc ADMIN
Hành động: Xóa thành viên nhóm

Yêu cầu:
✓ User hiện tại có vai trò OWNER hoặc ADMIN
✓ User mục tiêu không phải OWNER (chuyển quyền trước)
✓ User hiện tại không thể tự xóa (trừ OWNER)

Quy trình:
1. Thu hồi quyền truy cập:
   DELETE /account/team/{member_id}

2. Cập nhật bản ghi:
   TeamMember.update(
     status: REVOKED,
     revoked_at: BÂY GIỜ(),
     revoked_by: current_user.id
   )

3. Kết thúc phiên:
   • Vô hiệu hóa tất cả phiên active cho thành viên này
   • Buộc đăng xuất
   • Ngăn đăng nhập trong tương lai

4. Nhật ký kiểm toán:
   AuditLog.create(
     action: "TEAM_MEMBER_REMOVED",
     actor: current_user.id,
     target: member.user_id,
     details: {
       member_name: member.user.name,
       member_role: member.role,
       removal_reason: "Admin action"
     }
   )

5. Thông báo:
   • Thành viên bị xóa: "Quyền truy cập của bạn vào {company} đã bị thu hồi"
   • Thành viên nhóm khác (tùy chọn): "{name} rời khỏi nhóm"

Quy tắc nghiệp vụ:
• Không thể xóa Owner (phải chuyển quyền sở hữu trước)
• Xóa có hiệu lực ngay lập tức (buộc đăng xuất)
• Thành viên bị xóa có thể được mời lại sau
• Dấu vết kiểm toán được bảo tồn (ai xóa ai, khi nào)
```

---

### Quy tắc 4: Tuân thủ & Hạn chế

#### 4.1 Ngành nghề Bị cấm

```
Các ngành KHÔNG được phép quảng cáo:

1. Nội dung & Dịch vụ Người lớn
   • Khiêu dâm
   • Giải trí người lớn
   • Dịch vụ hộ tống

2. Hàng hóa & Dịch vụ Bất hợp pháp
   • Ma túy & chất gây nghiện
   • Vũ khí & chất nổ
   • Hàng giả
   • Dịch vụ hack

3. Cờ bạc (không có giấy phép)
   • Casino trực tuyến
   • Cá cược thể thao
   • Dịch vụ xổ số

4. Sản phẩm Thuốc lá (quy định nghiêm ngặt)
   • Thuốc lá
   • Sản phẩm vaping
   • Phụ kiện thuốc lá

5. Chiến dịch Chính trị (yêu cầu phê duyệt riêng)
   • Chiến dịch ứng cử viên
   • Vận động chính trị
   • Quảng cáo vấn đề

6. Tiền mã hóa (không có xác minh)
   • ICO & bán token
   • Sàn crypto (chưa quy định)

7. Chăm sóc sức khỏe (không có thông tin đăng nhập)
   • Dược phẩm (theo toa)
   • Dịch vụ y tế (không có giấy phép)
   • Phương thuốc kỳ diệu

8. Dịch vụ Tài chính (không có giấy phép)
   • Cho vay không phép
   • Lừa đảo đầu tư
   • Đa cấp

Kiểm tra:
Khi đăng ký:
  NẾU advertiser.industry TRONG prohibited_industries:
    NẾU has_special_approval(advertiser):
      CHO PHÉP với hạn chế
    NGƯỢC LẠI:
      TỪ CHỐI đăng ký

Khi tạo chiến dịch:
  scan_content_for_prohibited_categories(content)
  NẾU gắn cờ:
    GIỮ để đánh giá thủ công

Quy tắc nghiệp vụ:
• Ngành nghề khai báo khi đăng ký
• Không thể thay đổi ngành nghề mà không xác minh lại
• Danh mục đặc biệt yêu cầu tài liệu bổ sung (giấy phép, giấy phép)
• Nội dung tự động quét vi phạm
• Vi phạm dẫn đến đình chỉ
```

#### 4.2 Hạn chế Nội dung

```
Nội dung Bị cấm:

1. Tuyên bố Gây hiểu lầm
   • Quảng cáo sai
   • Tuyên bố không có căn cứ
   • Lời chứng thực giả

2. Nội dung Xúc phạm
   • Ngôn ngữ thù hận
   • Bạo lực
   • Phân biệt đối xử

3. Tài liệu Có bản quyền
   • Nhạc không có giấy phép
   • Hình ảnh bị đánh cắp
   • Vi phạm thương hiệu

4. Dữ liệu Cá nhân Nhạy cảm
   • Tình trạng sức khỏe
   • Thông tin tài chính
   • Trẻ em dưới 13 tuổi

5. Tuyên bố Trước/Sau (sức khỏe/sắc đẹp)
   • Giảm cân
   • Tăng cơ
   • Chống lão hóa
   (Yêu cầu tuyên bố miễn trừ trách nhiệm)

Quy trình Đánh giá Nội dung:
1. Quét AI (tự động):
   • Nhận dạng hình ảnh (nội dung xúc phạm)
   • Phân tích văn bản (từ khóa bị cấm)
   • Phân tích âm thanh (nhạc có bản quyền)

2. Chấm điểm rủi ro:
   • Rủi ro cao (>80): Giữ để đánh giá thủ công
   • Rủi ro trung bình (50-80): Phê duyệt có gắn cờ
   • Rủi ro thấp (<50): Tự động phê duyệt

3. Đánh giá thủ công (nếu gắn cờ):
   • Đội tuân thủ xem xét trong 24h
   • APPROVE / REJECT / REQUEST_CHANGES

4. Vi phạm:
   • Vi phạm lần đầu: Cảnh báo + xóa nội dung
   • Vi phạm lần hai: Đình chỉ 7 ngày
   • Vi phạm lần ba: Cấm vĩnh viễn

Quy tắc nghiệp vụ:
• Tất cả nội dung được quét trước khi phê duyệt
• Nội dung rủi ro cao được xem xét thủ công
• Advertiser được thông báo về vi phạm
• Vi phạm lặp lại leo thang hình phạt
• Quy trình kháng cáo có sẵn
```

---

### Quy tắc 5: Quản lý Trạng thái Tài khoản

#### 5.1 Đình chỉ

```
Lý do Đình chỉ:

1. Vấn đề Thanh toán
   • Thanh toán thất bại (3 lần liên tiếp)
   • Tranh chấp hoàn tiền

2. Vi phạm Chính sách
   • Nội dung bị cấm
   • Quảng cáo gây hiểu lầm
   • Khiếu nại người dùng quá mức

3. Chỉ báo Gian lận
   • Mẫu hoạt động đáng ngờ
   • Cờ AML
   • Vấn đề xác minh danh tính

4. Vi phạm Điều khoản Dịch vụ
   • Lạm dụng nền tảng
   • Thử thao túng
   • Hành vi không xác thực phối hợp

Quy trình Đình chỉ:
1. Kích hoạt phát hiện:
   • Tự động (thanh toán thất bại, cờ nội dung)
   • Thủ công (đánh giá admin)

2. Cập nhật tài khoản:
   advertiser.status = SUSPENDED
   advertiser.suspended_at = BÂY GIỜ()
   advertiser.suspension_reason = reason

3. Hiệu lực ngay lập tức:
   • Tất cả chiến dịch tạm dừng (ngừng phục vụ quảng cáo)
   • Không cho phép chiến dịch mới
   • Upload nội dung bị vô hiệu hóa
   • Rút tiền ví bị vô hiệu hóa (nếu áp dụng)
   • Đăng nhập vẫn được phép (chỉ đọc)

4. Thông báo advertiser:
   Email: "Tài khoản bị đình chỉ"
   Lý do: Vi phạm cụ thể
   Hành động: Bước để giải quyết
   Thời gian: Thời lượng đình chỉ

5. Đường giải quyết:

   Vấn đề Thanh toán:
     • Cập nhật phương thức thanh toán
     • Thanh toán số dư nợ
     • Kích hoạt lại tự động

   Vi phạm Chính sách:
     • Xóa nội dung vi phạm
     • Xác nhận chính sách
     • Gửi kháng cáo (nếu áp dụng)
     • Đánh giá thủ công → kích hoạt lại

   Điều tra Gian lận:
     • Cung cấp tài liệu bổ sung
     • Đánh giá tuân thủ (3-5 ngày)
     • Kích hoạt lại hoặc cấm

6. Kích hoạt lại:
   NẾU issue_resolved:
     advertiser.status = ACTIVE
     advertiser.suspended_at = null
     advertiser.suspension_reason = null

     Tiếp tục chiến dịch
     Thông báo: "Tài khoản đã kích hoạt lại"

Quy tắc nghiệp vụ:
• Đình chỉ có thể đảo ngược
• Advertiser được thông báo với lý do
• Bước giải quyết rõ ràng được cung cấp
• Chiến dịch tự động tiếp tục khi kích hoạt lại
• Nhiều lần đình chỉ → cấm vĩnh viễn
```

#### 5.2 Cấm Vĩnh viễn

```
Lý do Cấm Vĩnh viễn:

1. Vi phạm Nghiêm trọng
   • Nội dung bất hợp pháp
   • Vi phạm chính sách nghiêm trọng
   • Gian lận

2. Vi phạm Lặp lại
   • 3+ lần đình chỉ
   • Vi phạm chính sách dai dẳng
   • Không cải thiện sau cảnh báo

3. Lý do Pháp lý
   • Lệnh tòa án
   • Yêu cầu quy định
   • Yêu cầu cơ quan thực thi pháp luật

Quy trình Cấm:
1. Đánh giá cuối cùng:
   • Đánh giá đội tuân thủ
   • Phê duyệt quản lý cấp cao
   • Đánh giá pháp lý (nếu cần)

2. Thực thi cấm:
   advertiser.status = BANNED
   advertiser.banned_at = BÂY GIỜ()
   advertiser.ban_reason = reason

3. Hiệu lực ngay lập tức:
   • Tất cả chiến dịch chấm dứt (không tạm dừng)
   • Tất cả nội dung bị xóa
   • Số dư ví giữ (chờ tranh chấp)
   • Đăng nhập bị vô hiệu hóa
   • Thành viên nhóm bị xóa
   • Truy cập API bị thu hồi

4. Giải quyết tài chính:
   • Ngân sách chiến dịch chưa dùng được hoàn tiền
   • Giao dịch đang chờ được xóa
   • Số dư ví xử lý theo chính sách:
     * Thoát sạch: Hoàn số dư khả dụng
     * Trường hợp gian lận: Số dư có thể bị tịch thu

5. Thông báo advertiser:
   Email: "Tài khoản bị cấm vĩnh viễn"
   Lý do: Chi tiết vi phạm
   Kháng cáo: Quy trình kháng cáo (nếu đủ điều kiện)
   Dữ liệu: Xuất dữ liệu có sẵn (30 ngày)

6. Quy trình kháng cáo:
   • Cửa sổ: 30 ngày từ khi cấm
   • Gửi: Kháng cáo bằng văn bản với bằng chứng
   • Xem xét: Đánh giá tuân thủ + pháp lý
   • Quyết định: Giữ nguyên cấm hoặc khôi phục

   Kháng cáo hiếm khi được chấp thuận (< 5%)

Quy tắc nghiệp vụ:
• Cấm là vĩnh viễn (ngoại lệ hiếm)
• Yêu cầu tài liệu vi phạm rõ ràng
• Giải quyết tài chính theo chính sách
• Xuất dữ liệu có sẵn (cửa sổ 30 ngày)
• Quy trình kháng cáo có sẵn nhưng nghiêm ngặt
• Dấu vân tay IP/thiết bị để ngăn đăng ký lại
```

---

## ⚠️ Các trường hợp đặc biệt

### Trường hợp 1: Chuyển Quyền sở hữu Thành viên Nhóm

```
Tình huống: OWNER rời công ty, cần chuyển quyền sở hữu

Quy trình:
1. OWNER hiện tại khởi tạo chuyển:
   POST /account/transfer-ownership
   {
     "new_owner_user_id": "uuid"
   }

2. Kiểm tra:
   ✓ User hiện tại là OWNER
   ✓ Owner mới là thành viên nhóm active
   ✓ Owner mới chấp nhận (yêu cầu xác nhận)

3. Xác nhận từ owner mới:
   • Email gửi: "Bạn đã được đề cử làm owner mới"
   • Chấp nhận/Từ chối trong 7 ngày

4. Nếu chấp nhận:
   // Cập nhật vai trò
   old_owner = TeamMember.find_by(role: OWNER)
   old_owner.update(role: ADMIN) // Hạ xuống ADMIN

   new_owner = TeamMember.find_by(user_id: new_owner_id)
   new_owner.update(role: OWNER) // Thăng lên OWNER

   // Chuyển quyền sở hữu billing
   advertiser.user_id = new_owner_user_id
   advertiser.updated_at = BÂY GIỜ()

   // Nhật ký kiểm toán
   Ghi chuyển quyền sở hữu

5. Thông báo tất cả thành viên nhóm:
   "Quyền sở hữu đã chuyển: {old_owner} → {new_owner}"

Quy tắc nghiệp vụ:
• Chỉ một OWNER tại một thời điểm
• Chuyển yêu cầu xác nhận owner mới
• Owner cũ trở thành ADMIN (không bị xóa)
• Trách nhiệm billing chuyển
```

### Trường hợp 2: Hạ cấp Giữa Chiến dịch

```
Tình huống: User Premium hạ xuống Basic trong khi chiến dịch đang chạy

Trạng thái hiện tại:
• Cấp: PREMIUM (tối đa 20 chiến dịch)
• Chiến dịch active: 15
• Cấp mới: BASIC (tối đa 5 chiến dịch)

Vấn đề: 15 chiến dịch vượt giới hạn Basic là 5

Giải quyết:
1. Cảnh báo user trước khi hạ cấp:
   "Bạn có 15 chiến dịch active. Cấp Basic cho phép 5."
   Tùy chọn:
   • Hủy hạ cấp
   • Tạm dừng 10 chiến dịch (user chọn cái nào)
   • Lên lịch hạ cấp cho cuối chiến dịch

2. Nếu user tiếp tục:
   • Chiến dịch tiếp tục chạy (được bảo vệ)
   • Không thể tạo chiến dịch mới cho đến khi số < 5
   • Chiến dịch tiếp theo kết thúc, số giảm

Quy tắc nghiệp vụ:
• Chiến dịch hiện tại được bảo vệ
• Tạo chiến dịch mới bị chặn
• User được cảnh báo trước khi hạ cấp
```

### Trường hợp 3: Xác minh Hết hạn Giữa Chiến dịch

```
Tình huống: Xác minh hết hạn (2 năm), chiến dịch vẫn đang chạy

Quy trình:
1. Phát hiện hết hạn:
   NẾU advertiser.verified_at < BÂY GIỜ - 2 năm:
     advertiser.verification_status = EXPIRED

2. Thông báo user (30 ngày trước):
   "Xác minh sắp hết hạn. Xác minh lại để duy trì giới hạn."

3. Khi hết hạn:
   • Trạng thái → EXPIRED
   • Giới hạn quay về chưa xác minh
   • Chiến dịch hiện tại tiếp tục (được bảo vệ)
   • Chiến dịch mới: Áp dụng giới hạn giảm

4. User xác minh lại:
   • Gửi tài liệu mới
   • Quy trình xác minh
   • Giới hạn khôi phục

Quy tắc nghiệp vụ:
• Xác minh lại bắt buộc mỗi 2 năm
• Thông báo trước 30 ngày
• Chiến dịch hiện tại không bị ảnh hưởng
• Chiến dịch mới dùng giới hạn thấp hơn cho đến khi xác minh lại
```

---

## ✅ Quy tắc Kiểm tra

### Ma trận Kiểm tra Advertiser

| Trường | Quy tắc | Thông báo lỗi |
|--------|---------|---------------|
| `company_name` | Độ dài 2-100 | "Tên công ty phải từ 2-100 ký tự" |
| `brand_name` | Độ dài 2-100, bắt buộc | "Tên thương hiệu là bắt buộc" |
| `website_url` | Định dạng URL hợp lệ | "URL website không hợp lệ" |
| `description` | Tối đa 500 ký tự | "Mô tả tối đa 500 ký tự" |
| `industry` | Giá trị enum hợp lệ | "Lựa chọn ngành nghề không hợp lệ" |
| `billing_email` | Định dạng email hợp lệ | "Địa chỉ email không hợp lệ" |
| `billing_address` | Các trường bắt buộc | "Yêu cầu địa chỉ thanh toán đầy đủ" |
| `tax_id` | Định dạng hợp lệ theo quốc gia | "Định dạng mã số thuế không hợp lệ" |

---

## 📚 Phụ lục: Bảng So sánh Cấp Tài khoản

| Tính năng | FREE | BASIC | PREMIUM | ENTERPRISE |
|-----------|------|-------|---------|------------|
| **Giá/tháng** | $0 | $99 | $499 | Tùy chỉnh |
| **Chiến dịch Đồng thời** | 2 | 5 | 20 | Không giới hạn |
| **Ngân sách/Chiến dịch** | $500 | $2,000 | $10,000 | Tùy chỉnh |
| **Chi tiêu Hàng ngày** | $100 | $500 | $2,000 | Tùy chỉnh |
| **Chi tiêu Hàng tháng** | $1,000 | $5,000 | $50,000 | Tùy chỉnh |
| **Tài sản Nội dung** | 10 | 50 | 200 | Không giới hạn |
| **Thành viên Nhóm** | 1 | 3 | 10 | Không giới hạn |
| **Hỗ trợ** | Cộng đồng | Email 48h | Ưu tiên 24h | Quản lý chuyên biệt |
| **Truy cập API** | Không | Không | Có | Có |
| **Phân tích** | Cơ bản | Nâng cao | Nâng cao | Tùy chỉnh |
| **White Label** | Không | Không | Không | Có |

---

## 📚 Bảng thuật ngữ

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Advertiser** | Nhà quảng cáo - doanh nghiệp/cá nhân chạy chiến dịch |
| **Account Tier** | Cấp tài khoản (FREE/BASIC/PREMIUM/ENTERPRISE) |
| **KYC** | Know Your Customer - Xác minh danh tính |
| **Verification** | Xác minh tài khoản qua tài liệu |
| **Team Member** | Thành viên nhóm có quyền truy cập tài khoản |
| **OWNER** | Chủ sở hữu tài khoản, toàn quyền |
| **Suspended** | Tài khoản bị đình chỉ tạm thời |
| **Banned** | Tài khoản bị cấm vĩnh viễn |

---

## 📚 Tham khảo

### Tài liệu liên quan

| Tài liệu | Mô tả |
|----------|-------|
| [Từ điển Thuật ngữ](./00-tu-dien-thuat-ngu.md) | Giải thích tất cả thuật ngữ |
| [Quy tắc Chiến dịch](./04-quy-tac-chien-dich.md) | Tạo chiến dịch bởi advertiser |
| [Quy tắc Ví](./07-quy-tac-vi-thanh-toan.md) | Ví & thanh toán advertiser |
| [Quy tắc Nội dung](./10-quy-tac-noi-dung.md) | Upload nội dung bởi advertiser |

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team  
**Trạng thái**: Sẵn sàng để review

**Bước tiếp theo**:
1. Đánh giá với stakeholder
2. Xác nhận đội product
3. Đầu vào đội sales (cấp Enterprise)
4. Lập kế hoạch triển khai