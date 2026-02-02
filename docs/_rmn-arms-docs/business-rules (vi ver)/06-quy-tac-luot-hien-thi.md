# 📊 Quy tắc Nghiệp vụ: Ghi nhận Lượt hiển thị

**Phiên bản**: 1.0  
**Ngày**: 2026-01-23  
**Trạng thái**: Bản nháp  
**Chủ quản**: Product Team

---

## 📖 Mục lục

1. [Tổng quan](#-tổng-quan)
2. [Các thực thể Domain](#-các-thực-thể-domain)
3. [Vòng đời Impression](#-vòng-đời-impression)
4. [Quy tắc Nghiệp vụ](#-quy-tắc-nghiệp-vụ)
5. [Đặc tả Proof-of-Play](#-đặc-tả-proof-of-play)
6. [Xác minh & Kiểm tra](#-xác-minh--kiểm-tra)
7. [Phát hiện Gian lận](#-phát-hiện-gian-lận)
8. [Chấm điểm Chất lượng](#-chấm-điểm-chất-lượng)
9. [Tranh chấp & Hoàn tiền](#-tranh-chấp--hoàn-tiền)
10. [Các trường hợp đặc biệt](#-các-trường-hợp-đặc-biệt)
11. [Quy tắc Kiểm tra](#-quy-tắc-kiểm-tra)
12. [Công thức Tính toán](#-công-thức-tính-toán)

---

## 🎯 Tổng quan

### Mục đích

Tài liệu này mở rộng quy tắc ghi nhận impression từ module Campaign, cung cấp chi tiết toàn diện về xác minh, phát hiện gian lận, chấm điểm chất lượng và giải quyết tranh chấp.

### Phạm vi

**Bao gồm:**
- ✅ Ghi nhận và kiểm tra impression
- ✅ Yêu cầu proof-of-play
- ✅ State machine xác minh
- ✅ Thuật toán phát hiện gian lận
- ✅ Hệ thống chấm điểm chất lượng
- ✅ Quy trình tranh chấp và hoàn tiền

**KHÔNG bao gồm:**
- ❌ Quản lý chiến dịch (xem module Campaign)
- ❌ Quản lý thiết bị (xem module Device)
- ❌ Tính phí chi tiết (xem module Campaign)

### Khái niệm Chủ chốt

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Impression** | Lần phát quảng cáo được xác minh |
| **Proof-of-Play** | Bằng chứng quảng cáo thực sự được hiển thị |
| **Verification** | Quy trình xác thực tính xác thực impression |
| **Quality Score** | Chỉ số giá trị/độ tin cậy impression |
| **Dispute** | Thách thức tính hợp lệ impression bởi advertiser |

---

## 📦 Các thực thể Domain

### 1. Impression (Mở rộng)

> **Định nghĩa**: Sự kiện phát nội dung quảng cáo được xác minh trên thiết bị.

#### Các thuộc tính Mở rộng (ngoài module Campaign)

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `verification_status` | Enum | Có | PENDING/VERIFIED/REJECTED/UNDER_REVIEW/DISPUTED |
| `verification_timestamp` | DateTime | Không | Khi xác minh hoàn thành |
| `verification_method` | Enum | Có | AUTOMATIC/MANUAL/HYBRID |
| `quality_score` | Integer | Có | 0-100, chỉ số chất lượng tính toán |
| `fraud_flags` | JSON | Có | Mảng các cờ phát hiện gian lận |
| `fraud_score` | Integer | Có | 0-100 (0=sạch, 100=chắc chắn gian lận) |
| `proof_screenshot_url` | String(500) | Không | S3 URL screenshot (tạm, 30 ngày) |
| `proof_screenshot_hash` | String(64) | Có | SHA256 hash của screenshot |
| `proof_device_signature` | Text | Có | Chữ ký RSA từ thiết bị |
| `proof_gps_lat` | Decimal(10,8) | Không | GPS latitude tại thời điểm phát |
| `proof_gps_lng` | Decimal(11,8) | Không | GPS longitude tại thời điểm phát |
| `proof_gps_accuracy` | Integer | Không | Độ chính xác GPS (mét) |
| `attention_score` | Integer | Không | 0-100 nếu dùng AI phát hiện chú ý |
| `viewability_score` | Integer | Có | 0-100 phần trăm màn hình nhìn thấy |
| `audio_enabled` | Boolean | Có | Âm thanh có bật không |
| `environment_brightness` | Integer | Không | Đọc cảm biến ánh sáng môi trường |
| `distance_from_store` | Integer | Không | Mét từ vị trí cửa hàng đăng ký |
| `time_drift_seconds` | Integer | Có | Chênh lệch giữa giờ thiết bị và server |
| `verification_notes` | Text | Không | Ghi chú admin nếu đánh giá thủ công |
| `rejected_reason` | String(200) | Không | Tại sao xác minh thất bại |
| `dispute_id` | UUID | Không | Link đến tranh chấp nếu bị thách thức |
| `chargeback_at` | DateTime | Không | Khi hoàn tiền được phát hành |
| `chargeback_reason` | String(200) | Không | Lý do hoàn tiền |

---

### 2. ImpressionVerificationLog (Nhật ký Xác minh)

> **Định nghĩa**: Nhật ký chi tiết quy trình xác minh để kiểm toán.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `impression_id` | UUID | Có | Link đến impression |
| `step` | String(50) | Có | Tên bước xác minh |
| `status` | Enum | Có | PASS/FAIL/SKIP/WARN |
| `check_type` | Enum | Có | SIGNATURE/TIMESTAMP/DURATION/LOCATION/DUPLICATE |
| `expected_value` | Text | Không | Giá trị mong đợi |
| `actual_value` | Text | Không | Giá trị tìm thấy |
| `result_message` | Text | Có | Kết quả dễ đọc |
| `severity` | Enum | Có | INFO/WARNING/ERROR/CRITICAL |
| `processing_time_ms` | Integer | Có | Thời gian hoàn thành kiểm tra này |
| `created_at` | DateTime | Có | Không thay đổi |

---

### 3. ImpressionQualityMetrics (Chỉ số Chất lượng)

> **Định nghĩa**: Chỉ số chất lượng chi tiết để chấm điểm impression.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `impression_id` | UUID | Có | Link đến impression |
| `viewability_score` | Integer | Có | 0-100% nội dung nhìn thấy |
| `completion_rate` | Decimal(5,2) | Có | % nội dung đã phát |
| `attention_score` | Integer | Không | Chú ý AI phát hiện (0-100) |
| `audio_enabled` | Boolean | Có | Âm thanh có bật không |
| `screen_brightness` | Integer | Không | Độ sáng màn hình % |
| `environment_brightness` | Integer | Không | Mức độ ánh sáng môi trường |
| `device_orientation_correct` | Boolean | Có | Nội dung khớp hướng màn hình |
| `network_quality` | Enum | Có | EXCELLENT/GOOD/FAIR/POOR |
| `playback_smoothness` | Integer | Không | 0-100, không buffering/giật |
| `timestamp_accuracy` | Integer | Có | Lệch thời gian (giây) |
| `location_accuracy` | Integer | Không | Độ chính xác GPS (mét) |
| `proof_quality` | Integer | Có | 0-100, độ đầy đủ proof |
| `overall_quality_score` | Integer | Có | Điểm cuối tính toán (0-100) |
| `quality_tier` | Enum | Có | PREMIUM/STANDARD/BASIC/POOR |
| `created_at` | DateTime | Có | Không thay đổi |

---

### 4. ImpressionDispute (Tranh chấp Impression)

> **Định nghĩa**: Advertiser thách thức tính hợp lệ impression.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `impression_id` | UUID | Có | Impression bị tranh chấp |
| `campaign_id` | UUID | Có | Chiến dịch liên quan |
| `advertiser_id` | UUID | Có | Người nộp tranh chấp |
| `dispute_type` | Enum | Có | Xem [Loại Tranh chấp](#loại-tranh-chấp) |
| `reason` | Text | Có | Giải thích chi tiết |
| `evidence` | JSON | Không | URL bằng chứng hỗ trợ |
| `status` | Enum | Có | PENDING/INVESTIGATING/RESOLVED/REJECTED |
| `priority` | Enum | Có | LOW/NORMAL/HIGH/URGENT |
| `assigned_to` | UUID | Không | Admin điều tra |
| `investigation_notes` | Text | Không | Phát hiện của admin |
| `resolution` | Enum | Không | CHARGEBACK_APPROVED/CHARGEBACK_DENIED/PARTIAL_REFUND |
| `refund_amount` | Decimal(10,4) | Không | Số tiền hoàn lại |
| `supplier_penalty` | Decimal(10,4) | Không | Số tiền trừ từ supplier |
| `filed_at` | DateTime | Có | Khi tranh chấp mở |
| `resolved_at` | DateTime | Không | Khi tranh chấp đóng |
| `resolution_time_hours` | Integer | Không | Tính: resolved_at - filed_at |

#### Loại Tranh chấp

```
INVALID_PROOF         → Screenshot/chữ ký không hợp lệ
DEVICE_OFFLINE        → Thiết bị đã offline tại thời điểm báo cáo
WRONG_LOCATION        → Thiết bị xa vị trí cửa hàng
DUPLICATE             → Cùng impression báo cáo nhiều lần
CONTENT_MISMATCH      → Nội dung sai được hiển thị
TIME_MANIPULATION     → Timestamp xuất hiện bị thao túng
QUALITY_ISSUE         → Chất lượng phát kém
OTHER                 → Lý do khác (yêu cầu giải thích chi tiết)
```

---

### 5. FraudDetectionRule (Quy tắc Phát hiện Gian lận)

> **Định nghĩa**: Quy tắc phát hiện gian lận có thể cấu hình.

#### Các thuộc tính

| Trường | Kiểu | Bắt buộc | Quy tắc nghiệp vụ |
|--------|------|----------|-------------------|
| `id` | UUID | Có | Tự động tạo |
| `rule_name` | String(100) | Có | Tên dễ đọc |
| `rule_type` | Enum | Có | FREQUENCY/LOCATION/TIMING/PATTERN/SIGNATURE |
| `description` | Text | Có | Quy tắc này phát hiện gì |
| `severity` | Enum | Có | LOW/MEDIUM/HIGH/CRITICAL |
| `threshold_value` | Decimal(10,2) | Có | Ngưỡng kích hoạt |
| `time_window_minutes` | Integer | Không | Cửa sổ thời gian trượt |
| `action_on_trigger` | Enum | Có | LOG/FLAG/HOLD/REJECT/SUSPEND |
| `is_active` | Boolean | Có | Có thể vô hiệu hóa |
| `false_positive_rate` | Decimal(5,2) | Không | Chỉ số giám sát |
| `true_positive_rate` | Decimal(5,2) | Không | Chỉ số giám sát |
| `triggered_count` | Integer | Có | Số lần quy tắc này kích hoạt |
| `last_triggered_at` | DateTime | Không | Lần kích hoạt gần nhất |
| `created_by` | UUID | Có | Admin tạo |
| `created_at` | DateTime | Có | Không thay đổi |

---

## 🔄 Vòng đời Impression

### State Machine Xác minh

```
                    [Thiết bị Gửi]
                          ↓
                    ┌─────────┐
                    │ PENDING │ (Trạng thái ban đầu)
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        ↓                ↓                ↓
   [Tất cả         [Đáng ngờ]       [Lỗi nghiêm
    kiểm tra                           trọng]
    đạt]                ↓                ↓
        ↓         ┌──────────────┐  ┌──────────┐
   ┌─────────┐    │ UNDER_REVIEW │  │ REJECTED │
   │VERIFIED │    └──────┬───────┘  └──────────┘
   └────┬────┘           │
        │         [Quyết định admin]
        │                │
        │         ┌──────┴──────┐
        │         ↓             ↓
        │    ┌─────────┐   ┌──────────┐
        │    │VERIFIED │   │ REJECTED │
        │    └─────────┘   └──────────┘
        │
 [Advertiser
  tranh chấp]
        ↓
   ┌─────────┐
   │DISPUTED │
   └────┬────┘
        │
 [Admin giải quyết]
        │
   ┌────┴─────┐
   ↓          ↓
[Giữ nguyên] [Đảo ngược]
   │          │
   ↓          ↓
┌─────────┐ ┌──────────┐
│VERIFIED │ │ REJECTED │
└─────────┘ └──────────┘
             +hoàn tiền
```

### Mô tả Trạng thái

**PENDING** (Ban đầu):
```
• Thời lượng: < 5 giây (kiểm tra tự động)
• Xác thực tự động đang tiến hành
• Chưa hiển thị trong dashboard advertiser
• Chưa ảnh hưởng billing
```

**VERIFIED** (Kết thúc - Thành công):
```
• Tất cả kiểm tra xác thực đạt
• Billing xác nhận (chi phí đã trừ)
• Doanh thu supplier đã ghi nhận
• Đếm vào chỉ số chiến dịch
• Vẫn có thể tranh chấp (cửa sổ 30 ngày)
```

**REJECTED** (Kết thúc - Thất bại):
```
• Không đạt kiểm tra xác thực
• Không billing (chi phí không tính)
• Không có doanh thu supplier
• Ghi log để khắc phục thiết bị
• Lý do lưu trong trường rejected_reason
```

**UNDER_REVIEW** (Trung gian):
```
• Thời lượng: Lên đến 24 giờ
• Kích hoạt bởi các mẫu đáng ngờ
• Yêu cầu đánh giá thủ công admin
• Billing tạm giữ
• Thiết bị được thông báo trạng thái đánh giá
```

**DISPUTED** (Sau xác minh):
```
• Advertiser thách thức impression
• Điều tra đang tiến hành
• Billing giữ/đảo ngược chờ giải quyết
• Admin đánh giá bằng chứng
• Giải quyết: Giữ nguyên (VERIFIED) hoặc Đảo ngược (REJECTED + hoàn tiền)
```

---

## 📋 Quy tắc Nghiệp vụ

### Quy tắc 1: Tiêu chí Ghi nhận Impression

#### 1.1 Thời lượng Phát Tối thiểu

```
Quy tắc: Impression chỉ được ghi nhận nếu nội dung phát ≥ 80% thời lượng

Công thức:
minimum_duration = content.duration × 0.80

Kiểm tra:
IF impression.duration_actual >= minimum_duration:
  Ghi nhận impression
ELSE:
  Từ chối với "INSUFFICIENT_DURATION"

Ví dụ:
  Thời lượng nội dung: 30 giây
  Tối thiểu yêu cầu: 30 × 0.80 = 24 giây

  Trường hợp 1: Phát 25 giây → ✓ Ghi nhận impression
  Trường hợp 2: Phát 20 giây → ✗ Từ chối (quá ngắn)
  Trường hợp 3: Phát 30 giây → ✓ Ghi nhận impression (100%)

Quy tắc nghiệp vụ:
• Ngưỡng 80% ngăn phát tình cờ/không hoàn chỉnh
• Impression một phần không được đếm
• Thiết bị phải báo thời lượng thực tế
• Server xác thực độ chính xác thời lượng
```

---

#### 1.2 Cửa sổ Hợp lệ Timestamp

```
Quy tắc: Timestamp impression phải trong giới hạn hợp lý

Kiểm tra phía Server:
played_at = impression.played_at
server_time = BÂY GIỜ()

time_diff = abs(played_at - server_time)

IF time_diff > 10 phút:
  TỪ CHỐI với "TIMESTAMP_OUT_OF_BOUNDS"
  LOG cảnh báo: "Đồng hồ thiết bị {time_diff} lệch server"

IF played_at > server_time + 5 phút:
  TỪ CHỐI với "TIMESTAMP_IN_FUTURE"
  LOG cảnh báo: "Đồng hồ thiết bị nhanh {time_diff}"

IF played_at < campaign.start_date:
  TỪ CHỐI với "BEFORE_CAMPAIGN_START"

IF played_at > campaign.end_date:
  TỪ CHỐI với "AFTER_CAMPAIGN_END"

Quy tắc nghiệp vụ:
• Dung sai 10 phút cho lệch đồng hồ
• Timestamp tương lai bị từ chối (đồng hồ nhanh)
• Phải nằm trong khoảng ngày chiến dịch
• Vấn đề đồng hồ liên tục gắn cờ thiết bị để bảo trì
```

---

#### 1.3 Yêu cầu Trạng thái Thiết bị

```
Quy tắc: Thiết bị phải ở trạng thái hợp lệ để ghi impression

Kiểm tra:
device = Device.find(impression.device_id)

Điều kiện yêu cầu:
✓ device.status = ACTIVE
✓ device.last_heartbeat_at > BÂY GIỜ - 10 phút
✓ device.store_id = impression.store_id
✓ impression.store_id NOT IN campaign.blocked_stores

Từ chối:
IF device.status != ACTIVE:
  TỪ CHỐI với "DEVICE_NOT_ACTIVE"

IF device.last_heartbeat_at < BÂY GIỜ - 10 phút:
  TỪ CHỐI với "DEVICE_OFFLINE"
  // Thiết bị nên được đánh dấu offline

IF device.store_id != impression.store_id:
  TỪ CHỐI với "STORE_MISMATCH"
  GẮN CỜ để điều tra gian lận

IF impression.store_id IN campaign.blocked_stores:
  TỪ CHỐI với "STORE_BLOCKED"
  // Vi phạm quy tắc chặn đối thủ

Quy tắc nghiệp vụ:
• Chỉ thiết bị active mới ghi được impression
• Thiết bị phải có heartbeat gần đây (< 10 phút)
• Liên kết cửa hàng phải khớp
• Cửa hàng bị chặn không thể tạo impression
• Vi phạm được log để kiểm toán
```

---

#### 1.4 Yêu cầu Trạng thái Chiến dịch

```
Quy tắc: Chiến dịch phải active và có đủ ngân sách

Kiểm tra:
campaign = Campaign.find(impression.campaign_id)

Điều kiện yêu cầu:
✓ campaign.status = ACTIVE
✓ campaign.remaining_budget >= impression.cost
✓ campaign.start_date <= impression.played_at <= campaign.end_date

Từ chối:
IF campaign.status != ACTIVE:
  TỪ CHỐI với "CAMPAIGN_NOT_ACTIVE"
  Thiết bị nên dừng phục vụ chiến dịch này

IF campaign.remaining_budget < impression.cost:
  TỪ CHỐI với "INSUFFICIENT_BUDGET"
  Kích hoạt tự động tạm dừng chiến dịch

IF impression.played_at < campaign.start_date:
  TỪ CHỐI với "BEFORE_CAMPAIGN_START"

IF impression.played_at > campaign.end_date:
  TỪ CHỐI với "CAMPAIGN_ENDED"
  Thiết bị nên xóa khỏi playlist

Quy tắc nghiệp vụ:
• Chỉ chiến dịch active đếm impression
• Ngân sách kiểm tra trước khi ghi (tránh chi vượt)
• Timestamp phải nằm trong khoảng chiến dịch
• Cạn ngân sách kích hoạt tự động tạm dừng
• Playlist thiết bị nên được cập nhật
```

---

### Quy tắc 2: Phát hiện Trùng lặp

#### 2.1 Trùng lặp Ngắn hạn (cửa sổ 5 phút)

```
Thuật toán: Cùng campaign + device + bucket 5 phút

Triển khai:
dedup_key = generate_dedup_key(
  campaign_id: impression.campaign_id,
  device_id: impression.device_id,
  time_bucket: floor(impression.played_at / 5 phút)
)

Ví dụ:
  Campaign: "abc-123"
  Device: "device-456"
  Phát lúc: 14:32:30

  Time bucket: floor(14:32:30 / 5 phút) = 14:30:00
  Dedup key: SHA256("abc-123:device-456:14:30:00")

Kiểm tra Redis:
IF EXISTS(dedup_key):
  TỪ CHỐI với "DUPLICATE_IMPRESSION"
  LOG: "Trùng trong 5 phút"
ELSE:
  SET dedup_key = 1
  EXPIRE dedup_key = 300 giây (5 phút)
  TIẾP TỤC với xác minh

Quy tắc nghiệp vụ:
• Cửa sổ 5 phút ngăn trùng nhanh
• Cùng campaign + device + time bucket = trùng
• Redis cache tự hết hạn sau 5 phút
• Phát lại hợp lệ sau 5 phút được phép
• Nhiều chiến dịch có thể phát trong 5 phút (dedup keys khác nhau)

Các tình huống Ví dụ:
Tình huống 1: Cùng QC 2 lần trong 3 phút
  Impression 1: 14:30:00 → Ghi nhận
  Impression 2: 14:33:00 → TỪ CHỐI (cùng bucket)

Tình huống 2: Cùng QC sau 6 phút
  Impression 1: 14:30:00 → Ghi nhận
  Impression 2: 14:36:00 → Ghi nhận (bucket khác: 14:35:00)

Tình huống 3: Chiến dịch khác trong 5 phút
  Campaign A lúc 14:30:00 → Ghi nhận
  Campaign B lúc 14:32:00 → Ghi nhận (dedup keys khác)
```

---

#### 2.2 Trùng lặp Trung hạn (cửa sổ 1 giờ)

```
Thuật toán: Cùng campaign + device + content + cửa sổ 1 giờ

Mục đích: Phát hiện tần suất phát lại bất thường

Kiểm tra database:
recent_impressions = Impressions.where(
  campaign_id: impression.campaign_id,
  device_id: impression.device_id,
  content_asset_id: impression.content_asset_id,
  played_at: [BÂY GIỜ - 1 giờ, BÂY GIỜ]
).count

max_expected = device.advertising_slots_per_hour / campaign_count_on_device

IF recent_impressions >= max_expected × 1.5:
  GẮN CỜ "HIGH_FREQUENCY"
  IF recent_impressions >= max_expected × 2.0:
    GIỮ LẠI để đánh giá
    LOG: "Tần suất phát lại bất thường"

Ví dụ:
  Thiết bị có 12 slots/giờ
  Thiết bị phục vụ 3 chiến dịch
  Dự kiến mỗi chiến dịch: 12 / 3 = 4 impressions/giờ

  Thực tế: 6 impressions (cùng chiến dịch trong 1 giờ)
  → 6 >= 4 × 1.5 = GẮN CỜ
  → 6 < 4 × 2.0 = Cho phép nhưng gắn cờ

  Thực tế: 9 impressions
  → 9 >= 4 × 2.0 = GIỮ để đánh giá

Quy tắc nghiệp vụ:
• Theo dõi tần suất phát lại mỗi campaign mỗi thiết bị
• Cho phép lên đến 1.5× tần suất dự kiến (phương sai)
• Giữ impression vượt 2× dự kiến (có khả năng gian lận)
• Impression được gắn cờ vẫn ghi nhưng đánh dấu
• Impression bị giữ yêu cầu đánh giá thủ công
```

---

#### 2.3 Phát hiện Mẫu Dài hạn (cửa sổ 24 giờ)

```
Thuật toán: Phát hiện các mẫu đáng ngờ nhất quán

Phân tích:
daily_impressions = Impressions.where(
  device_id: impression.device_id,
  played_at: [BÂY GIỜ - 24 giờ, BÂY GIỜ]
)

Các mẫu cần phát hiện:

1. Mẫu timing chính xác:
   timestamps = daily_impressions.pluck(:played_at)
   intervals = calculate_intervals(timestamps)

   IF all_intervals_equal(intervals):
     GẮN CỜ "ROBOTIC_PATTERN"
     // Quá hoàn hảo để là ngẫu nhiên

2. Timestamp tròn đáng ngờ:
   round_timestamps = timestamps.select { |t|
     t.seconds == 0 AND t.minutes % 5 == 0
   }

   IF round_timestamps.count / timestamps.count > 0.8:
     GẮN CỜ "SUSPICIOUS_TIMING"
     // 80% impression tại các mốc 5 phút chính xác

3. Bất thường hoạt động qua đêm:
   IF store.operating_hours.closed_at < impression.played_at:
     GẮN CỜ "AFTER_HOURS_IMPRESSION"
     // Phát QC khi cửa hàng đóng

Quy tắc nghiệp vụ:
• Các mẫu giống máy chỉ ra tự động hóa/gian lận
• Phát tự nhiên có phương sai
• Timestamp tròn đáng ngờ (gửi thủ công?)
• Impression sau giờ yêu cầu giải thích
• Các mẫu không tự động từ chối, nhưng gắn cờ để đánh giá
```

---

## 🔐 Đặc tả Proof-of-Play

### Quy tắc 3: Yêu cầu Proof

#### 3.1 Chụp Screenshot

```
Mục đích: Bằng chứng trực quan nội dung được hiển thị

Yêu cầu:
• Chụp khung hình ngẫu nhiên giữa 40%-60% phát
• Độ phân giải: Tối thiểu 800x600 (độ phân giải thấp chấp nhận cho proof)
• Định dạng: JPEG (nén, ~50-200KB)
• Chất lượng: JPEG 70% quality đủ
• Timestamp: Nhúng trong EXIF data

Quy trình:
1. Thiết bị chọn điểm ngẫu nhiên:
   capture_at = random(40%, 60%) của content.duration

   Ví dụ:
   Video 30 giây → chụp giữa 12s và 18s

2. Chụp screenshot:
   screenshot = capture_screen(at: capture_at)

3. Tính hash:
   screenshot_hash = SHA256(screenshot)

4. Lưu tạm thời (phía thiết bị):
   save_to_temp(screenshot) // Để upload tiềm năng

5. Bao gồm hash trong impression:
   impression.proof_screenshot_hash = screenshot_hash

6. Upload có điều kiện:
   IF flagged_for_review OR random(5%):
     upload_to_s3(screenshot)
     impression.proof_screenshot_url = s3_url

Quy tắc nghiệp vụ:
• Screenshot bắt buộc cho tất cả impression
• Hash luôn gửi, file upload có chọn lọc (5% ngẫu nhiên + bị gắn cờ)
• Screenshot lưu 30 ngày sau đó xóa (riêng tư + chi phí lưu trữ)
• Thời gian chụp ngẫu nhiên hóa (khó giả mạo)
• Độ phân giải thấp chấp nhận (proof, không kiểm tra chất lượng)
```

---

#### 3.2 Chữ ký Thiết bị

```
Mục đích: Bằng chứng mật mã về tính xác thực

Thuật toán: Chữ ký RSA-SHA256

Dữ liệu để ký:
signature_payload = {
  device_id: "uuid",
  campaign_id: "uuid",
  content_asset_id: "uuid",
  played_at: "2026-01-23T14:30:00Z",
  duration_actual: 28,
  screenshot_hash: "sha256:abc123...",
  location: {lat: 10.762622, lng: 106.660172}
}

canonical_string = JSON.stringify(signature_payload, sorted_keys: true)
signature = RSA_sign(private_key, SHA256(canonical_string))

Impression bao gồm:
• signature_payload (plaintext)
• signature (base64-encoded RSA signature)

Xác minh Server:
canonical_string = JSON.stringify(impression.proof_payload, sorted: true)
public_key = Device.find(impression.device_id).public_key

IF verify_signature(signature, canonical_string, public_key):
  ĐẠT kiểm tra chữ ký
ELSE:
  TỪ CHỐI với "INVALID_SIGNATURE"
  consecutive_failures += 1
  IF consecutive_failures >= 3:
    ĐÌNH CHỈ thiết bị (bị xâm nhập?)

Quy tắc nghiệp vụ:
• Chữ ký bắt buộc cho tất cả impression
• Sử dụng RSA private key của thiết bị (duy nhất mỗi thiết bị)
• Server có public key thiết bị (đăng ký khi kích hoạt)
• Định dạng JSON canonical (sắp xếp nhất quán)
• Chữ ký thất bại được đếm (3 strikes = đình chỉ)
• Chữ ký bao gồm tất cả trường quan trọng (chống giả mạo)
```

---

#### 3.3 Vị trí GPS (Tùy chọn nhưng Khuyến nghị)

```
Mục đích: Xác minh thiết bị vật lý tại vị trí cửa hàng

Thu thập:
IF device_has_gps:
  location = get_gps_coordinates()
  impression.proof_gps_lat = location.latitude
  impression.proof_gps_lng = location.longitude
  impression.proof_gps_accuracy = location.accuracy_meters

Kiểm tra:
IF impression.proof_gps_lat AND impression.proof_gps_lng:
  store = Store.find(device.store_id)
  distance = haversine_distance(
    impression.location,
    store.location
  )

  impression.distance_from_store = distance

  IF distance > 1000 mét: // 1 km
    GẮN CỜ "LOCATION_ANOMALY"
    quality_score -= 20 điểm

  IF distance > 5000 mét: // 5 km
    GẮN CỜ "LOCATION_CRITICAL"
    GIỮ để đánh giá thủ công

  IF distance > 50000 mét: // 50 km
    TỪ CHỐI với "INVALID_LOCATION"
    // Thiết bị có khả năng không ở cửa hàng

Xử lý Độ chính xác:
IF proof_gps_accuracy > 100 mét:
  // Độ chính xác GPS thấp, không phạt
  Bỏ qua kiểm tra vị trí
  quality_score -= 5 điểm (phạt nhỏ)

Quy tắc nghiệp vụ:
• GPS tùy chọn nhưng khuyến nghị (cải thiện quality score)
• Thiết bị không có GPS không bị phạt (nhưng chất lượng thấp hơn)
• Vị trí xác thực với tọa độ cửa hàng
• Khoảng cách < 1km: Bình thường
• Khoảng cách 1-5km: Gắn cờ (điều tra)
• Khoảng cách > 5km: Giữ để đánh giá
• Khoảng cách > 50km: Từ chối (rõ ràng sai)
• Độ chính xác GPS thấp được tha (vấn đề thu trong nhà)
```

---

#### 3.4 Xác minh Timestamp

```
Mục đích: Ngăn tấn công thao túng thời gian

Các thành phần:
• device_timestamp: Giờ địa phương thiết bị khi phát
• server_timestamp: Giờ server khi nhận impression
• time_drift: Chênh lệch giữa thiết bị và server

Tính toán:
time_drift_seconds = device_timestamp - server_timestamp

impression.time_drift_seconds = time_drift_seconds

Kiểm tra:
IF abs(time_drift_seconds) > 600: // 10 phút
  GẮN CỜ "CLOCK_SKEW"
  quality_score -= 15 điểm

IF abs(time_drift_seconds) > 1800: // 30 phút
  TỪ CHỐI với "EXCESSIVE_CLOCK_DRIFT"
  Thông báo supplier: "Đồng hồ thiết bị cần đồng bộ"

IF time_drift_seconds < -300: // 5 phút trong quá khứ
  // Đồng hồ thiết bị chậm
  CẢNH BÁO: "Đồng hồ thiết bị chậm"

IF time_drift_seconds > 300: // 5 phút trong tương lai
  // Đồng hồ thiết bị nhanh
  GẮN CỜ "CLOCK_AHEAD"
  // Có thể là tấn công time travel

Xu hướng Lệch đồng hồ:
recent_drifts = device.recent_impressions.pluck(:time_drift_seconds)

IF increasing_drift_trend(recent_drifts):
  GẮN CỜ thiết bị "CLOCK_DRIFT_TREND"
  Đề xuất đồng bộ NTP

Quy tắc nghiệp vụ:
• Tất cả impression bao gồm timestamp thiết bị và server
• Lệch được tính và lưu để phân tích
• Lệch vừa phải (< 10 phút) chấp nhận nhưng gắn cờ
• Lệch quá mức (> 30 phút) từ chối
• Xu hướng lệch gợi ý vấn đề phần cứng/phần mềm
• Thiết bị nên đồng bộ với NTP thường xuyên
```

---

## ✅ Xác minh & Kiểm tra

### Quy tắc 4: Pipeline Xác minh Tự động

```
Xử lý: Kiểm tra tuần tự, fail-fast

Các giai đoạn pipeline:

1. SIGNATURE_VERIFICATION (Nghiêm trọng)
   Thời lượng: ~10ms
   verify_device_signature(impression)
   NẾU THẤT BẠI: TỪ CHỐI ngay lập tức (không tiếp tục)

2. TIMESTAMP_VALIDATION (Nghiêm trọng)
   Thời lượng: ~5ms
   validate_timestamp_bounds(impression)
   NẾU THẤT BẠI: TỪ CHỐI ngay lập tức

3. CAMPAIGN_STATUS_CHECK (Nghiêm trọng)
   Thời lượng: ~20ms
   validate_campaign_active_and_funded(impression)
   NẾU THẤT BẠI: TỪ CHỐI ngay lập tức

4. DEVICE_STATUS_CHECK (Nghiêm trọng)
   Thời lượng: ~15ms
   validate_device_active_and_online(impression)
   NẾU THẤT BẠI: TỪ CHỐI ngay lập tức

5. DUPLICATE_CHECK (Nghiêm trọng)
   Thời lượng: ~30ms
   check_redis_dedup_key(impression)
   NẾU THẤT BẠI: TỪ CHỐI ngay lập tức

6. DURATION_VALIDATION (Nghiêm trọng)
   Thời lượng: ~5ms
   validate_minimum_duration(impression)
   NẾU THẤT BẠI: TỪ CHỐI ngay lập tức

7. LOCATION_VALIDATION (Ưu tiên cao)
   Thời lượng: ~10ms
   validate_gps_proximity(impression) NẾU gps_available
   NẾU khoảng cách > 50km: TỪ CHỐI
   NẾU khoảng cách > 5km: GẮN CỜ và GIỮ
   NẾU khoảng cách > 1km: GẮN CỜ nhưng TIẾP TỤC

8. QUALITY_CHECKS (Ưu tiên trung bình)
   Thời lượng: ~20ms
   calculate_quality_score(impression)
   NẾU quality_score < 30: GIỮ để đánh giá
   NẾU quality_score < 50: GẮN CỜ nhưng TIẾP TỤC

9. FRAUD_DETECTION (Ưu tiên thấp, chạy async)
   Thời lượng: ~100ms
   run_fraud_detection_rules(impression)
   NẾU fraud_score > 80: GIỮ để đánh giá
   NẾU fraud_score > 50: GẮN CỜ nhưng TIẾP TỤC

10. FINAL_DECISION
    NẾU không TỪ CHỐI và không GIỮ:
      impression.verification_status = VERIFIED
      process_billing(impression)
    NGƯỢC LẠI NẾU GIỮ:
      impression.verification_status = UNDER_REVIEW
      create_review_task(impression)
    NGƯỢC LẠI:
      impression.verification_status = REJECTED

Tổng thời lượng: ~215ms (mục tiêu < 500ms)

Ghi log:
FOR EACH giai đoạn:
  ImpressionVerificationLog.create(
    impression_id: impression.id,
    step: tên_giai_đoạn,
    status: PASS/FAIL/WARN,
    check_type: loại_kiểm_tra,
    result_message: thông_báo,
    processing_time_ms: thời_lượng
  )

Quy tắc nghiệp vụ:
• Kiểm tra chạy tuần tự (tối ưu fail-fast)
• Kiểm tra nghiêm trọng trước (từ chối sớm)
• Mỗi kiểm tra được log để kiểm toán
• Mục tiêu: 95% xác minh trong 500ms
• Impression bị giữ đánh giá trong 24 giờ
```

---

## 🕵️ Phát hiện Gian lận

### Quy tắc 5: Các quy tắc Phát hiện Gian lận

#### 5.1 Phát hiện dựa trên Vận tốc

```
Quy tắc: Tỷ lệ impression quá mức từ thiết bị đơn

Ngưỡng:
max_impressions_per_hour = device.advertising_slots_per_hour × 1.2

Phát hiện:
impressions_last_hour = COUNT(
  impressions WHERE device_id = X
  AND played_at > BÂY GIỜ - 1 giờ
)

IF impressions_last_hour > max_impressions_per_hour:
  fraud_score += 30
  GẮN CỜ "EXCESSIVE_VELOCITY"

  IF impressions_last_hour > max_impressions_per_hour × 1.5:
    fraud_score += 50
    GIỮ tất cả impression từ thiết bị này
    ĐÌNH CHỈ thiết bị để điều tra

Ví dụ:
  Thiết bị: 12 slots/giờ được cấu hình
  Tối đa cho phép: 12 × 1.2 = 14.4 → 14 impressions/giờ

  Thực tế: 16 impressions trong giờ qua
  → fraud_score += 30
  → GẮN CỜ nhưng cho phép

  Thực tế: 22 impressions trong giờ qua
  → fraud_score += 50
  → GIỮ và ĐÌNH CHỈ thiết bị

Quy tắc nghiệp vụ:
• Vận tốc theo dõi mỗi thiết bị mỗi giờ
• Cho phép phương sai 20% (lưu lượng đột biến)
• Vượt giới hạn 50% kích hoạt đình chỉ
• Áp dụng toàn cầu (tất cả chiến dịch kết hợp)
• Reset mỗi giờ (cửa sổ trượt)
```

---

#### 5.2 Phát hiện dựa trên Vị trí

```
Quy tắc: Thiết bị xa vị trí cửa hàng đăng ký

Các mức ngưỡng:
• < 1km: Bình thường (0 điểm)
• 1-5km: Đáng ngờ (+20 điểm)
• 5-20km: Rất đáng ngờ (+40 điểm)
• 20-50km: Nghiêm trọng (+60 điểm)
• > 50km: Chắc chắn gian lận (+100 điểm, tự động từ chối)

Phát hiện:
IF impression có GPS:
  distance_km = haversine_distance(
    impression.location,
    device.store.location
  )

  CASE distance_km:
    WHEN < 1:
      fraud_score += 0
    WHEN 1..5:
      fraud_score += 20
      GẮN CỜ "LOCATION_SUSPICIOUS"
    WHEN 5..20:
      fraud_score += 40
      GẮN CỜ "LOCATION_VERY_SUSPICIOUS"
      GIỮ để đánh giá
    WHEN 20..50:
      fraud_score += 60
      GẮN CỜ "LOCATION_CRITICAL"
      GIỮ để đánh giá
    WHEN > 50:
      fraud_score = 100
      TỪ CHỐI với "LOCATION_FRAUD"

Ngoại lệ:
• Thiết bị mới chuyển sang cửa hàng mới (gia hạn 7 ngày)
• Cửa hàng có nhiều địa điểm (kiểm tra tất cả)
• Thiết bị là loại di động (kiosk, màn hình xe)

Quy tắc nghiệp vụ:
• GPS bắt buộc cho phát hiện dựa trên vị trí
• Khoảng cách tính bằng công thức Haversine
• Nhiều ngưỡng gần
• Chuyển giao cửa hàng có thời gian gia hạn
• Thiết bị di động miễn kiểm tra vị trí
```

---

#### 5.3 Phát hiện Mẫu Thời gian

```
Quy tắc: Phát hiện các mẫu timing phát không tự nhiên

Mẫu 1: Khoảng thời gian Robotic
suspicious_if_variance_low = true

intervals = []
FOR i IN 1..N-1:
  interval = impressions[i+1].played_at - impressions[i].played_at
  intervals.append(interval)

mean_interval = MEAN(intervals)
std_dev = STDDEV(intervals)
coefficient_of_variation = std_dev / mean_interval

IF coefficient_of_variation < 0.05:
  // Quá nhất quán (mong đợi phương sai con người)
  fraud_score += 25
  GẮN CỜ "ROBOTIC_TIMING"

Ví dụ:
  Impressions lúc: 10:00, 10:05, 10:10, 10:15, 10:20
  Khoảng: 5phút, 5phút, 5phút, 5phút
  Mean: 5phút, StdDev: 0
  CV: 0 / 5 = 0 → Quá hoàn hảo!

Mẫu 2: Hoạt động sau giờ
IF impression.played_at NOT IN device.operating_hours:
  fraud_score += 40
  GẮN CỜ "AFTER_HOURS"

  IF repeated_after_hours_pattern:
    fraud_score += 60
    GIỮ để đánh giá

Mẫu 3: Bất thường cuối tuần
IF is_weekend(impression.played_at):
  AND store.weekend_closed:
    fraud_score += 50
    GẮN CỜ "WEEKEND_FRAUD"

Quy tắc nghiệp vụ:
• Phát tự nhiên có phương sai timing
• Khoảng thời gian hoàn hảo gợi ý tự động hóa
• Impression sau giờ rất đáng ngờ
• Hoạt động cuối tuần kiểm tra với giờ cửa hàng
• Các mẫu đóng góp vào fraud score (không tự động từ chối)
```

---

#### 5.4 Kiểm tra Hash Nội dung

```
Quy tắc: Screenshot phải khớp nội dung đã duyệt

Quy trình:
1. Trích xuất đặc điểm chủ đạo từ screenshot:
   screenshot_features = extract_perceptual_hash(
     impression.proof_screenshot_url
   )

2. So sánh với nội dung đã duyệt:
   content = ContentAsset.find(impression.content_asset_id)
   content_features = content.perceptual_hash

   similarity = compare_perceptual_hashes(
     screenshot_features,
     content_features
   )

   // Độ tương đồng: 0-100 (100 = giống hệt)

3. Kiểm tra ngưỡng:
   IF similarity < 60:
     fraud_score += 40
     GẮN CỜ "CONTENT_MISMATCH"
     GIỮ để đánh giá thủ công

   IF similarity < 30:
     fraud_score += 80
     TỪ CHỐI với "INVALID_CONTENT"

Ví dụ:
  Nội dung đã duyệt: Quảng cáo sản phẩm X
  Screenshot hiển thị: Quảng cáo sản phẩm Y
  Độ tương đồng: 25%
  → TỪ CHỐI (nội dung sai được phát)

Các trường hợp đặc biệt:
• Video: So sánh với các khung hình ngẫu nhiên (không chỉ thumbnail)
• Màn hình trống: Độ tương đồng = 0 → TỪ CHỐI
• Che khuất một phần: Độ tương đồng 50-70% → GẮN CỜ nhưng cho phép

Quy tắc nghiệp vụ:
• Perceptual hashing (không so sánh pixel hoàn hảo)
• Tính đến artifacts nén
• Ngưỡng: độ tương đồng tối thiểu 60%
• Đánh giá thủ công cho trường hợp biên (50-70%)
• Màn hình trống luôn từ chối
```

---

#### 5.5 Chấm điểm Uy tín Thiết bị

```
Quy tắc: Theo dõi các mẫu gian lận lịch sử thiết bị

Điểm uy tín: 0-100 (100 = xuất sắc, 0 = gian lận)

Điểm khởi đầu: 80 (thiết bị mới)

Điều chỉnh điểm:

Các yếu tố tích cực:
+ Impression đã xác minh: +0.1 mỗi impression (lên đến 100)
+ Hoạt động sạch: +5 mỗi tuần không có cờ
+ Điểm chất lượng cao: +2 mỗi impression cao cấp
+ Uptime dài: +5 mỗi tháng >95% uptime

Các yếu tố tiêu cực:
- Impression bị gắn cờ: -2 mỗi cờ
- Impression bị giữ: -5 mỗi lần giữ
- Impression bị từ chối: -10 mỗi lần từ chối
- Impression bị tranh chấp: -15 mỗi tranh chấp
- Tranh chấp giữ nguyên (hoàn tiền): -30 mỗi chargeback
- Bị đình chỉ: -50 (ngay lập tức)

Quyết định gian lận hiện tại:
device_reputation = Device.find(impression.device_id).reputation_score

IF device_reputation < 30:
  // Uy tín rất thấp
  fraud_score += 40
  GIỮ tất cả impression để đánh giá thủ công

IF device_reputation < 10:
  // Gần bị cấm
  fraud_score = 100
  TỪ CHỐI với "LOW_REPUTATION"
  Đề xuất thay thế thiết bị

IF device_reputation >= 90:
  // Uy tín xuất sắc
  fraud_score -= 10 (thưởng)
  Xác minh nhanh

Phục hồi Uy tín:
// Thiết bị có thể phục hồi uy tín theo thời gian
FOR EACH tuần sạch:
  device.reputation_score += 2 (tối đa 100)

Quy tắc nghiệp vụ:
• Uy tín theo dõi mỗi thiết bị
• Bắt đầu ở 80 (lợi ích của nghi ngờ)
• Cải thiện với hoạt động sạch
• Suy giảm với chỉ báo gian lận
• Uy tín rất thấp = tự động giữ/từ chối
• Uy tín cao = xử lý nhanh
• Uy tín có thể phục hồi (không cấm vĩnh viễn)
```

---

## 🎯 Chấm điểm Chất lượng

### Quy tắc 6: Tính Điểm Chất lượng

```
Mục đích: Đánh giá giá trị/độ tin cậy impression ngoài phát hiện gian lận

Quality Score: 0-100 (cao hơn = impression chất lượng tốt hơn)

Công thức:
quality_score = (
  technical_quality × 0.30 +
  proof_quality × 0.25 +
  viewability_quality × 0.20 +
  location_quality × 0.15 +
  timing_quality × 0.10
)

Tính toán Thành phần:

1. Chất lượng Kỹ thuật (30%):
   technical_quality = 100
   IF duration_actual < duration_expected × 0.90:
     technical_quality -= 20 // Không phát đầy đủ
   IF time_drift > 300 giây:
     technical_quality -= 15 // Lệch đồng hồ
   IF network_quality = POOR:
     technical_quality -= 10
   IF device.health_score < 70:
     technical_quality -= 15 // Thiết bị không đáng tin

2. Chất lượng Proof (25%):
   proof_quality = 100
   IF NOT has_screenshot:
     proof_quality -= 30
   IF screenshot_quality < 0.7:
     proof_quality -= 20
   IF NOT has_valid_signature:
     proof_quality = 0 // Nghiêm trọng
   IF NOT has_gps:
     proof_quality -= 15

3. Chất lượng Viewability (20%):
   viewability_quality = 100
   IF screen_brightness < 30%:
     viewability_quality -= 20 // Quá mờ
   IF environment_brightness < 100 lux:
     viewability_quality -= 15 // Môi trường tối
   IF audio_enabled = false:
     viewability_quality -= 10 // Không có âm thanh
   IF device_orientation_incorrect:
     viewability_quality -= 25 // Tỷ lệ khung hình sai

4. Chất lượng Vị trí (15%):
   location_quality = 100
   IF NOT has_gps:
     location_quality = 70 // Phạt vì thiếu
   ELSE:
     distance_km = distance_from_store
     IF distance_km > 1:
       location_quality -= (distance_km × 5) // Tối đa -100

5. Chất lượng Timing (10%):
   timing_quality = 100
   IF played_outside_peak_hours:
     timing_quality -= 20 // Kém giá trị hơn
   IF played_outside_operating_hours:
     timing_quality -= 50 // Đáng ngờ
   IF is_weekend AND store.weekend_traffic_low:
     timing_quality -= 15

Điểm Cuối:
quality_score = CLAMP(computed_score, 0, 100)

Các cấp Chất lượng:
• PREMIUM: 90-100 (xuất sắc)
• STANDARD: 70-89 (tốt)
• BASIC: 50-69 (chấp nhận được)
• POOR: 0-49 (đáng ngờ)

Tác động lên Impression:
IF quality_score < 30:
  GIỮ để đánh giá thủ công
IF quality_score >= 90:
  impression.quality_tier = PREMIUM
  Xác minh nhanh
IF quality_score < 50:
  GẮN CỜ "LOW_QUALITY"
  Thông báo supplier

Quy tắc nghiệp vụ:
• Quality score tính cho mỗi impression
• Impression chất lượng kém bị giữ để đánh giá
• Impression chất lượng cao được xác minh nhanh
• Chất lượng ảnh hưởng uy tín supplier
• Advertiser có thể lọc theo cấp chất lượng
• Impression cao cấp có thể biện minh CPM cao hơn
```

---

## ⚖️ Tranh chấp & Hoàn tiền

### Quy tắc 7: Quy trình Tranh chấp

#### 7.1 Nộp Tranh chấp

```
Người thực hiện: Advertiser
Cửa sổ: 30 ngày từ ngày impression

Điều kiện:
• Impression phải có status VERIFIED
• Trong cửa sổ tranh chấp 30 ngày
• Advertiser phải cung cấp lý do và bằng chứng

Quy trình:
1. Advertiser nộp tranh chấp:
   POST /impressions/:id/dispute
   {
     "dispute_type": "INVALID_PROOF",
     "reason": "Screenshot hiển thị nội dung khác với chiến dịch",
     "evidence": [
       {"type": "screenshot_comparison", "url": "..."},
       {"type": "description", "text": "..."}
     ]
   }

2. Kiểm tra:
   impression = Impression.find(id)

   ✓ impression.verification_status = VERIFIED
   ✓ impression.created_at > BÂY GIỜ - 30 ngày
   ✓ impression.campaign.advertiser_id = current_user.id
   ✓ CHƯA tranh chấp

3. Tạo tranh chấp:
   dispute = ImpressionDispute.create(
     impression_id: impression.id,
     campaign_id: impression.campaign_id,
     advertiser_id: current_user.id,
     dispute_type: params[:dispute_type],
     reason: params[:reason],
     evidence: params[:evidence],
     status: PENDING,
     priority: calculate_priority(dispute_type),
     filed_at: BÂY GIỜ
   )

4. Cập nhật impression:
   impression.update(
     verification_status: DISPUTED,
     dispute_id: dispute.id
   )

5. Giữ billing:
   // Đảo ngược billing tạm thời
   campaign.spent -= impression.cost
   campaign.remaining_budget += impression.cost

   supplier.pending_revenue -= impression.supplier_revenue
   supplier.held_revenue += impression.supplier_revenue

6. Thông báo các bên:
   • Advertiser: "Tranh chấp đã nộp, điều tra bắt đầu"
   • Supplier: "Impression bị advertiser tranh chấp"
   • Admin: Tạo nhiệm vụ điều tra

Quy tắc nghiệp vụ:
• Cửa sổ tranh chấp 30 ngày (nghiêm ngặt)
• Bằng chứng bắt buộc (không chỉ khiếu nại)
• Billing giữ trong quá trình điều tra
• Cả hai bên được thông báo
• Admin được gán để điều tra
```

---

#### 7.2 Quy trình Điều tra

```
Người thực hiện: Admin
SLA: Giải quyết trong 72 giờ (3 ngày)

Quy trình:
1. Admin được gán tranh chấp:
   dispute.update(
     assigned_to: admin.id,
     status: INVESTIGATING
   )

2. Đánh giá bằng chứng:
   Đánh giá bằng chứng advertiser:
   • So sánh screenshot
   • Nhật ký thiết bị
   • Giờ hoạt động cửa hàng
   • Dữ liệu GPS
   • Timestamp

   Đánh giá bằng chứng hệ thống:
   • Nhật ký xác minh impression
   • Dữ liệu proof-of-play
   • Lịch sử heartbeat thiết bị
   • Mẫu impression gần đây

3. Ma trận Quyết định:

   Loại Tranh chấp: INVALID_PROOF
   Kiểm tra: Screenshot có khớp nội dung đã duyệt không?
   NẾU screenshot rõ ràng khác:
     Quyết định: CHARGEBACK_APPROVED
   NGƯỢC LẠI NẾU screenshot tương tự nhưng không rõ:
     Quyết định: PARTIAL_REFUND (50%)
   NGƯỢC LẠI:
     Quyết định: CHARGEBACK_DENIED

   Loại Tranh chấp: DEVICE_OFFLINE
   Kiểm tra: Thiết bị có online tại thời điểm báo cáo không?
   NẾU last_heartbeat > played_at + 10 phút:
     Quyết định: CHARGEBACK_APPROVED
   NGƯỢC LẠI:
     Quyết định: CHARGEBACK_DENIED

   Loại Tranh chấp: WRONG_LOCATION
   Kiểm tra: Khoảng cách GPS từ cửa hàng
   NẾU khoảng cách > 10 km:
     Quyết định: CHARGEBACK_APPROVED
   NGƯỢC LẠI NẾU khoảng cách 1-10 km:
     Quyết định: PARTIAL_REFUND (50%)
   NGƯỢC LẠI:
     Quyết định: CHARGEBACK_DENIED

4. Ghi lại phát hiện:
   dispute.update(
     investigation_notes: ghi_chú_admin,
     resolution: quyết_định,
     resolved_at: BÂY GIỜ
   )

5. Áp dụng giải quyết (xem Quy tắc 7.3)

Quy tắc nghiệp vụ:
• Đánh giá admin bắt buộc cho tất cả tranh chấp
• SLA 72 giờ (hầu hết giải quyết trong 24 giờ)
• Quyết định dựa trên bằng chứng
• Cho phép hoàn tiền một phần (50%)
• Phát hiện được ghi lại để minh bạch
```

---

#### 7.3 Thực thi Hoàn tiền

**Giải quyết: CHARGEBACK_APPROVED**

```
Quy trình:
1. Cập nhật impression:
   impression.update(
     verification_status: REJECTED,
     rejected_reason: f"Tranh chấp giữ nguyên: {dispute.resolution}",
     chargeback_at: BÂY GIỜ,
     chargeback_reason: dispute.reason
   )

2. Hoàn tiền advertiser:
   refund_amount = impression.cost

   campaign.spent -= refund_amount
   campaign.remaining_budget += refund_amount

   BudgetTransaction.create(
     campaign_id: campaign.id,
     type: CREDIT,
     amount: refund_amount,
     reference_id: dispute.id,
     description: "Hoàn tiền cho impression bị tranh chấp"
   )

3. Phạt supplier:
   supplier_penalty = impression.supplier_revenue

   supplier.held_revenue -= supplier_penalty
   // Không ghi có trở lại (supplier mất doanh thu)

   SupplierTransaction.create(
     supplier_id: supplier.id,
     type: DEBIT,
     amount: supplier_penalty,
     reference_id: dispute.id,
     description: f"Phạt hoàn tiền cho impression {impression.id}"
   )

4. Cập nhật uy tín thiết bị:
   device.reputation_score -= 30
   device.chargeback_count += 1

   IF device.chargeback_count >= 5:
     device.status = MAINTENANCE
     GẮN CỜ thiết bị "EXCESSIVE_CHARGEBACKS"

5. Cập nhật tranh chấp:
   dispute.update(
     status: RESOLVED,
     refund_amount: refund_amount,
     supplier_penalty: supplier_penalty,
     resolved_at: BÂY GIỜ
   )

6. Thông báo các bên:
   • Advertiser: "Tranh chấp giải quyết có lợi cho bạn. Hoàn tiền: ${refund_amount}"
   • Supplier: "Tranh chấp giải quyết không có lợi cho bạn. Phạt: ${supplier_penalty}"
   • Bao gồm: Lý do, bằng chứng, hướng dẫn kháng cáo

Quy tắc nghiệp vụ:
• Hoàn tiền đầy đủ cho advertiser
• Supplier mất doanh thu (phạt)
• Uy tín thiết bị bị ảnh hưởng
• Hoàn tiền quá mức gắn cờ thiết bị
• Cả hai bên thông báo với lý do
• Cho phép kháng cáo trong 7 ngày
```

---

**Giải quyết: CHARGEBACK_DENIED**

```
Giải quyết: Tranh chấp không giữ nguyên, impression hợp lệ

Quy trình:
1. Cập nhật tranh chấp:
   dispute.update(
     status: RESOLVED,
     resolution: CHARGEBACK_DENIED,
     resolved_at: BÂY GIỜ
   )

2. Khôi phục impression:
   impression.update(
     verification_status: VERIFIED
     // Trở lại trạng thái verified
   )

3. Giải phóng billing đã giữ:
   // Đã trừ, chỉ giải phóng giữ
   supplier.held_revenue -= impression.supplier_revenue
   supplier.available_revenue += impression.supplier_revenue

4. Không hoàn tiền cho advertiser:
   // Billing giữ nguyên như cũ

5. Thông báo các bên:
   • Advertiser: "Tranh chấp giải quyết không có lợi cho bạn. Không hoàn tiền. Lý do: {admin_notes}"
   • Supplier: "Tranh chấp giải quyết có lợi cho bạn. Doanh thu được giải phóng."

Quy tắc nghiệp vụ:
• Impression vẫn hợp lệ
• Không thay đổi tài chính (status quo)
• Doanh thu supplier được giải phóng khỏi giữ
• Advertiser có thể kháng cáo trong 7 ngày
• Tranh chấp vô căn cứ có thể bị phạt
```

---

## ⚠️ Các trường hợp đặc biệt

### Trường hợp 1: Impression trong khi Mất Mạng

```
Tình huống: Thiết bị ghi impression cục bộ, gửi sau khi mạng khôi phục

Hành vi:
1. Thiết bị cache dữ liệu impression cục bộ:
   • Timestamp
   • Content ID
   • Dữ liệu proof-of-play
   • Xếp hàng để gửi

2. Khi mạng khôi phục:
   • Gửi impression backfill với timestamp gốc
   • Bao gồm cờ network_outage

3. Kiểm tra Server:
   IF impression.played_at < BÂY GIỜ - 4 giờ:
     TỪ CHỐI với "TOO_STALE"
     // Vượt cửa sổ backfill chấp nhận

   IF device_was_offline_during(impression.played_at):
     // Kiểm tra lịch sử heartbeat thiết bị
     CHẤP NHẬN với quality_score thấp hơn

   IF no_evidence_of_outage:
     GẮN CỜ "SUSPICIOUS_BACKFILL"
     GIỮ để đánh giá

Quy tắc nghiệp vụ:
• Cửa sổ backfill: tối đa 4 giờ
• Thiết bị phải offline trong khoảng đó
• Quality score giảm cho impression backfilled
• Backfill timing đáng ngờ bị giữ để đánh giá
```

---

### Trường hợp 2: Upload Screenshot Thất bại

```
Tình huống: Thiết bị tính screenshot_hash nhưng upload S3 thất bại

Hành vi:
1. Impression bao gồm screenshot_hash nhưng không có screenshot_url
2. Server chấp nhận impression (hash là proof)
3. Nếu sau đó bị gắn cờ để đánh giá:
   • Yêu cầu thiết bị upload lại screenshot
   • Thiết bị có thể không còn file (đã xóa)
   • Quyết định: Tin hash hoặc từ chối?

Giải quyết:
IF impression.flagged_for_review:
  AND NOT impression.proof_screenshot_url:
    request_screenshot_reupload(device, impression)

    IF device_responds_with_screenshot:
      verify_hash_matches(screenshot, impression.proof_screenshot_hash)
      IF match:
        TIẾP TỤC với đánh giá
      ELSE:
        TỪ CHỐI với "HASH_MISMATCH"
    ELSE:
      // Thiết bị không còn screenshot
      decision_based_on_other_evidence()

Quy tắc nghiệp vụ:
• Screenshot hash đủ cho impression bình thường
• Đánh giá thủ công yêu cầu screenshot thực tế
• Thiết bị có thể không có file sau 24 giờ (đã xóa)
• Hash không khớp = bằng chứng rõ ràng về giả mạo
```

---

### Trường hợp 3: Ngân sách Chiến dịch Cạn kiệt Giữa Impression

```
Tình huống: Ngân sách chiến dịch cạn trong khi impression đang xác minh

Timeline:
• T+0s: Impression gửi, remaining_budget = $0.05
• T+1s: Xác minh bắt đầu, cost tính = $0.08
• T+2s: Phát hiện ngân sách không đủ

Hành vi:
budget_check_result = check_budget(campaign, impression.cost)

IF budget_check_result = INSUFFICIENT:
  // Race condition: ngân sách cạn kiệt trong xác minh

  // Tùy chọn 1: Từ chối impression
  TỪ CHỐI với "BUDGET_EXHAUSTED"
  Kích hoạt tự động tạm dừng chiến dịch

  // Tùy chọn 2: Giữ impression (cho phép số dư âm)
  IF impression.played_at < campaign.paused_at:
    // Impression bắt đầu trước khi tạm dừng
    CHẤP NHẬN impression
    Cho phép số dư âm (lên đến -$1.00)
    campaign.remaining_budget = -$0.03

  // Tùy chọn 3: Tín dụng một phần
  IF campaign.remaining_budget > 0:
    partial_cost = campaign.remaining_budget
    Ghi nhận impression với partial_cost
    Ghi chú: "Billing một phần do giới hạn ngân sách"

Khuyến nghị: Tùy chọn 2 (giữ impression đang bay)

Quy tắc nghiệp vụ:
• Impression đang bay được giữ
• Cho phép gia hạn: số dư âm lên đến $1.00
• Chiến dịch tạm dừng ngay sau đó
• Advertiser thông báo về chi vượt
• Lần nạp tiếp theo phải bù chi vượt
```

---

## ✅ Quy tắc Kiểm tra

### Ma trận Kiểm tra Impression

| Trường | Quy tắc | Thông báo lỗi |
|--------|---------|---------------|
| `campaign_id` | Phải là chiến dịch active | "Chiến dịch không tìm thấy hoặc inactive" |
| `device_id` | Phải là thiết bị active | "Thiết bị không tìm thấy hoặc inactive" |
| `content_asset_id` | Phải là nội dung đã duyệt | "Nội dung không tìm thấy hoặc chưa duyệt" |
| `played_at` | Trong ±10 phút server time | "Timestamp ngoài phạm vi chấp nhận" |
| `duration_actual` | >= 80% của dự kiến | "Thời lượng phát không đủ" |
| `duration_actual` | <= 150% của dự kiến | "Thời lượng vượt độ dài nội dung" |
| `proof_screenshot_hash` | Định dạng SHA256 (64 ký tự) | "Định dạng hash screenshot không hợp lệ" |
| `proof_device_signature` | Chữ ký RSA hợp lệ | "Chữ ký thiết bị không hợp lệ hoặc thiếu" |
| `proof_gps_lat` | Phạm vi: -90 đến 90 | "Latitude không hợp lệ" |
| `proof_gps_lng` | Phạm vi: -180 đến 180 | "Longitude không hợp lệ" |
| `cost` | > 0 | "Chi phí impression phải dương" |
| `cpm_rate` | Khớp bảng giá hiện tại | "Giá CPM không khớp" |

---

## 🧮 Công thức Tính toán

### Tổng hợp Công thức

#### 1. Quality Score

```
quality_score = (
  technical_quality × 0.30 +
  proof_quality × 0.25 +
  viewability_quality × 0.20 +
  location_quality × 0.15 +
  timing_quality × 0.10
)

Phạm vi: 0-100
Mục tiêu: ≥ 70
Premium: ≥ 90
```

#### 2. Fraud Score

```
fraud_score = BASE_SCORE(0) +
  velocity_penalty +
  location_penalty +
  pattern_penalty +
  reputation_penalty -
  device_reputation_bonus

Phạm vi: 0-100 (cao hơn = khả năng gian lận cao hơn)
Ngưỡng:
• < 30: Sạch (không hành động)
• 30-50: Đáng ngờ (gắn cờ)
• 50-80: Rất đáng ngờ (giữ)
• > 80: Có khả năng gian lận (từ chối hoặc đình chỉ)
```

#### 3. Tỷ lệ Thành công Xác minh (Chỉ số Thiết bị)

```
verification_rate = (
  verified_impressions /
  (verified_impressions + rejected_impressions)
) × 100

Mục tiêu: ≥ 95%
Tốt: 90-95%
Kém: < 90%
```

#### 4. Tỷ lệ Tranh chấp (Chỉ số Hệ thống)

```
dispute_rate = (
  disputed_impressions /
  total_verified_impressions
) × 100

Mục tiêu: < 1%
Chấp nhận được: 1-3%
Cao: > 3% (điều tra)
```

#### 5. Tỷ lệ Hoàn tiền (Chỉ số Supplier/Thiết bị)

```
chargeback_rate = (
  chargebacks_approved /
  total_verified_impressions
) × 100

Xuất sắc: < 0.5%
Chấp nhận được: 0.5-2%
Kém: > 2%
Nghiêm trọng: > 5% (đình chỉ thiết bị)
```

---

## 📚 Phụ lục: Ví dụ Nhật ký Xác minh

```
Các bản ghi ImpressionVerificationLog cho impression_id: "abc-123"

1. {
     step: "SIGNATURE_VERIFICATION",
     status: "PASS",
     check_type: "SIGNATURE",
     result_message: "Chữ ký thiết bị hợp lệ",
     processing_time_ms: 12
   }

2. {
     step: "TIMESTAMP_VALIDATION",
     status: "WARN",
     check_type: "TIMESTAMP",
     expected_value: "< 600s drift",
     actual_value: "420s drift",
     result_message: "Phát hiện lệch đồng hồ nhưng trong dung sai",
     severity: "WARNING",
     processing_time_ms: 5
   }

3. {
     step: "CAMPAIGN_STATUS_CHECK",
     status: "PASS",
     check_type: "CAMPAIGN",
     result_message: "Chiến dịch active với ngân sách đủ",
     processing_time_ms: 18
   }

4. {
     step: "DUPLICATE_CHECK",
     status: "PASS",
     check_type: "DUPLICATE",
     result_message: "Không tìm thấy trùng trong cửa sổ 5 phút",
     processing_time_ms: 25
   }

5. {
     step: "LOCATION_VALIDATION",
     status: "WARN",
     check_type: "LOCATION",
     expected_value: "< 1000m từ cửa hàng",
     actual_value: "1250m từ cửa hàng",
     result_message: "Thiết bị hơi xa cửa hàng (đã gắn cờ)",
     severity: "WARNING",
     processing_time_ms: 8
   }

6. {
     step: "QUALITY_SCORE_CALCULATION",
     status: "PASS",
     check_type: "QUALITY",
     actual_value: "78",
     result_message: "Quality score: 78 (cấp STANDARD)",
     processing_time_ms: 22
   }

7. {
     step: "FRAUD_DETECTION",
     status: "PASS",
     check_type: "FRAUD",
     actual_value: "fraud_score: 15",
     result_message: "Không phát hiện chỉ báo gian lận",
     processing_time_ms: 95
   }

8. {
     step: "FINAL_DECISION",
     status: "PASS",
     result_message: "Impression VERIFIED với cảnh báo",
     processing_time_ms: 2
   }

Tổng thời gian xử lý: 187ms
Trạng thái cuối: VERIFIED (với 2 cảnh báo)
Quality score: 78
Fraud score: 15
```

---

## 📚 Phụ lục: Bảng thuật ngữ

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Impression** | Lần phát quảng cáo được xác minh |
| **Proof-of-Play** | Gói bằng chứng (screenshot + chữ ký + GPS) |
| **Verification** | Quy trình xác thực tự động |
| **Quality Score** | Chỉ số 0-100 chỉ giá trị impression |
| **Fraud Score** | Chỉ số 0-100 chỉ khả năng gian lận |
| **Dispute** | Advertiser thách thức tính hợp lệ impression |
| **Chargeback** | Hoàn tiền phát hành cho advertiser vì impression không hợp lệ |
| **Hold** | Trạng thái tạm thời chờ đánh giá thủ công |
| **Backfill** | Impression gửi sau mất mạng |

---

## 📚 Tham khảo

### Tài liệu liên quan

| Tài liệu | Mô tả |
|----------|-------|
| [Từ điển Thuật ngữ](./00-tu-dien-thuat-ngu.md) | Giải thích tất cả thuật ngữ |
| [Quy tắc Chiến dịch](./04-quy-tac-chien-dich.md) | Cơ bản chiến dịch & billing |
| [Quy tắc Thiết bị](./05-quy-tac-thiet-bi.md) | Quản lý thiết bị & heartbeat |
| [Quy tắc Supplier](./09-quy-tac-nha-cung-cap.md) | Chi trả supplier & tranh chấp |

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team  
**Trạng thái**: Sẵn sàng để review