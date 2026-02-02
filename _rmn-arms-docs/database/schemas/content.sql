-- ============================================================================
-- RMN-Arms Database Schema: Content Management Module
-- ============================================================================
-- Version: 1.0
-- Last Updated: 2026-01-23
-- Description: Complete database schema for Content/CMS Management including
--              content assets, versioning, moderation, CDN delivery, and performance tracking
-- ============================================================================

-- ============================================================================
-- TABLE: content_assets
-- Description: Main content entity with file info, status, and performance tracking
-- ============================================================================

CREATE TABLE content_assets (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE RESTRICT,
    uploaded_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    folder_id UUID REFERENCES content_folders(id) ON DELETE SET NULL,

    -- File Information
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(20) NOT NULL CHECK (file_type IN (
        'IMAGE', 'VIDEO', 'AUDIO', 'DOCUMENT', 'HTML5'
    )),
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL CHECK (file_size_bytes > 0),
    file_hash VARCHAR(64) NOT NULL, -- SHA-256 hash for deduplication

    -- Storage & Delivery
    storage_url TEXT NOT NULL, -- S3/GCS URL
    cdn_url TEXT NOT NULL, -- CloudFront/Cloudflare URL
    thumbnail_url TEXT,

    -- Media Properties
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
    tags TEXT[], -- Array of tags for search
    category VARCHAR(100),
    brand VARCHAR(100),

    -- Status & Lifecycle
    status VARCHAR(50) NOT NULL DEFAULT 'UPLOADED' CHECK (status IN (
        'UPLOADED', 'PROCESSING', 'PROCESSING_FAILED', 'PENDING_APPROVAL',
        'APPROVED', 'REJECTED', 'ACTIVE', 'ARCHIVED', 'SUSPENDED', 'EXPIRED'
    )),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    rejected_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ,

    -- Moderation
    moderation_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (moderation_status IN (
        'PENDING', 'APPROVED', 'REJECTED', 'FLAGGED'
    )),
    moderation_score DECIMAL(5, 2) CHECK (moderation_score BETWEEN 0 AND 100),
    moderation_flags TEXT[], -- ["adult_content", "violence", etc.]
    moderated_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    moderation_notes TEXT,

    -- Usage & Performance Tracking
    used_in_campaigns_count INTEGER NOT NULL DEFAULT 0,
    total_impressions BIGINT NOT NULL DEFAULT 0,
    total_clicks BIGINT NOT NULL DEFAULT 0,
    average_ctr DECIMAL(5, 4) CHECK (average_ctr IS NULL OR average_ctr BETWEEN 0 AND 1),
    performance_score DECIMAL(5, 2) CHECK (performance_score IS NULL OR performance_score BETWEEN 0 AND 100),

    -- Licensing & Rights
    license_type VARCHAR(20) NOT NULL DEFAULT 'OWNED' CHECK (license_type IN (
        'OWNED', 'LICENSED', 'STOCK', 'USER_GENERATED'
    )),
    license_expiry_date DATE,
    rights_holder VARCHAR(200),
    usage_rights_confirmed BOOLEAN NOT NULL DEFAULT FALSE,

    -- Organization
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    current_version INTEGER NOT NULL DEFAULT 1,

    -- Processing Information
    processing_error_message TEXT,

    -- Soft Delete
    deleted_at TIMESTAMPTZ,

    -- Audit
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT content_assets_hash_advertiser_unique UNIQUE(advertiser_id, file_hash),
    CONSTRAINT content_assets_license_expiry_check CHECK (
        license_type != 'LICENSED' OR license_expiry_date IS NOT NULL
    )
);

-- Indexes
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

-- Comments
COMMENT ON TABLE content_assets IS 'Main content assets table with file info, moderation, and performance tracking';
COMMENT ON COLUMN content_assets.status IS 'Current lifecycle status of content asset';
COMMENT ON COLUMN content_assets.moderation_status IS 'AI and manual moderation status';
COMMENT ON COLUMN content_assets.moderation_score IS 'AI confidence score 0-100 (100=safe)';
COMMENT ON COLUMN content_assets.file_hash IS 'SHA-256 hash for deduplication detection';
COMMENT ON COLUMN content_assets.performance_score IS 'Calculated performance score 0-100';

-- ============================================================================
-- TABLE: content_folders
-- Description: Hierarchical folder structure for content organization
-- ============================================================================

CREATE TABLE content_folders (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,
    parent_folder_id UUID REFERENCES content_folders(id) ON DELETE CASCADE,

    -- Folder Information
    folder_name VARCHAR(100) NOT NULL CHECK (LENGTH(folder_name) >= 1),
    description TEXT,
    folder_path TEXT, -- Computed path for hierarchy (e.g., "/root/summer/images")
    depth INTEGER NOT NULL DEFAULT 0 CHECK (depth BETWEEN 0 AND 5), -- Max 5 levels

    -- Statistics
    asset_count INTEGER NOT NULL DEFAULT 0,
    total_size_bytes BIGINT NOT NULL DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT content_folders_unique UNIQUE(advertiser_id, parent_folder_id, folder_name)
);

-- Indexes
CREATE INDEX idx_content_folders_advertiser_id ON content_folders(advertiser_id);
CREATE INDEX idx_content_folders_parent_id ON content_folders(parent_folder_id);
CREATE INDEX idx_content_folders_path ON content_folders(folder_path);

-- Comments
COMMENT ON TABLE content_folders IS 'Hierarchical folder structure for organizing content assets';
COMMENT ON COLUMN content_folders.depth IS 'Folder nesting level (max 5)';

-- ============================================================================
-- TABLE: content_versions
-- Description: Version history for content assets
-- ============================================================================

CREATE TABLE content_versions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Version Information
    version_number INTEGER NOT NULL CHECK (version_number > 0),
    change_description TEXT,

    -- File Information (snapshot)
    file_url TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    file_hash VARCHAR(64) NOT NULL,

    -- Media Properties (snapshot)
    width INTEGER,
    height INTEGER,
    duration_seconds DECIMAL(10, 2),

    -- Status
    is_current BOOLEAN NOT NULL DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by_user_id UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT content_versions_unique UNIQUE(asset_id, version_number)
);

-- Indexes
CREATE INDEX idx_content_versions_asset_id ON content_versions(asset_id);
CREATE INDEX idx_content_versions_current ON content_versions(asset_id, is_current) WHERE is_current = TRUE;
CREATE INDEX idx_content_versions_created_at ON content_versions(created_at DESC);

-- Comments
COMMENT ON TABLE content_versions IS 'Version history for content assets with rollback capability';
COMMENT ON COLUMN content_versions.is_current IS 'Flag indicating if this is the current active version';

-- ============================================================================
-- TABLE: content_moderation
-- Description: Detailed moderation history and review queue
-- ============================================================================

CREATE TABLE content_moderation (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Moderation Event
    moderation_type VARCHAR(20) NOT NULL CHECK (moderation_type IN (
        'AI_SCAN', 'MANUAL_REVIEW', 'APPEAL'
    )),
    moderation_result VARCHAR(20) NOT NULL CHECK (moderation_result IN (
        'APPROVED', 'REJECTED', 'FLAGGED', 'PENDING'
    )),

    -- AI Moderation Details
    ai_provider VARCHAR(50), -- 'AWS_REKOGNITION', 'GOOGLE_VISION', 'CLARIFAI'
    ai_confidence_score DECIMAL(5, 2) CHECK (ai_confidence_score BETWEEN 0 AND 100),
    detected_labels TEXT[], -- Array of detected content labels
    policy_violations TEXT[], -- Array of policy violation flags

    -- Manual Review Details
    reviewer_user_id UUID REFERENCES users(id),
    review_notes TEXT,
    rejection_reason VARCHAR(200),
    action_taken VARCHAR(50), -- 'APPROVED', 'REJECTED', 'REQUEST_CHANGES'

    -- Appeal Information
    is_appeal BOOLEAN NOT NULL DEFAULT FALSE,
    appeal_reason TEXT,
    appeal_status VARCHAR(20) CHECK (appeal_status IN (
        'PENDING', 'APPROVED', 'REJECTED'
    )),

    -- Priority & SLA
    priority VARCHAR(20) NOT NULL DEFAULT 'STANDARD' CHECK (priority IN (
        'STANDARD', 'ENTERPRISE', 'URGENT'
    )),
    sla_deadline TIMESTAMPTZ, -- When review must be completed
    completed_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_content_moderation_asset_id ON content_moderation(asset_id);
CREATE INDEX idx_content_moderation_type ON content_moderation(moderation_type);
CREATE INDEX idx_content_moderation_result ON content_moderation(moderation_result);
CREATE INDEX idx_content_moderation_pending ON content_moderation(moderation_result, priority, created_at)
    WHERE moderation_result = 'PENDING';
CREATE INDEX idx_content_moderation_reviewer ON content_moderation(reviewer_user_id);
CREATE INDEX idx_content_moderation_sla ON content_moderation(sla_deadline)
    WHERE completed_at IS NULL AND sla_deadline IS NOT NULL;
CREATE INDEX idx_content_moderation_created_at ON content_moderation(created_at DESC);

-- Comments
COMMENT ON TABLE content_moderation IS 'Complete moderation history including AI scans, manual reviews, and appeals';
COMMENT ON COLUMN content_moderation.ai_confidence_score IS 'AI moderation confidence 0-100 (100=safe)';
COMMENT ON COLUMN content_moderation.priority IS 'Review priority based on advertiser tier';

-- ============================================================================
-- TABLE: cdn_distributions
-- Description: CDN distribution configuration and delivery tracking
-- ============================================================================

CREATE TABLE cdn_distributions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- CDN Configuration
    cdn_provider VARCHAR(50) NOT NULL CHECK (cdn_provider IN (
        'CLOUDFRONT', 'CLOUDFLARE', 'GOOGLE_CDN', 'AZURE_CDN'
    )),
    distribution_id VARCHAR(200) NOT NULL, -- Provider-specific distribution ID
    distribution_domain VARCHAR(200) NOT NULL, -- CDN domain name

    -- URLs
    origin_url TEXT NOT NULL, -- Original S3/GCS URL
    cdn_url TEXT NOT NULL, -- Full CDN URL
    signed_url TEXT, -- Presigned URL for secure access
    signed_url_expires_at TIMESTAMPTZ,

    -- Cache Configuration
    cache_control VARCHAR(100), -- "max-age=31536000, immutable"
    cache_status VARCHAR(20), -- 'CACHED', 'INVALIDATED', 'PENDING'
    last_cache_invalidation_at TIMESTAMPTZ,

    -- Delivery Statistics
    total_requests BIGINT NOT NULL DEFAULT 0,
    cache_hits BIGINT NOT NULL DEFAULT 0,
    cache_misses BIGINT NOT NULL DEFAULT 0,
    bytes_delivered BIGINT NOT NULL DEFAULT 0,
    error_count INTEGER NOT NULL DEFAULT 0,

    -- Performance Metrics
    average_response_time_ms DECIMAL(8, 2),
    p95_response_time_ms DECIMAL(8, 2),

    -- Edge Locations
    edge_locations TEXT[], -- Array of edge location codes

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN (
        'PENDING', 'ACTIVE', 'INVALIDATED', 'DISABLED', 'ERROR'
    )),
    error_message TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT cdn_distributions_unique UNIQUE(asset_id, cdn_provider)
);

-- Indexes
CREATE INDEX idx_cdn_distributions_asset_id ON cdn_distributions(asset_id);
CREATE INDEX idx_cdn_distributions_provider ON cdn_distributions(cdn_provider);
CREATE INDEX idx_cdn_distributions_status ON cdn_distributions(status);
CREATE INDEX idx_cdn_distributions_cache_status ON cdn_distributions(cache_status);
CREATE INDEX idx_cdn_distributions_signed_url_expiry ON cdn_distributions(signed_url_expires_at)
    WHERE signed_url_expires_at IS NOT NULL;

-- Comments
COMMENT ON TABLE cdn_distributions IS 'CDN distribution configuration and delivery performance tracking';
COMMENT ON COLUMN cdn_distributions.cache_hits IS 'Number of requests served from edge cache';
COMMENT ON COLUMN cdn_distributions.bytes_delivered IS 'Total bytes delivered via CDN';

-- ============================================================================
-- TABLE: content_tags
-- Description: Reusable tags for content organization and search
-- ============================================================================

CREATE TABLE content_tags (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,

    -- Tag Information
    tag_name VARCHAR(50) NOT NULL CHECK (LENGTH(tag_name) >= 1),
    tag_slug VARCHAR(50) NOT NULL, -- URL-friendly version
    description TEXT,
    color VARCHAR(7), -- Hex color code for UI

    -- Statistics
    usage_count INTEGER NOT NULL DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT content_tags_unique UNIQUE(advertiser_id, tag_slug)
);

-- Indexes
CREATE INDEX idx_content_tags_advertiser_id ON content_tags(advertiser_id);
CREATE INDEX idx_content_tags_usage_count ON content_tags(usage_count DESC);
CREATE INDEX idx_content_tags_name ON content_tags(tag_name);

-- Comments
COMMENT ON TABLE content_tags IS 'Reusable tags for content categorization and search';
COMMENT ON COLUMN content_tags.usage_count IS 'Number of assets using this tag';

-- ============================================================================
-- TABLE: content_performance_history
-- Description: Daily aggregated performance metrics per content asset
-- ============================================================================

CREATE TABLE content_performance_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id) ON DELETE SET NULL,

    -- Date
    metrics_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Impression Metrics
    impressions BIGINT NOT NULL DEFAULT 0,
    unique_devices INTEGER NOT NULL DEFAULT 0,

    -- Engagement Metrics
    clicks BIGINT NOT NULL DEFAULT 0,
    ctr DECIMAL(5, 4) DEFAULT 0.0000,
    average_view_duration_seconds DECIMAL(10, 2),
    completion_rate DECIMAL(5, 4) CHECK (completion_rate IS NULL OR completion_rate BETWEEN 0 AND 1),

    -- Delivery Metrics
    successful_deliveries BIGINT NOT NULL DEFAULT 0,
    failed_deliveries BIGINT NOT NULL DEFAULT 0,
    download_errors INTEGER NOT NULL DEFAULT 0,

    -- Device Breakdown
    device_types JSONB, -- {"TABLET": 500, "TV": 300, "KIOSK": 200}
    screen_sizes JSONB, -- {"1920x1080": 800, "3840x2160": 200}

    -- Geographic Breakdown
    countries JSONB, -- {"US": 700, "CA": 200, "UK": 100}
    top_cities TEXT[],

    -- Quality Metrics
    average_quality_score DECIMAL(5, 2) CHECK (average_quality_score IS NULL OR average_quality_score BETWEEN 0 AND 100),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT content_performance_history_unique UNIQUE(asset_id, campaign_id, metrics_date)
);

-- Indexes
CREATE INDEX idx_content_performance_asset_id ON content_performance_history(asset_id);
CREATE INDEX idx_content_performance_campaign_id ON content_performance_history(campaign_id);
CREATE INDEX idx_content_performance_date ON content_performance_history(metrics_date DESC);
CREATE INDEX idx_content_performance_asset_date ON content_performance_history(asset_id, metrics_date DESC);
CREATE INDEX idx_content_performance_ctr ON content_performance_history(ctr DESC);

-- Comments
COMMENT ON TABLE content_performance_history IS 'Daily aggregated performance metrics per content asset and campaign';
COMMENT ON COLUMN content_performance_history.completion_rate IS 'Percentage of video/audio played to completion';

-- ============================================================================
-- TABLE: content_audit_log
-- Description: Complete audit trail of all content operations
-- ============================================================================

CREATE TABLE content_audit_log (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Event Information
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'UPLOADED', 'UPDATED', 'DELETED', 'RESTORED', 'APPROVED', 'REJECTED',
        'MODERATED', 'APPEALED', 'VERSION_CREATED', 'MOVED', 'ARCHIVED',
        'ASSIGNED_TO_CAMPAIGN', 'REMOVED_FROM_CAMPAIGN', 'LICENSE_UPDATED',
        'METADATA_UPDATED', 'CACHE_INVALIDATED'
    )),

    -- Event Details
    event_description TEXT,
    old_value JSONB, -- Previous state
    new_value JSONB, -- New state
    changes JSONB, -- Specific field changes

    -- Context
    ip_address INET,
    user_agent TEXT,
    referrer_campaign_id UUID REFERENCES campaigns(id),

    -- Timestamp
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    performed_by_user_id UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_content_audit_log_asset_id ON content_audit_log(asset_id);
CREATE INDEX idx_content_audit_log_event_type ON content_audit_log(event_type);
CREATE INDEX idx_content_audit_log_occurred_at ON content_audit_log(occurred_at DESC);
CREATE INDEX idx_content_audit_log_user_id ON content_audit_log(performed_by_user_id);
CREATE INDEX idx_content_audit_log_asset_event ON content_audit_log(asset_id, occurred_at DESC);

-- Comments
COMMENT ON TABLE content_audit_log IS 'Complete audit trail of all content operations and changes';
COMMENT ON COLUMN content_audit_log.changes IS 'JSON object showing field-level changes';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Active Content with Performance
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

-- View: Moderation Queue
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

-- View: Content Storage Summary by Advertiser
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

-- View: Top Performing Content
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

-- View: Content with Expiring Licenses
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

-- Comments on views
COMMENT ON VIEW v_active_content IS 'Active approved content with performance metrics';
COMMENT ON VIEW v_moderation_queue IS 'Pending moderation items with priority and SLA tracking';
COMMENT ON VIEW v_content_storage_summary IS 'Storage usage summary by advertiser';
COMMENT ON VIEW v_top_performing_content IS 'Top performing content assets (score >= 80)';
COMMENT ON VIEW v_expiring_licenses IS 'Content with licenses expiring in next 30 days';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update content updated_at timestamp
CREATE OR REPLACE FUNCTION update_content_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate content performance score
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
    -- Impression volume score (max 100)
    v_impression_score := LEAST(100, (p_total_impressions::DECIMAL / 10000.0) * 100);

    -- CTR score (assuming 5% CTR = 100 score)
    v_ctr_score := COALESCE((p_average_ctr * 100) * 20, 0);

    -- Campaign usage score (max 100)
    v_usage_score := LEAST(100, p_used_in_campaigns_count * 10);

    -- Recency score (days since creation)
    v_days_since_created := EXTRACT(DAY FROM CURRENT_TIMESTAMP - p_created_at);
    v_recency_score := CASE
        WHEN v_days_since_created < 30 THEN 100
        WHEN v_days_since_created < 90 THEN 90
        WHEN v_days_since_created < 180 THEN 70
        WHEN v_days_since_created < 365 THEN 50
        ELSE 30
    END;

    -- Weighted average
    v_performance_score := (
        (v_impression_score * 0.30) +
        (v_ctr_score * 0.30) +
        (v_usage_score * 0.20) +
        (v_recency_score * 0.20)
    );

    RETURN ROUND(v_performance_score, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function: Update folder statistics
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

-- Function: Validate folder depth
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
            RAISE EXCEPTION 'Maximum folder depth (5) exceeded';
        END IF;
    ELSE
        NEW.depth := 0;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Log content audit event
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

        -- Determine specific event type
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
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at on content_assets
CREATE TRIGGER trigger_content_assets_updated_at
    BEFORE UPDATE ON content_assets
    FOR EACH ROW
    EXECUTE FUNCTION update_content_updated_at();

-- Trigger: Update updated_at on content_folders
CREATE TRIGGER trigger_content_folders_updated_at
    BEFORE UPDATE ON content_folders
    FOR EACH ROW
    EXECUTE FUNCTION update_content_updated_at();

-- Trigger: Update updated_at on cdn_distributions
CREATE TRIGGER trigger_cdn_distributions_updated_at
    BEFORE UPDATE ON cdn_distributions
    FOR EACH ROW
    EXECUTE FUNCTION update_content_updated_at();

-- Trigger: Update folder statistics
CREATE TRIGGER trigger_update_folder_statistics
    AFTER INSERT OR UPDATE OR DELETE ON content_assets
    FOR EACH ROW
    EXECUTE FUNCTION update_folder_statistics();

-- Trigger: Validate folder depth
CREATE TRIGGER trigger_validate_folder_depth
    BEFORE INSERT OR UPDATE ON content_folders
    FOR EACH ROW
    EXECUTE FUNCTION validate_folder_depth();

-- Trigger: Log content audit events
CREATE TRIGGER trigger_log_content_audit_event
    AFTER INSERT OR UPDATE OR DELETE ON content_assets
    FOR EACH ROW
    EXECUTE FUNCTION log_content_audit_event();

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get moderation queue with priorities
SELECT * FROM v_moderation_queue
WHERE sla_status IN ('URGENT', 'OVERDUE')
ORDER BY priority DESC, moderation_request_time ASC;

-- Get advertiser storage usage
SELECT
    adv.business_name,
    css.total_assets,
    css.total_storage_gb,
    css.total_impressions_all_assets
FROM v_content_storage_summary css
INNER JOIN advertisers adv ON css.advertiser_id = adv.id
ORDER BY css.total_storage_gb DESC;

-- Get top performing content for advertiser
SELECT * FROM v_top_performing_content
WHERE advertiser_id = 'ADVERTISER_UUID'
ORDER BY performance_score DESC
LIMIT 10;

-- Get content with expiring licenses
SELECT * FROM v_expiring_licenses
WHERE urgency_level IN ('CRITICAL', 'EXPIRED')
ORDER BY license_expiry_date ASC;

-- Get content performance over time
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

-- Get content audit trail
SELECT
    event_type,
    event_description,
    occurred_at,
    performed_by_user_id
FROM content_audit_log
WHERE asset_id = 'ASSET_UUID'
ORDER BY occurred_at DESC;

-- Find duplicate content by hash
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
-- END OF CONTENT SCHEMA
-- ============================================================================
