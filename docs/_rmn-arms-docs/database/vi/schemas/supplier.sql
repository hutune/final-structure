-- ============================================================================
-- Schema Cơ sở dữ liệu RMN-Arms: Supplier Management Module
-- ============================================================================
-- Phiên bản: 1.0
-- Cập nhật lần cuối: 2026-01-23
-- Mô tả: Schema cơ sở dữ liệu đầy đủ for Supplier Management including
--              suppliers, stores, revenue tracking, payouts, and blocking rules
-- ============================================================================

-- ============================================================================
-- BẢNG: suppliers
-- Mô tả: Main supplier entity with business details, status, and performance
-- ============================================================================

CREATE TABLE suppliers (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    wallet_id UUID REFERENCES wallets(id) ON DELETE RESTRICT,

    -- Basic Business Information
    business_name VARCHAR(200) NOT NULL CHECK (LENGTH(business_name) >= 2),
    display_name VARCHAR(200),
    business_type VARCHAR(50) NOT NULL CHECK (business_type IN (
        'INDIVIDUAL', 'SOLE_PROPRIETORSHIP', 'LLC', 'CORPORATION', 'PARTNERSHIP'
    )),

    -- Business Registration
    tax_id VARCHAR(50) NOT NULL UNIQUE,
    business_registration_number VARCHAR(100),
    registration_country VARCHAR(2) NOT NULL, -- ISO 3166-1 alpha-2
    registration_state VARCHAR(50),
    incorporation_date DATE,

    -- Contact Information
    primary_contact_name VARCHAR(100) NOT NULL,
    primary_contact_email VARCHAR(255) NOT NULL,
    primary_contact_phone VARCHAR(50) NOT NULL,

    -- Business Address (JSONB for flexibility)
    business_address JSONB NOT NULL,
    billing_address JSONB,

    -- Status & Verification
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING_REGISTRATION' CHECK (status IN (
        'PENDING_REGISTRATION', 'ACTIVE', 'INACTIVE', 'SUSPENDED', 'PERMANENTLY_BANNED'
    )),
    tier VARCHAR(50) NOT NULL DEFAULT 'STARTER' CHECK (tier IN (
        'STARTER', 'PROFESSIONAL', 'ENTERPRISE'
    )),
    verification_status VARCHAR(50) NOT NULL DEFAULT 'UNVERIFIED' CHECK (verification_status IN (
        'UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED'
    )),

    -- Financial Settings
    revenue_share_percentage DECIMAL(5, 2) NOT NULL DEFAULT 80.00 CHECK (revenue_share_percentage BETWEEN 0 AND 100),
    payment_schedule VARCHAR(20) NOT NULL DEFAULT 'WEEKLY' CHECK (payment_schedule IN (
        'WEEKLY', 'BIWEEKLY', 'MONTHLY'
    )),
    minimum_payout_threshold DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    payout_method VARCHAR(50) DEFAULT 'BANK_TRANSFER' CHECK (payout_method IN (
        'BANK_TRANSFER', 'PAYPAL', 'STRIPE'
    )),

    -- Bank Information (encrypted in production)
    bank_account_details JSONB,

    -- Performance Metrics
    total_stores INTEGER NOT NULL DEFAULT 0,
    total_devices INTEGER NOT NULL DEFAULT 0,
    total_impressions_served BIGINT NOT NULL DEFAULT 0,
    total_revenue_earned DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    average_device_uptime DECIMAL(5, 2) DEFAULT 0.00,
    quality_score DECIMAL(5, 2) DEFAULT 0.00 CHECK (quality_score IS NULL OR quality_score BETWEEN 0 AND 100),

    -- Settings
    auto_approve_campaigns BOOLEAN NOT NULL DEFAULT FALSE,
    notification_preferences JSONB,
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    locale VARCHAR(10) NOT NULL DEFAULT 'en-US',

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ,
    last_payout_at TIMESTAMPTZ,
    suspended_at TIMESTAMPTZ,
    banned_at TIMESTAMPTZ,

    -- Suspension/Ban Information
    suspension_reason TEXT,
    ban_reason TEXT,

    -- Audit
    version INTEGER NOT NULL DEFAULT 1,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Chỉ mục
CREATE INDEX idx_suppliers_user_id ON suppliers(user_id);
CREATE INDEX idx_suppliers_status ON suppliers(status);
CREATE INDEX idx_suppliers_tier ON suppliers(tier);
CREATE INDEX idx_suppliers_verification_status ON suppliers(verification_status);
CREATE INDEX idx_suppliers_created_at ON suppliers(created_at DESC);
CREATE INDEX idx_suppliers_quality_score ON suppliers(quality_score DESC);
CREATE INDEX idx_suppliers_status_tier ON suppliers(status, tier);
CREATE INDEX idx_suppliers_tax_id ON suppliers(tax_id);

-- Comments
COMMENT ON TABLE suppliers IS 'Main supplier table tracking business details, status, and performance';
COMMENT ON COLUMN suppliers.status IS 'Current operational status (PENDING_REGISTRATION, ACTIVE, INACTIVE, SUSPENDED, PERMANENTLY_BANNED)';
COMMENT ON COLUMN suppliers.tier IS 'Account tier (STARTER: 1-5 devices, PROFESSIONAL: 6-50, ENTERPRISE: 51+)';
COMMENT ON COLUMN suppliers.revenue_share_percentage IS 'Supplier revenue share percentage (default 80%, can be 85% for Platinum)';
COMMENT ON COLUMN suppliers.quality_score IS 'Overall performance score 0-100 based on uptime, revenue, compliance, etc.';

-- ============================================================================
-- BẢNG: supplier_stores
-- Mô tả: Physical retail locations where devices are installed
-- ============================================================================

CREATE TABLE supplier_stores (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,

    -- Store Information
    store_name VARCHAR(200) NOT NULL,
    store_code VARCHAR(50), -- Internal supplier code (optional)
    store_type VARCHAR(50) NOT NULL CHECK (store_type IN (
        'GROCERY', 'RETAIL', 'RESTAURANT', 'GYM', 'PHARMACY',
        'CONVENIENCE', 'DEPARTMENT_STORE', 'SHOPPING_MALL', 'OTHER'
    )),

    -- Location
    address JSONB NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    geofence_radius_meters INTEGER NOT NULL DEFAULT 100,

    -- Store Profile
    square_footage INTEGER,
    average_daily_visitors INTEGER,
    operating_hours JSONB, -- Array of {day_of_week, open_time, close_time, is_closed}

    -- Store Categories (for targeting)
    primary_category VARCHAR(100),
    subcategories TEXT[],

    -- Device Management
    max_devices_allowed INTEGER NOT NULL DEFAULT 1,
    total_devices INTEGER NOT NULL DEFAULT 0,
    active_devices INTEGER NOT NULL DEFAULT 0,

    -- Performance
    total_impressions_served BIGINT NOT NULL DEFAULT 0,
    total_revenue_generated DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    average_device_uptime DECIMAL(5, 2) DEFAULT 0.00,
    quality_score DECIMAL(5, 2) DEFAULT 0.00 CHECK (quality_score IS NULL OR quality_score BETWEEN 0 AND 100),

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN (
        'ACTIVE', 'INACTIVE', 'SUSPENDED'
    )),
    verified BOOLEAN NOT NULL DEFAULT FALSE,

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ,
    last_impression_at TIMESTAMPTZ,

    -- Ràng buộc
    CONSTRAINT supplier_stores_unique_name UNIQUE(supplier_id, store_name),
    CONSTRAINT supplier_stores_device_limit CHECK (total_devices <= max_devices_allowed)
);

-- Chỉ mục
CREATE INDEX idx_supplier_stores_supplier_id ON supplier_stores(supplier_id);
CREATE INDEX idx_supplier_stores_status ON supplier_stores(status);
CREATE INDEX idx_supplier_stores_verified ON supplier_stores(verified);
CREATE INDEX idx_supplier_stores_location ON supplier_stores(latitude, longitude);
CREATE INDEX idx_supplier_stores_supplier_status ON supplier_stores(supplier_id, status);
CREATE INDEX idx_supplier_stores_store_type ON supplier_stores(store_type);

-- Comments
COMMENT ON TABLE supplier_stores IS 'Physical retail store locations with device management and performance tracking';
COMMENT ON COLUMN supplier_stores.geofence_radius_meters IS 'Radius in meters for device location verification (default 100m)';
COMMENT ON COLUMN supplier_stores.max_devices_allowed IS 'Maximum devices allowed based on store size and tier';
COMMENT ON COLUMN supplier_stores.operating_hours IS 'JSON array of daily operating hours for ad serving windows';

-- ============================================================================
-- BẢNG: supplier_revenue_share
-- Mô tả: Daily revenue tracking and 80/20 split calculation
-- ============================================================================

CREATE TABLE supplier_revenue_share (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    store_id UUID REFERENCES supplier_stores(id) ON DELETE SET NULL,
    device_id UUID REFERENCES devices(id) ON DELETE SET NULL,

    -- Date for revenue (daily rollup)
    revenue_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Impression Metrics
    total_impressions BIGINT NOT NULL DEFAULT 0,
    verified_impressions BIGINT NOT NULL DEFAULT 0,
    fraudulent_impressions BIGINT NOT NULL DEFAULT 0,

    -- Revenue Calculations (all amounts in USD)
    gross_impression_cost DECIMAL(12, 2) NOT NULL DEFAULT 0.00, -- Total CPM cost
    supplier_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0.00, -- 80% share
    platform_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0.00, -- 20% share

    -- Revenue Status
    revenue_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (revenue_status IN (
        'PENDING', 'AVAILABLE', 'PAID', 'HELD', 'DISPUTED'
    )),

    -- Average Metrics
    average_cpm DECIMAL(10, 4) DEFAULT 0.0000,

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    available_at TIMESTAMPTZ, -- Date when revenue becomes available (verified_at + 7 days)

    -- Ràng buộc
    CONSTRAINT supplier_revenue_share_unique UNIQUE(supplier_id, revenue_date, store_id, device_id),
    CONSTRAINT supplier_revenue_share_split_check CHECK (
        ABS(gross_impression_cost - (supplier_revenue + platform_revenue)) < 0.01
    )
);

-- Chỉ mục
CREATE INDEX idx_revenue_share_supplier_id ON supplier_revenue_share(supplier_id);
CREATE INDEX idx_revenue_share_date ON supplier_revenue_share(revenue_date DESC);
CREATE INDEX idx_revenue_share_supplier_date ON supplier_revenue_share(supplier_id, revenue_date DESC);
CREATE INDEX idx_revenue_share_status ON supplier_revenue_share(revenue_status);
CREATE INDEX idx_revenue_share_available_at ON supplier_revenue_share(available_at);
CREATE INDEX idx_revenue_share_store_id ON supplier_revenue_share(store_id);
CREATE INDEX idx_revenue_share_device_id ON supplier_revenue_share(device_id);

-- Comments
COMMENT ON TABLE supplier_revenue_share IS 'Daily aggregated revenue tracking with 80/20 supplier/platform split';
COMMENT ON COLUMN supplier_revenue_share.supplier_revenue IS 'Supplier share (80% of gross impression cost by default)';
COMMENT ON COLUMN supplier_revenue_share.platform_revenue IS 'Platform share (20% of gross impression cost)';
COMMENT ON COLUMN supplier_revenue_share.available_at IS 'Date when revenue moves from PENDING to AVAILABLE (7-day hold)';

-- ============================================================================
-- BẢNG: supplier_payout_history
-- Mô tả: Complete record of all payouts to suppliers
-- ============================================================================

CREATE TABLE supplier_payout_history (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
    wallet_transaction_id UUID REFERENCES wallet_transactions(id),

    -- Payout Information
    payout_amount DECIMAL(12, 2) NOT NULL CHECK (payout_amount > 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Tax Withholding
    tax_withholding_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    net_payout_amount DECIMAL(12, 2) NOT NULL CHECK (net_payout_amount > 0),

    -- Payout Method
    payout_method VARCHAR(50) NOT NULL CHECK (payout_method IN (
        'BANK_TRANSFER', 'PAYPAL', 'STRIPE', 'WIRE_TRANSFER'
    )),
    payout_destination JSONB, -- Masked bank account or payment details

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED'
    )),

    -- Period Covered
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,

    -- External Reference
    external_transaction_id VARCHAR(255), -- Payment processor transaction ID
    processor_response JSONB, -- Full response from payment processor

    -- Failure Information
    failure_reason TEXT,
    failure_code VARCHAR(50),

    -- Timestamp
    scheduled_at TIMESTAMPTZ NOT NULL,
    initiated_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by UUID REFERENCES users(id),
    cancelled_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT payout_history_amount_check CHECK (
        payout_amount = tax_withholding_amount + net_payout_amount
    ),
    CONSTRAINT payout_history_period_check CHECK (period_end_date >= period_start_date)
);

-- Chỉ mục
CREATE INDEX idx_payout_history_supplier_id ON supplier_payout_history(supplier_id);
CREATE INDEX idx_payout_history_status ON supplier_payout_history(status);
CREATE INDEX idx_payout_history_scheduled_at ON supplier_payout_history(scheduled_at DESC);
CREATE INDEX idx_payout_history_completed_at ON supplier_payout_history(completed_at DESC);
CREATE INDEX idx_payout_history_supplier_date ON supplier_payout_history(supplier_id, scheduled_at DESC);
CREATE INDEX idx_payout_history_period ON supplier_payout_history(period_start_date, period_end_date);

-- Comments
COMMENT ON TABLE supplier_payout_history IS 'Complete audit trail of all supplier payouts';
COMMENT ON COLUMN supplier_payout_history.payout_amount IS 'Gross payout amount before tax withholding';
COMMENT ON COLUMN supplier_payout_history.tax_withholding_amount IS 'Tax withholding (30% for non-US suppliers without treaty)';
COMMENT ON COLUMN supplier_payout_history.net_payout_amount IS 'Net amount transferred to supplier';

-- ============================================================================
-- BẢNG: supplier_competitor_blocking_rules
-- Mô tả: Competitor blocking rules defined by suppliers
-- ============================================================================

CREATE TABLE supplier_competitor_blocking_rules (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    store_id UUID REFERENCES supplier_stores(id) ON DELETE CASCADE, -- NULL = applies to all stores

    -- Rule Configuration
    rule_name VARCHAR(200) NOT NULL,
    rule_type VARCHAR(50) NOT NULL CHECK (rule_type IN (
        'ADVERTISER', 'INDUSTRY', 'KEYWORD', 'CUSTOM'
    )),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Blocking Criteria
    blocked_advertiser_ids UUID[],
    blocked_industry_categories TEXT[],
    blocked_keywords TEXT[],

    -- Scope
    applies_to_all_stores BOOLEAN NOT NULL DEFAULT TRUE,
    specific_store_ids UUID[],

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by_user_id UUID REFERENCES users(id),
    updated_by_user_id UUID REFERENCES users(id)
);

-- Chỉ mục
CREATE INDEX idx_blocking_rules_supplier_id ON supplier_competitor_blocking_rules(supplier_id);
CREATE INDEX idx_blocking_rules_store_id ON supplier_competitor_blocking_rules(store_id);
CREATE INDEX idx_blocking_rules_active ON supplier_competitor_blocking_rules(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_blocking_rules_type ON supplier_competitor_blocking_rules(rule_type);
CREATE INDEX idx_blocking_rules_supplier_active ON supplier_competitor_blocking_rules(supplier_id, is_active);

-- Comments
COMMENT ON TABLE supplier_competitor_blocking_rules IS 'Supplier-defined rules to block competitor ads';
COMMENT ON COLUMN supplier_competitor_blocking_rules.applies_to_all_stores IS 'If TRUE, rule applies to all supplier stores';
COMMENT ON COLUMN supplier_competitor_blocking_rules.blocked_keywords IS 'Case-insensitive keyword matching in campaign/content';

-- ============================================================================
-- BẢNG: supplier_verification_documents
-- Mô tả: Track verification documents submitted by suppliers
-- ============================================================================

CREATE TABLE supplier_verification_documents (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,

    -- Verification Type
    verification_type VARCHAR(50) NOT NULL CHECK (verification_type IN (
        'BUSINESS', 'TAX', 'BANK_ACCOUNT', 'IDENTITY', 'ADDRESS'
    )),

    -- Document Information
    document_type VARCHAR(100) NOT NULL, -- 'EIN_LETTER', 'BUSINESS_LICENSE', 'W9', etc.
    document_url VARCHAR(500), -- S3 URL or file storage path
    document_metadata JSONB, -- Original filename, file size, mime type, etc.

    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'APPROVED', 'REJECTED', 'EXPIRED'
    )),

    -- Review Information
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES users(id),
    rejection_reason TEXT,
    notes TEXT,

    -- Expiration
    expires_at DATE,

    -- Timestamp
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Chỉ mục
CREATE INDEX idx_verification_docs_supplier_id ON supplier_verification_documents(supplier_id);
CREATE INDEX idx_verification_docs_status ON supplier_verification_documents(status);
CREATE INDEX idx_verification_docs_type ON supplier_verification_documents(verification_type);
CREATE INDEX idx_verification_docs_expires_at ON supplier_verification_documents(expires_at);
CREATE INDEX idx_verification_docs_supplier_status ON supplier_verification_documents(supplier_id, status);

-- Comments
COMMENT ON TABLE supplier_verification_documents IS 'Track verification documents and their review status';
COMMENT ON COLUMN supplier_verification_documents.expires_at IS 'Document expiration date (e.g., business license renewal)';

-- ============================================================================
-- BẢNG: supplier_status_history
-- Mô tả: Track supplier status transitions
-- ============================================================================

CREATE TABLE supplier_status_history (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,

    -- Status Transition
    from_status VARCHAR(50),
    to_status VARCHAR(50) NOT NULL,

    -- Reason & Notes
    reason VARCHAR(200),
    notes TEXT,

    -- Timestamp
    transitioned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    changed_by UUID REFERENCES users(id)
);

-- Chỉ mục
CREATE INDEX idx_supplier_status_history_supplier_id ON supplier_status_history(supplier_id);
CREATE INDEX idx_supplier_status_history_transitioned_at ON supplier_status_history(transitioned_at DESC);
CREATE INDEX idx_supplier_status_history_to_status ON supplier_status_history(to_status);
CREATE INDEX idx_supplier_status_history_supplier_date ON supplier_status_history(supplier_id, transitioned_at DESC);

-- Comments
COMMENT ON TABLE supplier_status_history IS 'Audit trail of supplier status changes';

-- ============================================================================
-- BẢNG: supplier_performance_metrics
-- Mô tả: Historical performance metrics for suppliers
-- ============================================================================

CREATE TABLE supplier_performance_metrics (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,

    -- Date for metrics (monthly rollup)
    metrics_month DATE NOT NULL, -- First day of month

    -- Performance Scores (0-100)
    device_uptime_score DECIMAL(5, 2),
    revenue_performance_score DECIMAL(5, 2),
    compliance_score DECIMAL(5, 2),
    customer_rating_score DECIMAL(5, 2),
    growth_score DECIMAL(5, 2),
    overall_quality_score DECIMAL(5, 2),

    -- Revenue Metrics
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    expected_revenue DECIMAL(12, 2),
    revenue_growth_percentage DECIMAL(5, 2),

    -- Device Metrics
    average_device_uptime DECIMAL(5, 2),
    total_devices INTEGER NOT NULL DEFAULT 0,
    active_devices INTEGER NOT NULL DEFAULT 0,

    -- Compliance Metrics
    violation_count INTEGER NOT NULL DEFAULT 0,
    dispute_count INTEGER NOT NULL DEFAULT 0,

    -- Engagement Metrics
    total_impressions BIGINT NOT NULL DEFAULT 0,
    verified_impressions BIGINT NOT NULL DEFAULT 0,
    average_cpm DECIMAL(10, 4),

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT supplier_performance_unique UNIQUE(supplier_id, metrics_month)
);

-- Chỉ mục
CREATE INDEX idx_performance_metrics_supplier_id ON supplier_performance_metrics(supplier_id);
CREATE INDEX idx_performance_metrics_month ON supplier_performance_metrics(metrics_month DESC);
CREATE INDEX idx_performance_metrics_quality_score ON supplier_performance_metrics(overall_quality_score DESC);
CREATE INDEX idx_performance_metrics_supplier_month ON supplier_performance_metrics(supplier_id, metrics_month DESC);

-- Comments
COMMENT ON TABLE supplier_performance_metrics IS 'Monthly aggregated performance metrics and quality scores';
COMMENT ON COLUMN supplier_performance_metrics.overall_quality_score IS 'Weighted average of all component scores';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Active Suppliers with Current Performance
CREATE OR REPLACE VIEW v_active_suppliers AS
SELECT
    s.id,
    s.business_name,
    s.display_name,
    s.status,
    s.tier,
    s.verification_status,
    s.total_stores,
    s.total_devices,
    s.quality_score,
    s.revenue_share_percentage,
    s.average_device_uptime,
    COALESCE(rs.monthly_revenue, 0) AS current_month_revenue,
    COALESCE(rs.monthly_impressions, 0) AS current_month_impressions,
    w.available_balance AS wallet_available_balance,
    w.pending_balance AS wallet_pending_balance,
    s.last_payout_at,
    s.created_at
FROM suppliers s
LEFT JOIN wallets w ON s.wallet_id = w.id
LEFT JOIN LATERAL (
    SELECT
        SUM(supplier_revenue) AS monthly_revenue,
        SUM(verified_impressions) AS monthly_impressions
    FROM supplier_revenue_share
    WHERE supplier_id = s.id
      AND revenue_date >= DATE_TRUNC('month', CURRENT_DATE)
) rs ON TRUE
WHERE s.status = 'ACTIVE';

-- View: Supplier Revenue Summary
CREATE OR REPLACE VIEW v_supplier_revenue_summary AS
SELECT
    s.id AS supplier_id,
    s.business_name,
    s.tier,
    COUNT(DISTINCT st.id) AS total_stores,
    COUNT(DISTINCT d.id) AS total_devices,
    SUM(rs.verified_impressions) AS lifetime_impressions,
    SUM(rs.supplier_revenue) AS lifetime_revenue,
    SUM(CASE WHEN rs.revenue_date >= CURRENT_DATE - INTERVAL '30 days'
        THEN rs.supplier_revenue ELSE 0 END) AS revenue_last_30_days,
    SUM(CASE WHEN rs.revenue_date >= CURRENT_DATE - INTERVAL '7 days'
        THEN rs.supplier_revenue ELSE 0 END) AS revenue_last_7_days,
    AVG(rs.average_cpm) AS average_cpm,
    s.revenue_share_percentage,
    s.last_payout_at,
    w.available_balance,
    w.pending_balance
FROM suppliers s
LEFT JOIN supplier_stores st ON s.id = st.supplier_id
LEFT JOIN devices d ON st.id = d.store_id
LEFT JOIN supplier_revenue_share rs ON s.id = rs.supplier_id
LEFT JOIN wallets w ON s.wallet_id = w.id
GROUP BY s.id, s.business_name, s.tier, s.revenue_share_percentage, s.last_payout_at, w.available_balance, w.pending_balance;

-- View: Suppliers Pending Payout
CREATE OR REPLACE VIEW v_suppliers_pending_payout AS
SELECT
    s.id AS supplier_id,
    s.business_name,
    s.payment_schedule,
    s.minimum_payout_threshold,
    s.payout_method,
    w.available_balance,
    w.pending_balance,
    s.last_payout_at,
    CASE s.payment_schedule
        WHEN 'WEEKLY' THEN DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days'
        WHEN 'BIWEEKLY' THEN DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '14 days'
        WHEN 'MONTHLY' THEN DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
    END AS next_payout_date,
    CASE
        WHEN w.available_balance >= s.minimum_payout_threshold THEN 'ELIGIBLE'
        ELSE 'BELOW_THRESHOLD'
    END AS payout_eligibility
FROM suppliers s
JOIN wallets w ON s.wallet_id = w.id
WHERE s.status = 'ACTIVE'
  AND s.verification_status = 'VERIFIED';

-- View: Supplier Store Performance
CREATE OR REPLACE VIEW v_supplier_store_performance AS
SELECT
    st.id AS store_id,
    st.store_name,
    st.supplier_id,
    s.business_name AS supplier_business_name,
    st.store_type,
    st.status,
    st.verified,
    st.total_devices,
    st.active_devices,
    st.max_devices_allowed,
    st.quality_score,
    st.average_device_uptime,
    rs.revenue_30d,
    rs.impressions_30d
FROM supplier_stores st
JOIN suppliers s ON st.supplier_id = s.id
LEFT JOIN LATERAL (
    SELECT
        SUM(supplier_revenue) AS revenue_30d,
        SUM(verified_impressions) AS impressions_30d
    FROM supplier_revenue_share
    WHERE store_id = st.id
      AND revenue_date >= CURRENT_DATE - INTERVAL '30 days'
) rs ON TRUE;

-- Comments on views
COMMENT ON VIEW v_active_suppliers IS 'Active suppliers with current performance and wallet balances';
COMMENT ON VIEW v_supplier_revenue_summary IS 'Comprehensive revenue summary per supplier';
COMMENT ON VIEW v_suppliers_pending_payout IS 'Suppliers eligible for payout based on schedule and threshold';
COMMENT ON VIEW v_supplier_store_performance IS 'Performance metrics for all supplier stores';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update supplier updated_at timestamp
CREATE OR REPLACE FUNCTION update_supplier_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate supplier quality score
CREATE OR REPLACE FUNCTION calculate_supplier_quality_score(
    p_supplier_id UUID,
    p_period_days INTEGER DEFAULT 30
)
RETURNS DECIMAL(5, 2) AS $$
DECLARE
    v_uptime_score DECIMAL(5, 2) := 0;
    v_revenue_score DECIMAL(5, 2) := 0;
    v_compliance_score DECIMAL(5, 2) := 0;
    v_rating_score DECIMAL(5, 2) := 0;
    v_growth_score DECIMAL(5, 2) := 0;
    v_quality_score DECIMAL(5, 2);
BEGIN
    -- Device Uptime Score (35%)
    SELECT COALESCE(average_device_uptime, 0) INTO v_uptime_score
    FROM suppliers
    WHERE id = p_supplier_id;

    -- Revenue Performance Score (25%)
    -- Simplified: Compare actual vs expected based on device count
    SELECT CASE
        WHEN SUM(supplier_revenue) >= (COUNT(DISTINCT device_id) * 200) THEN 100
        WHEN SUM(supplier_revenue) >= (COUNT(DISTINCT device_id) * 150) THEN 80
        WHEN SUM(supplier_revenue) >= (COUNT(DISTINCT device_id) * 100) THEN 60
        ELSE 40
    END INTO v_revenue_score
    FROM supplier_revenue_share
    WHERE supplier_id = p_supplier_id
      AND revenue_date >= CURRENT_DATE - p_period_days;

    -- Compliance Score (20%)
    SELECT GREATEST(0, 100 - (COUNT(*) * 10)) INTO v_compliance_score
    FROM supplier_status_history
    WHERE supplier_id = p_supplier_id
      AND to_status IN ('SUSPENDED', 'PERMANENTLY_BANNED')
      AND transitioned_at >= CURRENT_DATE - 90;

    -- Customer Rating Score (10%) - Placeholder
    v_rating_score := 80; -- Default until rating system implemented

    -- Growth Score (10%)
    WITH monthly_revenue AS (
        SELECT
            DATE_TRUNC('month', revenue_date) AS month,
            SUM(supplier_revenue) AS revenue
        FROM supplier_revenue_share
        WHERE supplier_id = p_supplier_id
          AND revenue_date >= CURRENT_DATE - 60
        GROUP BY DATE_TRUNC('month', revenue_date)
        ORDER BY month DESC
        LIMIT 2
    )
    SELECT LEAST(100, GREATEST(0,
        ((revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 200)
    )) INTO v_growth_score
    FROM monthly_revenue
    LIMIT 1;

    -- Calculate weighted quality score
    v_quality_score := (
        v_uptime_score * 0.35 +
        COALESCE(v_revenue_score, 0) * 0.25 +
        COALESCE(v_compliance_score, 100) * 0.20 +
        v_rating_score * 0.10 +
        COALESCE(v_growth_score, 0) * 0.10
    );

    RETURN ROUND(v_quality_score, 2);
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate max devices for store based on square footage
CREATE OR REPLACE FUNCTION calculate_max_devices_for_store(
    p_square_footage INTEGER
)
RETURNS INTEGER AS $$
BEGIN
    RETURN CASE
        WHEN p_square_footage < 1000 THEN 1
        WHEN p_square_footage < 3000 THEN 2
        WHEN p_square_footage < 5000 THEN 3
        WHEN p_square_footage < 10000 THEN 5
        ELSE 10
    END;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate supplier can add device
CREATE OR REPLACE FUNCTION validate_supplier_device_limit()
RETURNS TRIGGER AS $$
DECLARE
    v_supplier_id UUID;
    v_tier VARCHAR(50);
    v_total_devices INTEGER;
    v_max_devices INTEGER;
BEGIN
    -- Get supplier info from store
    SELECT st.supplier_id, s.tier, s.total_devices
    INTO v_supplier_id, v_tier, v_total_devices
    FROM supplier_stores st
    JOIN suppliers s ON st.supplier_id = s.id
    WHERE st.id = NEW.store_id;

    -- Determine max devices based on tier
    v_max_devices := CASE v_tier
        WHEN 'STARTER' THEN 5
        WHEN 'PROFESSIONAL' THEN 50
        WHEN 'ENTERPRISE' THEN 999999 -- Effectively unlimited
    END;

    IF v_total_devices >= v_max_devices THEN
        RAISE EXCEPTION 'Device limit reached for tier %: % devices', v_tier, v_max_devices;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at on suppliers
CREATE TRIGGER trigger_suppliers_updated_at
    BEFORE UPDATE ON suppliers
    FOR EACH ROW
    EXECUTE FUNCTION update_supplier_updated_at();

-- Trigger: Update updated_at on supplier_stores
CREATE TRIGGER trigger_supplier_stores_updated_at
    BEFORE UPDATE ON supplier_stores
    FOR EACH ROW
    EXECUTE FUNCTION update_supplier_updated_at();

-- Trigger: Update updated_at on supplier_revenue_share
CREATE TRIGGER trigger_supplier_revenue_share_updated_at
    BEFORE UPDATE ON supplier_revenue_share
    FOR EACH ROW
    EXECUTE FUNCTION update_supplier_updated_at();

-- Trigger: Update updated_at on supplier_competitor_blocking_rules
CREATE TRIGGER trigger_blocking_rules_updated_at
    BEFORE UPDATE ON supplier_competitor_blocking_rules
    FOR EACH ROW
    EXECUTE FUNCTION update_supplier_updated_at();

-- Trigger: Log supplier status changes
CREATE OR REPLACE FUNCTION log_supplier_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO supplier_status_history (
            supplier_id,
            from_status,
            to_status,
            reason,
            changed_by
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            NEW.suspension_reason,
            NEW.updated_by
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_supplier_status_change
    AFTER UPDATE ON suppliers
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION log_supplier_status_change();

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get suppliers ready for payout
SELECT * FROM v_suppliers_pending_payout
WHERE payout_eligibility = 'ELIGIBLE'
  AND payment_schedule = 'WEEKLY'
ORDER BY available_balance DESC;

-- Get top performing suppliers by revenue (last 30 days)
SELECT
    business_name,
    tier,
    total_devices,
    revenue_last_30_days,
    lifetime_revenue,
    average_cpm
FROM v_supplier_revenue_summary
ORDER BY revenue_last_30_days DESC
LIMIT 10;

-- Get stores with low performance
SELECT * FROM v_supplier_store_performance
WHERE quality_score < 60
  OR average_device_uptime < 85
ORDER BY quality_score ASC;

-- Calculate revenue split for a supplier
SELECT
    revenue_date,
    verified_impressions,
    gross_impression_cost,
    supplier_revenue,
    platform_revenue,
    ROUND((supplier_revenue / NULLIF(gross_impression_cost, 0) * 100), 2) AS supplier_share_pct
FROM supplier_revenue_share
WHERE supplier_id = 'SUPPLIER_UUID'
  AND revenue_date >= CURRENT_DATE - 30
ORDER BY revenue_date DESC;

-- Get supplier performance trend
SELECT
    metrics_month,
    overall_quality_score,
    device_uptime_score,
    revenue_performance_score,
    compliance_score,
    total_revenue
FROM supplier_performance_metrics
WHERE supplier_id = 'SUPPLIER_UUID'
ORDER BY metrics_month DESC;

-- Find suppliers with pending verification
SELECT
    s.business_name,
    s.verification_status,
    COUNT(d.id) AS pending_documents
FROM suppliers s
LEFT JOIN supplier_verification_documents d ON s.id = d.supplier_id AND d.status = 'PENDING'
WHERE s.verification_status = 'PENDING'
GROUP BY s.id, s.business_name, s.verification_status;
*/

-- ============================================================================
-- END OF SUPPLIER SCHEMA
-- ============================================================================
