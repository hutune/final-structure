-- ============================================================================
-- RMN-Arms Database Schema: Campaign Management Module
-- ============================================================================
-- Version: 1.0
-- Last Updated: 2026-01-23
-- Description: Complete database schema for Campaign Management including
--              campaigns, targeting, metrics, content assignments, and budget tracking
-- ============================================================================

-- ============================================================================
-- TABLE: campaigns
-- Description: Main campaign entity with lifecycle, budget, and billing info
-- ============================================================================

CREATE TABLE campaigns (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE RESTRICT,

    -- Basic Information
    name VARCHAR(200) NOT NULL CHECK (LENGTH(name) >= 3),
    description TEXT,

    -- Status & Lifecycle
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

    -- Budget Information
    total_budget_amount DECIMAL(12, 2) NOT NULL CHECK (total_budget_amount >= 100.00),
    total_budget_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    allocated_budget_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    spent_budget_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    -- Daily Budget Cap
    daily_cap_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    daily_cap_amount DECIMAL(12, 2),
    daily_spent_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    daily_spent_reset_at TIMESTAMPTZ,

    -- Billing Model (CPM only for now)
    billing_model VARCHAR(20) NOT NULL DEFAULT 'CPM' CHECK (billing_model = 'CPM'),
    cpm_rate_amount DECIMAL(10, 4) NOT NULL CHECK (cpm_rate_amount >= 0.10 AND cpm_rate_amount <= 50.00),
    cpm_rate_currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Rejection/Pause Information
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
COMMENT ON TABLE campaigns IS 'Main campaign table tracking full lifecycle and budget';
COMMENT ON COLUMN campaigns.status IS 'Current lifecycle status of campaign';
COMMENT ON COLUMN campaigns.total_budget_amount IS 'Total campaign budget - minimum $100';
COMMENT ON COLUMN campaigns.allocated_budget_amount IS 'Amount held from advertiser wallet';
COMMENT ON COLUMN campaigns.spent_budget_amount IS 'Amount actually spent on impressions';
COMMENT ON COLUMN campaigns.cpm_rate_amount IS 'Cost per 1000 impressions - range $0.10-$50.00';

-- ============================================================================
-- TABLE: campaign_targeting
-- Description: Targeting criteria for campaign ad serving
-- ============================================================================

CREATE TABLE campaign_targeting (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

    -- Geographic Targeting
    countries TEXT[], -- ISO 3166-1 alpha-2 codes
    states TEXT[],
    cities TEXT[],
    postal_codes TEXT[],

    -- Demographic Targeting
    age_groups VARCHAR(20)[], -- ['18-24', '25-34', '35-44', '45-54', '55-64', '65+']
    genders VARCHAR(20)[], -- ['MALE', 'FEMALE', 'OTHER', 'ALL']
    languages TEXT[], -- ISO 639-1 codes

    -- Behavioral Targeting
    interests TEXT[],
    purchase_categories TEXT[],

    -- Contextual Targeting
    content_categories TEXT[],
    keywords TEXT[],

    -- Device Targeting
    device_types VARCHAR(50)[], -- ['TABLET', 'TV', 'KIOSK', 'DIGITAL_SIGNAGE']
    os_types VARCHAR(50)[], -- ['ANDROID', 'IOS', 'LINUX', 'WINDOWS']
    min_screen_size_inches DECIMAL(4, 1),

    -- Time Targeting (Day Parting)
    days_of_week INTEGER[], -- [1-7] where 1=Monday
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
COMMENT ON TABLE campaign_targeting IS 'Targeting rules for campaign ad serving';
COMMENT ON COLUMN campaign_targeting.time_windows IS 'JSON array of time windows for day parting';

-- ============================================================================
-- TABLE: campaign_competitor_blocking
-- Description: Competitor blocking rules for campaigns
-- ============================================================================

CREATE TABLE campaign_competitor_blocking (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

    -- Blocking Configuration
    enabled BOOLEAN NOT NULL DEFAULT FALSE,
    block_level VARCHAR(20) NOT NULL DEFAULT 'MODERATE' CHECK (block_level IN ('STRICT', 'MODERATE', 'RELAXED')),

    -- Blocked Entities
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
COMMENT ON TABLE campaign_competitor_blocking IS 'Competitor blocking configuration per campaign';

-- ============================================================================
-- TABLE: campaign_content_assignments
-- Description: Assignment of content assets to campaigns
-- ============================================================================

CREATE TABLE campaign_content_assignments (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    content_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE RESTRICT,

    -- Assignment Details
    priority INTEGER NOT NULL DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
    rotation_weight INTEGER NOT NULL DEFAULT 100 CHECK (rotation_weight BETWEEN 1 AND 100),

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAUSED', 'EXPIRED')),

    -- Scheduling
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,

    -- Performance Tracking
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
COMMENT ON TABLE campaign_content_assignments IS 'Maps content assets to campaigns with scheduling and rotation';
COMMENT ON COLUMN campaign_content_assignments.priority IS 'Display priority 1-10 (10 is highest)';
COMMENT ON COLUMN campaign_content_assignments.rotation_weight IS 'Percentage weight for rotation (1-100)';

-- ============================================================================
-- TABLE: campaign_metrics
-- Description: Performance metrics for campaigns
-- ============================================================================

CREATE TABLE campaign_metrics (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

    -- Date for metrics (for daily rollup)
    metrics_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Impression Metrics
    total_impressions BIGINT NOT NULL DEFAULT 0,
    verified_impressions BIGINT NOT NULL DEFAULT 0,
    fraudulent_impressions BIGINT NOT NULL DEFAULT 0,
    low_quality_impressions BIGINT NOT NULL DEFAULT 0,

    -- Engagement Metrics
    clicks BIGINT NOT NULL DEFAULT 0,
    ctr DECIMAL(5, 4) DEFAULT 0.0000, -- Click-through rate

    -- Financial Metrics
    total_spent_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_spent_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    average_cpm_amount DECIMAL(10, 4) DEFAULT 0.0000,
    cost_per_click_amount DECIMAL(10, 4) DEFAULT 0.0000,

    -- Quality Metrics
    average_quality_score DECIMAL(5, 2) CHECK (average_quality_score IS NULL OR average_quality_score BETWEEN 0 AND 100),
    completion_rate DECIMAL(5, 4) CHECK (completion_rate IS NULL OR completion_rate BETWEEN 0 AND 1),

    -- Timing
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
COMMENT ON TABLE campaign_metrics IS 'Daily aggregated performance metrics per campaign';
COMMENT ON COLUMN campaign_metrics.ctr IS 'Click-through rate (clicks / impressions)';
COMMENT ON COLUMN campaign_metrics.average_cpm_amount IS 'Average cost per 1000 impressions';

-- ============================================================================
-- TABLE: campaign_budget_history
-- Description: Audit trail for budget changes
-- ============================================================================

CREATE TABLE campaign_budget_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    wallet_transaction_id UUID REFERENCES wallet_transactions(id),

    -- Event Type
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'ALLOCATED', 'SPENT', 'RELEASED', 'REFUNDED'
    )),

    -- Amount
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Balance After Transaction
    allocated_balance_after DECIMAL(12, 2),
    spent_balance_after DECIMAL(12, 2),

    -- Reference
    reference_type VARCHAR(50), -- 'IMPRESSION', 'REFUND', 'CAMPAIGN_END'
    reference_id UUID,

    -- Notes
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
COMMENT ON TABLE campaign_budget_history IS 'Complete audit trail of all budget transactions';
COMMENT ON COLUMN campaign_budget_history.event_type IS 'Type of budget event (ALLOCATED, SPENT, RELEASED, REFUNDED)';

-- ============================================================================
-- TABLE: campaign_status_history
-- Description: Track campaign status transitions
-- ============================================================================

CREATE TABLE campaign_status_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,

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

-- Indexes
CREATE INDEX idx_status_history_campaign_id ON campaign_status_history(campaign_id);
CREATE INDEX idx_status_history_transitioned_at ON campaign_status_history(transitioned_at DESC);
CREATE INDEX idx_status_history_to_status ON campaign_status_history(to_status);

-- Comments
COMMENT ON TABLE campaign_status_history IS 'Audit trail of campaign status changes';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Active Campaigns with Current Metrics
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

-- View: Campaign Budget Status
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
COMMENT ON VIEW v_active_campaigns IS 'Active campaigns with aggregated performance metrics';
COMMENT ON VIEW v_campaign_budget_status IS 'Campaign budget status with thresholds';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update campaign updated_at timestamp
CREATE OR REPLACE FUNCTION update_campaign_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Reset daily spend at midnight
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

-- Function: Validate budget constraints
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

-- Trigger: Update updated_at on campaigns
CREATE TRIGGER trigger_campaigns_updated_at
    BEFORE UPDATE ON campaigns
    FOR EACH ROW
    EXECUTE FUNCTION update_campaign_updated_at();

-- Trigger: Reset daily spend
CREATE TRIGGER trigger_reset_daily_spend
    BEFORE UPDATE ON campaigns
    FOR EACH ROW
    WHEN (OLD.daily_spent_amount IS DISTINCT FROM NEW.daily_spent_amount)
    EXECUTE FUNCTION reset_campaign_daily_spend();

-- Trigger: Validate budget constraints
CREATE TRIGGER trigger_validate_campaign_budget
    BEFORE INSERT OR UPDATE ON campaigns
    FOR EACH ROW
    EXECUTE FUNCTION validate_campaign_budget();

-- Trigger: Update updated_at on campaign_targeting
CREATE TRIGGER trigger_campaign_targeting_updated_at
    BEFORE UPDATE ON campaign_targeting
    FOR EACH ROW
    EXECUTE FUNCTION update_campaign_updated_at();

-- Trigger: Update updated_at on campaign_content_assignments
CREATE TRIGGER trigger_campaign_content_assignments_updated_at
    BEFORE UPDATE ON campaign_content_assignments
    FOR EACH ROW
    EXECUTE FUNCTION update_campaign_updated_at();

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get active campaigns with budget near exhaustion
SELECT * FROM v_campaign_budget_status
WHERE status = 'ACTIVE'
  AND budget_status IN ('LOW', 'CRITICAL')
ORDER BY spend_rate DESC;

-- Get campaign performance for advertiser
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

-- Get campaigns that should be activated (scheduled and start date reached)
SELECT * FROM campaigns
WHERE status = 'SCHEDULED'
  AND start_date <= CURRENT_TIMESTAMP
  AND (end_date IS NULL OR end_date > CURRENT_TIMESTAMP);

-- Get budget allocation history for campaign
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
-- END OF CAMPAIGN SCHEMA
-- ============================================================================
