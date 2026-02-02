# 📖 Từ điển Thuật ngữ RMN-Arms

**Phiên bản**: 1.0  
**Cập nhật**: 2026-01-23  
**Mục đích**: Giải thích tất cả thuật ngữ trong dự án để mọi người đều hiểu được

---

## 📋 Mục lục

1. [Thuật ngữ Kinh doanh](#-thuật-ngữ-kinh-doanh)
2. [Thuật ngữ Kỹ thuật](#-thuật-ngữ-kỹ-thuật)
3. [Thuật ngữ Thanh toán](#-thuật-ngữ-thanh-toán)
4. [Thuật ngữ Trạng thái](#-thuật-ngữ-trạng-thái)
5. [Viết tắt thường dùng](#-viết-tắt-thường-dùng)

---

## 💼 Thuật ngữ Kinh doanh

### RMN (Retail Media Network)
> **Phát âm**: /ˌriːteɪl ˈmiːdiə ˈnetwɜːk/

**Định nghĩa**: Mạng lưới quảng cáo bán lẻ - hệ thống cho phép các thương hiệu quảng cáo sản phẩm trực tiếp tại các điểm bán lẻ (siêu thị, cửa hàng tiện lợi, trung tâm thương mại...) thông qua màn hình kỹ thuật số.

**Ví dụ thực tế**:
- Màn hình LED ở lối vào siêu thị Big C
- TV quảng cáo trong thang máy chung cư
- Màn hình tại quầy thanh toán Circle K

**Tại sao quan trọng**: Quảng cáo đúng lúc khách hàng đang có ý định mua sắm → tỷ lệ chuyển đổi cao hơn.

---

### Advertiser (Nhà quảng cáo)
> **Phát âm**: /ˈædvətaɪzə/

**Định nghĩa**: Doanh nghiệp hoặc cá nhân muốn quảng cáo sản phẩm/dịch vụ của mình trên các màn hình digital signage.

**Vai trò trong hệ thống**:
- Tạo chiến dịch quảng cáo
- Nạp tiền vào ví (prepaid)
- Upload nội dung quảng cáo (hình ảnh, video)
- Chọn cửa hàng muốn hiển thị
- Theo dõi hiệu quả chiến dịch

**Ví dụ**: 
- Công ty Coca-Cola muốn quảng cáo sản phẩm mới
- Cửa hàng thời trang muốn quảng bá khuyến mãi

**Phân biệt với Supplier**: Advertiser **trả tiền** để quảng cáo, Supplier **nhận tiền** từ việc cho thuê màn hình.

---

### Supplier (Nhà cung cấp)
> **Phát âm**: /səˈplaɪə/

**Định nghĩa**: Chủ sở hữu các cửa hàng/địa điểm có lắp đặt màn hình digital signage, cho phép hiển thị quảng cáo và nhận doanh thu.

**Vai trò trong hệ thống**:
- Đăng ký cửa hàng và thiết bị
- Thiết lập giờ hoạt động của màn hình
- Đặt quy tắc chặn đối thủ cạnh tranh
- Nhận 80% doanh thu từ mỗi lượt hiển thị

**Ví dụ**:
- Chuỗi siêu thị VinMart
- Chủ chuỗi cửa hàng tiện lợi
- Quản lý tòa nhà văn phòng

**Công thức thu nhập**:
```
Thu nhập Supplier = Số lượt hiển thị × Giá CPM ÷ 1000 × 80%
```

---

### Campaign (Chiến dịch)
> **Phát âm**: /kæmˈpeɪn/

**Định nghĩa**: Một đợt chạy quảng cáo có thời gian bắt đầu, kết thúc, ngân sách và mục tiêu cụ thể.

**Các thành phần của Campaign**:
| Thành phần | Mô tả | Ví dụ |
|------------|-------|-------|
| Tên chiến dịch | Tên gọi để dễ quản lý | "Khuyến mãi Tết 2026" |
| Ngân sách | Số tiền tối đa chi cho chiến dịch | 10,000,000 VNĐ |
| Thời gian | Ngày bắt đầu → Ngày kết thúc | 01/02/2026 → 15/02/2026 |
| Nội dung | Hình ảnh/video quảng cáo | Video 30 giây |
| Cửa hàng mục tiêu | Nơi muốn hiển thị | 50 cửa hàng tại Hà Nội |

**Vòng đời Campaign**:
```
Nháp → Chờ duyệt → Đã lên lịch → Đang chạy → Hoàn thành
  ↓                                    ↓
Đã hủy                              Tạm dừng
```

---

### Impression (Lượt hiển thị)
> **Phát âm**: /ɪmˈpreʃn/

**Định nghĩa**: Mỗi lần quảng cáo được phát hoàn chỉnh trên màn hình = 1 impression.

**Điều kiện tính là 1 Impression hợp lệ**:
1. ✅ Video/hình ảnh phát được ≥ 80% thời lượng
2. ✅ Thiết bị đang online và hoạt động bình thường
3. ✅ Có bằng chứng phát (Proof-of-Play)
4. ✅ Không bị phát hiện gian lận

**Ví dụ**:
- Video 30 giây → phát được ≥ 24 giây mới tính
- Hình ảnh hiển thị 10 giây → phải hiển thị ≥ 8 giây

**KHÔNG tính là Impression**:
- ❌ Màn hình bị tắt giữa chừng
- ❌ Video bị lỗi, không phát được
- ❌ Thiết bị offline
- ❌ Phát hiện gian lận (fraud)

---

### Store (Cửa hàng)
> **Phát âm**: /stɔː/

**Định nghĩa**: Địa điểm vật lý nơi đặt các thiết bị màn hình quảng cáo.

**Thông tin cần thiết**:
- Tên cửa hàng
- Địa chỉ đầy đủ
- Tọa độ GPS
- Loại hình (siêu thị, cửa hàng tiện lợi, mall...)
- Giờ hoạt động
- Lượng khách trung bình/ngày

**Tại sao quan trọng**: Cửa hàng ở vị trí đông người → CPM cao hơn → doanh thu cao hơn.

---

### Device (Thiết bị)
> **Phát âm**: /dɪˈvaɪs/

**Định nghĩa**: Màn hình kỹ thuật số (digital signage) được lắp đặt tại cửa hàng để phát nội dung quảng cáo.

**Các loại thiết bị**:
| Loại | Mô tả | Ví dụ |
|------|-------|-------|
| DISPLAY | Màn hình tiêu chuẩn | TV 55 inch treo tường |
| VIDEO_WALL | Màn hình ghép | 2x2 màn hình ghép thành 1 |
| KIOSK | Màn hình cảm ứng | Kiosk tra cứu thông tin |
| LED_BOARD | Bảng LED | Biển LED ngoài trời |

**Thông số quan trọng**:
- Kích thước màn hình (32-100 inch)
- Độ phân giải (1920x1080 Full HD, 4K...)
- Hướng màn hình (ngang/dọc)
- Số slot quảng cáo/giờ

---

### Content (Nội dung)
> **Phát âm**: /ˈkɒntent/

**Định nghĩa**: File hình ảnh hoặc video quảng cáo được upload lên hệ thống.

**Định dạng hỗ trợ**:
| Loại | Định dạng | Kích thước tối đa |
|------|-----------|-------------------|
| Hình ảnh | JPG, PNG, GIF | 10 MB |
| Video | MP4 (H.264) | 500 MB |
| Audio | MP3, AAC | 50 MB |

**Yêu cầu kỹ thuật**:
- Video: 10-60 giây
- Độ phân giải tối thiểu: 1920x1080 (Full HD)
- Tỷ lệ khung hình: 16:9 (ngang) hoặc 9:16 (dọc)

---

### Blocking Rule (Quy tắc chặn)
> **Phát âm**: /ˈblɒkɪŋ ruːl/

**Định nghĩa**: Quy tắc do Supplier thiết lập để ngăn quảng cáo của đối thủ cạnh tranh hiển thị tại cửa hàng của mình.

**Ví dụ thực tế**:
- Cửa hàng Pepsi → chặn quảng cáo Coca-Cola
- Đại lý Samsung → chặn quảng cáo Apple, Oppo
- Nhà hàng Lotteria → chặn quảng cáo KFC, McDonald's

**Cách hoạt động**:
```
1. Supplier đặt quy tắc: Chặn "Coca-Cola"
2. Advertiser tạo chiến dịch cho "Coca-Cola"
3. Hệ thống tự động loại cửa hàng này khỏi danh sách
4. Coca-Cola không thể chọn cửa hàng này
```

---

## 🔧 Thuật ngữ Kỹ thuật

### Heartbeat (Tín hiệu sống)
> **Phát âm**: /ˈhɑːtbiːt/

**Định nghĩa**: Tín hiệu định kỳ mà thiết bị gửi về server để báo "tôi vẫn đang hoạt động bình thường".

**Cách hoạt động**:
```
Thiết bị ──(mỗi 5 phút)──► "Tôi vẫn sống!" ──► Server
```

**Thông tin gửi kèm**:
- Trạng thái màn hình (bật/tắt)
- Đang phát nội dung gì
- Mức sử dụng CPU, RAM
- Kết nối mạng
- Tọa độ GPS (nếu có)

**Quy tắc quan trọng**:
| Tình huống | Hành động |
|------------|-----------|
| Heartbeat đều đặn | ✅ Thiết bị ONLINE |
| Không có heartbeat > 10 phút | ⚠️ Đánh dấu OFFLINE |
| Offline > 1 giờ | 📧 Gửi cảnh báo cho Supplier |
| Offline > 24 giờ | 🚨 Cần kiểm tra khẩn cấp |

**Ví dụ thực tế**:
Giống như việc bạn gọi điện hỏi thăm bố mẹ mỗi ngày. Nếu 3 ngày không liên lạc được → có vấn đề!

---

### Proof-of-Play (Bằng chứng phát)
> **Phát âm**: /pruːf əv pleɪ/

**Định nghĩa**: Bằng chứng kỹ thuật chứng minh rằng quảng cáo đã thực sự được phát trên màn hình.

**Bao gồm**:
1. **Chữ ký số (Digital Signature)**: Mã hóa từ thiết bị, không thể làm giả
2. **Ảnh chụp màn hình**: Chụp tự động khi đang phát
3. **Timestamp**: Thời gian chính xác (giờ:phút:giây)
4. **Tọa độ GPS**: Vị trí thiết bị lúc phát
5. **Hash**: Mã băm của nội dung được phát

**Tại sao cần Proof-of-Play**:
- Advertiser biết chắc tiền mình chi đúng mục đích
- Phòng chống gian lận
- Giải quyết tranh chấp khi có khiếu nại

**Ví dụ**:
```json
{
  "impression_id": "abc-123",
  "device_id": "DVC-001",
  "played_at": "2026-01-23 14:30:25",
  "duration": 30,
  "screenshot_hash": "sha256:abcd1234...",
  "gps": {"lat": 21.0285, "lng": 105.8542},
  "signature": "RSA-2048-signed-data..."
}
```

---

### Sync (Đồng bộ)
> **Phát âm**: /sɪŋk/

**Định nghĩa**: Quá trình tải nội dung quảng cáo mới từ server về thiết bị.

**Quy trình Sync**:
```
1. Server có nội dung mới
2. Server thông báo cho thiết bị
3. Thiết bị tải file về (qua CDN)
4. Thiết bị xác nhận đã nhận
5. Server đánh dấu "đã đồng bộ"
```

**Các loại Sync**:
| Loại | Khi nào dùng | Mô tả |
|------|--------------|-------|
| FULL | Lần đầu / Reset | Tải toàn bộ nội dung |
| INCREMENTAL | Hàng ngày | Chỉ tải nội dung mới |
| FORCED | Khẩn cấp | Bắt buộc tải ngay |

---

### CDN (Content Delivery Network)
> **Phát âm**: /siː diː en/

**Định nghĩa**: Mạng lưới máy chủ phân tán toàn cầu, giúp phân phối nội dung (video, hình ảnh) nhanh chóng đến thiết bị.

**Cách hoạt động đơn giản**:
```
Không có CDN:
  Thiết bị ở HCM ──────────► Server ở Singapore
                   (chậm, xa)

Có CDN:
  Thiết bị ở HCM ──► CDN Node ở HCM ──► Server
                   (nhanh, gần)
```

**Lợi ích**:
- Tải nội dung nhanh hơn 5-10 lần
- Giảm tải cho server chính
- Ổn định hơn khi nhiều thiết bị tải cùng lúc

---

### API (Application Programming Interface)
> **Phát âm**: /ˌeɪ piː ˈaɪ/

**Định nghĩa**: "Cổng giao tiếp" cho phép các phần mềm khác nhau nói chuyện với nhau.

**Ví dụ dễ hiểu**:
Giống như menu nhà hàng:
- Bạn (App) đọc menu và gọi món
- Phục vụ (API) chuyển order vào bếp
- Bếp (Server) làm món và trả ra
- Bạn nhận được món ăn (dữ liệu)

**API trong RMN-Arms**:
```
POST /campaigns          → Tạo chiến dịch mới
GET /campaigns/123       → Xem thông tin chiến dịch 123
POST /wallet/topup       → Nạp tiền vào ví
POST /devices/heartbeat  → Thiết bị báo cáo trạng thái
```

---

### JWT (JSON Web Token)
> **Phát âm**: /dʒɒt/ hoặc /ˌdʒeɪ dʌbəljuː ˈtiː/

**Định nghĩa**: "Thẻ ra vào" kỹ thuật số, chứng minh bạn là ai và có quyền làm gì trong hệ thống.

**Cách hoạt động**:
```
1. Bạn đăng nhập (email + password)
2. Server kiểm tra đúng → cấp JWT token
3. Mỗi lần gọi API, bạn gửi kèm JWT
4. Server kiểm tra JWT → cho phép hoặc từ chối
```

**Ví dụ JWT** (đã đơn giản hóa):
```
{
  "user_id": "user-123",
  "email": "admin@company.com",
  "role": "ADVERTISER",
  "expires": "2026-01-24 00:00:00"
}
```

---

### Webhook
> **Phát âm**: /ˈwebhʊk/

**Định nghĩa**: Cơ chế "gọi điện thông báo" - khi có sự kiện xảy ra, hệ thống tự động gửi thông tin đến URL bạn chỉ định.

**Ví dụ**:
```
Sự kiện: Chiến dịch hết ngân sách
    ↓
Hệ thống gọi webhook: POST https://your-app.com/notify
    ↓
App của bạn nhận được thông báo ngay lập tức
```

**Khác với API thông thường**:
- API: Bạn hỏi → Server trả lời (Polling)
- Webhook: Server có tin → Tự gọi cho bạn (Push)

---

## 💰 Thuật ngữ Thanh toán

### CPM (Cost Per Mille)
> **Phát âm**: /ˌsiː piː ˈem/

**Định nghĩa**: Chi phí cho mỗi 1000 lượt hiển thị (Mille = 1000 trong tiếng Latin).

**Công thức**:
```
Chi phí = (Số impression × Giá CPM) ÷ 1000

Ví dụ:
- Giá CPM: $5
- Số impression: 10,000
- Chi phí = (10,000 × $5) ÷ 1000 = $50
```

**CPM thay đổi theo**:
| Yếu tố | CPM thấp | CPM cao |
|--------|----------|---------|
| Khung giờ | Sáng sớm (6-9h) | Giờ vàng (18-21h) |
| Vị trí | Cửa hàng nhỏ | Trung tâm thương mại |
| Loại cửa hàng | Cửa hàng tạp hóa | Flagship store |
| Lượng khách | < 500 người/ngày | > 5000 người/ngày |

---

### Wallet (Ví)
> **Phát âm**: /ˈwɒlɪt/

**Định nghĩa**: Tài khoản tiền điện tử trong hệ thống, dùng để thanh toán (Advertiser) hoặc nhận tiền (Supplier).

**Các loại số dư**:
| Loại | Tiếng Việt | Giải thích |
|------|------------|------------|
| Available Balance | Số dư khả dụng | Tiền có thể dùng ngay |
| Held Balance | Số dư tạm giữ | Tiền đang giữ cho chiến dịch |
| Pending Balance | Số dư chờ xử lý | Tiền đang nạp/rút, chưa hoàn tất |

**Ví dụ**:
```
Tổng tiền trong ví: 10,000,000 VNĐ
├── Khả dụng: 3,000,000 VNĐ (có thể tạo chiến dịch mới)
├── Tạm giữ: 6,000,000 VNĐ (đang dùng cho 2 chiến dịch)
└── Chờ xử lý: 1,000,000 VNĐ (đang nạp từ ngân hàng)
```

---

### Top-up (Nạp tiền)
> **Phát âm**: /tɒp ʌp/

**Định nghĩa**: Hành động thêm tiền vào ví Advertiser.

**Các phương thức**:
- 💳 Thẻ tín dụng/ghi nợ (Visa, Mastercard)
- 🏦 Chuyển khoản ngân hàng
- 📱 Ví điện tử (MoMo, ZaloPay...)

**Quy trình**:
```
1. Advertiser chọn số tiền nạp
2. Chọn phương thức thanh toán
3. Hoàn tất thanh toán
4. Tiền vào Pending Balance
5. Xác nhận xong → chuyển sang Available Balance
```

---

### Withdrawal (Rút tiền)
> **Phát âm**: /wɪðˈdrɔːəl/

**Định nghĩa**: Hành động chuyển tiền từ ví Supplier về tài khoản ngân hàng.

**Điều kiện rút tiền**:
- ✅ Số dư khả dụng ≥ Số tiền tối thiểu ($50)
- ✅ Đã xác minh tài khoản ngân hàng
- ✅ Không có tranh chấp đang xử lý

**Thời gian xử lý**:
| Phương thức | Thời gian |
|-------------|-----------|
| Chuyển khoản nội địa | 1-2 ngày làm việc |
| Chuyển khoản quốc tế | 3-5 ngày làm việc |

---

### Refund (Hoàn tiền)
> **Phát âm**: /ˈriːfʌnd/

**Định nghĩa**: Trả lại tiền cho Advertiser trong các trường hợp đặc biệt.

**Khi nào được hoàn tiền**:
- Chiến dịch bị hủy trước khi chạy → hoàn 100%
- Chiến dịch bị dừng giữa chừng → hoàn phần chưa dùng
- Impression bị phát hiện gian lận → hoàn tiền impression đó
- Lỗi hệ thống → hoàn theo thỏa thuận

---

### Revenue Share (Chia sẻ doanh thu)
> **Phát âm**: /ˈrevənjuː ʃeə/

**Định nghĩa**: Cách phân chia tiền quảng cáo giữa Supplier và Platform.

**Tỷ lệ mặc định**:
```
100% Doanh thu từ Impression
    ├── 80% → Supplier (chủ cửa hàng)
    └── 20% → Platform (RMN-Arms)
```

**Ví dụ**:
```
Chiến dịch chi $1000 cho 200,000 impressions
├── Supplier nhận: $1000 × 80% = $800
└── Platform nhận: $1000 × 20% = $200
```

---

## 🚦 Thuật ngữ Trạng thái

### Campaign Status (Trạng thái chiến dịch)

| Trạng thái | Tiếng Việt | Mô tả |
|------------|------------|-------|
| `DRAFT` | Nháp | Đang tạo, chưa gửi |
| `PENDING_APPROVAL` | Chờ duyệt | Đã gửi, đang chờ admin duyệt |
| `SCHEDULED` | Đã lên lịch | Đã duyệt, chờ đến ngày bắt đầu |
| `ACTIVE` | Đang chạy | Chiến dịch đang hoạt động |
| `PAUSED` | Tạm dừng | Tạm ngưng (có thể chạy lại) |
| `COMPLETED` | Hoàn thành | Kết thúc bình thường |
| `CANCELLED` | Đã hủy | Hủy bỏ (không chạy lại được) |
| `REJECTED` | Bị từ chối | Admin không duyệt |

---

### Device Status (Trạng thái thiết bị)

| Trạng thái | Tiếng Việt | Mô tả |
|------------|------------|-------|
| `REGISTERED` | Đã đăng ký | Mới đăng ký, chưa kích hoạt |
| `ACTIVE` | Hoạt động | Online và phát quảng cáo bình thường |
| `OFFLINE` | Ngoại tuyến | Mất kết nối (tạm thời) |
| `MAINTENANCE` | Bảo trì | Đang bảo trì theo lịch |
| `DECOMMISSIONED` | Ngừng hoạt động | Đã gỡ bỏ vĩnh viễn |

---

### Impression Status (Trạng thái lượt hiển thị)

| Trạng thái | Tiếng Việt | Mô tả |
|------------|------------|-------|
| `PENDING` | Chờ xác minh | Đang kiểm tra tính hợp lệ |
| `VERIFIED` | Đã xác minh | Hợp lệ, đã tính tiền |
| `REJECTED` | Bị từ chối | Không hợp lệ, không tính tiền |
| `UNDER_REVIEW` | Đang xem xét | Cần admin kiểm tra thủ công |
| `DISPUTED` | Đang tranh chấp | Advertiser khiếu nại |

---

### Wallet Transaction Types (Loại giao dịch ví)

| Loại | Tiếng Việt | Mô tả |
|------|------------|-------|
| `DEPOSIT` | Nạp tiền | Advertiser nạp tiền vào ví |
| `WITHDRAWAL` | Rút tiền | Supplier rút tiền về ngân hàng |
| `CAMPAIGN_HOLD` | Tạm giữ cho chiến dịch | Giữ ngân sách khi tạo chiến dịch |
| `CAMPAIGN_CHARGE` | Trừ tiền impression | Tính phí cho mỗi lượt hiển thị |
| `REFUND` | Hoàn tiền | Trả lại tiền chưa dùng |
| `REVENUE` | Doanh thu | Supplier nhận tiền từ impression |

---

## 📝 Viết tắt thường dùng

| Viết tắt | Đầy đủ | Nghĩa tiếng Việt |
|----------|--------|------------------|
| RMN | Retail Media Network | Mạng quảng cáo bán lẻ |
| CPM | Cost Per Mille | Chi phí mỗi 1000 lượt hiển thị |
| CTR | Click-Through Rate | Tỷ lệ nhấp chuột |
| API | Application Programming Interface | Giao diện lập trình ứng dụng |
| JWT | JSON Web Token | Token xác thực |
| CDN | Content Delivery Network | Mạng phân phối nội dung |
| UUID | Universally Unique Identifier | Mã định danh duy nhất |
| CRUD | Create, Read, Update, Delete | Tạo, Đọc, Sửa, Xóa |
| SLA | Service Level Agreement | Cam kết chất lượng dịch vụ |
| KPI | Key Performance Indicator | Chỉ số đánh giá hiệu quả |
| ROI | Return on Investment | Tỷ suất hoàn vốn |
| SDK | Software Development Kit | Bộ công cụ phát triển |
| CMS | Content Management System | Hệ thống quản lý nội dung |
| POS | Point of Sale | Điểm bán hàng |
| GPS | Global Positioning System | Hệ thống định vị toàn cầu |
| SSL/TLS | Secure Sockets Layer | Mã hóa bảo mật |
| RBAC | Role-Based Access Control | Phân quyền theo vai trò |
| KYC | Know Your Customer | Xác minh khách hàng |
| AML | Anti-Money Laundering | Chống rửa tiền |

---

## 🔗 Tham khảo nhanh

### Công thức tính toán quan trọng

```
Chi phí Advertiser = (Impressions × CPM) ÷ 1000

Doanh thu Supplier = Chi phí Advertiser × 80%

Doanh thu Platform = Chi phí Advertiser × 20%

Uptime % = (Thời gian online ÷ Tổng thời gian) × 100

Quality Score = (Viewability + Completion + Proof) ÷ 3
```

### Ngưỡng quan trọng

| Metric | Ngưỡng | Ý nghĩa |
|--------|--------|---------|
| Heartbeat timeout | 10 phút | Quá thời gian này → OFFLINE |
| Min impression duration | 80% | Dưới mức này → không tính |
| Min top-up | $10 | Số tiền nạp tối thiểu |
| Min withdrawal | $50 | Số tiền rút tối thiểu |
| Campaign min budget | $100 | Ngân sách chiến dịch tối thiểu |
| Campaign max duration | 365 ngày | Thời gian chiến dịch tối đa |
| Device uptime target | 95% | Mục tiêu thời gian hoạt động |

---

**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team
