# 🎨 Quy tắc Nghiệp vụ: Hệ thống Quản lý Nội dung (CMS)

**Phiên bản**: 1.0  
**Ngày**: 2026-01-23  
**Trạng thái**: Bản nháp  
**Chủ quản**: Product Team

---

## 📖 Mục lục

1. [Tổng quan](#-tổng-quan)
2. [Thực thể Tài sản Nội dung](#-thực-thể-tài-sản-nội-dung)
3. [Upload & Kiểm tra Nội dung](#-upload--kiểm-tra-nội-dung)
4. [Kiểm duyệt & Phê duyệt](#-kiểm-duyệt--phê-duyệt)
5. [Thư viện & Tổ chức Nội dung](#-thư-viện--tổ-chức-nội-dung)
6. [Cấp phép & Quản lý Quyền](#-cấp-phép--quản-lý-quyền)
7. [Phân phối Nội dung & CDN](#-phân-phối-nội-dung--cdn)
8. [Gán Nội dung cho Chiến dịch](#-gán-nội-dung-cho-chiến-dịch)
9. [Phân tích Hiệu suất Nội dung](#-phân-tích-hiệu-suất-nội-dung)
10. [Phiên bản & Lịch sử Nội dung](#-phiên-bản--lịch-sử-nội-dung)
11. [Lưu trữ & Xóa Nội dung](#-lưu-trữ--xóa-nội-dung)
12. [Điểm Tích hợp](#-điểm-tích-hợp)
13. [Các trường hợp đặc biệt](#-các-trường-hợp-đặc-biệt)
14. [Công thức Nghiệp vụ](#-công-thức-nghiệp-vụ)

---

## 🎯 Tổng quan

### 1.1 Mục đích

Hệ thống Quản lý Nội dung (CMS) quản lý tất cả tài sản sáng tạo quảng cáo hiển thị trên thiết bị signage kỹ thuật số. Nó xử lý:
- Upload, kiểm tra và lưu trữ nội dung
- Luồng công việc kiểm duyệt và phê duyệt
- Tổ chức và tìm kiếm thư viện nội dung
- Phân phối nội dung qua CDN
- Theo dõi hiệu suất nội dung

### 1.2 Vòng đời Nội dung

```
UPLOADED → PROCESSING → PENDING_APPROVAL → APPROVED → ACTIVE → ARCHIVED
                             ↓
                          REJECTED
```

**Định nghĩa Trạng thái**:
- **UPLOADED**: File upload thành công, chờ xử lý
- **PROCESSING**: Hệ thống đang xử lý file (chuyển mã, tạo thumbnail, kiểm tra)
- **PENDING_APPROVAL**: Chờ người kiểm duyệt xem xét
- **APPROVED**: Đạt kiểm duyệt, sẵn sàng dùng trong chiến dịch
- **REJECTED**: Không đạt kiểm duyệt hoặc kiểm tra
- **ACTIVE**: Hiện đang được dùng trong chiến dịch active
- **ARCHIVED**: Không còn dùng, chuyển vào lưu trữ

### 1.3 Loại Nội dung Hỗ trợ

| Loại | Định dạng | Kích thước Tối đa | Trường hợp Sử dụng |
|------|-----------|-------------------|-------------------|
| **Hình ảnh** | JPG, PNG, GIF, WebP, SVG | 10 MB | Quảng cáo tĩnh, banner |
| **Video** | MP4 (H.264), WebM, MOV | 500 MB | Quảng cáo video, đồ họa chuyển động |
| **Âm thanh** | MP3, AAC, WAV | 50 MB | Quảng cáo chỉ âm thanh (cho màn hình có âm thanh) |
| **Tài liệu** | PDF | 20 MB | Bảng menu, hiển thị thông tin |
| **HTML5** | ZIP (HTML/CSS/JS) | 50 MB | Quảng cáo tương tác, rich media |

---

## 📦 Thực thể Tài sản Nội dung

### 2.1 Thuộc tính Cốt lõi

```typescript
interface ContentAsset {
  // Định danh
  asset_id: string                       // UUID, khóa chính
  advertiser_id: string                  // FK đến advertiser (chủ sở hữu)
  user_id: string                        // FK đến user đã upload

  // Thông tin File
  file_name: string                      // Tên file gốc
  file_type: ContentType                 // IMAGE | VIDEO | AUDIO | DOCUMENT | HTML5
  mime_type: string                      // "image/jpeg", "video/mp4", v.v.
  file_size_bytes: number                // Kích thước file (bytes)
  file_hash: string                      // Hash SHA-256 (để loại trùng)

  // Lưu trữ
  storage_url: string                    // URL S3/GCS (file gốc)
  cdn_url: string                        // URL CloudFront/Cloudflare (đã cache)
  thumbnail_url: string | null           // Thumbnail xem trước (cho video/PDF)

  // Thuộc tính Media (nếu áp dụng)
  width: number | null                   // Chiều rộng pixel (hình ảnh/video)
  height: number | null                  // Chiều cao pixel (hình ảnh/video)
  aspect_ratio: string | null            // "16:9", "9:16", "1:1", v.v.
  duration_seconds: number | null        // Thời lượng (video/âm thanh)
  frame_rate: number | null              // FPS (video)
  bitrate_kbps: number | null           // Bitrate (video/âm thanh)
  codec: string | null                   // "H.264", "VP9", v.v.

  // Metadata
  title: string                          // Tên hiển thị
  description: string | null             // Mô tả tùy chọn
  tags: string[]                         // Tag do user định nghĩa để tìm kiếm
  category: string | null                // "Food", "Fashion", "Electronics", v.v.
  brand: string | null                   // Tên thương hiệu (nếu áp dụng)

  // Vòng đời
  status: ContentStatus                  
  uploaded_at: Date
  processed_at: Date | null
  approved_at: Date | null
  rejected_at: Date | null
  archived_at: Date | null

  // Kiểm duyệt
  moderation_status: ModerationStatus    // PENDING | APPROVED | REJECTED | FLAGGED
  moderation_score: number | null        // Điểm tin cậy AI (0-100)
  moderation_flags: string[]             // ["adult_content", "violence", v.v.]
  moderated_by_user_id: string | null    // ID user đánh giá thủ công
  moderation_notes: string | null

  // Sử dụng & Hiệu suất
  used_in_campaigns_count: number        // Số chiến dịch dùng tài sản này
  total_impressions: number              // Tổng impression qua tất cả chiến dịch
  total_clicks: number | null            // Click (nếu nội dung tương tác)
  average_ctr: number | null             // Tỷ lệ click (%)

  // Cấp phép & Quyền
  license_type: LicenseType              // OWNED | LICENSED | STOCK | USER_GENERATED
  license_expiry_date: Date | null       // Ngày hết hạn cho nội dung được cấp phép
  rights_holder: string | null           // Người sở hữu nội dung
  usage_rights_confirmed: boolean        // Advertiser xác nhận có quyền

  // Tổ chức
  folder_id: string | null               // FK đến folder (để tổ chức)
  is_favorite: boolean                   // User đánh dấu yêu thích

  // Metadata
  created_at: Date
  updated_at: Date
  deleted_at: Date | null                // Xóa mềm
}

enum ContentType {
  IMAGE = "IMAGE",
  VIDEO = "VIDEO",
  AUDIO = "AUDIO",
  DOCUMENT = "DOCUMENT",
  HTML5 = "HTML5"
}

enum ContentStatus {
  UPLOADED = "UPLOADED",
  PROCESSING = "PROCESSING",
  PENDING_APPROVAL = "PENDING_APPROVAL",
  APPROVED = "APPROVED",
  REJECTED = "REJECTED",
  ACTIVE = "ACTIVE",
  ARCHIVED = "ARCHIVED"
}

enum ModerationStatus {
  PENDING = "PENDING",
  APPROVED = "APPROVED",
  REJECTED = "REJECTED",
  FLAGGED = "FLAGGED"           // Yêu cầu đánh giá thủ công
}

enum LicenseType {
  OWNED = "OWNED",                       // Advertiser sở hữu nội dung
  LICENSED = "LICENSED",                 // Được cấp phép từ bên thứ ba
  STOCK = "STOCK",                       // Ảnh/video stock
  USER_GENERATED = "USER_GENERATED"      // UGC có phép
}
```

### 2.2 Thực thể Liên quan

#### ContentFolder (Thư mục Nội dung)
```typescript
interface ContentFolder {
  folder_id: string                      // UUID
  advertiser_id: string                  // FK đến advertiser
  parent_folder_id: string | null        // Cho folder lồng nhau
  folder_name: string                    // "Summer Campaign 2026"
  description: string | null
  asset_count: number                    // Số tài sản trong folder
  created_at: Date
  updated_at: Date
}
```

#### ContentVersion (Phiên bản Nội dung)
```typescript
interface ContentVersion {
  version_id: string                     // UUID
  asset_id: string                       // FK đến content_asset
  version_number: number                 // 1, 2, 3, ...
  file_url: string                       // URL đến phiên bản này
  change_description: string             // "Cập nhật kích thước logo"
  created_by_user_id: string
  created_at: Date
}
```

#### ContentTag (Tag Nội dung)
```typescript
interface ContentTag {
  tag_id: string                         // UUID
  advertiser_id: string                  // FK (tag theo advertiser)
  tag_name: string                       // "sale", "holiday", "new-product"
  usage_count: number                    // Số tài sản có tag này
  created_at: Date
}
```

---

## 📤 Upload & Kiểm tra Nội dung

### 3.1 Quy trình Upload

**Luồng Upload**:
1. **Kiểm tra Trước Upload**: Kiểm tra kích thước file, loại, quyền user
2. **Upload vào Lưu trữ**: Upload trực tiếp vào S3/GCS với presigned URL
3. **Xử lý**: Kiểm tra file, trích xuất metadata, tạo thumbnail
4. **Kiểm duyệt**: Kiểm duyệt AI + đánh giá thủ công tùy chọn
5. **Phê duyệt**: Tài sản đánh dấu APPROVED và sẵn sàng dùng

### 3.2 Kiểm tra Trước Upload

**Quy tắc 3.2.1: Kiểm tra Loại File**
```
Loại file CHO PHÉP theo cấp:

TẤT CẢ CẤP:
  • Hình ảnh: JPG, PNG, GIF, WebP
  • Video: MP4 (codec H.264)

PROFESSIONAL & ENTERPRISE:
  • Hình ảnh: + SVG
  • Video: + WebM, MOV
  • Âm thanh: MP3, AAC, WAV
  • HTML5: Gói ZIP

NẾU loại file upload không được phép cho cấp:
  • TỪ CHỐI upload
  • HIỂN THỊ: "Nâng cấp lên {tier} để upload file {file_type}"
```

**Quy tắc 3.2.2: Kiểm tra Kích thước File**
```
Kích thước file tối đa:

• Hình ảnh: 10 MB
• Video: 500 MB
• Âm thanh: 50 MB
• Tài liệu: 20 MB
• HTML5: 50 MB (giới hạn kích thước giải nén: 100 MB)

NẾU file vượt giới hạn:
  • TỪ CHỐI upload
  • GỢI Ý: "Nén file xuống dưới {limit}"
  • CUNG CẤP: Link đến công cụ nén
```

**Quy tắc 3.2.3: Kiểm tra Tên File**
```
Tên file PHẢI:
  • Từ 1-255 ký tự
  • Không chứa ký tự đặc biệt: < > : " / \ | ? *
  • Không là phần mở rộng file thực thi (.exe, .sh, .bat, v.v.)

LÀM SẠCH:
  • Xóa ký tự đặc biệt
  • Thay thế khoảng trắng bằng dấu gạch dưới
  • Chuyển sang chữ thường (tùy chọn, để nhất quán)

VÍ DỤ:
  Gốc: "My Ad Campaign #1 (Final).jpg"
  Đã làm sạch: "my_ad_campaign_1_final.jpg"
```

**Quy tắc 3.2.4: Thực thi Hạn ngạch**
```
Hạn ngạch lưu trữ theo cấp:

FREE:         1 GB lưu trữ tổng, tối đa 100 tài sản
BASIC:        10 GB lưu trữ tổng, tối đa 500 tài sản
PREMIUM:      50 GB lưu trữ tổng, tối đa 2000 tài sản
ENTERPRISE:   500 GB+ (tùy chỉnh), tài sản không giới hạn

NẾU advertiser vượt hạn ngạch:
  • TỪ CHỐI upload
  • THÔNG BÁO: "Bạn đã đạt giới hạn lưu trữ. Nâng cấp hoặc xóa tài sản không dùng."
  • HIỂN THỊ: Thống kê sử dụng hiện tại và tùy chọn nâng cấp
```

### 3.3 Xử lý Upload

**Quy tắc 3.3.1: Hash File & Loại trùng**
```
KHI file được upload:
  1. TÍNH hash SHA-256 của file
  2. KIỂM TRA nếu hash tồn tại trong thư viện advertiser
  3. NẾU tìm thấy trùng:
     • TÙY CHỌN A (mặc định): Bỏ qua upload, dùng lại tài sản hiện có
     • TÙY CHỌN B: Tạo tài sản mới tham chiếu cùng file (tiết kiệm lưu trữ)
     • THÔNG BÁO user: "File này đã tồn tại là '{existing_asset_name}'"

LỢI ÍCH:
  • Tiết kiệm chi phí lưu trữ
  • Ngăn upload trùng
  • Liên kết tất cả chiến dịch đến file nguồn đơn
```

**Quy tắc 3.3.2: Xử lý Media**
```
SAU upload, tự động xử lý:

CHO HÌNH ẢNH:
  1. Kiểm tra định dạng hình ảnh (đảm bảo không hỏng)
  2. Trích xuất kích thước (rộng x cao)
  3. Tính tỷ lệ khung hình
  4. Tạo thumbnail (300x300px)
  5. Tối ưu cho web (nếu cần)

CHO VIDEO:
  1. Kiểm tra codec video (H.264 cần cho tương thích)
  2. Trích xuất metadata (thời lượng, kích thước, frame rate, bitrate)
  3. Tạo thumbnail (khung đầu hoặc giữa)
  4. Tạo GIF xem trước (3 giây, tùy chọn)
  5. Chuyển mã sang nhiều độ phân giải (480p, 720p, 1080p) cho streaming thích ứng

CHO ÂM THANH:
  1. Kiểm tra định dạng âm thanh
  2. Trích xuất thời lượng, bitrate, codec
  3. Tạo hình ảnh sóng âm (thumbnail)

CHO HTML5:
  1. Giải nén gói
  2. Kiểm tra cấu trúc (index.html có mặt)
  3. Quét mã độc hại (XSS, script bên ngoài)
  4. Kiểm tra giới hạn kích thước file
  5. Tạo screenshot HTML đã render

THỜI GIAN XỬ LÝ:
  • Hình ảnh: < 5 giây
  • Video: 1-10 phút (tùy độ dài)
  • HTML5: < 30 giây
```

**Quy tắc 3.3.3: Trích xuất Metadata**
```
Tự động trích xuất metadata từ file:

TỪ DỮ LIỆU EXIF HÌNH ẢNH:
  • Model máy ảnh, vị trí (GPS), ngày chụp
  • LƯU Ý: Loại bỏ metadata nhạy cảm trước khi dùng công khai (riêng tư)

TỪ METADATA VIDEO:
  • Ngày tạo, thiết bị, vị trí
  • Phần mềm chỉnh sửa đã dùng

LƯU TRỮ metadata cho:
  • Debug (vấn đề chất lượng)
  • Xác minh nội dung
  • KHÔNG hiển thị công khai (riêng tư)
```

### 3.4 Xử lý Lỗi Upload

**Quy tắc 3.4.1: Khôi phục Upload Thất bại**
```
NẾU upload thất bại giữa chừng:
  • TỰ ĐỘNG thử lại (tối đa 3 lần)
  • Hỗ trợ upload có thể tiếp tục (upload theo chunk)
  • Cung cấp thông báo lỗi rõ ràng cho user

LỖI PHỔ BIẾN:
  • Timeout mạng: "Upload bị gián đoạn. Click để thử lại."
  • File không hợp lệ: "File bị hỏng hoặc định dạng không hợp lệ."
  • Vượt hạn ngạch: "Vượt hạn ngạch lưu trữ. Nâng cấp hoặc xóa tài sản."
```

**Quy tắc 3.4.2: Thất bại Xử lý**
```
NẾU xử lý thất bại:
  • ĐẶT status = "PROCESSING_FAILED"
  • THÔNG BÁO user với lý do
  • CUNG CẤP tùy chọn upload lại hoặc liên hệ hỗ trợ

THẤT BẠI PHỔ BIẾN:
  • File hỏng: "Không thể xử lý file. Thử xuất lại."
  • Codec không hỗ trợ: "Codec video không được hỗ trợ. Dùng H.264."
  • Timeout: "File quá lớn để xử lý. Nén và thử lại."
```

---

## ✅ Kiểm duyệt & Phê duyệt

### 4.1 Quy trình Kiểm duyệt

**Kiểm duyệt Hai Cấp**:
1. **Kiểm duyệt AI Tự động**: Tất cả upload được quét bởi AI
2. **Đánh giá Thủ công**: Nội dung bị gắn cờ hoặc lấy mẫu ngẫu nhiên

### 4.2 Kiểm duyệt AI

**Quy tắc 4.2.1: Quét Nội dung Tự động**
```
MỖI tài sản upload được quét bởi AI cho:
  • Nội dung người lớn/tình dục
  • Bạo lực/máu me
  • Biểu tượng/lời nói thù hận
  • Nội dung có bản quyền (tìm kiếm tương tự hình ảnh)
  • Văn bản không phù hợp (OCR + NLP)
  • Vũ khí, ma túy, rượu (cho danh mục hạn chế)

AI TRẢ VỀ:
  • moderation_score: 0-100 (100 = an toàn, 0 = không an toàn)
  • moderation_flags: Danh sách vấn đề phát hiện

NGƯỠNG CHẤM ĐIỂM:
  • Điểm 90-100: TỰ ĐỘNG PHÊ DUYỆT
  • Điểm 70-89: GẮN CỜ để đánh giá thủ công
  • Điểm < 70: TỰ ĐỘNG TỪ CHỐI
```

**Quy tắc 4.2.2: Phê duyệt Tự động**
```
NẾU moderation_score >= 90:
  • ĐẶT moderation_status = "APPROVED"
  • ĐẶT status = "APPROVED"
  • THÔNG BÁO advertiser: "Nội dung của bạn đã được phê duyệt"
  • Tài sản sẵn sàng dùng trong chiến dịch

BỎ QUA đánh giá thủ công (tiết kiệm thời gian và chi phí)
```

**Quy tắc 4.2.3: Từ chối Tự động**
```
NẾU moderation_score < 70:
  • ĐẶT moderation_status = "REJECTED"
  • ĐẶT status = "REJECTED"
  • THÔNG BÁO advertiser với lý do:
    - "Nội dung vi phạm chính sách: {policy_name}"
    - Cờ cụ thể: "Phát hiện nội dung người lớn"
  • CUNG CẤP: Link đến chính sách nội dung

TÀI SẢN KHÔNG THỂ dùng trong chiến dịch
ADVERTISER có thể kháng cáo hoặc upload phiên bản đã sửa
```

**Quy tắc 4.2.4: Gắn cờ Đánh giá Thủ công**
```
NẾU moderation_score 70-89:
  • ĐẶT moderation_status = "FLAGGED"
  • ĐẶT status = "PENDING_APPROVAL"
  • THÊM vào hàng đợi đánh giá thủ công
  • THÔNG BÁO advertiser: "Nội dung của bạn đang được xem xét"

SLA ĐÁNH GIÁ THỦ CÔNG:
  • Tiêu chuẩn: 24 giờ
  • Enterprise: 4 giờ
```

### 4.3 Đánh giá Thủ công

**Quy tắc 4.3.1: Hàng đợi Đánh giá**
```
Người đánh giá thủ công xem hàng đợi nội dung bị gắn cờ:
  • Sắp xếp theo ưu tiên (khách Enterprise trước)
  • Hiển thị thumbnail tài sản, cờ AI, metadata
  • Tùy chọn người đánh giá:
    - APPROVE: Nội dung chấp nhận được
    - REJECT: Nội dung vi phạm chính sách
    - REQUEST_CHANGES: Cần chỉnh sửa nhỏ

NGƯỜI ĐÁNH GIÁ PHẢI:
  • Cung cấp lý do từ chối
  • Trích dẫn vi phạm chính sách cụ thể
```

**Quy tắc 4.3.2: Phê duyệt**
```
KHI người đánh giá phê duyệt:
  • ĐẶT moderation_status = "APPROVED"
  • ĐẶT status = "APPROVED"
  • ĐẶT moderated_by_user_id = ID người đánh giá
  • THÊM moderation_notes (tùy chọn)
  • THÔNG BÁO advertiser: "Nội dung của bạn đã được phê duyệt"
```

**Quy tắc 4.3.3: Từ chối**
```
KHI người đánh giá từ chối:
  • ĐẶT moderation_status = "REJECTED"
  • ĐẶT status = "REJECTED"
  • ĐẶT moderated_by_user_id = ID người đánh giá
  • YÊU CẦU rejection_reason (từ danh sách định sẵn + tùy chỉnh)
  • THÔNG BÁO advertiser với lý do chi tiết

TÙY CHỌN ADVERTISER:
  • Kháng cáo quyết định (yêu cầu xem xét lại)
  • Upload phiên bản đã sửa
  • Xóa tài sản
```

### 4.4 Chính sách Nội dung

**Nội dung Bị cấm**:
- Nội dung người lớn/tình dục
- Bạo lực, máu me, hoặc hình ảnh đồ họa
- Lời nói thù hận, phân biệt đối xử
- Tuyên bố gây hiểu lầm/lừa dối
- Sản phẩm hoặc dịch vụ bất hợp pháp
- Vũ khí, chất nổ
- Vi phạm bản quyền/thương hiệu

**Nội dung Hạn chế** (yêu cầu phê duyệt):
- Quảng cáo rượu (giới hạn độ tuổi)
- Cờ bạc (chỉ advertiser được cấp phép)
- Chiến dịch chính trị (phê duyệt đặc biệt)
- Chăm sóc sức khỏe/dược phẩm (tuân thủ quy định)
- Dịch vụ tài chính (yêu cầu công khai)

**Quy tắc 4.4.1: Quy tắc Cụ thể Danh mục**
```
QUẢNG CÁO RƯỢU:
  • YÊU CẦU: Giấy phép advertiser bán rượu
  • YÊU CẦU: Giới hạn tuổi (21+ ở Mỹ)
  • PHẢI hiển thị: Thông điệp "Uống có trách nhiệm"
  • KHÔNG nhắm mục tiêu gần trường học

QUẢNG CÁO CỜ BẠC:
  • YÊU CẦU: Giấy phép cờ bạc
  • YÊU CẦU: Giới hạn tuổi (21+ hoặc 18+ tùy khu vực)
  • PHẢI hiển thị: Đường dây nóng chơi game có trách nhiệm

QUẢNG CÁO DƯỢC PHẨM:
  • YÊU CẦU: Tài liệu phê duyệt FDA
  • PHẢI hiển thị: Công khai đầy đủ tác dụng phụ
  • KHÔNG THỂ đưa ra tuyên bố sức khỏe chưa được phê duyệt
```

### 4.5 Quy trình Kháng cáo

**Quy tắc 4.5.1: Kháng cáo Từ chối Nội dung**
```
KHI advertiser kháng cáo từ chối:
  1. TẠO yêu cầu kháng cáo
  2. YÊU CẦU: Giải thích tại sao nội dung nên được phê duyệt
  3. TÙY CHỌN: Upload phiên bản đã sửa
  4. LEO THANG lên người đánh giá cấp cao

SLA ĐÁNH GIÁ KHÁNG CÁO:
  • Tiêu chuẩn: 48 giờ
  • Enterprise: 8 giờ

KẾT QUẢ:
  • Phê duyệt: Quyết định ban đầu bị lật lại
  • Từ chối: Quyết định ban đầu giữ nguyên (cuối cùng)
  • Yêu cầu Thay đổi: Cần chỉnh sửa cụ thể

GIỚI HẠN: 1 kháng cáo mỗi tài sản
```

---

## 📚 Thư viện & Tổ chức Nội dung

### 5.1 Cấu trúc Thư viện

**Phân cấp Thư mục**:
```
Thư viện Nội dung Advertiser
├── Summer 2026 Campaign
│   ├── Images
│   ├── Videos
│   └── Archived
├── Holiday Campaign
└── Evergreen Content
    ├── Logos
    └── Product Images
```

**Quy tắc 5.1.1: Tạo Thư mục**
```
Advertiser có thể tạo thư mục để tổ chức tài sản:
  • Thư mục không giới hạn (tất cả cấp)
  • Thư mục lồng nhau (tối đa 5 cấp)
  • Tên thư mục: 1-100 ký tự

THỦ MỤC MẶC ĐỊNH (tự động tạo):
  • "Uncategorized" (vị trí upload mặc định)
  • "Favorites"
  • "Recently Uploaded"
```

**Quy tắc 5.1.2: Di chuyển Tài sản**
```
Tài sản có thể di chuyển giữa các thư mục:
  • Kéo thả trong UI
  • Di chuyển hàng loạt (chọn nhiều tài sản)
  • Di chuyển KHÔNG ảnh hưởng chiến dịch dùng tài sản

KHÔNG ẢNH HƯỞNG URL tài sản (URL giữ nguyên)
```

### 5.2 Tìm kiếm & Lọc

**Quy tắc 5.2.1: Chức năng Tìm kiếm**
```
TÌM KIẾM qua:
  • Tiêu đề tài sản
  • Mô tả
  • Tag
  • Tên file
  • Metadata (thương hiệu, danh mục)

TÍNH NĂNG TÌM KIẾM:
  • Tìm kiếm toàn văn
  • Gợi ý tự động hoàn thành
  • Tìm kiếm trong thư mục
  • Lưu truy vấn tìm kiếm (để dùng lại)

VÍ DỤ TRUY VẤN:
  • "summer sale" → Khớp tiêu đề, mô tả, tag
  • "type:video tag:fashion" → Lọc nâng cao
```

**Quy tắc 5.2.2: Lọc**
```
LỌC theo:
  • Loại nội dung (hình ảnh, video, v.v.)
  • Trạng thái (đã phê duyệt, đang chờ, từ chối)
  • Ngày upload (7 ngày gần, 30 ngày gần, khoảng tùy chỉnh)
  • Kích thước file (< 1MB, 1-10MB, > 10MB)
  • Kích thước (dọc, ngang, vuông)
  • Thời lượng (video/âm thanh)
  • Tag
  • Sử dụng (dùng trong chiến dịch vs chưa dùng)

KẾT HỢP nhiều bộ lọc với logic AND
```

**Quy tắc 5.2.3: Sắp xếp**
```
SẮP XẾP theo:
  • Ngày upload (mới nhất/cũ nhất)
  • Tên file (A-Z, Z-A)
  • Kích thước file (lớn nhất/nhỏ nhất)
  • Số lần dùng (nhiều nhất/ít nhất)
  • Tổng impression (nhiều nhất/ít nhất)

MẶC ĐỊNH: Sắp xếp theo ngày upload (mới nhất trước)
```

### 5.3 Thao tác Hàng loạt

**Quy tắc 5.3.1: Hành động Hàng loạt**
```
CHỌN nhiều tài sản và thực hiện hành động:
  • Di chuyển vào thư mục
  • Thêm tag
  • Xóa
  • Lưu trữ
  • Tải xuống (dạng ZIP)
  • Cập nhật metadata

GIỚI HẠN: 100 tài sản mỗi thao tác hàng loạt
```

**Quy tắc 5.3.2: Upload Hàng loạt**
```
Upload nhiều file cùng lúc:
  • Kéo thả nhiều file
  • Upload thư mục (bảo tồn cấu trúc)
  • Xử lý hàng đợi (xử lý ở nền)

GIỚI HẠN: 50 file mỗi phiên upload
TIẾN TRÌNH: Hiển thị tiến trình upload cho mỗi file
```

### 5.4 Yêu thích & Bộ sưu tập

**Quy tắc 5.4.1: Yêu thích**
```
User có thể đánh dấu tài sản yêu thích:
  • Truy cập nhanh tài sản thường dùng
  • Thư mục thông minh "Favorites" (tự động điền)
  • Trạng thái yêu thích theo user (không chia sẻ qua nhóm)
```

**Quy tắc 5.4.2: Bộ sưu tập Thông minh** (chỉ ENTERPRISE)
```
Bộ sưu tập tự động cập nhật dựa vào quy tắc:
  • "Quảng cáo hiệu suất cao" (CTR > 2%)
  • "Tài sản chưa dùng" (không dùng trong chiến dịch nào)
  • "Giấy phép sắp hết hạn" (giấy phép hết hạn < 30 ngày)

LÀM MỚI: Bộ sưu tập cập nhật hàng ngày
```

---

## 📜 Cấp phép & Quản lý Quyền

### 6.1 Xác nhận Quyền

**Quy tắc 6.1.1: Khai báo Quyền Sử dụng**
```
KHI upload nội dung, advertiser PHẢI xác nhận:
  • "Tôi sở hữu nội dung này HOẶC có phép sử dụng"
  • Loại giấy phép: OWNED | LICENSED | STOCK | USER_GENERATED

TUYÊN BỐ PHÁP LÝ hiển thị khi upload:
  • "Bạn chịu trách nhiệm đảm bảo có quyền sử dụng nội dung này"
  • "Vi phạm bản quyền có thể dẫn đến đình chỉ tài khoản"
```

**Quy tắc 6.1.2: Chọn Loại Giấy phép**
```
OWNED (Sở hữu):
  • Advertiser tạo nội dung nội bộ
  • Không hết hạn

LICENSED (Được cấp phép):
  • Nội dung được cấp phép từ bên thứ ba
  • YÊU CẦU: Ngày hết hạn giấy phép
  • CẢNH BÁO khi giấy phép hết hạn

STOCK:
  • Ảnh/video stock từ nhà cung cấp (Shutterstock, Getty, v.v.)
  • YÊU CẦU: Chi tiết giấy phép
  • Nền tảng KHÔNG xác minh tính hợp lệ giấy phép stock

USER_GENERATED (Do User tạo):
  • Nội dung từ khách hàng/user
  • YÊU CẦU: Chứng minh phép (mẫu phát hành đã ký)
```

### 6.2 Hết hạn Giấy phép

**Quy tắc 6.2.1: Theo dõi Hết hạn**
```
CHO nội dung được cấp phép có ngày hết hạn:
  • CẢNH BÁO advertiser 30 ngày trước hết hạn:
    "Giấy phép cho '{asset_name}' hết hạn vào {date}"
  • CẢNH BÁO lại 7 ngày trước hết hạn
  • VÀO ngày hết hạn:
    - ĐẶT status = "EXPIRED"
    - TẠM DỪNG chiến dịch dùng tài sản này
    - THÔNG BÁO advertiser: "Gia hạn giấy phép hoặc thay nội dung"

CHIẾN DỊCH BỊ ẢNH HƯỞNG:
  • Hiển thị cảnh báo: "Chiến dịch này dùng nội dung đã hết hạn"
  • Ngăn khởi chạy chiến dịch mới với nội dung đã hết hạn
```

**Quy tắc 6.2.2: Gia hạn Giấy phép**
```
Advertiser có thể cập nhật ngày hết hạn giấy phép:
  • Chỉnh sửa chi tiết tài sản
  • Cập nhật ngày hết hạn
  • YÊU CẦU: Xác nhận lại quyền

TIẾP TỤC chiến dịch tự động sau khi gia hạn
```

### 6.3 Khiếu nại Bản quyền

**Quy tắc 6.3.1: Quy trình Gỡ xuống DMCA**
```
NẾU nền tảng nhận thông báo gỡ xuống DMCA:
  1. ĐÌNH CHỈ tài sản ngay lập tức (đặt status = "SUSPENDED")
  2. TẠM DỪNG tất cả chiến dịch dùng tài sản
  3. THÔNG BÁO advertiser:
     • "Nội dung của bạn bị gắn cờ vi phạm bản quyền"
     • Cung cấp chi tiết người khiếu nại (theo DMCA)
     • Tùy chọn: Nộp phản khiếu HOẶC xóa nội dung
  4. ĐIỀU TRA khiếu nại

KẾT QUẢ:
  • Khiếu nại hợp lệ: Xóa vĩnh viễn tài sản, cảnh cáo advertiser
  • Khiếu nại không hợp lệ: Khôi phục tài sản, tiếp tục chiến dịch
  • Vi phạm lặp lại: Đình chỉ tài khoản advertiser
```

---

## 🌐 Phân phối Nội dung & CDN

### 7.1 Kiến trúc Lưu trữ

**Lưu trữ Ba Cấp**:
1. **Lưu trữ Gốc**: S3/GCS (file chính)
2. **Cache CDN Edge**: CloudFront/Cloudflare (phân phối nhanh)
3. **Cache Thiết bị**: Lưu trữ cục bộ trên thiết bị (khả năng offline)

### 7.2 Cấu hình CDN

**Quy tắc 7.2.1: Luồng Upload CDN**
```
KHI tài sản được upload và phê duyệt:
  1. LƯU file gốc trong lưu trữ gốc (S3/GCS)
  2. TẠO URL CDN (phân phối CloudFront)
  3. CACHE tại vị trí edge toàn cầu
  4. TRẢ VỀ cdn_url cho advertiser

LỢI ÍCH CDN:
  • Phân phối nhanh (độ trễ thấp)
  • Tính khả dụng cao (99.9% uptime)
  • Giảm tải nguồn
```

**Quy tắc 7.2.2: Vô hiệu Cache**
```
NẾU tài sản được cập nhật (phiên bản mới):
  • VÔ HIỆU cache CDN
  • TRUYỀN phiên bản mới đến vị trí edge
  • MẤT: 5-15 phút toàn cầu

TRONG KHI truyền:
  • Một số thiết bị có thể phục vụ phiên bản cũ (không nhất quán ngắn)
  • KHÔNG vấn đề cho chiến dịch (dùng URL có phiên bản)
```

**Quy tắc 7.2.3: Streaming Bitrate Thích ứng** (cho video)
```
VIDEO chuyển mã sang nhiều độ phân giải:
  • 480p (1 Mbps)
  • 720p (2.5 Mbps)
  • 1080p (5 Mbps)

THIẾT BỊ chọn độ phân giải dựa vào:
  • Độ phân giải màn hình
  • Băng thông mạng
  • Tải CPU hiện tại

GIAO THỨC STREAMING:
  • HLS (HTTP Live Streaming) cho tương thích
```

### 7.3 Đồng bộ Nội dung Thiết bị

**Quy tắc 7.3.1: Tải xuống Nội dung**
```
KHI chiến dịch gán cho thiết bị:
  1. THIẾT BỊ nhận manifest nội dung (danh sách tài sản)
  2. KIỂM TRA cache cục bộ cho tài sản
  3. TẢI XUỐNG tài sản còn thiếu từ CDN
  4. XÁC MINH toàn vẹn file (kiểm tra hash)
  5. ĐÁNH DẤU nội dung sẵn sàng

TỐI ƯU TẢI XUỐNG:
  • Tải xuống trong giờ ít traffic (nếu đã lên lịch)
  • Tiếp tục tải xuống bị gián đoạn
  • Ưu tiên nội dung đã lên lịch sắp tới
```

**Quy tắc 7.3.2: Cache Cục bộ**
```
THIẾT BỊ cache nội dung cục bộ:
  • Lưu trên lưu trữ thiết bị (SSD/HDD)
  • Kích thước cache tối đa: 10 GB (có thể cấu hình)
  • Chính sách đuổi LRU (Least Recently Used)

LỢI ÍCH:
  • Phát nội dung không cần mạng
  • Giảm sử dụng băng thông
  • Chuyển nội dung tức thì
```

**Quy tắc 7.3.3: Push Cập nhật Nội dung**
```
KHI nội dung được cập nhật trong chiến dịch:
  • PUSH thông báo đến thiết bị bị ảnh hưởng
  • THIẾT BỊ tải xuống nội dung đã cập nhật ở nền
  • CHUYỂN sang nội dung mới ở lần phát tiếp theo đã lên lịch

KHÔNG GIÁN ĐOẠN phát hiện tại
```

---

## 🎬 Gán Nội dung cho Chiến dịch

### 8.1 Chọn Nội dung Chiến dịch

**Quy tắc 8.1.1: Thêm Nội dung vào Chiến dịch**
```
KHI tạo chiến dịch, advertiser chọn nội dung:
  • Tài sản đơn (chiến dịch tĩnh)
  • Nhiều tài sản (playlist/xoay vòng)
  • Quy tắc động (nội dung dựa vào thời gian, vị trí, v.v.)

KIỂM TRA:
  • Nội dung PHẢI có trạng thái APPROVED
  • Giấy phép nội dung PHẢI hợp lệ (không hết hạn)
  • Kích thước nội dung PHẢI khớp tỷ lệ khung hình thiết bị (hoặc cho phép cắt)
```

**Quy tắc 8.1.2: Xoay vòng Nội dung**
```
NẾU nhiều tài sản trong chiến dịch:
  • XOAY VÒNG tài sản dựa vào lịch:
    - Phân phối đều (mặc định)
    - Phân phối có trọng số (vd: 70% tài sản A, 30% tài sản B)
    - Dựa vào thời gian (tài sản A buổi sáng, tài sản B buổi chiều)

THEO DÕI XOAY VÒNG:
  • Mỗi impression ghi lại tài sản nào được hiển thị
  • Hiệu suất so sánh qua các tài sản
```

### 8.2 Tương thích Nội dung

**Quy tắc 8.2.1: Khớp Tỷ lệ Khung hình**
```
THIẾT BỊ có tỷ lệ khung hình màn hình cụ thể:
  • 16:9 (ngang)
  • 9:16 (dọc)
  • 1:1 (vuông)

KHI gán nội dung cho chiến dịch:
  • KIỂM TRA nếu tỷ lệ khung hình nội dung khớp thiết bị đích
  • NẾU không khớp:
    - TÙY CHỌN A: Cắt/vừa nội dung (letterbox/pillarbox)
    - TÙY CHỌN B: Cảnh báo advertiser và yêu cầu tài sản khác

ĐỀ XUẤT: Upload nhiều phiên bản cho tỷ lệ khung hình khác nhau
```

**Quy tắc 8.2.2: Kiểm tra Độ phân giải**
```
ĐỀ XUẤT độ phân giải nội dung >= độ phân giải thiết bị:
  • Nội dung 1920x1080 cho màn hình 1080p
  • Nội dung 3840x2160 cho màn hình 4K

NẾU độ phân giải thấp hơn:
  • CẢNH BÁO advertiser: "Nội dung có thể xuất hiện răng cưa trên màn hình độ phân giải cao"
  • CHO PHÉP sử dụng (lựa chọn advertiser)
```

**Quy tắc 8.2.3: Tối ưu Kích thước File**
```
FILE LỚN có thể gây vấn đề:
  • Tải xuống chậm đến thiết bị
  • Hạn chế lưu trữ

ĐỀ XUẤT:
  • Hình ảnh: Tối ưu xuống < 2 MB mỗi hình
  • Video: Dùng codec hiệu quả (H.264), bitrate < 5 Mbps
  • HTML5: Minify mã, nén tài sản

NỀN TẢNG có thể tự động tối ưu (với phép advertiser)
```

### 8.3 Lên lịch Nội dung

**Quy tắc 8.3.1: Nội dung Theo Thời gian**
```
Advertiser có thể lên lịch nội dung khác nhau cho thời gian khác nhau:
  • Menu sáng (6am-11am)
  • Menu trưa (11am-2pm)
  • Menu tối (5pm-10pm)

THIẾT BỊ tự động chuyển nội dung dựa vào lịch
```

**Quy tắc 8.3.2: Nội dung Động**
```
Cấp ENTERPRISE hỗ trợ nội dung động:
  • Dựa vào thời tiết (hiển thị quảng cáo ô khi mưa)
  • Dựa vào tồn kho (hiển thị quảng cáo chỉ nếu sản phẩm còn hàng)
  • Dữ liệu thời gian thực (hiển thị giá hiện tại, đếm ngược)

YÊU CẦU: Tích hợp API với nguồn dữ liệu bên ngoài
```

---

## 📊 Phân tích Hiệu suất Nội dung

### 9.1 Phân tích Cấp Tài sản

**Chỉ số Theo dõi**:
- **Impression**: Tổng số lần tài sản hiển thị
- **Thiết bị Duy nhất**: Số thiết bị duy nhất hiển thị tài sản
- **Chiến dịch**: Số chiến dịch dùng tài sản
- **CTR**: Tỷ lệ click (nếu tương tác)
- **Tương tác**: Thời lượng xem, sự kiện tương tác
- **Chuyển đổi**: Doanh số/hành động quy kết (nếu theo dõi)

**Quy tắc 9.1.1: Dashboard Hiệu suất**
```
CHO mỗi tài sản, hiển thị:
  • Tổng impression (từ trước đến nay)
  • Xu hướng impression (30 ngày gần)
  • Chiến dịch hiệu suất cao nhất dùng tài sản
  • Loại thiết bị hiển thị tài sản (kích thước màn hình, vị trí)
  • So sánh với trung bình advertiser
```

**Quy tắc 9.1.2: Chấm điểm Hiệu suất**
```
TÍNH điểm hiệu suất tài sản (0-100):
  • Khối lượng impression: 30%
  • CTR (nếu áp dụng): 30%
  • Sử dụng chiến dịch: 20%
  • Tính gần đây (mới dùng): 20%

TÀI SẢN HIỆU SUẤT CAO (điểm > 80):
  • Huy hiệu: "Top Performer"
  • Gợi ý cho chiến dịch mới
```

### 9.2 Kiểm thử A/B

**Quy tắc 9.2.1: Biến thể Nội dung**
```
ADVERTISER có thể kiểm thử nhiều phiên bản:
  • Tạo 2+ biến thể cùng tài sản (CTA khác, màu sắc, v.v.)
  • Chia traffic 50/50 (hoặc chia tùy chỉnh)
  • Theo dõi hiệu suất cho mỗi biến thể

SAU 1000 impression (tối thiểu):
  • HIỂN THỊ ý nghĩa thống kê của kết quả
  • ĐỀ XUẤT biến thể hiệu suất tốt nhất
```

**Quy tắc 9.2.2: Tối ưu Tự động** (ENTERPRISE)
```
NỀN TẢNG có thể tự động tối ưu:
  • Bắt đầu với phân phối đều qua các biến thể
  • Dần chuyển traffic sang biến thể tốt nhất (multi-armed bandit)
  • Tối đa hóa hiệu suất chiến dịch tổng thể

VÍ DỤ:
  • Biến thể A: 1.5% CTR
  • Biến thể B: 2.8% CTR
  • Sau 500 impression mỗi biến thể, chuyển sang 80% Biến thể B, 20% Biến thể A
```

### 9.3 Heatmap & Tương tác

**Quy tắc 9.3.1: Theo dõi Nội dung Tương tác** (cho quảng cáo HTML5)
```
THEO DÕI tương tác user:
  • Click vào nút/link
  • Độ sâu cuộn
  • Thời gian dành cho mỗi phần
  • Gửi form

TẠO heatmap hiển thị:
  • Khu vực được click nhiều nhất
  • Vùng chú ý (nơi user nhìn)

DÙNG để tối ưu: Điều chỉnh bố cục, vị trí CTA
```

### 9.4 Đề xuất Nội dung

**Quy tắc 9.4.1: Gợi ý Tài sản**
```
DỰA VÀO dữ liệu hiệu suất, ĐỀ XUẤT:
  • "5 tài sản hiệu suất cao nhất của bạn" (để dùng lại)
  • "Tài sản chưa dùng" (đã upload nhưng không dùng trong chiến dịch)
  • "Tài sản hiệu suất cao tương tự" (từ advertiser khác, nếu công khai)

GIÚP advertiser tối ưu chiến lược nội dung
```

---

## 🔄 Phiên bản & Lịch sử Nội dung

### 10.1 Kiểm soát Phiên bản

**Quy tắc 10.1.1: Tạo Phiên bản**
```
KHI advertiser cập nhật tài sản:
  • TẠO phiên bản mới (version_number tăng)
  • LƯU phiên bản cũ trong lịch sử
  • CẬP NHẬT cdn_url sang phiên bản mới

CHIẾN DỊCH dùng tài sản:
  • TÙY CHỌN A: Tự động cập nhật sang phiên bản mới (mặc định)
  • TÙY CHỌN B: Ghim vào phiên bản cụ thể (yêu cầu cập nhật thủ công)
```

**Quy tắc 10.1.2: Hoàn nguyên Phiên bản**
```
Advertiser có thể quay về phiên bản trước:
  • XEM tất cả phiên bản (với xem trước)
  • CHỌN phiên bản để khôi phục
  • HOÀN NGUYÊN: Đặt phiên bản đã chọn làm hiện tại

TRƯỜNG HỢP SỬ DỤNG: Phiên bản mới có lỗi, nhanh chóng quay về phiên bản ổn định
```

**Quy tắc 10.1.3: Giới hạn Phiên bản**
```
LƯU tối đa 10 phiên bản mỗi tài sản (tất cả cấp)
ENTERPRISE: Phiên bản không giới hạn

Phiên bản CŨ NHẤT tự động xóa nếu vượt giới hạn
NGOẠI LỆ: Phiên bản hiện dùng trong chiến dịch active được giữ lại
```

### 10.2 Lịch sử Thay đổi

**Quy tắc 10.2.1: Nhật ký Kiểm toán**
```
THEO DÕI tất cả thay đổi tài sản:
  • Upload
  • Chỉnh sửa metadata (tiêu đề, tag, v.v.)
  • Cập nhật phiên bản
  • Thay đổi trạng thái (đã phê duyệt, từ chối)
  • Gán cho chiến dịch
  • Xóa

CHO MỖI thay đổi:
  • Timestamp
  • User thực hiện thay đổi
  • Mô tả thay đổi

TRUY CẬP: Xem được bởi nhóm tài khoản advertiser
```

---

## 🗄️ Lưu trữ & Xóa Nội dung

### 11.1 Lưu trữ

**Quy tắc 11.1.1: Lưu trữ Thủ công**
```
Advertiser có thể LƯU TRỮ tài sản:
  • Di chuyển vào thư mục "Archived"
  • Không còn hiển thị trong thư viện chính
  • Không thể dùng trong chiến dịch MỚI
  • Chiến dịch HIỆN CÓ dùng tài sản tiếp tục (không gián đoạn)

TRƯỜNG HỢP SỬ DỤNG: Nội dung theo mùa, thiết kế lỗi thời (giữ để tham khảo)
```

**Quy tắc 11.1.2: Tự động Lưu trữ**
```
NỀN TẢNG có thể tự động lưu trữ:
  • Tài sản không dùng trong 365 ngày
  • Thông báo gửi 30 ngày trước lưu trữ
  • Advertiser có thể từ chối tự động lưu trữ

LỢI ÍCH: Giữ thư viện sạch, giảm lộn xộn
```

**Quy tắc 11.1.3: Khôi phục từ Lưu trữ**
```
Advertiser có thể khôi phục tài sản đã lưu trữ:
  • Di chuyển lại vào thư viện active
  • Có sẵn để dùng trong chiến dịch ngay lập tức
```

### 11.2 Xóa

**Quy tắc 11.2.1: Xóa Mềm**
```
KHI advertiser xóa tài sản:
  • ĐẶT deleted_at = BÂY GIỜ()
  • Ẩn khỏi thư viện
  • Giữ lại trong database 30 ngày (thời gian khôi phục)

NẾU tài sản dùng trong chiến dịch active:
  • CẢNH BÁO: "Tài sản này được dùng trong X chiến dịch active"
  • YÊU CẦU xác nhận
  • CHIẾN DỊCH tiếp tục dùng tài sản (URL vẫn truy cập được)
```

**Quy tắc 11.2.2: Xóa Vĩnh viễn**
```
SAU 30 ngày (thời gian ân hạn xóa mềm):
  • XÓA VĨNH VIỄN file khỏi lưu trữ
  • Xóa khỏi database
  • KHÔNG THỂ khôi phục

NGOẠI LỆ: Tài sản có chiến dịch active giữ lại cho đến khi chiến dịch kết thúc
```

**Quy tắc 11.2.3: Xóa Hàng loạt**
```
Advertiser có thể xóa nhiều tài sản:
  • Chọn tài sản
  • Xác nhận xóa
  • XỬ LÝ ở nền (nếu batch lớn)

AN TOÀN: Yêu cầu xác nhận gấp đôi cho >10 tài sản
```

---

## 🔗 Điểm Tích hợp

### 12.1 Tích hợp với Module Campaign

```
PHỤ THUỘC:
  • Chiến dịch tham chiếu content_assets qua asset_id
  • Trạng thái chiến dịch ảnh hưởng sử dụng nội dung (chiến dịch active dùng nội dung)
  • Hiệu suất nội dung theo dõi theo chiến dịch

TƯƠNG TÁC:
  • Tạo chiến dịch: Chọn nội dung từ thư viện
  • Báo cáo chiến dịch: Hiển thị hiệu suất nội dung trong chiến dịch
  • Cập nhật nội dung: Thông báo chiến dịch bị ảnh hưởng
```

### 12.2 Tích hợp với Module Device

```
TƯƠNG TÁC:
  • Thiết bị tải xuống nội dung cho chiến dịch đã gán
  • Khả năng thiết bị (kích thước màn hình, độ phân giải) ảnh hưởng chọn nội dung
  • Cache thiết bị lưu nội dung cục bộ
  • Thiết bị báo cáo nội dung nào đang phát
```

### 12.3 Tích hợp với Module Advertiser

```
PHỤ THUỘC:
  • Nội dung thuộc sở hữu advertiser (advertiser_id FK)
  • Cấp advertiser ảnh hưởng hạn ngạch lưu trữ và tính năng
  • Thành viên nhóm advertiser có quyền khác nhau (upload, phê duyệt, xóa)

HẠN NGẠCH thực thi ở cấp advertiser
```

### 12.4 Tích hợp Bên ngoài

#### Nhà cung cấp CDN
```
TÍCH HỢP:
  • AWS CloudFront: Phân phối nội dung
  • Cloudflare: CDN + bảo vệ DDoS
  • Google Cloud CDN: CDN thay thế

WEBHOOK:
  • cdn.cache_invalidated → Thông báo hệ thống
  • cdn.file_deleted → Dọn dẹp tham chiếu
```

#### Dịch vụ Kiểm duyệt
```
TÍCH HỢP:
  • AWS Rekognition: Kiểm duyệt hình ảnh/video
  • Google Vision AI: Phát hiện nội dung
  • Clarifai: Mô hình kiểm duyệt tùy chỉnh

GỌI API:
  • Upload → Gửi đến API kiểm duyệt
  • Nhận điểm tin cậy
  • Lưu kết quả trong moderation_flags
```

#### Nhà cung cấp Lưu trữ
```
TÍCH HỢP:
  • AWS S3: Lưu trữ chính
  • Google Cloud Storage: Thay thế
  • Azure Blob Storage: Tùy chọn đa đám mây

THAO TÁC:
  • Upload: Presigned URL (upload trực tiếp)
  • Download: Presigned URL (truy cập bảo mật)
  • Chính sách vòng đời: Tự động lưu trữ file cũ
```

---

## ⚠️ Các trường hợp đặc biệt

### 13.1 Xử lý Nội dung Trùng

**Tình huống**: Advertiser upload cùng file nhiều lần.

**Quy tắc**:
```
PHÁT HIỆN:
  • Tính hash file (SHA-256)
  • Kiểm tra nếu hash tồn tại trong thư viện advertiser

TÙY CHỌN:
  A) BỎ QUA UPLOAD (mặc định):
     • Hiển thị tài sản hiện có
     • "File này đã tồn tại là '{name}'"

  B) TẠO TÀI SẢN MỚI:
     • Cho phép trùng với metadata khác
     • Hữu ích nếu cùng hình ảnh dùng cho mục đích khác

  C) CẬP NHẬT HIỆN CÓ:
     • Thay thế tài sản hiện có bằng upload mới
     • Tạo phiên bản mới
```

### 13.2 File Rất Lớn

**Tình huống**: Advertiser upload video 500 MB (ở giới hạn cấp).

**Quy tắc**:
```
TỐI ƯU:
  • Đề nghị nén trong khi upload
  • "File của bạn là 500 MB. Nén xuống 250 MB? (đề xuất)"
  • Dùng codec hiệu quả (H.264, kích thước nhỏ hơn)

UPLOAD:
  • Dùng upload có thể tiếp tục/theo chunk
  • Hiển thị tiến trình chi tiết (MB đã upload / tổng)
  • Cho phép tạm dừng/tiếp tục

XỬ LÝ:
  • Xử lý ở nền (mất 10+ phút)
  • Thông báo advertiser khi hoàn thành
```

### 13.3 File Hỏng/Lỗi

**Tình huống**: File upload bị hỏng và không thể xử lý.

**Quy tắc**:
```
PHÁT HIỆN:
  • Xử lý thất bại (không thể đọc file)
  • ĐẶT status = "PROCESSING_FAILED"

THÔNG BÁO:
  • "Không thể xử lý file của bạn. Nó có thể bị hỏng."
  • GỢI Ý: Xuất lại từ ứng dụng nguồn và upload lại

KHÔI PHỤC:
  • Cho phép thử lại (xử lý lại cùng file)
  • Cho phép thay thế (upload file mới)

NẾU thất bại dai dẳng:
  • Gắn cờ để hỗ trợ thủ công xem xét
```

### 13.4 Tranh chấp Giấy phép

**Tình huống**: Hai advertiser khẳng định quyền sở hữu cùng nội dung.

**Quy tắc**:
```
NẾU khiếu nại DMCA được nộp HOẶC cả hai advertiser dùng cùng nội dung:
  1. ĐIỀU TRA:
     • Yêu cầu chứng minh quyền sở hữu từ cả hai bên
     • Kiểm tra timestamp upload (ai upload trước)
     • Xem xét tài liệu giấy phép

  2. GIẢI QUYẾT:
     • Chủ hợp lệ: Giữ tài sản
     • Chủ không hợp lệ: Xóa tài sản, cảnh cáo tài khoản

  3. LEO THANG PHÁP LÝ:
     • Nếu không giải quyết được, có thể cần can thiệp pháp lý
     • Đình chỉ tài sản cho đến khi giải quyết
```

### 13.5 Nội dung Dùng qua Nhiều Chiến dịch

**Tình huống**: Tài sản dùng trong 50+ chiến dịch, advertiser muốn cập nhật.

**Quy tắc**:
```
TÙY CHỌN CẬP NHẬT:
  A) CẬP NHẬT TẤT CẢ CHIẾN DỊCH:
     • Phiên bản mới dùng khắp nơi
     • Hiệu lực ngay lập tức

  B) GHIM CHIẾN DỊCH HIỆN CÓ:
     • Chiến dịch hiện có dùng phiên bản cũ
     • Chiến dịch mới dùng phiên bản mới

  C) CẬP NHẬT CÓ CHỌN LỌC:
     • Chọn chiến dịch nào cập nhật
     • Kiểm soát thủ công

THÔNG BÁO:
  • "Tài sản này được dùng trong 50 chiến dịch. Cập nhật tất cả?"
  • Hiển thị danh sách chiến dịch bị ảnh hưởng
```

### 13.6 Tự động hóa Nội dung Theo mùa

**Tình huống**: Advertiser có nội dung ngày lễ chỉ nên hiển thị trong tháng 12.

**Quy tắc**:
```
LÊN LỊCH:
  • Đặt active_date_range cho tài sản
  • Tự động kích hoạt tài sản vào ngày bắt đầu
  • Tự động lưu trữ tài sản vào ngày kết thúc

CHIẾN DỊCH:
  • Chiến dịch dùng tài sản theo mùa tự động tạm dừng ngoài khoảng ngày
  • Tự động tiếp tục khi trở lại trong khoảng

LỢI ÍCH: Chiến dịch theo mùa "đặt và quên"
```

### 13.7 Nội dung Do User Tạo (UGC)

**Tình huống**: Advertiser chạy chiến dịch UGC, upload nội dung do khách hàng nộp.

**Quy tắc**:
```
KIỂM DUYỆT THÊM:
  • YÊU CẦU: Chứng minh phép (mẫu phát hành đã ký)
  • KIỂM DUYỆT NGHIÊM NGẶT HƠN (đánh giá thủ công bắt buộc)
  • NHÃN: "User-Generated Content" (để minh bạch)

BẢO VỆ PHÁP LÝ:
  • Advertiser chịu trách nhiệm về phép
  • Nền tảng không chịu trách nhiệm tranh chấp UGC (theo ToS)

ĐỀ XUẤT:
  • Upload mẫu phát hành dạng tài liệu riêng
  • Liên kết đến tài sản cho dấu vết kiểm toán
```

---

## 📐 Công thức Nghiệp vụ

### 14.1 Tính toán Chi phí Lưu trữ

```
storage_cost_per_gb_per_month = $0.023 (cấp chuẩn S3)

total_storage_gb = SUM(file_size_bytes cho tất cả tài sản) / (1024^3)

monthly_storage_cost = total_storage_gb × storage_cost_per_gb_per_month

VÍ DỤ:
  Advertiser dùng 50 GB lưu trữ
  Chi phí = 50 × $0.023 = $1.15/tháng

LƯU Ý: Advertiser không trả phí lưu trữ trực tiếp (bao gồm trong thuê bao cấp)
```

### 14.2 Chi phí Băng thông CDN

```
cdn_cost_per_gb = $0.085 (trung bình CloudFront)

total_bandwidth_gb = SUM(file_size_bytes × impressions) / (1024^3)

monthly_cdn_cost = total_bandwidth_gb × cdn_cost_per_gb

VÍ DỤ:
  • Tài sản: Video 2 MB
  • Impression: 100,000
  • Băng thông = (2 MB × 100,000) / 1024 = 195 GB
  • Chi phí = 195 × $0.085 = $16.58

LƯU Ý: Nền tảng hấp thụ chi phí CDN (không tính tiền advertiser)
```

### 14.3 Điểm Hiệu suất Nội dung

```
performance_score = (
  impression_volume_score × 0.30 +
  ctr_score × 0.30 +
  campaign_usage_score × 0.20 +
  recency_score × 0.20
)

TRONG ĐÓ:
  impression_volume_score = MIN(100, (total_impressions / 10000) × 100)
  ctr_score = ctr_percentage × 20  // Giả sử 5% CTR = 100 điểm
  campaign_usage_score = MIN(100, used_in_campaigns_count × 10)
  recency_score = 100 nếu last_used < 30 ngày NGƯỢC LẠI (100 - số ngày từ lần dùng cuối)

VÍ DỤ:
  • Impression: 50,000 → volume_score = 100 (đã giới hạn)
  • CTR: 3% → ctr_score = 60
  • Dùng trong 8 chiến dịch → usage_score = 80
  • Dùng lần cuối 10 ngày trước → recency_score = 90

  performance_score = (100 × 0.30) + (60 × 0.30) + (80 × 0.20) + (90 × 0.20)
                    = 30 + 18 + 16 + 18
                    = 82 (Hiệu suất tốt)
```

### 14.4 Sử dụng Hạn ngạch Lưu trữ

```
current_usage_percentage = (
  (total_storage_bytes / storage_quota_bytes) × 100
)

NẾU current_usage_percentage >= 80:
  CẢNH BÁO: "Bạn đang dùng 80% hạn ngạch lưu trữ"
  GỢI Ý: Nâng cấp hoặc xóa tài sản không dùng

NẾU current_usage_percentage >= 100:
  CHẶN upload mới cho đến khi giải phóng không gian
```

### 14.5 Ước tính Thời gian Xử lý

```
HÌNH ẢNH:
  processing_time_seconds = 5 (hằng số)

VIDEO:
  processing_time_seconds = duration_seconds × 0.5  // Mã hóa thời gian thực

  VÍ DỤ:
    Video 60 giây → 30 giây xử lý

HTML5:
  processing_time_seconds = 10 + (total_files × 2)

  VÍ DỤ:
    Gói có 20 file → 10 + (20 × 2) = 50 giây
```

### 14.6 Kích thước Tài sản Đề xuất

```
CHO thiết bị có độ phân giải (device_width × device_height):

  recommended_content_width = device_width × 1.5
  recommended_content_height = device_height × 1.5

VÍ DỤ:
  Thiết bị: 1920×1080
  Đề xuất: 2880×1620 (cho phép scale không mất chất lượng)

NẾU content_width < device_width:
  quality_warning = "Nội dung có thể xuất hiện răng cưa"
```

---

## 📚 Bảng thuật ngữ

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| **Asset** | Tài sản - một phần nội dung đơn (hình ảnh, video, v.v.) trong thư viện |
| **CDN** | Content Delivery Network - hệ thống phân tán để phân phối nội dung nhanh |
| **Moderation** | Kiểm duyệt - quy trình xem xét nội dung để tuân thủ chính sách |
| **Aspect Ratio** | Tỷ lệ khung hình - mối quan hệ tỷ lệ giữa rộng và cao (vd: 16:9) |
| **Transcoding** | Chuyển mã - chuyển đổi video từ định dạng/độ phân giải này sang khác |
| **Cache** | Bộ nhớ đệm - lưu trữ tạm thời nội dung để truy cập nhanh hơn |
| **License** | Giấy phép - phép pháp lý để sử dụng nội dung |
| **DMCA** | Digital Millennium Copyright Act - luật bản quyền Mỹ |
| **UGC** | User-Generated Content - nội dung do khách hàng/user tạo |

---

## 📚 Tham khảo

### Tài liệu liên quan

| Tài liệu | Mô tả |
|----------|-------|
| [Từ điển Thuật ngữ](./00-tu-dien-thuat-ngu.md) | Giải thích tất cả thuật ngữ |
| [Quy tắc Chiến dịch](./04-quy-tac-chien-dich.md) | Chiến dịch sử dụng nội dung |
| [Quy tắc Thiết bị](./05-quy-tac-thiet-bi.md) | Thiết bị tải xuống và hiển thị nội dung |
| [Quy tắc Advertiser](./08-quy-tac-nha-quang-cao.md) | Advertiser sở hữu nội dung |
| [Quy tắc Supplier](./09-quy-tac-nha-cung-cap.md) | Nội dung hiển thị tại cửa hàng supplier |

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: 2026-01-23  
**Người phụ trách**: Product Team  
**Trạng thái**: Sẵn sàng để review

**Bước tiếp theo**:
1. Đánh giá với stakeholder
2. Xác nhận đội product
3. Đầu vào đội content moderation
4. Lập kế hoạch triển khai