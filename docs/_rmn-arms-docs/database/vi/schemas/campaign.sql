-- ============================================================================
-- RMN-Arms Database Schema: Module Quản lý Chiến dịch
-- ============================================================================
-- Version: 1.0
-- Last Updated: 2026-01-23
-- Mô tả: Schema database đầy đủ cho Quản lý Chiến dịch bao gồm
--        chiến dịch, nhắm mục tiêu, số liệu, gán nội dung, và theo dõi ngân sách
-- ============================================================================

-- ============================================================================
-- TABLE: campaigns
-- Mô tả: Thực thể chiến dịch chính với vòng đời, ngân sách, và thông tin thanh toán
-- ============================================================================

CREATE TABLE campaigns (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE RESTRICT,

    -- Thông tin Cơ bản
    name VARCHAR(200) NOT NULL CHECK (LENGTH(name) >= 3),
    description TEXT,

    -- Trạng thái & Vòng đời
    status VARCHAR(50) NOT NULL CHECK (status IN (
        'DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED',
        'SCHEDULED', 'ACTIVE', 'PAUSED', 'COMPLETED'
    )),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    rejected_at TIMESTAMPTZ,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    activated_at TIMESTAMPTZ,
    paused_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    -- Thông tin Ngân sách
    total_budget_amount DECIMAL(12, 2) NOT NULL CHECK (total_budget_amount >= 100.00),
    total_budget_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    allocated_budget_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    spent_budget_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    -- Giới hạn Ngân sách Hàng ngày
    daily_cap_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    daily_cap_amount DECIMAL(12, 2),
    daily_spent_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    daily_spent_reset_at TIMESTAMPTZ,

    -- Mô hình Thanh toán (chỉ CPM hiện tại)
    billing_model VARCHAR(20) NOT NULL DEFAULT 'CPM' CHECK (billing_model = 'CPM'),
    cpm_rate_amount DECIMAL(10, 4) NOT NULL CHECK (cpm_rate_amount >= 0.10 AND cpm_rate_amount <= 50.00),
    cpm_rate_currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Thông tin Từ chối/Tạm dừng
    rejection_reason TEXT,
    rejected_by UUID REFERENCES users(id),
    pause_reason VARCHAR(100),
    paused_by UUID REFERENCES users(id),
    completion_reason VARCHAR(100),

    -- Audit
    version INTEGER NOT NULL DEFAULT 1,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT campaigns_date_range_check CHECK (
        end_date IS NULL OR start_date IS NULL OR end_date > start_date
    ),
    CONSTRAINT campaigns_budget_check CHECK (
        allocated_budget_amount <= total_budget_amount AND
        spent_budget_amount <= allocated_budget_amount
    ),
    CONSTRAINT campaigns_daily_cap_check CHECK (
        daily_cap_enabled = FALSE OR daily_cap_amount > 0
    )
);

-- Indexes
CREATE INDEX idx_campaigns_advertiser_id ON campaigns(advertiser_id);
CREATE INDEX idx_campaigns_status ON campaigns(status);
CREATE INDEX idx_campaigns_created_at ON campaigns(created_at DESC);
CREATE INDEX idx_campaigns_start_date ON campaigns(start_date);
CREATE INDEX idx_campaigns_end_date ON campaigns(end_date);
CREATE INDEX idx_campaigns_activated_at ON campaigns(activated_at);
CREATE INDEX idx_campaigns_status_dates ON campaigns(status, start_date, end_date);
CREATE INDEX idx_campaigns_advertiser_status ON campaigns(advertiser_id, status);

-- Comments
COMMENT ON TABLE campaigns IS 'Bảng chiến dịch chính theo dõi vòng đời đầy đủ và ngân sách';
COMMENT ON COLUMN campaigns.status IS 'Trạng thái vòng đời hiện tại của chiến dịch';
COMMENT ON COLUMN campaigns.total_budget_amount IS 'Tổng ngân sách chiến dịch - tối thiểu $100';
COMMENT ON COLUMN campaigns.allocated_budget_amount IS 'Số tiền giữ từ ví nhà quảng cáo';
COMMENT ON COLUMN campaigns.spent_budget_amount IS 'Số tiền thực tế chi cho lượt hiển thị';
COMMENT ON COLUMN campaigns.cpm_rate_amount IS 'Chi phí cho 1000 lượt hiển thị - phạm vi $0.10-$50.00';

-- ============================================================================
-- TABLE: campaign_targeting
-- Mô tả: Tiêu chí nhắm mục tiêu cho phân phối quảng cáo chiến dịch
-- ============================================================================

CREATE TABLE campaign_targeting (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

    -- Nhắm mục tiêu Địa lý
    countries TEXT[], -- Mã ISO 3166-1 alpha-2
    states TEXT[],
    cities TEXT[],
    postal_codes TEXT[],

    -- Nhắm mục tiêu Nhân khẩu học
    age_groups VARCHAR(20)[], -- ['18-24', '25-34', '35-44', '45-54', '55-64', '65+']
    genders VARCHAR(20)[], -- ['MALE', 'FEMALE', 'OTHER', 'ALL']
    languages TEXT[], -- Mã ISO 639-1

    -- Nhắm mục tiêu Hành vi
    interests TEXT[],
    purchase_categories TEXT[],

    -- Nhắm mục tiêu Ngữ cảnh
    content_categories TEXT[],
    keywords TEXT[],

    -- Nhắm mục tiêu Thiết bị
    device_types VARCHAR(50)[], -- ['TABLET', 'TV', 'KIOSK', 'DIGITAL_SIGNAGE']
    os_types VARCHAR(50)[], -- ['ANDROID', 'IOS', 'LINUX', 'WINDOWS']
    min_screen_size_inches DECIMAL(4, 1),

    -- Nhắm mục tiêu Thời gian (Day Parting)
    days_of_week INTEGER[], -- [1-7] trong đó 1=Thứ Hai
    time_windows JSONB, -- [{start: "HH:MM", end: "HH:MM"}]
    timezone VARCHAR(50),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT campaign_targeting_unique UNIQUE(campaign_id)
);

-- Indexes
CREATE INDEX idx_campaign_targeting_campaign_id ON campaign_targeting(campaign_id);
CREATE INDEX idx_campaign_targeting_countries ON campaign_targeting USING GIN(countries);
CREATE INDEX idx_campaign_targeting_device_types ON campaign_targeting USING GIN(device_types);

-- Comments
COMMENT ON TABLE campaign_targeting IS 'Quy tắc nhắm mục tiêu cho phân phối quảng cáo chiến dịch';
COMMENT ON COLUMN campaign_targeting.time_windows IS 'Mảng JSON của cửa sổ thời gian cho day parting';

-- ============================================================================
-- TABLE: campaign_competitor_blocking
-- Mô tả: Quy tắc chặn đối thủ cho chiến dịch
-- ============================================================================

CREATE TABLE campaign_competitor_blocking (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

    -- Cấu hình Chặn
    enabled BOOLEAN NOT NULL DEFAULT FALSE,
    block_level VARCHAR(20) NOT NULL DEFAULT 'MODERATE' CHECK (block_level IN ('STRICT', 'MODERATE', 'RELAXED')),

    -- Thực thể Bị chặn
    blocked_advertiser_ids UUID[],
    blocked_categories TEXT[],
    blocked_keywords TEXT[],

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT campaign_competitor_blocking_unique UNIQUE(campaign_id)
);

-- Indexes
CREATE INDEX idx_competitor_blocking_campaign_id ON campaign_competitor_blocking(campaign_id);
CREATE INDEX idx_competitor_blocking_enabled ON campaign_competitor_blocking(enabled) WHERE enabled = TRUE;

-- Comments
COMMENT ON TABLE campaign_competitor_blocking IS 'Cấu hình chặn đối thủ cho mỗi chiến dịch';

-- ============================================================================
-- TABLE: campaign_content_assignments
-- Mô tả: Gán nội dung cho chiến dịch
-- ============================================================================

CREATE TABLE campaign_content_assignments (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    content_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE RESTRICT,

    -- Chi tiết Gán
    priority INTEGER NOT NULL DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
    rotation_weight INTEGER NOT NULL DEFAULT 100 CHECK (rotation_weight BETWEEN 1 AND 100),

    -- Trạng thái
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAUSED', 'EXPIRED')),

    -- Lịch trình
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,

    -- Theo dõi Hiệu suất
    impressions_served BIGINT NOT NULL DEFAULT 0,
    clicks_received BIGINT NOT NULL DEFAULT 0,

    -- Timestamps
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT campaign_content_assignments_unique UNIQUE(campaign_id, content_id),
    CONSTRAINT campaign_content_date_range CHECK (
        end_date IS NULL OR start_date IS NULL OR end_date > start_date
    )
);

-- Indexes
CREATE INDEX idx_content_assignments_campaign_id ON campaign_content_assignments(campaign_id);
CREATE INDEX idx_content_assignments_content_id ON campaign_content_assignments(content_id);
CREATE INDEX idx_content_assignments_status ON campaign_content_assignments(status);
CREATE INDEX idx_content_assignments_campaign_status ON campaign_content_assignments(campaign_id, status);

-- Comments
COMMENT ON TABLE campaign_content_assignments IS 'Ánh xạ nội dung cho chiến dịch với lịch trình và xoay vòng';
COMMENT ON COLUMN campaign_content_assignments.priority IS 'Ưu tiên hiển thị 1-10 (10 là cao nhất)';
COMMENT ON COLUMN campaign_content_assignments.rotation_weight IS 'Trọng số phần trăm cho xoay vòng (1-100)';

-- ============================================================================
-- TABLE: campaign_metrics
-- Mô tả: Số liệu hiệu suất cho chiến dịch
-- ============================================================================

CREATE TABLE campaign_metrics (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

    -- Ngày cho số liệu (tổng hợp hàng ngày)
    metrics_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Số liệu Lượt hiển thị
    total_impressions BIGINT NOT NULL DEFAULT 0,
    verified_impressions BIGINT NOT NULL DEFAULT 0,
    fraudulent_impressions BIGINT NOT NULL DEFAULT 0,
    low_quality_impressions BIGINT NOT NULL DEFAULT 0,

    -- Số liệu Tương tác
    clicks BIGINT NOT NULL DEFAULT 0,
    ctr DECIMAL(5, 4) DEFAULT 0.0000, -- Tỷ lệ nhấp chuột

    -- Số liệu Tài chính
    total_spent_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_spent_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    average_cpm_amount DECIMAL(10, 4) DEFAULT 0.0000,
    cost_per_click_amount DECIMAL(10, 4) DEFAULT 0.0000,

    -- Số liệu Chất lượng
    average_quality_score DECIMAL(5, 2) CHECK (average_quality_score IS NULL OR average_quality_score BETWEEN 0 AND 100),
    completion_rate DECIMAL(5, 4) CHECK (completion_rate IS NULL OR completion_rate BETWEEN 0 AND 1),

    -- Thời gian
    last_impression_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT campaign_metrics_unique UNIQUE(campaign_id, metrics_date)
);

-- Indexes
CREATE INDEX idx_campaign_metrics_campaign_id ON campaign_metrics(campaign_id);
CREATE INDEX idx_campaign_metrics_date ON campaign_metrics(metrics_date DESC);
CREATE INDEX idx_campaign_metrics_campaign_date ON campaign_metrics(campaign_id, metrics_date DESC);

-- Comments
COMMENT ON TABLE campaign_metrics IS 'Số liệu hiệu suất tổng hợp hàng ngày cho mỗi chiến dịch';
COMMENT ON COLUMN campaign_metrics.ctr IS 'Tỷ lệ nhấp chuột (nhấp / lượt hiển thị)';
COMMENT ON COLUMN campaign_metrics.average_cpm_amount IS 'Chi phí trung bình cho 1000 lượt hiển thị';

-- ============================================================================
-- TABLE: campaign_budget_history
-- Mô tả: Audit trail cho thay đổi ngân sách
-- ============================================================================

CREATE TABLE campaign_budget_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    wallet_transaction_id UUID REFERENCES wallet_transactions(id),

    -- Loại Sự kiện
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'ALLOCATED', 'SPENT', 'RELEASED', 'REFUNDED'
    )),

    -- Số tiền
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Số dư Sau Giao dịch
    allocated_balance_after DECIMAL(12, 2),
    spent_balance_after DECIMAL(12, 2),

    -- Tham chiếu
    reference_type VARCHAR(50), -- 'IMPRESSION', 'REFUND', 'CAMPAIGN_END'
    reference_id UUID,

    -- Ghi chú
    notes TEXT,

    -- Timestamps
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_budget_history_campaign_id ON campaign_budget_history(campaign_id);
CREATE INDEX idx_budget_history_occurred_at ON campaign_budget_history(occurred_at DESC);
CREATE INDEX idx_budget_history_event_type ON campaign_budget_history(event_type);
CREATE INDEX idx_budget_history_campaign_date ON campaign_budget_history(campaign_id, occurred_at DESC);

-- Comments
COMMENT ON TABLE campaign_budget_history IS 'Audit trail đầy đủ của tất cả giao dịch ngân sách';
COMMENT ON COLUMN campaign_budget_history.event_type IS 'Loại sự kiện ngân sách (ALLOCATED, SPENT, RELEASED, REFUNDED)';

-- ============================================================================
-- TABLE: campaign_status_history
-- Mô tả: Theo dõi chuyển đổi trạng thái chiến dịch
-- ============================================================================

CREATE TABLE campaign_status_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

    -- Chuyển đổi Trạng thái
    from_status VARCHAR(50),
    to_status VARCHAR(50) NOT NULL,

    -- Lý do & Ghi chú
    reason VARCHAR(200),
    notes TEXT,

    -- Timestamp
    transitioned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    changed_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_status_history_campaign_id ON campaign_status_history(campaign_id);
CREATE INDEX idx_status_history_transitioned_at ON campaign_status_history(transitioned_at DESC);
CREATE INDEX idx_status_history_to_status ON campaign_status_history(to_status);

-- Comments
COMMENT ON TABLE campaign_status_history IS 'Audit trail của thay đổi trạng thái chiến dịch';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Chiến dịch Hoạt động với Số liệu Hiện tại
CREATE OR REPLACE VIEW v_active_campaigns AS
SELECT
    c.id,
    c.name,
    c.advertiser_id,
    c.status,
    c.total_budget_amount,
    c.allocated_budget_amount,
    c.spent_budget_amount,
    c.total_budget_amount - c.spent_budget_amount AS remaining_budget,
    ROUND((c.spent_budget_amount / NULLIF(c.total_budget_amount, 0) * 100), 2) AS budget_used_percentage,
    c.start_date,
    c.end_date,
    c.cpm_rate_amount,
    cm.total_impressions,
    cm.verified_impressions,
    cm.clicks,
    cm.ctr,
    cm.average_cpm_amount,
    cm.average_quality_score
FROM campaigns c
LEFT JOIN LATERAL (
    SELECT
        SUM(total_impressions) AS total_impressions,
        SUM(verified_impressions) AS verified_impressions,
        SUM(clicks) AS clicks,
        CASE
            WHEN SUM(total_impressions) > 0
            THEN ROUND((SUM(clicks)::DECIMAL / SUM(total_impressions)), 4)
            ELSE 0
        END AS ctr,
        AVG(average_cpm_amount) AS average_cpm_amount,
        AVG(average_quality_score) AS average_quality_score
    FROM campaign_metrics
    WHERE campaign_id = c.id
) cm ON TRUE
WHERE c.status = 'ACTIVE';

-- View: Trạng thái Ngân sách Chiến dịch
CREATE OR REPLACE VIEW v_campaign_budget_status AS
SELECT
    c.id,
    c.name,
    c.advertiser_id,
    c.status,
    c.total_budget_amount,
    c.allocated_budget_amount,
    c.spent_budget_amount,
    c.allocated_budget_amount - c.spent_budget_amount AS unspent_allocated,
    CASE
        WHEN c.spent_budget_amount >= c.allocated_budget_amount THEN 'EXHAUSTED'
        WHEN c.spent_budget_amount >= (c.allocated_budget_amount * 0.95) THEN 'CRITICAL'
        WHEN c.spent_budget_amount >= (c.allocated_budget_amount * 0.80) THEN 'LOW'
        ELSE 'AVAILABLE'
    END AS budget_status,
    ROUND((c.spent_budget_amount / NULLIF(c.allocated_budget_amount, 0) * 100), 2) AS spend_rate
FROM campaigns c;

-- Comments on views
COMMENT ON VIEW v_active_campaigns IS 'Chiến dịch hoạt động với số liệu hiệu suất tổng hợp';
COMMENT ON VIEW v_campaign_budget_status IS 'Trạng thái ngân sách chiến dịch với ngưỡng';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Cập nhật timestamp updated_at của chiến dịch
CREATE OR REPLACE FUNCTION update_campaign_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Đặt lại chi tiêu hàng ngày vào nửa đêm
CREATE OR REPLACE FUNCTION reset_campaign_daily_spend()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.daily_spent_reset_at IS NULL OR
       NEW.daily_spent_reset_at < CURRENT_DATE THEN
        NEW.daily_spent_amount = 0;
        NEW.daily_spent_reset_at = CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Xác thực ràng buộc ngân sách
CREATE OR REPLACE FUNCTION validate_campaign_budget()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.spent_budget_amount > NEW.allocated_budget_amount THEN
        RAISE EXCEPTION 'Spent budget cannot exceed allocated budget';
    END IF;

    IF NEW.allocated_budget_amount > NEW.total_budget_amount THEN
        RAISE EXCEPTION 'Allocated budget cannot exceed total budget';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Cập nhật updated_at trên campaigns
CREATE TRIGGER trigger_campaigns_updated_at
    BEFORE UPDATE ON campaigns
    FOR EACH ROW
    EXECUTE FUNCTION update_campaign_updated_at();

-- Trigger: Đặt lại chi tiêu hàng ngày
CREATE TRIGGER trigger_reset_daily_spend
    BEFORE UPDATE ON campaigns
    FOR EACH ROW
    WHEN (OLD.daily_spent_amount IS DISTINCT FROM NEW.daily_spent_amount)
    EXECUTE FUNCTION reset_campaign_daily_spend();

-- Trigger: Xác thực ràng buộc ngân sách
CREATE TRIGGER trigger_validate_campaign_budget
    BEFORE INSERT OR UPDATE ON campaigns
    FOR EACH ROW
    EXECUTE FUNCTION validate_campaign_budget();

-- Trigger: Cập nhật updated_at trên campaign_targeting
CREATE TRIGGER trigger_campaign_targeting_updated_at
    BEFORE UPDATE ON campaign_targeting
    FOR EACH ROW
    EXECUTE FUNCTION update_campaign_updated_at();

-- Trigger: Cập nhật updated_at trên campaign_content_assignments
CREATE TRIGGER trigger_campaign_content_assignments_updated_at
    BEFORE UPDATE ON campaign_content_assignments
    FOR EACH ROW
    EXECUTE FUNCTION update_campaign_updated_at();

-- ============================================================================
-- TRUY VẤN MẪU
-- ============================================================================

/*
-- Lấy chiến dịch hoạt động với ngân sách gần cạn kiệt
SELECT * FROM v_campaign_budget_status
WHERE status = 'ACTIVE'
  AND budget_status IN ('LOW', 'CRITICAL')
ORDER BY spend_rate DESC;

-- Lấy hiệu suất chiến dịch cho nhà quảng cáo
SELECT
    c.name,
    c.status,
    SUM(cm.total_impressions) AS total_impressions,
    SUM(cm.verified_impressions) AS verified_impressions,
    SUM(cm.clicks) AS clicks,
    AVG(cm.ctr) AS avg_ctr,
    SUM(cm.total_spent_amount) AS total_spent
FROM campaigns c
LEFT JOIN campaign_metrics cm ON c.id = cm.campaign_id
WHERE c.advertiser_id = 'ADVERTISER_UUID'
GROUP BY c.id, c.name, c.status;

-- Lấy chiến dịch cần được kích hoạt (đã lên lịch và ngày bắt đầu đã đến)
SELECT * FROM campaigns
WHERE status = 'SCHEDULED'
  AND start_date <= CURRENT_TIMESTAMP
  AND (end_date IS NULL OR end_date > CURRENT_TIMESTAMP);

-- Lấy lịch sử phân bổ ngân sách cho chiến dịch
SELECT
    event_type,
    amount,
    allocated_balance_after,
    spent_balance_after,
    notes,
    occurred_at
FROM campaign_budget_history
WHERE campaign_id = 'CAMPAIGN_UUID'
ORDER BY occurred_at DESC;
*/

-- ============================================================================
-- KẾT THÚC SCHEMA CHIẾN DỊCH
-- ============================================================================
