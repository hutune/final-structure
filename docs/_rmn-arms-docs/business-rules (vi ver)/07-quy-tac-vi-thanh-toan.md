# 💰 Quy tắc Nghiệp vụ: Module Ví & Thanh toán

**Phiên bản**: 1.0  
**Ngày**: 2026-01-23  
**Trạng thái**: Bản nháp  
**Chủ quản**: Product Team

---

## 📖 Mục lục

1. [Tổng quan](#-tổng-quan)
2. [Các thực thể Domain](#-các-thực-thể-domain)
3. [Vòng đời Ví](#-vòng-đời-ví)
4. [Quy tắc Nghiệp vụ](#-quy-tắc-nghiệp-vụ)
5. [Nạp tiền & Xử lý Thanh toán](#-nạp-tiền--xử-lý-thanh-toán)
6. [Quản lý Giao dịch](#-quản-lý-giao-dịch)
7. [Xử lý Hoàn tiền](#-xử-lý-hoàn-tiền)
8. [Rút tiền Supplier](#-rút-tiền-supplier)
9. [Tiền tệ & Tỷ giá](#-tiền-tệ--tỷ-giá)
10. [Xử lý Thuế](#-xử-lý-thuế)
11. [Đối soát Tài chính](#-đối-soát-tài-chính)
12. [Chống Rửa tiền (AML)](#-chống-rửa-tiền-aml)
13. [Các trường hợp đặc biệt](#-các-trường-hợp-đặc-biệt)
14. [Quy tắc Kiểm tra](#-quy-tắc-kiểm-tra)
15. [Công thức Tính toán](#-công-thức-tính-toán)

---

## 🎯 Tổng quan

### Mục đích

Tài liệu này định nghĩa TẤT CẢ quy tắc nghiệp vụ cho module Ví & Thanh toán, bao gồm giao dịch tài chính, xử lý thanh toán, hoàn tiền, rút tiền và yêu cầu tuân thủ.

### Phạm vi

**Bao gồm:**
- ✅ Quản lý ví (Advertiser & Supplier)
- ✅ Các loại số dư và chuyển đổi
- ✅ Tích hợp cổng thanh toán
- ✅ Quy trình nạp và rút tiền
- ✅ Ghi nhận và kiểm toán giao dịch
- ✅ Xử lý hoàn tiền
- ✅ Tính thuế và tuân thủ
- ✅ Chuyển đổi tiền tệ
- ✅ Đối soát tài chính
- ✅ Tuân thủ chống rửa tiền (AML)

**KHÔNG bao gồm:**
- ❌ Tính phí chiến dịch (xem module Campaign)
- ❌ Chi phí impression (xem module Campaign/Impression)
- ❌ Tính doanh thu supplier (xem module Campaign/Supplier)

### Khái niệm Chủ chốt

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Wallet (Ví)** | Tài khoản kỹ thuật số chứa tiền của người dùng |
| **Balance Types** | Số dư Khả dụng, Giữ, Đang chờ |
| **Transaction (Giao dịch)** | Bản ghi bất biến về thay đổi số dư |
| **Top-up (Nạp tiền)** | Thêm tiền vào ví advertiser |
| **Withdrawal (Rút tiền)** | Chuyển tiền từ ví supplier về ngân hàng |
| **Reconciliation (Đối soát)** | Xác minh độ chính xác tài chính hàng ngày |

---

## 📦 Các thực thể Domain

### 1. Wallet (Ví)

> **Định nghĩa**: Tài khoản kỹ thuật số để quản lý tiền trên nền tảng.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Mặc định | Quy tắc nghiệp vụ |
|--------|------|----------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo | Không thay đổi |
| `user_id` | UUID | Có | - | Một ví mỗi người dùng |
| `user_type` | Enum | Có | - | ADVERTISER / SUPPLIER |
| `currency` | String(3) | Có | "USD" | Mã ISO 4217 |
| `available_balance` | Decimal(12,2) | Có | 0.00 | Tiền có thể dùng ngay |
| `held_balance` | Decimal(12,2) | Có | 0.00 | Tiền bị khóa/ký quỹ |
| `pending_balance` | Decimal(12,2) | Có | 0.00 | Nạp/rút đang xử lý |
| `lifetime_deposits` | Decimal(12,2) | Có | 0.00 | Tổng nạp từ trước đến nay |
| `lifetime_withdrawals` | Decimal(12,2) | Có | 0.00 | Tổng rút từ trước đến nay |
| `lifetime_spent` | Decimal(12,2) | Có | 0.00 | Tổng chi chiến dịch (advertiser) |
| `lifetime_earned` | Decimal(12,2) | Có | 0.00 | Tổng doanh thu (supplier) |
| `min_balance_alert` | Decimal(12,2) | Không | null | Cảnh báo khi số dư dưới mức |
| `max_balance_limit` | Decimal(12,2) | Không | null | Số dư tối đa cho phép |
| `status` | Enum | Có | ACTIVE | ACTIVE / FROZEN / SUSPENDED |
| `frozen_reason` | String(200) | Không | null | Lý do đóng băng ví |
| `frozen_at` | DateTime | Không | null | Thời điểm đóng băng |
| `last_topup_at` | DateTime | Không | null | Nạp tiền gần nhất |
| `last_withdrawal_at` | DateTime | Không | null | Rút tiền gần nhất |
| `created_at` | DateTime | Có | BÂY GIỜ() | Không thay đổi |
| `updated_at` | DateTime | Có | BÂY GIỜ() | Tự động cập nhật |

#### Bất biến Số dư

```
Công thức cơ bản:
total_balance = available_balance + held_balance + pending_balance

// Phải luôn bằng tổng tất cả giao dịch
total_balance == SUM(transactions.amount WHERE type IN [CREDIT, DEBIT])

Giải thích:
• available_balance: Tiền có thể dùng ngay cho chiến dịch hoặc rút
• held_balance: Tiền bị khóa tạm thời (ngân sách chiến dịch, tranh chấp)
• pending_balance: Tiền đang xử lý (nạp/rút chưa hoàn thành)
```

---

### 2. WalletTransaction (Giao dịch Ví)

> **Định nghĩa**: Bản ghi bất biến về sự kiện thay đổi số dư.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `wallet_id` | UUID | Có | Ví nguồn |
| `transaction_type` | Enum | Có | Xem [Loại Giao dịch](#loại-giao-dịch) |
| `amount` | Decimal(12,2) | Có | Luôn dương (type chỉ chiều) |
| `currency` | String(3) | Có | Mã ISO 4217 |
| `balance_before` | Decimal(12,2) | Có | Snapshot trước giao dịch |
| `balance_after` | Decimal(12,2) | Có | Snapshot sau giao dịch |
| `balance_type_affected` | Enum | Có | AVAILABLE / HELD / PENDING |
| `status` | Enum | Có | PENDING / COMPLETED / FAILED / REVERSED |
| `reference_type` | String(50) | Không | Campaign, Impression, Withdrawal, v.v. |
| `reference_id` | UUID | Không | Link đến thực thể liên quan |
| `payment_method` | Enum | Không | CARD / BANK_TRANSFER / WALLET / OTHER |
| `payment_gateway` | Enum | Không | STRIPE / PAYPAL / BANK / MANUAL |
| `gateway_transaction_id` | String(100) | Không | ID thanh toán bên ngoài |
| `description` | Text | Có | Mô tả dễ đọc |
| `metadata` | JSON | Không | Dữ liệu bổ sung |
| `fee_amount` | Decimal(12,2) | Có | Phí giao dịch (mặc định: 0.00) |
| `tax_amount` | Decimal(12,2) | Có | Thuế khấu trừ (mặc định: 0.00) |
| `net_amount` | Decimal(12,2) | Có | amount - fee - tax |
| `processed_by` | UUID | Không | User/Admin khởi tạo |
| `processed_at` | DateTime | Có | Khi giao dịch thực hiện |
| `reversed_at` | DateTime | Không | Khi đảo ngược (nếu có) |
| `reversal_reason` | String(200) | Không | Lý do đảo ngược |
| `created_at` | DateTime | Có | Không thay đổi |

#### Loại Giao dịch

```
Credit (tăng số dư):
• DEPOSIT: Người dùng nạp tiền
• REFUND: Hoàn tiền ngân sách chiến dịch
• REVENUE: Thu nhập supplier
• ADJUSTMENT_CREDIT: Điều chỉnh thủ công (admin)
• BONUS: Khuyến khích từ nền tảng

Debit (giảm số dư):
• CAMPAIGN_HOLD: Ngân sách ký quỹ cho chiến dịch
• CAMPAIGN_CHARGE: Tính phí impression
• WITHDRAWAL: Rút tiền supplier
• FEE: Phí nền tảng/giao dịch
• TAX_WITHHOLDING: Khấu trừ thuế
• ADJUSTMENT_DEBIT: Điều chỉnh thủ công (admin)
• CHARGEBACK: Impression bị tranh chấp

Hold/Release (không thay đổi tổng số dư):
• HOLD: Chuyển available → held
• RELEASE: Chuyển held → available

Pending (đang xử lý):
• PENDING_DEPOSIT: Nạp tiền đang xử lý
• PENDING_WITHDRAWAL: Rút tiền đang xử lý
```

---

### 3. PaymentMethod (Phương thức Thanh toán)

> **Định nghĩa**: Phương thức thanh toán đã lưu của người dùng.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `user_id` | UUID | Có | Chủ sở hữu |
| `type` | Enum | Có | CREDIT_CARD / DEBIT_CARD / BANK_ACCOUNT |
| `provider` | Enum | Có | STRIPE / PAYPAL |
| `provider_payment_method_id` | String(100) | Có | ID PM của gateway |
| `is_default` | Boolean | Có | Mặc định cho nạp tiền |
| `card_last4` | String(4) | Không | 4 số cuối (nếu thẻ) |
| `card_brand` | String(20) | Không | Visa, Mastercard, v.v. |
| `card_exp_month` | Integer | Không | Tháng hết hạn (1-12) |
| `card_exp_year` | Integer | Không | Năm hết hạn |
| `bank_name` | String(100) | Không | Tên ngân hàng (nếu TK ngân hàng) |
| `bank_account_last4` | String(4) | Không | 4 số cuối TK |
| `billing_address` | JSON | Không | Chi tiết địa chỉ |
| `status` | Enum | Có | ACTIVE / EXPIRED / FAILED |
| `verified_at` | DateTime | Không | Khi được xác minh |
| `last_used_at` | DateTime | Không | Sử dụng gần nhất |
| `created_at` | DateTime | Có | Không thay đổi |

---

### 4. WithdrawalRequest (Yêu cầu Rút tiền)

> **Định nghĩa**: Yêu cầu của supplier chuyển tiền về tài khoản ngân hàng.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `wallet_id` | UUID | Có | Ví supplier |
| `supplier_id` | UUID | Có | Người yêu cầu |
| `amount` | Decimal(12,2) | Có | Số tiền rút |
| `currency` | String(3) | Có | Mã ISO 4217 |
| `fee_amount` | Decimal(12,2) | Có | Phí rút tiền |
| `tax_amount` | Decimal(12,2) | Có | Thuế khấu trừ |
| `net_amount` | Decimal(12,2) | Có | amount - fee - tax |
| `bank_account_name` | String(100) | Có | Tên người nhận |
| `bank_account_number` | String(50) | Có | Số tài khoản (mã hóa) |
| `bank_routing_number` | String(20) | Có | Mã routing/SWIFT |
| `bank_name` | String(100) | Có | Tên ngân hàng |
| `bank_country` | String(2) | Có | Mã quốc gia ISO |
| `status` | Enum | Có | Xem [Trạng thái Rút tiền](#trạng-thái-rút-tiền) |
| `requested_at` | DateTime | Có | Khi gửi yêu cầu |
| `approved_at` | DateTime | Không | Khi admin duyệt |
| `approved_by` | UUID | Không | Admin duyệt |
| `processed_at` | DateTime | Không | Khi thanh toán gửi |
| `completed_at` | DateTime | Không | Khi xác nhận nhận được |
| `failed_at` | DateTime | Không | Khi thất bại |
| `failure_reason` | String(200) | Không | Lý do thất bại |
| `reference_number` | String(50) | Không | Mã tham chiếu ngân hàng |
| `retry_count` | Integer | Có | Số lần thử lại (mặc định: 0) |

#### Trạng thái Rút tiền

```
Luồng bình thường:
PENDING → APPROVED → PROCESSING → COMPLETED

Luồng thất bại và thử lại:
PENDING → APPROVED → PROCESSING → FAILED → RETRY → PROCESSING → COMPLETED

Luồng hủy:
PENDING → CANCELLED

Giải thích:
• PENDING: Chờ duyệt admin (< $5k: tự động, >= $5k: thủ công)
• APPROVED: Đã duyệt, chuẩn bị xử lý
• PROCESSING: Đang gửi chuyển khoản ngân hàng
• COMPLETED: Tiền đã đến tài khoản (3-5 ngày)
• FAILED: Lỗi (TK sai, TK đóng, v.v.)
• RETRY: Thử lại sau khi sửa lỗi
• CANCELLED: Hủy bởi user/admin
```

---

### 5. RefundRequest (Yêu cầu Hoàn tiền)

> **Định nghĩa**: Yêu cầu hoàn tiền của advertiser.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `wallet_id` | UUID | Có | Ví advertiser |
| `advertiser_id` | UUID | Có | Người yêu cầu |
| `campaign_id` | UUID | Không | Chiến dịch liên quan (nếu có) |
| `amount` | Decimal(12,2) | Có | Số tiền hoàn |
| `refund_type` | Enum | Có | CAMPAIGN_CANCELLED / UNUSED_BUDGET / DISPUTE / OTHER |
| `reason` | Text | Có | Lý do yêu cầu hoàn tiền |
| `status` | Enum | Có | PENDING / APPROVED / REJECTED / COMPLETED |
| `requested_at` | DateTime | Có | Khi gửi yêu cầu |
| `approved_at` | DateTime | Không | Khi được duyệt |
| `approved_by` | UUID | Không | Admin duyệt |
| `processed_at` | DateTime | Không | Khi hoàn tiền phát hành |
| `rejection_reason` | String(200) | Không | Lý do từ chối |

---

### 6. DailyReconciliation (Đối soát Hàng ngày)

> **Định nghĩa**: Kiểm tra độ chính xác tài chính hàng ngày.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `reconciliation_date` | Date | Có | Ngày kinh doanh được đối soát |
| `total_deposits` | Decimal(12,2) | Có | Tổng tất cả nạp tiền |
| `total_withdrawals` | Decimal(12,2) | Có | Tổng tất cả rút tiền |
| `total_campaign_spending` | Decimal(12,2) | Có | Tổng chi tiêu chiến dịch |
| `total_supplier_revenue` | Decimal(12,2) | Có | Tổng doanh thu supplier |
| `platform_revenue` | Decimal(12,2) | Có | Phần 20% của nền tảng |
| `expected_balance` | Decimal(12,2) | Có | Tổng tính toán |
| `actual_balance` | Decimal(12,2) | Có | Tổng số dư ví thực tế |
| `discrepancy` | Decimal(12,2) | Có | expected - actual |
| `status` | Enum | Có | PENDING / BALANCED / DISCREPANCY / RESOLVED |
| `discrepancy_reason` | Text | Không | Giải thích nếu có lệch |
| `reconciled_by` | UUID | Không | Admin đối soát |
| `reconciled_at` | DateTime | Không | Khi đối soát |
| `created_at` | DateTime | Có | Không thay đổi |

---

## 🔄 Vòng đời Ví

### 1. Tạo Ví

```
Kích hoạt: Tài khoản người dùng được tạo (Advertiser hoặc Supplier)

Quy trình:
1. Tạo ví tự động:
   Wallet.create(
     user_id: new_user.id,
     user_type: new_user.type, // ADVERTISER hoặc SUPPLIER
     currency: new_user.country.default_currency HOẶC "USD",
     available_balance: 0.00,
     held_balance: 0.00,
     pending_balance: 0.00,
     status: ACTIVE
   )

2. Khởi tạo nhật ký giao dịch:
   WalletTransaction.create(
     wallet_id: wallet.id,
     transaction_type: ADJUSTMENT_CREDIT,
     amount: 0.00,
     balance_before: 0.00,
     balance_after: 0.00,
     description: "Ví được khởi tạo",
     status: COMPLETED
   )

3. Đặt giới hạn mặc định:
   NẾU user_type = ADVERTISER:
     wallet.max_balance_limit = 100,000.00 // Tối đa $100k
     wallet.min_balance_alert = 100.00     // Cảnh báo dưới $100
   NGƯỢC LẠI NẾU user_type = SUPPLIER:
     wallet.max_balance_limit = null        // Không giới hạn
     wallet.min_balance_alert = 1,000.00   // Cảnh báo dưới $1k

Quy tắc nghiệp vụ:
• Một ví mỗi người dùng (quan hệ 1:1 nghiêm ngặt)
• Tạo tự động khi đăng ký
• Số dư ban đầu luôn 0.00
• Tiền tệ dựa trên quốc gia (mặc định: USD)
• Status = ACTIVE mặc định
• Không thay đổi sau khi tạo (không xóa ví)
```

---

## 📋 Quy tắc Nghiệp vụ

### Quy tắc 1: Quản lý Số dư

#### 1.1 Các loại Số dư

**Available Balance (Số dư Khả dụng)**:
```
Định nghĩa: Tiền có thể dùng ngay cho chiến dịch hoặc rút

Đối với Advertiser:
• Có thể tạo chiến dịch bằng số dư khả dụng
• Available = tiền nạp chưa bị ký quỹ

Đối với Supplier:
• Có thể rút số dư khả dụng
• Available = doanh thu đã kiếm và đã giải phóng (không bị giữ)

Quy tắc nghiệp vụ:
• Không bao giờ âm (ràng buộc database)
• Tăng bởi: nạp tiền, hoàn tiền, giải phóng giữ
• Giảm bởi: ký quỹ chiến dịch, rút tiền, phí
```

**Held Balance (Số dư Giữ)**:
```
Định nghĩa: Tiền tạm thời bị khóa cho hoạt động đang chờ

Đối với Advertiser:
• Ngân sách chiến dịch ký quỹ khi tạo chiến dịch
• Giải phóng khi chiến dịch hoàn thành hoặc hủy

Đối với Supplier:
• Doanh thu bị giữ trong 7 ngày chống gian lận
• Impression bị tranh chấp giữ cho đến khi giải quyết

Quy tắc nghiệp vụ:
• Không bao giờ âm
• Tăng bởi: tạo chiến dịch, tranh chấp
• Giảm bởi: hoàn thành chiến dịch, giải quyết tranh chấp
• Tự động giải phóng sau thời gian giữ
```

**Pending Balance (Số dư Đang chờ)**:
```
Định nghĩa: Tiền đang bay (nạp/rút đang xử lý)

Đối với Advertiser:
• Nạp tiền đang xử lý (1-3 ngày chuyển khoản NH)
• Chuyển sang available_balance khi cleared

Đối với Supplier:
• Rút tiền đang xử lý (3-5 ngày)
• Xóa khỏi ví khi wire đã gửi

Quy tắc nghiệp vụ:
• Không bao giờ âm
• Trạng thái tạm thời (tối đa 7 ngày)
• Cảnh báo nếu pending > 7 ngày (cần điều tra)
• Hoàn lại nếu thanh toán thất bại
```

#### 1.2 Bất biến Số dư

```
Bất biến 1: Số dư không âm
available_balance >= 0
held_balance >= 0
pending_balance >= 0

Bất biến 2: Độ chính xác tổng số dư
total_balance = available_balance + held_balance + pending_balance

Bất biến 3: Tổng giao dịch bằng số dư
total_balance == SUM(all transactions.net_amount)

Bất biến 4: Số dư advertiser khớp chiến dịch
advertiser.held_balance == SUM(active_campaigns.remaining_budget)

Kiểm tra:
NẾU có bất biến bị vi phạm:
  LỖI_NGHIÊM_TRỌNG: "Vi phạm toàn vẹn số dư"
  ĐÓNG BĂNG ví
  CẢNH BÁO đội tài chính
  KÍCH HOẠT đối soát thủ công
```

---

### Quy tắc 2: Xử lý Nạp tiền

#### 2.1 Giới hạn Nạp tiền

```
Giới hạn mỗi giao dịch:
• Tối thiểu: $50.00
• Tối đa: $10,000.00 mỗi giao dịch
• Tổng tối đa hàng ngày: $50,000.00

Giới hạn theo tài khoản:
• Tài khoản chưa xác minh: Tối đa $500/ngày
• Tài khoản đã xác minh: Tối đa $10,000/ngày
• Tài khoản doanh nghiệp: Giới hạn tùy chỉnh

Giới hạn tần suất:
• Tối đa 10 giao dịch mỗi ngày
• Cooldown: 1 phút giữa các giao dịch

Kiểm tra:
NẾU top_up_amount < 50:
  LỖI: "Nạp tối thiểu $50"

NẾU top_up_amount > 10,000:
  LỖI: "Nạp tối đa $10,000 mỗi giao dịch"

NẾU daily_total + top_up_amount > daily_limit:
  LỖI: "Vượt giới hạn hàng ngày"

NẾU transactions_today >= 10:
  LỖI: "Tối đa 10 giao dịch mỗi ngày"

Quy tắc nghiệp vụ:
• Giới hạn điều chỉnh theo cấp tài khoản
• Tài khoản doanh nghiệp có giới hạn tùy chỉnh
• Mẫu đáng ngờ được gắn cờ để đánh giá
• Chạm giới hạn liên tục kích hoạt đánh giá AML
```

#### 2.2 Luồng Nạp tiền

```
Người thực hiện: Advertiser
Phương thức: Thẻ tín dụng, Thẻ ghi nợ, Chuyển khoản NH

Quy trình:
1. User khởi tạo nạp tiền:
   POST /wallet/topup
   {
     "amount": 500.00,
     "payment_method_id": "pm_xxx",
     "save_payment_method": true
   }

2. Kiểm tra:
   ✓ amount >= $50 VÀ <= $10,000
   ✓ daily_limit không vượt
   ✓ payment_method hợp lệ và active
   ✓ wallet status = ACTIVE (không đóng băng)

3. Tạo giao dịch pending:
   transaction = WalletTransaction.create(
     wallet_id: wallet.id,
     transaction_type: PENDING_DEPOSIT,
     amount: 500.00,
     status: PENDING,
     payment_method: CREDIT_CARD,
     payment_gateway: STRIPE,
     description: "Nạp tiền qua Stripe"
   )

   wallet.pending_balance += 500.00

4. Xử lý thanh toán qua gateway:
   // Ví dụ Stripe
   payment_intent = Stripe.PaymentIntent.create(
     amount: 50000, // cents
     currency: "usd",
     payment_method: payment_method_id,
     confirm: true
   )

5. Xử lý phản hồi gateway:

   Thành công (payment_intent.status = "succeeded"):
     wallet.pending_balance -= 500.00
     wallet.available_balance += 500.00

     transaction.update(
       status: COMPLETED,
       gateway_transaction_id: payment_intent.id,
       processed_at: BÂY GIỜ()
     )

     WalletTransaction.create(
       transaction_type: DEPOSIT,
       amount: 500.00,
       balance_before: previous_available,
       balance_after: wallet.available_balance,
       balance_type_affected: AVAILABLE,
       status: COMPLETED
     )

     Thông báo user: "Nạp tiền thành công: $500"

   Thất bại (payment_intent.status = "failed"):
     wallet.pending_balance -= 500.00
     // Hoàn lại số dư pending

     transaction.update(
       status: FAILED,
       processed_at: BÂY GIỜ()
     )

     Thông báo user: "Nạp tiền thất bại: {error_message}"

   Yêu cầu Hành động (3D Secure):
     // Trả URL để user xác thực
     Return {
       status: "requires_action",
       client_secret: payment_intent.client_secret
     }
     // User hoàn thành 3DS, webhook xử lý kết quả

6. Kiểm tra AML (nếu áp dụng):
   NẾU amount >= 1,000 HOẶC suspicious_pattern:
     flag_for_aml_review(transaction)

Quy tắc nghiệp vụ:
• Thanh toán xử lý qua Stripe/PayPal
• 3D Secure bắt buộc cho thẻ (quy định châu Âu)
• Pending → Available khi thanh toán cleared
• Thanh toán thất bại hoàn lại số dư pending
• Tất cả giao dịch được log (bất biến)
• User nhận thông báo kết quả (email + push)
```

---

### Quy tắc 3: Giữ Ngân sách Chiến dịch

```
Kích hoạt: Chiến dịch được tạo với ngân sách

Quy trình:
1. Kiểm tra số dư khả dụng:
   NẾU wallet.available_balance < campaign.budget:
     LỖI: "Số dư không đủ"
     Nhắc user nạp tiền

2. Tạo giao dịch giữ:
   WalletTransaction.create(
     transaction_type: CAMPAIGN_HOLD,
     amount: campaign.budget,
     reference_type: "Campaign",
     reference_id: campaign.id,
     description: "Giữ ngân sách cho chiến dịch: {campaign.name}",
     status: COMPLETED
   )

3. Chuyển tiền: available → held
   wallet.available_balance -= campaign.budget
   wallet.held_balance += campaign.budget

4. Ảnh hưởng vòng đời chiến dịch:

   Khi ghi impression:
     // Trừ từ held balance
     impression_cost = calculate_cost(impression)

     wallet.held_balance -= impression_cost
     // Không cộng vào available (đã tiêu)

     WalletTransaction.create(
       transaction_type: CAMPAIGN_CHARGE,
       amount: impression_cost,
       reference_type: "Impression",
       reference_id: impression.id,
       description: "Chi phí impression",
       status: COMPLETED
     )

     campaign.spent += impression_cost
     campaign.remaining_budget -= impression_cost

   Khi chiến dịch hoàn thành:
     // Giải phóng ngân sách chưa dùng
     unused_budget = campaign.remaining_budget

     NẾU unused_budget > 0:
       wallet.held_balance -= unused_budget
       wallet.available_balance += unused_budget

       WalletTransaction.create(
         transaction_type: RELEASE,
         amount: unused_budget,
         reference_type: "Campaign",
         reference_id: campaign.id,
         description: "Ngân sách chưa dùng đã giải phóng",
         status: COMPLETED
       )

   Khi hủy chiến dịch:
     // Hoàn tiền đầy đủ
     wallet.held_balance -= campaign.remaining_budget
     wallet.available_balance += campaign.remaining_budget

     WalletTransaction.create(
       transaction_type: REFUND,
       amount: campaign.remaining_budget,
       reference_type: "Campaign",
       reference_id: campaign.id,
       description: "Chiến dịch hủy - ngân sách hoàn lại",
       status: COMPLETED
     )

Quy tắc nghiệp vụ:
• Giữ ngân sách là atomic (all-or-nothing)
• Held balance không dùng cho chiến dịch khác
• Chi phí impression trừ từ held balance
• Ngân sách chưa dùng tự động giải phóng
• Hủy = hoàn tiền đầy đủ ngân sách còn lại
• Giao dịch hold/release được log
```

---

### Quy tắc 4: Doanh thu & Chi trả Supplier

#### 4.1 Tích lũy Doanh thu

```
Kích hoạt: Impression được xác minh

Quy trình:
1. Tính phần của supplier:
   impression_cost = 0.08 // Ví dụ
   platform_share = impression_cost × 0.20 = 0.016
   supplier_share = impression_cost × 0.80 = 0.064

2. Ghi có ví supplier (held):
   supplier_wallet.held_balance += supplier_share

   WalletTransaction.create(
     transaction_type: REVENUE,
     amount: supplier_share,
     balance_type_affected: HELD,
     reference_type: "Impression",
     reference_id: impression.id,
     description: "Doanh thu từ impression",
     status: COMPLETED
   )

3. Thời gian giữ: 7 ngày (chống gian lận)
   scheduled_release_date = impression.created_at + 7 ngày

4. Sau 7 ngày (không tranh chấp):
   supplier_wallet.held_balance -= supplier_share
   supplier_wallet.available_balance += supplier_share

   WalletTransaction.create(
     transaction_type: RELEASE,
     amount: supplier_share,
     description: "Doanh thu giải phóng sau thời gian giữ",
     status: COMPLETED
   )

5. Nếu bị tranh chấp trong 7 ngày:
   // Doanh thu ở lại trong held_balance
   // Nếu tranh chấp giữ nguyên (chargeback):
     supplier_wallet.held_balance -= supplier_share
     // Bị trừ (mất doanh thu)

     WalletTransaction.create(
       transaction_type: CHARGEBACK,
       amount: supplier_share,
       reference_type: "Dispute",
       reference_id: dispute.id,
       description: "Hoàn tiền cho impression bị tranh chấp",
       status: COMPLETED
     )

Quy tắc nghiệp vụ:
• Doanh thu ghi có ngay nhưng bị giữ
• Thời gian giữ 7 ngày để phòng gian lận
• Tự động giải phóng sau thời gian giữ
• Doanh thu bị tranh chấp giữ cho đến khi giải quyết
• Chargeback trừ từ held balance
• Supplier thấy rõ held vs available
```

#### 4.2 Rút tiền Supplier

```
Người thực hiện: Supplier
Tần suất: Bất cứ lúc nào (có giới hạn)

Yêu cầu:
• Rút tối thiểu: $50.00
• Available balance >= số tiền rút + phí
• Tài khoản ngân hàng đã xác minh
• Không có tranh chấp đang chờ

Phí Rút tiền:
• < $500: $5 phí
• $500-$5,000: $10 phí
• > $5,000: $25 phí

Khấu trừ Thuế (supplier Mỹ):
• Có W9: Không khấu trừ
• Không có W9: Khấu trừ dự phòng 24%

Quy trình:
1. Supplier yêu cầu rút tiền:
   POST /wallet/withdraw
   {
     "amount": 1000.00,
     "bank_account_id": "ba_xxx"
   }

2. Kiểm tra:
   ✓ amount >= $50
   ✓ wallet.available_balance >= amount + fee
   ✓ bank_account đã xác minh
   ✓ no_pending_disputes
   ✓ wallet status = ACTIVE

3. Tính phí và thuế:
   withdrawal_amount = 1000.00
   fee = 10.00 // Tier $500-$5k
   tax = has_w9 ? 0.00 : (1000.00 × 0.24) = 240.00
   net_amount = 1000.00 - 10.00 - 240.00 = 750.00

4. Tạo yêu cầu rút tiền:
   WithdrawalRequest.create(
     wallet_id: wallet.id,
     supplier_id: supplier.id,
     amount: 1000.00,
     fee_amount: 10.00,
     tax_amount: 240.00,
     net_amount: 750.00,
     bank_account_name: "John Doe",
     bank_account_number: "***1234",
     bank_routing_number: "123456789",
     status: PENDING
   )

5. Khóa tiền:
   wallet.available_balance -= 1000.00
   wallet.pending_balance += 1000.00

   WalletTransaction.create(
     transaction_type: PENDING_WITHDRAWAL,
     amount: 1000.00,
     balance_type_affected: PENDING,
     status: PENDING,
     description: "Yêu cầu rút tiền"
   )

6. Duyệt admin (tự động < $5k):
   NẾU withdrawal_amount < 5000:
     auto_approve()
   NGƯỢC LẠI:
     require_manual_approval()

7. Xử lý thanh toán:
   // Qua Stripe Transfer hoặc Bank API
   transfer = Stripe.Transfer.create(
     amount: 75000, // cents
     currency: "usd",
     destination: supplier.stripe_account_id
   )

   NẾU transfer.status = "paid":
     withdrawal_request.update(
       status: PROCESSING,
       processed_at: BÂY GIỜ()
     )

8. Xác nhận (3-5 ngày làm việc):
   // Webhook từ ngân hàng/Stripe
   withdrawal_request.update(
     status: COMPLETED,
     completed_at: BÂY GIỜ(),
     reference_number: bank_reference
   )

   wallet.pending_balance -= 1000.00
   // Xóa khỏi ví

   WalletTransaction.create(
     transaction_type: WITHDRAWAL,
     amount: 1000.00,
     fee_amount: 10.00,
     tax_amount: 240.00,
     net_amount: 750.00,
     status: COMPLETED,
     description: "Rút tiền hoàn thành"
   )

   Thông báo supplier: "Rút tiền hoàn thành: ${net_amount} đã gửi về NH"

9. Xử lý lỗi:
   NẾU transfer.status = "failed":
     // Hoàn lại available balance
     wallet.pending_balance -= 1000.00
     wallet.available_balance += 1000.00

     withdrawal_request.update(
       status: FAILED,
       failed_at: BÂY GIỜ(),
       failure_reason: transfer.failure_message
     )

     WalletTransaction.create(
       transaction_type: ADJUSTMENT_CREDIT,
       amount: 1000.00,
       description: "Rút tiền thất bại - đã hoàn lại",
       status: COMPLETED
     )

     Thông báo supplier: "Rút tiền thất bại: {reason}"

Quy tắc nghiệp vụ:
• Rút tối thiểu $50
• Phí rút dựa trên số tiền
• Khấu trừ thuế nếu không có form W9
• Tiền bị khóa trong khi xử lý (pending_balance)
• Tự động duyệt < $5k, thủ công >= $5k
• Thời gian xử lý: 3-5 ngày làm việc
• Rút tiền thất bại tự động hoàn lại
• Tất cả bước được log và kiểm toán được
```

---

### Quy tắc 5: Xử lý Hoàn tiền

#### 5.1 Các loại Hoàn tiền

**Hoàn tiền Tự động**:
```
1. Chiến dịch Hủy (trước khi bắt đầu):
   • Hoàn: 100% ngân sách
   • Xử lý: Ngay lập tức

2. Ngân sách Chưa dùng (chiến dịch hoàn thành):
   • Hoàn: Ngân sách còn lại
   • Xử lý: Tự động khi hoàn thành

3. Impression bị Tranh chấp (chargeback được duyệt):
   • Hoàn: Chi phí impression
   • Xử lý: Sau đánh giá admin

4. Đảo ngược Thanh toán Thất bại:
   • Hoàn: Toàn bộ số tiền
   • Xử lý: Ngay lập tức
```

**Hoàn tiền Thủ công** (yêu cầu duyệt admin):
```
1. Yêu cầu Dịch vụ Khách hàng:
   • User yêu cầu hoàn tiền vì nhiều lý do
   • Admin xem xét và duyệt/từ chối
   • Xử lý: 1-3 ngày làm việc

2. Lỗi Nền tảng:
   • Vấn đề kỹ thuật gây tính phí sai
   • Admin khởi tạo hoàn tiền
   • Xử lý: Ngay lập tức

3. Hoàn tiền Một phần:
   • Giải quyết cho tranh chấp
   • Admin chỉ định số tiền
   • Xử lý: 1-3 ngày làm việc
```

#### 5.2 Quy trình Hoàn tiền

```
Ưu tiên Phương thức Hoàn tiền:
1. Phương thức thanh toán gốc (nếu < 90 ngày)
2. Số dư ví (nếu phương thức thanh toán thất bại)
3. Chuyển khoản NH (nếu phương thức thanh toán không khả dụng)

Quy trình:
1. Tạo yêu cầu hoàn tiền:
   RefundRequest.create(
     wallet_id: wallet.id,
     advertiser_id: advertiser.id,
     campaign_id: campaign.id,
     amount: refund_amount,
     refund_type: type,
     reason: reason,
     status: PENDING
   )

2. Kiểm tra:
   ✓ Số tiền hợp lệ (> 0, <= giao dịch gốc)
   ✓ Giao dịch gốc tồn tại
   ✓ Chưa hoàn tiền
   ✓ Trong cửa sổ hoàn tiền (90 ngày cho gateway)

3. Duyệt (tự động hoặc thủ công):
   NẾU auto_refund_eligible(refund_request):
     approve_automatically()
   NGƯỢC LẠI:
     assign_to_admin_for_review()

4. Xử lý hoàn tiền:

   Tùy chọn A: Hoàn gateway (< 90 ngày)
     gateway_refund = Stripe.Refund.create(
       charge: original_charge_id,
       amount: refund_amount_cents
     )

     NẾU gateway_refund.status = "succeeded":
       wallet.pending_balance += refund_amount
       // Sẽ available khi cleared (1-3 ngày)

       WalletTransaction.create(
         transaction_type: REFUND,
         amount: refund_amount,
         payment_gateway: STRIPE,
         gateway_transaction_id: gateway_refund.id,
         status: PENDING,
         description: "Hoàn về phương thức thanh toán gốc"
       )

   Tùy chọn B: Hoàn số dư ví
     wallet.available_balance += refund_amount

     WalletTransaction.create(
       transaction_type: REFUND,
       amount: refund_amount,
       status: COMPLETED,
       description: "Hoàn tiền ghi có vào ví"
     )

5. Xác nhận:
   refund_request.update(
     status: COMPLETED,
     processed_at: BÂY GIỜ()
   )

   Thông báo advertiser: "Hoàn tiền đã xử lý: ${amount}"

Quy tắc nghiệp vụ:
• Ưu tiên hoàn về phương thức thanh toán gốc
• Ghi có ví nếu phương thức thanh toán không khả dụng
• Hoàn tiền < $1000: tự động duyệt
• Hoàn tiền >= $1000: yêu cầu duyệt admin
• Cửa sổ 90 ngày cho hoàn gateway
• Sau 90 ngày: chỉ ghi có ví
• Tất cả hoàn tiền được log và kiểm toán
• Phí hoàn tiền: không có (nền tảng chịu)
```

---

## 💱 Tiền tệ & Tỷ giá

### Quy tắc 6: Hỗ trợ Đa tiền tệ

```
Các loại tiền hỗ trợ:
• USD (United States Dollar)
• EUR (Euro)
• GBP (British Pound)
• VND (Vietnamese Dong)
• ... (có thể cấu hình)

Tiền tệ Mặc định:
• Dựa trên quốc gia của user
• User Mỹ: USD
• User Việt Nam: VND
• User EU: EUR

Chuyển đổi:
• Tỷ giá thời gian thực từ nhà cung cấp (vd: OpenExchangeRates.org)
• Tỷ giá cache 1 giờ
• Chuyển đổi tại thời điểm giao dịch (không phải hiển thị)

Quy trình:
1. User xem số dư:
   Hiển thị theo wallet.currency

2. Nạp tiền bằng tiền tệ khác:
   User trả: €100 EUR
   Ví user: USD

   conversion_rate = get_rate("EUR", "USD") // 1.08
   usd_amount = 100 × 1.08 = 108.00

   wallet.available_balance += 108.00 USD

   WalletTransaction.create(
     amount: 108.00,
     currency: "USD",
     metadata: {
       original_amount: 100.00,
       original_currency: "EUR",
       exchange_rate: 1.08
     }
   )

3. Chiến dịch đa tiền tệ:
   Tiền tệ chiến dịch: VND
   Ví advertiser: USD

   impression_cost_vnd = 100,000 VND
   conversion_rate = get_rate("VND", "USD") // 0.000041
   impression_cost_usd = 100,000 × 0.000041 = 4.10 USD

   Trừ 4.10 USD từ ví

Quy tắc nghiệp vụ:
• Ví có đơn tiền tệ (không có ví đa tiền tệ)
• Chuyển đổi tại thời điểm giao dịch
• Tỷ giá lưu trong metadata giao dịch
• Tỷ giá cập nhật mỗi giờ
• Phí chuyển đổi: không có (đã bao gồm trong tỷ giá)
• User có thể xem ước tính chuyển đổi trong dashboard
```

---

## 💼 Xử lý Thuế

### Quy tắc 7: Tính thuế & Khấu trừ

#### 7.1 Thuế Doanh thu (cho Advertiser)

```
Áp dụng:
• Advertiser ở Mỹ: Thuế doanh thu tiểu bang trên chi tiêu quảng cáo
• Advertiser ở EU: VAT trên dịch vụ
• Các khu vực khác: Theo luật thuế địa phương

Xác định Thuế suất:
• Dựa trên địa chỉ thanh toán advertiser
• Tra cứu thuế suất từ TaxJar API hoặc tương tự
• Cập nhật hàng tháng

Tính toán:
campaign_budget = 1000.00
tax_rate = get_tax_rate(advertiser.billing_address) // vd: 8.25%
tax_amount = 1000.00 × 0.0825 = 82.50
total_charge = 1000.00 + 82.50 = 1082.50

// User trả total_charge
// Ngân sách chiến dịch = 1000.00 (trước thuế)
// Thuế nộp cho cơ quan

WalletTransaction.create(
  transaction_type: TAX_WITHHOLDING,
  amount: 82.50,
  description: "Thuế doanh thu (8.25%)",
  metadata: {
    tax_type: "SALES_TAX",
    tax_rate: 0.0825,
    jurisdiction: "California"
  }
)

Quy tắc nghiệp vụ:
• Thuế tính khi tạo chiến dịch
• Thuế hiển thị riêng trong hóa đơn
• Thuế nộp cho cơ quan hàng tháng
• Tài khoản miễn thuế (có giấy chứng nhận) được miễn
```

#### 7.2 Khấu trừ Thuế (cho Supplier)

```
Áp dụng:
• Supplier Mỹ không có form W-9: Khấu trừ dự phòng 24%
• Supplier ngoài Mỹ: Khấu trừ 30% (trừ khi có hiệp định)

Khấu trừ khi Thanh toán:
supplier_revenue = 1000.00

NẾU supplier.has_w9:
  withholding = 0.00
NGƯỢC LẠI NẾU supplier.country = "US":
  withholding = 1000.00 × 0.24 = 240.00
NGƯỢC LẠI NẾU supplier.country TRONG tax_treaty_countries:
  withholding = 1000.00 × treaty_rate
NGƯỢC LẠI:
  withholding = 1000.00 × 0.30 = 300.00

net_payout = 1000.00 - withholding

WalletTransaction.create(
  transaction_type: TAX_WITHHOLDING,
  amount: withholding,
  description: "Khấu trừ thuế (24%)",
  metadata: {
    tax_type: "BACKUP_WITHHOLDING",
    tax_rate: 0.24
  }
)

// Supplier nhận net_payout
// Withholding nộp cho IRS

Báo cáo cuối năm:
• Form 1099 phát hành cho supplier Mỹ
• Form 1042-S phát hành cho supplier ngoài Mỹ
• Tổng khấu trừ + tổng trả được báo cáo

Quy tắc nghiệp vụ:
• Khấu trừ áp dụng khi rút tiền
• Nộp W-9 ngừng khấu trừ
• Tôn trọng thuế suất theo hiệp định
• Số tiền khấu trừ báo cáo cho cơ quan thuế
• Form phát hành trước 31 tháng 1
```

---

## 📊 Đối soát Tài chính

### Quy tắc 8: Đối soát Hàng ngày

```
Lịch trình: Hàng ngày lúc 00:00 UTC

Mục đích: Xác minh độ chính xác tài chính

Quy trình:
1. Tính tổng dự kiến:
   expected_balance = (
     opening_balance +
     total_deposits -
     total_withdrawals -
     total_fees
   )

2. Tính tổng thực tế:
   actual_balance = SUM(
     wallet.available_balance +
     wallet.held_balance +
     wallet.pending_balance
     CHO TẤT CẢ ví
   )

3. So sánh:
   discrepancy = expected_balance - actual_balance

4. Kiểm tra giao dịch:
   transaction_sum = SUM(
     transactions.net_amount
     WHERE date = yesterday
   )

   NẾU transaction_sum != (deposits - withdrawals - fees):
     GẮN CỜ discrepancy

5. Ghi nhận đối soát:
   DailyReconciliation.create(
     reconciliation_date: yesterday,
     total_deposits: deposits,
     total_withdrawals: withdrawals,
     expected_balance: expected_balance,
     actual_balance: actual_balance,
     discrepancy: discrepancy,
     status: discrepancy == 0 ? BALANCED : DISCREPANCY
   )

6. Cảnh báo nếu có lệch:
   NẾU abs(discrepancy) > 0.01: // > 1 cent
     send_alert(finance_team, "Lệch đối soát: ${discrepancy}")
     require_investigation()

7. Điều tra:
   • Xem xét tất cả giao dịch của hôm qua
   • Kiểm tra giao dịch thất bại/pending
   • Xác minh webhook gateway đã nhận
   • Kiểm tra race condition
   • Kiểm toán thủ công nếu cần

8. Giải quyết:
   NẾU discrepancy_resolved:
     DailyReconciliation.update(
       status: RESOLVED,
       discrepancy_reason: explanation,
       reconciled_by: admin.id,
       reconciled_at: BÂY GIỜ()
     )

Quy tắc nghiệp vụ:
• Đối soát chạy tự động hàng ngày
• Lệch được điều tra ngay lập tức
• Chấp nhận ±$0.01 (lỗi làm tròn)
• Lệch lớn hơn dừng hoạt động cho đến khi giải quyết
• Tất cả đối soát có thể kiểm toán
• Đối soát hàng tháng tổng hợp kết quả hàng ngày
```

---

## 🛡️ Chống Rửa tiền (AML)

### Quy tắc 9: Tuân thủ AML

#### 9.1 Giám sát Giao dịch

```
Chỉ báo Hoạt động Đáng ngờ:

1. Giao dịch Đơn Lớn:
   NẾU deposit >= $10,000:
     flag_for_aml_review("Nạp tiền lớn")

2. Cấu trúc hóa (Smurfing):
   deposits_today = SUM(deposits WHERE date = today)
   NẾU deposits_today >= $10,000:
     VÀ max_single_deposit < $5,000:
       flag_for_aml_review("Có thể cấu trúc hóa")

3. Ra vào Nhanh:
   NẾU deposit_today > $5,000:
     VÀ withdrawal_within_24h > $4,000:
       flag_for_aml_review("Ra vào nhanh")

4. Mẫu Bất thường:
   NẾU typical_monthly_deposit < $1,000:
     VÀ current_deposit > $10,000:
       flag_for_aml_review("Mẫu bất thường")

5. Khu vực Rủi ro Cao:
   NẾU user.country TRONG high_risk_countries:
     flag_for_aml_review("Khu vực rủi ro cao")

Hành động khi Gắn cờ:
1. Giao dịch bị giữ (pending_balance)
2. Đội tuân thủ được thông báo
3. Yêu cầu tài liệu bổ sung:
   • Nguồn tiền
   • Lý do kinh doanh
   • Xác minh danh tính
4. Đánh giá trong 24-48 giờ
5. Duyệt hoặc từ chối

Duyệt:
  Giải phóng tiền về available_balance
  Xóa cờ

Từ chối:
  Hoàn tiền về nguồn thanh toán
  Đóng tài khoản nếu vi phạm lặp lại
```

#### 9.2 Biết Khách hàng của Bạn (KYC)

```
Các cấp Xác minh:

Cấp 1 (Cơ bản):
• Email đã xác minh
• Giới hạn: $500/ngày
• Yêu cầu: Chỉ email

Cấp 2 (Đã xác minh):
• Danh tính đã xác minh (giấy tờ ID)
• Giới hạn: $10,000/ngày
• Yêu cầu: ID chính phủ + Ảnh selfie

Cấp 3 (Doanh nghiệp):
• Doanh nghiệp đã xác minh
• Giới hạn: Tùy chỉnh
• Yêu cầu: Đăng ký KD + Mã số thuế

Quy trình Xác minh:
1. User upload tài liệu
2. Dịch vụ xác minh danh tính (vd: Stripe Identity)
3. Kiểm tra tự động:
   • Tính xác thực tài liệu
   • Khớp khuôn mặt
   • Kiểm tra database (danh sách trừng phạt, PEP)
4. Đánh giá thủ công nếu gắn cờ
5. Duyệt cấp giới hạn cao hơn

Quy tắc nghiệp vụ:
• Tài khoản chưa xác minh giới hạn $500/ngày
• Xác minh bắt buộc cho giới hạn cao hơn
• Xác minh lại mỗi 2 năm
• Due diligence nâng cao cho >$50k/tháng
• PEP (Politically Exposed Person) gắn cờ để đánh giá
• Kiểm tra danh sách trừng phạt tự động
```

---

## ⚠️ Các trường hợp đặc biệt

### Trường hợp 1: Nạp tiền Đồng thời

```
Tình huống: User gửi 2 yêu cầu nạp tiền cùng lúc

Race Condition:
  Giao dịch A: Nạp $500
  Giao dịch B: Nạp $500
  Giới hạn hàng ngày: $1,000

Không có lock:
  Cả hai kiểm tra daily_total = $0
  Cả hai tiếp tục (tổng = $1,000) → OK
  Nhưng nếu Giao dịch C cũng: tổng = $1,500 → VI PHẠM

Giải pháp: Khóa cấp database
BEGIN TRANSACTION;
SELECT available_balance FROM wallets
WHERE id = X
FOR UPDATE; // Khóa cấp row

daily_total = get_daily_total_with_lock(user_id)
NẾU daily_total + amount > daily_limit:
  ROLLBACK;
  LỖI: "Vượt giới hạn hàng ngày"
NGƯỢC LẠI:
  wallet.available_balance += amount
  COMMIT;

Quy tắc nghiệp vụ:
• Dùng khóa cấp row cho cập nhật số dư
• Thao tác atomic (all-or-nothing)
• Thử lại giao dịch thất bại (exponential backoff)
```

### Trường hợp 2: Trзадержка Webhook Cổng thanh toán

```
Tình huống: Thanh toán thành công nhưng webhook bị trễ

Timeline:
  T+0s: User gửi nạp tiền
  T+1s: Thanh toán thành công tại Stripe
  T+2s: Giao dịch pending được tạo
  T+3600s: Webhook đến (trễ 1 giờ)

Vấn đề: Số dư user hiển thị pending trong 1 giờ

Giải pháp: Webhook + Polling Kết hợp
1. Tạo giao dịch pending ngay lập tức
2. Poll trạng thái thanh toán mỗi 30 giây (timeout: 5 phút)
3. Nếu status = succeeded:
     Xử lý ngay (không đợi webhook)
4. Webhook là backup/xác nhận

Quy tắc nghiệp vụ:
• Poll tối đa 5 phút
• Webhook là nguồn chân lý (ghi đè poll nếu xung đột)
• Cảnh báo nếu webhook không nhận trong 1 giờ
```

### Trường hợp 3: Tài khoản NH Rút tiền Bị đóng

```
Tình huống: TK ngân hàng supplier đóng, rút tiền thất bại

Quy trình:
1. Rút tiền khởi tạo:
   wallet.available_balance -= 1000
   wallet.pending_balance += 1000

2. Thử chuyển khoản ngân hàng
3. Ngân hàng trả lỗi: "Tài khoản đóng"

4. Xử lý lỗi:
   wallet.pending_balance -= 1000
   wallet.available_balance += 1000

   withdrawal_request.update(
     status: FAILED,
     failure_reason: "Tài khoản ngân hàng đóng"
   )

   Thông báo supplier: "Rút tiền thất bại - vui lòng cập nhật TK NH"

5. Supplier cập nhật TK ngân hàng
6. Thử rút tiền lại

Quy tắc nghiệp vụ:
• Rút tiền thất bại tự động hoàn lại
• User nhận thông báo với lý do cụ thể
• Có thể thử lại sau khi cập nhật thông tin NH
• Tối đa 3 lần thử lại
• Sau 3 lần thất bại: yêu cầu can thiệp thủ công
```

---

## ✅ Quy tắc Kiểm tra

### Ma trận Kiểm tra Ví

| Trường | Quy tắc | Thông báo lỗi |
|--------|---------|---------------|
| `amount` | > 0 | "Số tiền phải dương" |
| `amount` | Tối đa 2 số thập phân | "Số tiền không thể có quá 2 số thập phân" |
| `top_up_amount` | >= $50 | "Nạp tối thiểu $50" |
| `top_up_amount` | <= $10,000 | "Nạp tối đa $10,000 mỗi giao dịch" |
| `withdrawal_amount` | >= $50 | "Rút tối thiểu $50" |
| `withdrawal_amount` | <= available_balance | "Số dư không đủ" |
| `currency` | Mã ISO 4217 | "Mã tiền tệ không hợp lệ" |
| `balance` | >= 0 | "Số dư không thể âm" |

---

## 🧮 Công thức Tính toán

### Tổng hợp Công thức

#### 1. Tổng Số dư

```
total_balance = available_balance + held_balance + pending_balance

Phải bằng: SUM(all transactions.net_amount)
```

#### 2. Số tiền Giao dịch Ròng

```
net_amount = amount - fee_amount - tax_amount

Ví dụ:
  Rút tiền: $1,000
  Phí: $10
  Thuế: $240
  Ròng: $1,000 - $10 - $240 = $750
```

#### 3. Phần Doanh thu Supplier

```
supplier_revenue = impression_cost × 0.80
platform_revenue = impression_cost × 0.20

Ví dụ:
  Chi phí impression: $0.10
  Supplier: $0.08
  Nền tảng: $0.02
```

#### 4. Đối soát Hàng ngày

```
expected_balance = (
  opening_balance +
  SUM(deposits) -
  SUM(withdrawals) -
  SUM(fees) -
  SUM(taxes)
)

discrepancy = expected_balance - actual_balance

Chấp nhận nếu: abs(discrepancy) <= $0.01
```

#### 5. Phí Rút tiền

```
fee = CASE withdrawal_amount
  KHI < $500: $5
  KHI $500-$5,000: $10
  KHI > $5,000: $25
```

#### 6. Khấu trừ Thuế

```
Supplier Mỹ không có W-9:
  withholding = amount × 0.24

Supplier ngoài Mỹ không có hiệp định:
  withholding = amount × 0.30

Có hiệp định:
  withholding = amount × treaty_rate
```

---

## 📚 Phụ lục: Ví dụ Giao dịch

### Ví dụ 1: Luồng Nạp tiền Hoàn chỉnh

```
Trạng thái ban đầu:
  available_balance: $100.00

1. User nạp $500:
   pending_balance += $500 → $500.00
   Giao dịch: PENDING_DEPOSIT, $500

2. Thanh toán cleared:
   pending_balance -= $500 → $0.00
   available_balance += $500 → $600.00
   Giao dịch: DEPOSIT, $500

Trạng thái cuối:
  available_balance: $600.00
  Số giao dịch: 2
```

### Ví dụ 2: Luồng Ngân sách Chiến dịch

```
Trạng thái ban đầu:
  available_balance: $600.00

1. Tạo chiến dịch (ngân sách $500):
   available_balance -= $500 → $100.00
   held_balance += $500 → $500.00
   Giao dịch: CAMPAIGN_HOLD, $500

2. Ghi impression ($300 chi):
   held_balance -= $300 → $200.00
   Giao dịch: CAMPAIGN_CHARGE × N (tổng $300)

3. Chiến dịch hoàn thành ($200 chưa dùng):
   held_balance -= $200 → $0.00
   available_balance += $200 → $300.00
   Giao dịch: RELEASE, $200

Trạng thái cuối:
  available_balance: $300.00
  held_balance: $0.00
  Chi chiến dịch: $300
```

### Ví dụ 3: Luồng Thanh toán Supplier

```
Trạng thái ban đầu:
  available_balance: $1,000.00

1. Yêu cầu rút $1,000:
   available_balance -= $1,000 → $0.00
   pending_balance += $1,000 → $1,000.00
   Giao dịch: PENDING_WITHDRAWAL, $1,000

2. Trừ phí và thuế:
   Phí: $10
   Thuế (không có W-9): $240
   Ròng: $750

3. Wire đã gửi:
   pending_balance -= $1,000 → $0.00
   Giao dịch: WITHDRAWAL, $1,000
   Giao dịch: FEE, $10
   Giao dịch: TAX_WITHHOLDING, $240

Trạng thái cuối:
  available_balance: $0.00
  pending_balance: $0.00
  Ngân hàng nhận: $750
```

---

## 📚 Bảng thuật ngữ

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Wallet (Ví)** | Tài khoản kỹ thuật số chứa tiền |
| **Available Balance** | Tiền có thể dùng ngay |
| **Held Balance** | Tiền bị khóa tạm thời (ký quỹ) |
| **Pending Balance** | Tiền đang xử lý (nạp/rút) |
| **Top-up** | Nạp tiền vào ví |
| **Withdrawal** | Rút tiền từ ví về ngân hàng |
| **Transaction** | Bản ghi thay đổi số dư |
| **Gateway** | Cổng thanh toán (Stripe, PayPal) |
| **Reconciliation** | Đối soát tài chính |
| **AML** | Anti-Money Laundering (Chống rửa tiền) |
| **KYC** | Know Your Customer (Biết khách hàng) |
| **Chargeback** | Hoàn tiền tranh chấp |

---

## 📚 Tham khảo

### Tài liệu liên quan

| Tài liệu | Mô tả |
|----------|-------|
| [Từ điển Thuật ngữ](./00-tu-dien-thuat-ngu.md) | Giải thích tất cả thuật ngữ |
| [Quy tắc Chiến dịch](./04-quy-tac-chien-dich.md) | Quản lý ngân sách chiến dịch |
| [Quy tắc Advertiser](./08-quy-tac-nha-quang-cao.md) | Tài khoản & ví advertiser |
| [Quy tắc Supplier](./09-quy-tac-nha-cung-cap.md) | Doanh thu & thanh toán supplier |

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team  
**Trạng thái**: Sẵn sàng để review

**Bước tiếp theo**:
1. Đánh giá với stakeholder
2. Đánh giá đội tài chính
3. Đánh giá tuân thủ (AML/KYC)
4. Lập kế hoạch tích hợp cổng thanh toán