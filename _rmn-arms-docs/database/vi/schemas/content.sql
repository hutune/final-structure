-- ============================================================================
-- RMN-Arms Database Schema: Mô-đun Quản lý Nội dung
-- ============================================================================
-- Phiên bản: 1.0
-- Cập nhật lần cuối: 2026-01-23
-- Mô tả: Schema cơ sở dữ liệu đầy đủ cho Quản lý Nội dung/CMS bao gồm
--              nội dung tài sản, phiên bản, kiểm duyệt, phân phối CDN, và theo dõi hiệu suất
-- ============================================================================

-- ============================================================================
-- BẢNG: content_assets
-- Mô tả: Thực thể nội dung chính với thông tin tệp, trạng thái, và theo dõi hiệu suất
-- ============================================================================

CREATE TABLE content_assets (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE RESTRICT,
    uploaded_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    folder_id UUID REFERENCES content_folders(id) ON DELETE SET NULL,

    -- Thông tin tệp
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(20) NOT NULL CHECK (file_type IN (
        'IMAGE', 'VIDEO', 'AUDIO', 'DOCUMENT', 'HTML5'
    )),
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL CHECK (file_size_bytes > 0),
    file_hash VARCHAR(64) NOT NULL, -- Băm SHA-256 để loại bỏ trùng lặp

    -- Lưu trữ & Phân phối
    storage_url TEXT NOT NULL, -- URL S3/GCS
    cdn_url TEXT NOT NULL, -- URL CloudFront/Cloudflare
    thumbnail_url TEXT,

    -- Thuộc tính phương tiện
    width INTEGER CHECK (width > 0),
    height INTEGER CHECK (height > 0),
    aspect_ratio VARCHAR(10), -- "16:9", "9:16", "1:1"
    duration_seconds DECIMAL(10, 2) CHECK (duration_seconds > 0),
    frame_rate DECIMAL(6, 2) CHECK (frame_rate > 0),
    bitrate_kbps INTEGER CHECK (bitrate_kbps > 0),
    codec VARCHAR(50),

    -- Metadata
    title VARCHAR(200) NOT NULL CHECK (LENGTH(title) >= 1),
    description TEXT,
    tags TEXT[], -- Mảng thẻ để tìm kiếm
    category VARCHAR(100),
    brand VARCHAR(100),

    -- Trạng thái & Vòng đời
    status VARCHAR(50) NOT NULL DEFAULT 'UPLOADED' CHECK (status IN (
        'UPLOADED', 'PROCESSING', 'PROCESSING_FAILED', 'PENDING_APPROVAL',
        'APPROVED', 'REJECTED', 'ACTIVE', 'ARCHIVED', 'SUSPENDED', 'EXPIRED'
    )),

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    rejected_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ,

    -- Kiểm duyệt
    moderation_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (moderation_status IN (
        'PENDING', 'APPROVED', 'REJECTED', 'FLAGGED'
    )),
    moderation_score DECIMAL(5, 2) CHECK (moderation_score BETWEEN 0 AND 100),
    moderation_flags TEXT[], -- ["adult_content", "violence", v.v.]
    moderated_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    moderation_notes TEXT,

    -- Theo dõi sử dụng & hiệu suất
    used_in_campaigns_count INTEGER NOT NULL DEFAULT 0,
    total_impressions BIGINT NOT NULL DEFAULT 0,
    total_clicks BIGINT NOT NULL DEFAULT 0,
    average_ctr DECIMAL(5, 4) CHECK (average_ctr IS NULL OR average_ctr BETWEEN 0 AND 1),
    performance_score DECIMAL(5, 2) CHECK (performance_score IS NULL OR performance_score BETWEEN 0 AND 100),

    -- Giấy phép & Quyền
    license_type VARCHAR(20) NOT NULL DEFAULT 'OWNED' CHECK (license_type IN (
        'OWNED', 'LICENSED', 'STOCK', 'USER_GENERATED'
    )),
    license_expiry_date DATE,
    rights_holder VARCHAR(200),
    usage_rights_confirmed BOOLEAN NOT NULL DEFAULT FALSE,

    -- Tổ chức
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    current_version INTEGER NOT NULL DEFAULT 1,

    -- Thông tin xử lý
    processing_error_message TEXT,

    -- Xóa mềm
    deleted_at TIMESTAMPTZ,

    -- Kiểm toán
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT content_assets_hash_advertiser_unique UNIQUE(advertiser_id, file_hash),
    CONSTRAINT content_assets_license_expiry_check CHECK (
        license_type != 'LICENSED' OR license_expiry_date IS NOT NULL
    )
);

-- Chỉ mục
CREATE INDEX idx_content_assets_advertiser_id ON content_assets(advertiser_id);
CREATE INDEX idx_content_assets_status ON content_assets(status);
CREATE INDEX idx_content_assets_file_type ON content_assets(file_type);
CREATE INDEX idx_content_assets_moderation_status ON content_assets(moderation_status);
CREATE INDEX idx_content_assets_created_at ON content_assets(created_at DESC);
CREATE INDEX idx_content_assets_folder_id ON content_assets(folder_id);
CREATE INDEX idx_content_assets_tags ON content_assets USING GIN(tags);
CREATE INDEX idx_content_assets_advertiser_status ON content_assets(advertiser_id, status);
CREATE INDEX idx_content_assets_license_expiry ON content_assets(license_expiry_date)
    WHERE license_type = 'LICENSED' AND license_expiry_date IS NOT NULL;
CREATE INDEX idx_content_assets_performance ON content_assets(performance_score DESC NULLS LAST);
CREATE INDEX idx_content_assets_file_hash ON content_assets(file_hash);
CREATE INDEX idx_content_assets_deleted_at ON content_assets(deleted_at) WHERE deleted_at IS NULL;

-- Chú thích
COMMENT ON TABLE content_assets IS 'Bảng nội dung tài sản chính với thông tin tệp, kiểm duyệt, và theo dõi hiệu suất';
COMMENT ON COLUMN content_assets.status IS 'Trạng thái vòng đời hiện tại của nội dung tài sản';
COMMENT ON COLUMN content_assets.moderation_status IS 'Trạng thái kiểm duyệt AI và thủ công';
COMMENT ON COLUMN content_assets.moderation_score IS 'Điểm tin cậy AI 0-100 (100=an toàn)';
COMMENT ON COLUMN content_assets.file_hash IS 'Băm SHA-256 để phát hiện trùng lặp';
COMMENT ON COLUMN content_assets.performance_score IS 'Điểm hiệu suất tính toán 0-100';

-- ============================================================================
-- BẢNG: content_folders
-- Mô tả: Cấu trúc thư mục phân cấp để tổ chức nội dung
-- ============================================================================

CREATE TABLE content_folders (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,
    parent_folder_id UUID REFERENCES content_folders(id) ON DELETE CASCADE,

    -- Thông tin thư mục
    folder_name VARCHAR(100) NOT NULL CHECK (LENGTH(folder_name) >= 1),
    description TEXT,
    folder_path TEXT, -- Đường dẫn tính toán cho phân cấp (ví dụ: "/root/summer/images")
    depth INTEGER NOT NULL DEFAULT 0 CHECK (depth BETWEEN 0 AND 5), -- Tối đa 5 cấp

    -- Thống kê
    asset_count INTEGER NOT NULL DEFAULT 0,
    total_size_bytes BIGINT NOT NULL DEFAULT 0,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Kiểm toán
    created_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT content_folders_unique UNIQUE(advertiser_id, parent_folder_id, folder_name)
);

-- Chỉ mục
CREATE INDEX idx_content_folders_advertiser_id ON content_folders(advertiser_id);
CREATE INDEX idx_content_folders_parent_id ON content_folders(parent_folder_id);
CREATE INDEX idx_content_folders_path ON content_folders(folder_path);

-- Chú thích
COMMENT ON TABLE content_folders IS 'Cấu trúc thư mục phân cấp để tổ chức nội dung tài sản';
COMMENT ON COLUMN content_folders.depth IS 'Cấp độ lồng thư mục (tối đa 5)';

-- ============================================================================
-- BẢNG: content_versions
-- Mô tả: Lịch sử phiên bản cho nội dung tài sản
-- ============================================================================

CREATE TABLE content_versions (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Thông tin phiên bản
    version_number INTEGER NOT NULL CHECK (version_number > 0),
    change_description TEXT,

    -- Thông tin tệp (ảnh chụp)
    file_url TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    file_hash VARCHAR(64) NOT NULL,

    -- Thuộc tính phương tiện (ảnh chụp)
    width INTEGER,
    height INTEGER,
    duration_seconds DECIMAL(10, 2),

    -- Trạng thái
    is_current BOOLEAN NOT NULL DEFAULT FALSE,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Kiểm toán
    created_by_user_id UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT content_versions_unique UNIQUE(asset_id, version_number)
);

-- Chỉ mục
CREATE INDEX idx_content_versions_asset_id ON content_versions(asset_id);
CREATE INDEX idx_content_versions_current ON content_versions(asset_id, is_current) WHERE is_current = TRUE;
CREATE INDEX idx_content_versions_created_at ON content_versions(created_at DESC);

-- Chú thích
COMMENT ON TABLE content_versions IS 'Lịch sử phiên bản cho nội dung tài sản với khả năng khôi phục';
COMMENT ON COLUMN content_versions.is_current IS 'Cờ cho biết đây có phải phiên bản hoạt động hiện tại hay không';

-- ============================================================================
-- BẢNG: content_moderation
-- Mô tả: Lịch sử kiểm duyệt chi tiết và hàng đợi đánh giá
-- ============================================================================

CREATE TABLE content_moderation (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Sự kiện kiểm duyệt
    moderation_type VARCHAR(20) NOT NULL CHECK (moderation_type IN (
        'AI_SCAN', 'MANUAL_REVIEW', 'APPEAL'
    )),
    moderation_result VARCHAR(20) NOT NULL CHECK (moderation_result IN (
        'APPROVED', 'REJECTED', 'FLAGGED', 'PENDING'
    )),

    -- Chi tiết kiểm duyệt AI
    ai_provider VARCHAR(50), -- 'AWS_REKOGNITION', 'GOOGLE_VISION', 'CLARIFAI'
    ai_confidence_score DECIMAL(5, 2) CHECK (ai_confidence_score BETWEEN 0 AND 100),
    detected_labels TEXT[], -- Mảng nhãn nội dung phát hiện
    policy_violations TEXT[], -- Mảng cờ vi phạm chính sách

    -- Chi tiết đánh giá thủ công
    reviewer_user_id UUID REFERENCES users(id),
    review_notes TEXT,
    rejection_reason VARCHAR(200),
    action_taken VARCHAR(50), -- 'APPROVED', 'REJECTED', 'REQUEST_CHANGES'

    -- Thông tin kháng cáo
    is_appeal BOOLEAN NOT NULL DEFAULT FALSE,
    appeal_reason TEXT,
    appeal_status VARCHAR(20) CHECK (appeal_status IN (
        'PENDING', 'APPROVED', 'REJECTED'
    )),

    -- Ưu tiên & SLA
    priority VARCHAR(20) NOT NULL DEFAULT 'STANDARD' CHECK (priority IN (
        'STANDARD', 'ENTERPRISE', 'URGENT'
    )),
    sla_deadline TIMESTAMPTZ, -- Khi đánh giá phải hoàn thành
    completed_at TIMESTAMPTZ,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Chỉ mục
CREATE INDEX idx_content_moderation_asset_id ON content_moderation(asset_id);
CREATE INDEX idx_content_moderation_type ON content_moderation(moderation_type);
CREATE INDEX idx_content_moderation_result ON content_moderation(moderation_result);
CREATE INDEX idx_content_moderation_pending ON content_moderation(moderation_result, priority, created_at)
    WHERE moderation_result = 'PENDING';
CREATE INDEX idx_content_moderation_reviewer ON content_moderation(reviewer_user_id);
CREATE INDEX idx_content_moderation_sla ON content_moderation(sla_deadline)
    WHERE completed_at IS NULL AND sla_deadline IS NOT NULL;
CREATE INDEX idx_content_moderation_created_at ON content_moderation(created_at DESC);

-- Chú thích
COMMENT ON TABLE content_moderation IS 'Lịch sử kiểm duyệt đầy đủ bao gồm quét AI, đánh giá thủ công, và kháng cáo';
COMMENT ON COLUMN content_moderation.ai_confidence_score IS 'Độ tin cậy kiểm duyệt AI 0-100 (100=an toàn)';
COMMENT ON COLUMN content_moderation.priority IS 'Ưu tiên đánh giá dựa trên bậc nhà quảng cáo';

-- ============================================================================
-- BẢNG: cdn_distributions
-- Mô tả: Cấu hình phân phối CDN và theo dõi phân phối
-- ============================================================================

CREATE TABLE cdn_distributions (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Cấu hình CDN
    cdn_provider VARCHAR(50) NOT NULL CHECK (cdn_provider IN (
        'CLOUDFRONT', 'CLOUDFLARE', 'GOOGLE_CDN', 'AZURE_CDN'
    )),
    distribution_id VARCHAR(200) NOT NULL, -- ID phân phối cụ thể của nhà cung cấp
    distribution_domain VARCHAR(200) NOT NULL, -- Tên miền CDN

    -- URL
    origin_url TEXT NOT NULL, -- URL S3/GCS gốc
    cdn_url TEXT NOT NULL, -- URL CDN đầy đủ
    signed_url TEXT, -- URL đã ký để truy cập an toàn
    signed_url_expires_at TIMESTAMPTZ,

    -- Cấu hình bộ nhớ cache
    cache_control VARCHAR(100), -- "max-age=31536000, immutable"
    cache_status VARCHAR(20), -- 'CACHED', 'INVALIDATED', 'PENDING'
    last_cache_invalidation_at TIMESTAMPTZ,

    -- Thống kê phân phối
    total_requests BIGINT NOT NULL DEFAULT 0,
    cache_hits BIGINT NOT NULL DEFAULT 0,
    cache_misses BIGINT NOT NULL DEFAULT 0,
    bytes_delivered BIGINT NOT NULL DEFAULT 0,
    error_count INTEGER NOT NULL DEFAULT 0,

    -- Chỉ số hiệu suất
    average_response_time_ms DECIMAL(8, 2),
    p95_response_time_ms DECIMAL(8, 2),

    -- Vị trí biên
    edge_locations TEXT[], -- Mảng mã vị trí biên

    -- Trạng thái
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN (
        'PENDING', 'ACTIVE', 'INVALIDATED', 'DISABLED', 'ERROR'
    )),
    error_message TEXT,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMPTZ,

    -- Ràng buộc
    CONSTRAINT cdn_distributions_unique UNIQUE(asset_id, cdn_provider)
);

-- Chỉ mục
CREATE INDEX idx_cdn_distributions_asset_id ON cdn_distributions(asset_id);
CREATE INDEX idx_cdn_distributions_provider ON cdn_distributions(cdn_provider);
CREATE INDEX idx_cdn_distributions_status ON cdn_distributions(status);
CREATE INDEX idx_cdn_distributions_cache_status ON cdn_distributions(cache_status);
CREATE INDEX idx_cdn_distributions_signed_url_expiry ON cdn_distributions(signed_url_expires_at)
    WHERE signed_url_expires_at IS NOT NULL;

-- Chú thích
COMMENT ON TABLE cdn_distributions IS 'Cấu hình phân phối CDN và theo dõi hiệu suất phân phối';
COMMENT ON COLUMN cdn_distributions.cache_hits IS 'Số lượng yêu cầu được phục vụ từ bộ nhớ cache biên';
COMMENT ON COLUMN cdn_distributions.bytes_delivered IS 'Tổng byte phân phối qua CDN';

-- ============================================================================
-- BẢNG: content_tags
-- Mô tả: Thẻ có thể tái sử dụng để tổ chức nội dung và tìm kiếm
-- ============================================================================

CREATE TABLE content_tags (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,

    -- Thông tin thẻ
    tag_name VARCHAR(50) NOT NULL CHECK (LENGTH(tag_name) >= 1),
    tag_slug VARCHAR(50) NOT NULL, -- Phiên bản thân thiện với URL
    description TEXT,
    color VARCHAR(7), -- Mã màu Hex cho UI

    -- Thống kê
    usage_count INTEGER NOT NULL DEFAULT 0,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT content_tags_unique UNIQUE(advertiser_id, tag_slug)
);

-- Chỉ mục
CREATE INDEX idx_content_tags_advertiser_id ON content_tags(advertiser_id);
CREATE INDEX idx_content_tags_usage_count ON content_tags(usage_count DESC);
CREATE INDEX idx_content_tags_name ON content_tags(tag_name);

-- Chú thích
COMMENT ON TABLE content_tags IS 'Thẻ có thể tái sử dụng để phân loại nội dung và tìm kiếm';
COMMENT ON COLUMN content_tags.usage_count IS 'Số lượng nội dung tài sản sử dụng thẻ này';

-- ============================================================================
-- BẢNG: content_performance_history
-- Mô tả: Chỉ số hiệu suất tổng hợp hàng ngày cho từng nội dung tài sản
-- ============================================================================

CREATE TABLE content_performance_history (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id) ON DELETE SET NULL,

    -- Ngày
    metrics_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Chỉ số hiển thị
    impressions BIGINT NOT NULL DEFAULT 0,
    unique_devices INTEGER NOT NULL DEFAULT 0,

    -- Chỉ số tương tác
    clicks BIGINT NOT NULL DEFAULT 0,
    ctr DECIMAL(5, 4) DEFAULT 0.0000,
    average_view_duration_seconds DECIMAL(10, 2),
    completion_rate DECIMAL(5, 4) CHECK (completion_rate IS NULL OR completion_rate BETWEEN 0 AND 1),

    -- Chỉ số phân phối
    successful_deliveries BIGINT NOT NULL DEFAULT 0,
    failed_deliveries BIGINT NOT NULL DEFAULT 0,
    download_errors INTEGER NOT NULL DEFAULT 0,

    -- Phân loại thiết bị
    device_types JSONB, -- {"TABLET": 500, "TV": 300, "KIOSK": 200}
    screen_sizes JSONB, -- {"1920x1080": 800, "3840x2160": 200}

    -- Phân loại địa lý
    countries JSONB, -- {"US": 700, "CA": 200, "UK": 100}
    top_cities TEXT[],

    -- Chỉ số chất lượng
    average_quality_score DECIMAL(5, 2) CHECK (average_quality_score IS NULL OR average_quality_score BETWEEN 0 AND 100),

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT content_performance_history_unique UNIQUE(asset_id, campaign_id, metrics_date)
);

-- Chỉ mục
CREATE INDEX idx_content_performance_asset_id ON content_performance_history(asset_id);
CREATE INDEX idx_content_performance_campaign_id ON content_performance_history(campaign_id);
CREATE INDEX idx_content_performance_date ON content_performance_history(metrics_date DESC);
CREATE INDEX idx_content_performance_asset_date ON content_performance_history(asset_id, metrics_date DESC);
CREATE INDEX idx_content_performance_ctr ON content_performance_history(ctr DESC);

-- Chú thích
COMMENT ON TABLE content_performance_history IS 'Chỉ số hiệu suất tổng hợp hàng ngày cho từng nội dung tài sản và chiến dịch';
COMMENT ON COLUMN content_performance_history.completion_rate IS 'Phần trăm video/âm thanh phát đến hết';

-- ============================================================================
-- BẢNG: content_audit_log
-- Mô tả: Nhật ký kiểm toán đầy đủ của tất cả các hoạt động nội dung
-- ============================================================================

CREATE TABLE content_audit_log (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Thông tin sự kiện
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'UPLOADED', 'UPDATED', 'DELETED', 'RESTORED', 'APPROVED', 'REJECTED',
        'MODERATED', 'APPEALED', 'VERSION_CREATED', 'MOVED', 'ARCHIVED',
        'ASSIGNED_TO_CAMPAIGN', 'REMOVED_FROM_CAMPAIGN', 'LICENSE_UPDATED',
        'METADATA_UPDATED', 'CACHE_INVALIDATED'
    )),

    -- Chi tiết sự kiện
    event_description TEXT,
    old_value JSONB, -- Trạng thái trước
    new_value JSONB, -- Trạng thái mới
    changes JSONB, -- Thay đổi trường cụ thể

    -- Ngữ cảnh
    ip_address INET,
    user_agent TEXT,
    referrer_campaign_id UUID REFERENCES campaigns(id),

    -- Dấu thời gian
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Kiểm toán
    performed_by_user_id UUID REFERENCES users(id)
);

-- Chỉ mục
CREATE INDEX idx_content_audit_log_asset_id ON content_audit_log(asset_id);
CREATE INDEX idx_content_audit_log_event_type ON content_audit_log(event_type);
CREATE INDEX idx_content_audit_log_occurred_at ON content_audit_log(occurred_at DESC);
CREATE INDEX idx_content_audit_log_user_id ON content_audit_log(performed_by_user_id);
CREATE INDEX idx_content_audit_log_asset_event ON content_audit_log(asset_id, occurred_at DESC);

-- Chú thích
COMMENT ON TABLE content_audit_log IS 'Nhật ký kiểm toán đầy đủ của tất cả các hoạt động và thay đổi nội dung';
COMMENT ON COLUMN content_audit_log.changes IS 'Đối tượng JSON hiển thị thay đổi cấp trường';

-- ============================================================================
-- VIEWS - CHẾ ĐỘ XEM
-- ============================================================================

-- View: Nội dung hoạt động với hiệu suất
CREATE OR REPLACE VIEW v_active_content AS
SELECT
    ca.id,
    ca.advertiser_id,
    ca.title,
    ca.file_type,
    ca.file_name,
    ca.file_size_bytes,
    ca.status,
    ca.moderation_status,
    ca.created_at,
    ca.cdn_url,
    ca.thumbnail_url,
    ca.used_in_campaigns_count,
    ca.total_impressions,
    ca.total_clicks,
    ca.average_ctr,
    ca.performance_score,
    ca.license_type,
    ca.license_expiry_date,
    CASE
        WHEN ca.license_type = 'LICENSED' AND ca.license_expiry_date < CURRENT_DATE + INTERVAL '30 days'
        THEN 'EXPIRING_SOON'
        WHEN ca.license_type = 'LICENSED' AND ca.license_expiry_date < CURRENT_DATE
        THEN 'EXPIRED'
        ELSE 'VALID'
    END AS license_status
FROM content_assets ca
WHERE ca.status = 'APPROVED'
  AND ca.deleted_at IS NULL;

-- View: Hàng đợi kiểm duyệt
CREATE OR REPLACE VIEW v_moderation_queue AS
SELECT
    ca.id,
    ca.advertiser_id,
    ca.title,
    ca.file_type,
    ca.file_name,
    ca.thumbnail_url,
    ca.uploaded_at,
    ca.moderation_status,
    ca.moderation_score,
    ca.moderation_flags,
    cm.priority,
    cm.sla_deadline,
    cm.created_at AS moderation_request_time,
    adv.business_name AS advertiser_name,
    adv.tier AS advertiser_tier,
    CASE
        WHEN cm.sla_deadline < CURRENT_TIMESTAMP THEN 'OVERDUE'
        WHEN cm.sla_deadline < CURRENT_TIMESTAMP + INTERVAL '2 hours' THEN 'URGENT'
        ELSE 'ON_TIME'
    END AS sla_status
FROM content_assets ca
INNER JOIN content_moderation cm ON ca.id = cm.asset_id
INNER JOIN advertisers adv ON ca.advertiser_id = adv.id
WHERE ca.moderation_status IN ('PENDING', 'FLAGGED')
  AND cm.moderation_result = 'PENDING'
  AND cm.completed_at IS NULL
  AND ca.deleted_at IS NULL
ORDER BY cm.priority DESC, cm.created_at ASC;

-- View: Tóm tắt lưu trữ nội dung theo nhà quảng cáo
CREATE OR REPLACE VIEW v_content_storage_summary AS
SELECT
    ca.advertiser_id,
    COUNT(ca.id) AS total_assets,
    SUM(ca.file_size_bytes) AS total_storage_bytes,
    ROUND(SUM(ca.file_size_bytes) / 1024.0 / 1024.0 / 1024.0, 2) AS total_storage_gb,
    COUNT(CASE WHEN ca.file_type = 'IMAGE' THEN 1 END) AS image_count,
    COUNT(CASE WHEN ca.file_type = 'VIDEO' THEN 1 END) AS video_count,
    COUNT(CASE WHEN ca.file_type = 'AUDIO' THEN 1 END) AS audio_count,
    COUNT(CASE WHEN ca.file_type = 'HTML5' THEN 1 END) AS html5_count,
    COUNT(CASE WHEN ca.status = 'APPROVED' THEN 1 END) AS approved_count,
    COUNT(CASE WHEN ca.status = 'PENDING_APPROVAL' THEN 1 END) AS pending_count,
    COUNT(CASE WHEN ca.status = 'REJECTED' THEN 1 END) AS rejected_count,
    SUM(ca.total_impressions) AS total_impressions_all_assets
FROM content_assets ca
WHERE ca.deleted_at IS NULL
GROUP BY ca.advertiser_id;

-- View: Nội dung hiệu suất cao nhất
CREATE OR REPLACE VIEW v_top_performing_content AS
SELECT
    ca.id,
    ca.advertiser_id,
    ca.title,
    ca.file_type,
    ca.thumbnail_url,
    ca.total_impressions,
    ca.total_clicks,
    ca.average_ctr,
    ca.performance_score,
    ca.used_in_campaigns_count,
    ca.created_at
FROM content_assets ca
WHERE ca.status = 'APPROVED'
  AND ca.deleted_at IS NULL
  AND ca.performance_score >= 80
ORDER BY ca.performance_score DESC, ca.total_impressions DESC;

-- View: Nội dung với giấy phép sắp hết hạn
CREATE OR REPLACE VIEW v_expiring_licenses AS
SELECT
    ca.id,
    ca.advertiser_id,
    ca.title,
    ca.file_name,
    ca.license_type,
    ca.license_expiry_date,
    ca.rights_holder,
    ca.used_in_campaigns_count,
    CURRENT_DATE - ca.license_expiry_date AS days_until_expiry,
    CASE
        WHEN ca.license_expiry_date < CURRENT_DATE THEN 'EXPIRED'
        WHEN ca.license_expiry_date < CURRENT_DATE + INTERVAL '7 days' THEN 'CRITICAL'
        WHEN ca.license_expiry_date < CURRENT_DATE + INTERVAL '30 days' THEN 'WARNING'
        ELSE 'OK'
    END AS urgency_level
FROM content_assets ca
WHERE ca.license_type = 'LICENSED'
  AND ca.license_expiry_date IS NOT NULL
  AND ca.license_expiry_date < CURRENT_DATE + INTERVAL '30 days'
  AND ca.deleted_at IS NULL
ORDER BY ca.license_expiry_date ASC;

-- Chú thích trên views
COMMENT ON VIEW v_active_content IS 'Nội dung đã phê duyệt hoạt động với chỉ số hiệu suất';
COMMENT ON VIEW v_moderation_queue IS 'Các mục kiểm duyệt đang chờ với ưu tiên và theo dõi SLA';
COMMENT ON VIEW v_content_storage_summary IS 'Tóm tắt sử dụng lưu trữ theo nhà quảng cáo';
COMMENT ON VIEW v_top_performing_content IS 'Nội dung tài sản hiệu suất cao nhất (điểm >= 80)';
COMMENT ON VIEW v_expiring_licenses IS 'Nội dung với giấy phép hết hạn trong 30 ngày tới';

-- ============================================================================
-- FUNCTIONS - HÀM
-- ============================================================================

-- Hàm: Cập nhật dấu thời gian updated_at nội dung
CREATE OR REPLACE FUNCTION update_content_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Hàm: Tính điểm hiệu suất nội dung
CREATE OR REPLACE FUNCTION calculate_content_performance_score(
    p_total_impressions BIGINT,
    p_average_ctr DECIMAL,
    p_used_in_campaigns_count INTEGER,
    p_created_at TIMESTAMPTZ
)
RETURNS DECIMAL AS $$
DECLARE
    v_impression_score DECIMAL;
    v_ctr_score DECIMAL;
    v_usage_score DECIMAL;
    v_recency_score DECIMAL;
    v_days_since_created INTEGER;
    v_performance_score DECIMAL;
BEGIN
    -- Điểm khối lượng hiển thị (tối đa 100)
    v_impression_score := LEAST(100, (p_total_impressions::DECIMAL / 10000.0) * 100);

    -- Điểm CTR (giả sử 5% CTR = 100 điểm)
    v_ctr_score := COALESCE((p_average_ctr * 100) * 20, 0);

    -- Điểm sử dụng chiến dịch (tối đa 100)
    v_usage_score := LEAST(100, p_used_in_campaigns_count * 10);

    -- Điểm mới (ngày kể từ khi tạo)
    v_days_since_created := EXTRACT(DAY FROM CURRENT_TIMESTAMP - p_created_at);
    v_recency_score := CASE
        WHEN v_days_since_created < 30 THEN 100
        WHEN v_days_since_created < 90 THEN 90
        WHEN v_days_since_created < 180 THEN 70
        WHEN v_days_since_created < 365 THEN 50
        ELSE 30
    END;

    -- Trung bình có trọng số
    v_performance_score := (
        (v_impression_score * 0.30) +
        (v_ctr_score * 0.30) +
        (v_usage_score * 0.20) +
        (v_recency_score * 0.20)
    );

    RETURN ROUND(v_performance_score, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Hàm: Cập nhật thống kê thư mục
CREATE OR REPLACE FUNCTION update_folder_statistics()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        IF NEW.folder_id IS NOT NULL THEN
            UPDATE content_folders
            SET
                asset_count = (
                    SELECT COUNT(*)
                    FROM content_assets
                    WHERE folder_id = NEW.folder_id
                      AND deleted_at IS NULL
                ),
                total_size_bytes = (
                    SELECT COALESCE(SUM(file_size_bytes), 0)
                    FROM content_assets
                    WHERE folder_id = NEW.folder_id
                      AND deleted_at IS NULL
                )
            WHERE id = NEW.folder_id;
        END IF;
    END IF;

    IF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND OLD.folder_id IS DISTINCT FROM NEW.folder_id) THEN
        IF OLD.folder_id IS NOT NULL THEN
            UPDATE content_folders
            SET
                asset_count = (
                    SELECT COUNT(*)
                    FROM content_assets
                    WHERE folder_id = OLD.folder_id
                      AND deleted_at IS NULL
                ),
                total_size_bytes = (
                    SELECT COALESCE(SUM(file_size_bytes), 0)
                    FROM content_assets
                    WHERE folder_id = OLD.folder_id
                      AND deleted_at IS NULL
                )
            WHERE id = OLD.folder_id;
        END IF;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Hàm: Xác thực độ sâu thư mục
CREATE OR REPLACE FUNCTION validate_folder_depth()
RETURNS TRIGGER AS $$
DECLARE
    v_parent_depth INTEGER;
BEGIN
    IF NEW.parent_folder_id IS NOT NULL THEN
        SELECT depth INTO v_parent_depth
        FROM content_folders
        WHERE id = NEW.parent_folder_id;

        NEW.depth := v_parent_depth + 1;

        IF NEW.depth > 5 THEN
            RAISE EXCEPTION 'Độ sâu thư mục tối đa (5) bị vượt quá';
        END IF;
    ELSE
        NEW.depth := 0;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Hàm: Ghi sự kiện kiểm toán nội dung
CREATE OR REPLACE FUNCTION log_content_audit_event()
RETURNS TRIGGER AS $$
DECLARE
    v_event_type VARCHAR(50);
    v_old_value JSONB;
    v_new_value JSONB;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_event_type := 'UPLOADED';
        v_new_value := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        v_event_type := 'UPDATED';
        v_old_value := to_jsonb(OLD);
        v_new_value := to_jsonb(NEW);

        -- Xác định loại sự kiện cụ thể
        IF OLD.status IS DISTINCT FROM NEW.status THEN
            IF NEW.status = 'APPROVED' THEN
                v_event_type := 'APPROVED';
            ELSIF NEW.status = 'REJECTED' THEN
                v_event_type := 'REJECTED';
            ELSIF NEW.status = 'ARCHIVED' THEN
                v_event_type := 'ARCHIVED';
            END IF;
        END IF;

        IF OLD.folder_id IS DISTINCT FROM NEW.folder_id THEN
            v_event_type := 'MOVED';
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        v_event_type := 'DELETED';
        v_old_value := to_jsonb(OLD);
    END IF;

    INSERT INTO content_audit_log (
        asset_id,
        event_type,
        old_value,
        new_value,
        performed_by_user_id
    ) VALUES (
        COALESCE(NEW.id, OLD.id),
        v_event_type,
        v_old_value,
        v_new_value,
        COALESCE(NEW.updated_by, OLD.updated_by)
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS - TRIGGER
-- ============================================================================

-- Trigger: Cập nhật updated_at trên content_assets
CREATE TRIGGER trigger_content_assets_updated_at
    BEFORE UPDATE ON content_assets
    FOR EACH ROW
    EXECUTE FUNCTION update_content_updated_at();

-- Trigger: Cập nhật updated_at trên content_folders
CREATE TRIGGER trigger_content_folders_updated_at
    BEFORE UPDATE ON content_folders
    FOR EACH ROW
    EXECUTE FUNCTION update_content_updated_at();

-- Trigger: Cập nhật updated_at trên cdn_distributions
CREATE TRIGGER trigger_cdn_distributions_updated_at
    BEFORE UPDATE ON cdn_distributions
    FOR EACH ROW
    EXECUTE FUNCTION update_content_updated_at();

-- Trigger: Cập nhật thống kê thư mục
CREATE TRIGGER trigger_update_folder_statistics
    AFTER INSERT OR UPDATE OR DELETE ON content_assets
    FOR EACH ROW
    EXECUTE FUNCTION update_folder_statistics();

-- Trigger: Xác thực độ sâu thư mục
CREATE TRIGGER trigger_validate_folder_depth
    BEFORE INSERT OR UPDATE ON content_folders
    FOR EACH ROW
    EXECUTE FUNCTION validate_folder_depth();

-- Trigger: Ghi sự kiện kiểm toán nội dung
CREATE TRIGGER trigger_log_content_audit_event
    AFTER INSERT OR UPDATE OR DELETE ON content_assets
    FOR EACH ROW
    EXECUTE FUNCTION log_content_audit_event();

-- ============================================================================
-- SAMPLE QUERIES - CÂU TRUY VẤN MẪU
-- ============================================================================

/*
-- Lấy hàng đợi kiểm duyệt với ưu tiên
SELECT * FROM v_moderation_queue
WHERE sla_status IN ('URGENT', 'OVERDUE')
ORDER BY priority DESC, moderation_request_time ASC;

-- Lấy việc sử dụng lưu trữ của nhà quảng cáo
SELECT
    adv.business_name,
    css.total_assets,
    css.total_storage_gb,
    css.total_impressions_all_assets
FROM v_content_storage_summary css
INNER JOIN advertisers adv ON css.advertiser_id = adv.id
ORDER BY css.total_storage_gb DESC;

-- Lấy nội dung hiệu suất cao nhất cho nhà quảng cáo
SELECT * FROM v_top_performing_content
WHERE advertiser_id = 'ADVERTISER_UUID'
ORDER BY performance_score DESC
LIMIT 10;

-- Lấy nội dung với giấy phép sắp hết hạn
SELECT * FROM v_expiring_licenses
WHERE urgency_level IN ('CRITICAL', 'EXPIRED')
ORDER BY license_expiry_date ASC;

-- Lấy hiệu suất nội dung theo thời gian
SELECT
    asset_id,
    metrics_date,
    impressions,
    clicks,
    ctr,
    average_view_duration_seconds
FROM content_performance_history
WHERE asset_id = 'ASSET_UUID'
ORDER BY metrics_date DESC;

-- Lấy nhật ký kiểm toán nội dung
SELECT
    event_type,
    event_description,
    occurred_at,
    performed_by_user_id
FROM content_audit_log
WHERE asset_id = 'ASSET_UUID'
ORDER BY occurred_at DESC;

-- Tìm nội dung trùng lặp theo băm
SELECT
    file_hash,
    COUNT(*) AS duplicate_count,
    ARRAY_AGG(id) AS asset_ids
FROM content_assets
WHERE deleted_at IS NULL
GROUP BY file_hash
HAVING COUNT(*) > 1;
*/

-- ============================================================================
-- KẾT THÚC SCHEMA NỘI DUNG
-- ============================================================================
