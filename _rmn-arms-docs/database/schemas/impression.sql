-- ============================================================================
-- RMN-Arms Database Schema: Impression Recording Module
-- ============================================================================
-- Version: 1.0
-- Last Updated: 2026-01-23
-- Description: Complete database schema for Impression Recording including
--              impression tracking, proof-of-play verification, quality scoring,
--              fraud detection, and dispute resolution
-- Notes: HIGH VOLUME - Optimized for millions of impressions per day
-- ============================================================================

-- ============================================================================
-- TABLE: impressions
-- Description: Main impression tracking table with verification and quality metrics
-- Volume: HIGH - Millions of rows per day
-- ============================================================================

CREATE TABLE impressions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE RESTRICT,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE RESTRICT,
    content_asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE RESTRICT,
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE RESTRICT,

    -- Verification Status
    verification_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (verification_status IN (
        'PENDING', 'VERIFIED', 'REJECTED', 'UNDER_REVIEW', 'DISPUTED'
    )),
    verification_method VARCHAR(20) NOT NULL DEFAULT 'AUTOMATIC' CHECK (verification_method IN (
        'AUTOMATIC', 'MANUAL', 'HYBRID'
    )),
    verification_timestamp TIMESTAMPTZ,
    verification_notes TEXT,
    rejected_reason VARCHAR(200),

    -- Playback Information
    played_at TIMESTAMPTZ NOT NULL,
    duration_expected INTEGER NOT NULL CHECK (duration_expected > 0), -- seconds
    duration_actual INTEGER NOT NULL CHECK (duration_actual > 0), -- seconds
    completion_rate DECIMAL(5, 2) NOT NULL CHECK (completion_rate BETWEEN 0 AND 100), -- percentage

    -- Financial
    cost_amount DECIMAL(10, 4) NOT NULL CHECK (cost_amount >= 0),
    cost_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    cpm_rate_amount DECIMAL(10, 4) NOT NULL CHECK (cpm_rate_amount >= 0),
    cpm_rate_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    supplier_revenue_amount DECIMAL(10, 4) NOT NULL DEFAULT 0,
    supplier_revenue_currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Quality & Fraud Metrics
    quality_score INTEGER NOT NULL DEFAULT 0 CHECK (quality_score BETWEEN 0 AND 100),
    fraud_score INTEGER NOT NULL DEFAULT 0 CHECK (fraud_score BETWEEN 0 AND 100),
    fraud_flags JSONB DEFAULT '[]'::jsonb,

    -- Proof-of-Play: Screenshot
    proof_screenshot_url VARCHAR(500), -- S3 URL (temporary, 30 days)
    proof_screenshot_hash VARCHAR(64) NOT NULL, -- SHA256 hash
    proof_screenshot_captured_at INTEGER, -- milliseconds into playback

    -- Proof-of-Play: Device Signature
    proof_device_signature TEXT NOT NULL, -- RSA signature (base64)
    proof_signature_payload JSONB NOT NULL, -- Data that was signed

    -- Proof-of-Play: Location
    proof_gps_lat DECIMAL(10, 8), -- GPS latitude
    proof_gps_lng DECIMAL(11, 8), -- GPS longitude
    proof_gps_accuracy INTEGER, -- meters
    distance_from_store INTEGER, -- meters from registered store location

    -- Proof-of-Play: Timing
    time_drift_seconds INTEGER NOT NULL DEFAULT 0, -- device time - server time
    device_timestamp TIMESTAMPTZ NOT NULL, -- device local time
    server_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, -- server receive time

    -- Viewability & Environment
    viewability_score INTEGER CHECK (viewability_score IS NULL OR viewability_score BETWEEN 0 AND 100),
    attention_score INTEGER CHECK (attention_score IS NULL OR attention_score BETWEEN 0 AND 100),
    audio_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    screen_brightness INTEGER CHECK (screen_brightness IS NULL OR screen_brightness BETWEEN 0 AND 100),
    environment_brightness INTEGER, -- lux
    device_orientation_correct BOOLEAN DEFAULT TRUE,

    -- Network Quality
    network_quality VARCHAR(20) CHECK (network_quality IN ('EXCELLENT', 'GOOD', 'FAIR', 'POOR')),
    network_outage_backfill BOOLEAN NOT NULL DEFAULT FALSE, -- submitted after network restored

    -- Dispute Information
    dispute_id UUID REFERENCES impression_disputes(id),
    chargeback_at TIMESTAMPTZ,
    chargeback_reason VARCHAR(200),
    chargeback_amount DECIMAL(10, 4),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT impressions_duration_check CHECK (
        duration_actual >= (duration_expected * 0.80) AND
        duration_actual <= (duration_expected * 1.50)
    ),
    CONSTRAINT impressions_gps_check CHECK (
        (proof_gps_lat IS NULL AND proof_gps_lng IS NULL) OR
        (proof_gps_lat IS NOT NULL AND proof_gps_lng IS NOT NULL)
    ),
    CONSTRAINT impressions_gps_range_check CHECK (
        proof_gps_lat IS NULL OR (proof_gps_lat >= -90 AND proof_gps_lat <= 90)
    ) AND CHECK (
        proof_gps_lng IS NULL OR (proof_gps_lng >= -180 AND proof_gps_lng <= 180)
    ),
    CONSTRAINT impressions_chargeback_check CHECK (
        (chargeback_at IS NULL AND chargeback_reason IS NULL) OR
        (chargeback_at IS NOT NULL AND chargeback_reason IS NOT NULL)
    )
);

-- Indexes for HIGH VOLUME table - Optimized for query patterns
CREATE INDEX idx_impressions_campaign_id ON impressions(campaign_id);
CREATE INDEX idx_impressions_device_id ON impressions(device_id);
CREATE INDEX idx_impressions_store_id ON impressions(store_id);
CREATE INDEX idx_impressions_content_asset_id ON impressions(content_asset_id);
CREATE INDEX idx_impressions_verification_status ON impressions(verification_status);
CREATE INDEX idx_impressions_played_at ON impressions(played_at DESC);
CREATE INDEX idx_impressions_created_at ON impressions(created_at DESC);

-- Composite indexes for common query patterns
CREATE INDEX idx_impressions_campaign_played_at ON impressions(campaign_id, played_at DESC);
CREATE INDEX idx_impressions_device_played_at ON impressions(device_id, played_at DESC);
CREATE INDEX idx_impressions_status_played_at ON impressions(verification_status, played_at DESC);
CREATE INDEX idx_impressions_campaign_status ON impressions(campaign_id, verification_status);

-- Partial indexes for specific queries (reduces index size)
CREATE INDEX idx_impressions_disputed ON impressions(dispute_id) WHERE dispute_id IS NOT NULL;
CREATE INDEX idx_impressions_under_review ON impressions(created_at) WHERE verification_status = 'UNDER_REVIEW';
CREATE INDEX idx_impressions_high_fraud ON impressions(fraud_score, device_id) WHERE fraud_score >= 50;
CREATE INDEX idx_impressions_low_quality ON impressions(quality_score, device_id) WHERE quality_score < 50;

-- GIN index for fraud flags JSON queries
CREATE INDEX idx_impressions_fraud_flags ON impressions USING GIN(fraud_flags);

-- Duplicate detection index (5-minute window)
CREATE INDEX idx_impressions_dedup ON impressions(campaign_id, device_id, played_at);

-- Comments
COMMENT ON TABLE impressions IS 'Main impression table tracking all ad playbacks with verification and quality metrics (HIGH VOLUME)';
COMMENT ON COLUMN impressions.verification_status IS 'Current verification status: PENDING/VERIFIED/REJECTED/UNDER_REVIEW/DISPUTED';
COMMENT ON COLUMN impressions.quality_score IS '0-100 quality metric: 90-100=PREMIUM, 70-89=STANDARD, 50-69=BASIC, 0-49=POOR';
COMMENT ON COLUMN impressions.fraud_score IS '0-100 fraud likelihood: 0-30=clean, 30-50=suspicious, 50-80=very suspicious, 80+=likely fraud';
COMMENT ON COLUMN impressions.proof_screenshot_hash IS 'SHA256 hash of screenshot (always required)';
COMMENT ON COLUMN impressions.proof_screenshot_url IS 'S3 URL to screenshot (uploaded selectively: 5% random + flagged), expires after 30 days';
COMMENT ON COLUMN impressions.time_drift_seconds IS 'Device clock drift from server time (positive=device ahead, negative=device behind)';
COMMENT ON COLUMN impressions.distance_from_store IS 'Distance in meters from registered store location (calculated from GPS)';
COMMENT ON COLUMN impressions.network_outage_backfill IS 'True if impression submitted after network outage (within 4 hour window)';

-- ============================================================================
-- TABLE: impression_verification_logs
-- Description: Detailed audit log of verification process for each impression
-- Volume: VERY HIGH - Multiple logs per impression
-- ============================================================================

CREATE TABLE impression_verification_logs (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    impression_id UUID NOT NULL REFERENCES impressions(id) ON DELETE CASCADE,

    -- Verification Step Details
    step VARCHAR(50) NOT NULL, -- e.g., SIGNATURE_VERIFICATION, TIMESTAMP_VALIDATION
    status VARCHAR(20) NOT NULL CHECK (status IN ('PASS', 'FAIL', 'SKIP', 'WARN')),
    check_type VARCHAR(50) NOT NULL CHECK (check_type IN (
        'SIGNATURE', 'TIMESTAMP', 'DURATION', 'LOCATION', 'DUPLICATE',
        'CAMPAIGN', 'DEVICE', 'QUALITY', 'FRAUD', 'OTHER'
    )),
    severity VARCHAR(20) NOT NULL DEFAULT 'INFO' CHECK (severity IN (
        'INFO', 'WARNING', 'ERROR', 'CRITICAL'
    )),

    -- Check Results
    expected_value TEXT,
    actual_value TEXT,
    result_message TEXT NOT NULL,
    processing_time_ms INTEGER NOT NULL CHECK (processing_time_ms >= 0),

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_verification_logs_impression_id ON impression_verification_logs(impression_id);
CREATE INDEX idx_verification_logs_created_at ON impression_verification_logs(created_at DESC);
CREATE INDEX idx_verification_logs_status ON impression_verification_logs(status) WHERE status IN ('FAIL', 'WARN');
CREATE INDEX idx_verification_logs_check_type ON impression_verification_logs(check_type);

-- Comments
COMMENT ON TABLE impression_verification_logs IS 'Detailed audit log of each verification step for impressions (VERY HIGH VOLUME)';
COMMENT ON COLUMN impression_verification_logs.processing_time_ms IS 'Time in milliseconds to complete this verification check';
COMMENT ON COLUMN impression_verification_logs.severity IS 'Severity level: INFO=normal, WARNING=attention needed, ERROR=failed check, CRITICAL=security issue';

-- ============================================================================
-- TABLE: impression_quality_metrics
-- Description: Detailed quality metrics breakdown for each impression
-- Volume: HIGH - One record per impression
-- ============================================================================

CREATE TABLE impression_quality_metrics (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    impression_id UUID NOT NULL REFERENCES impressions(id) ON DELETE CASCADE UNIQUE,

    -- Component Quality Scores (0-100 each)
    technical_quality INTEGER NOT NULL CHECK (technical_quality BETWEEN 0 AND 100),
    proof_quality INTEGER NOT NULL CHECK (proof_quality BETWEEN 0 AND 100),
    viewability_quality INTEGER NOT NULL CHECK (viewability_quality BETWEEN 0 AND 100),
    location_quality INTEGER NOT NULL CHECK (location_quality BETWEEN 0 AND 100),
    timing_quality INTEGER NOT NULL CHECK (timing_quality BETWEEN 0 AND 100),

    -- Detailed Metrics
    viewability_score INTEGER CHECK (viewability_score BETWEEN 0 AND 100),
    completion_rate DECIMAL(5, 2) CHECK (completion_rate BETWEEN 0 AND 100),
    attention_score INTEGER CHECK (attention_score BETWEEN 0 AND 100),
    audio_enabled BOOLEAN NOT NULL,
    screen_brightness INTEGER CHECK (screen_brightness BETWEEN 0 AND 100),
    environment_brightness INTEGER, -- lux
    device_orientation_correct BOOLEAN NOT NULL,

    -- Network & Performance
    network_quality VARCHAR(20) CHECK (network_quality IN ('EXCELLENT', 'GOOD', 'FAIR', 'POOR')),
    playback_smoothness INTEGER CHECK (playback_smoothness IS NULL OR playback_smoothness BETWEEN 0 AND 100),

    -- Accuracy Metrics
    timestamp_accuracy INTEGER NOT NULL, -- time drift in seconds
    location_accuracy INTEGER, -- GPS accuracy in meters
    proof_quality_score INTEGER NOT NULL CHECK (proof_quality_score BETWEEN 0 AND 100),

    -- Overall Assessment
    overall_quality_score INTEGER NOT NULL CHECK (overall_quality_score BETWEEN 0 AND 100),
    quality_tier VARCHAR(20) NOT NULL CHECK (quality_tier IN ('PREMIUM', 'STANDARD', 'BASIC', 'POOR')),

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_quality_metrics_impression_id ON impression_quality_metrics(impression_id);
CREATE INDEX idx_quality_metrics_quality_tier ON impression_quality_metrics(quality_tier);
CREATE INDEX idx_quality_metrics_overall_score ON impression_quality_metrics(overall_quality_score);

-- Comments
COMMENT ON TABLE impression_quality_metrics IS 'Detailed quality metrics breakdown for each impression';
COMMENT ON COLUMN impression_quality_metrics.technical_quality IS 'Technical quality component (30% weight): duration, timing, network, device health';
COMMENT ON COLUMN impression_quality_metrics.proof_quality IS 'Proof quality component (25% weight): screenshot, signature, GPS availability';
COMMENT ON COLUMN impression_quality_metrics.viewability_quality IS 'Viewability component (20% weight): brightness, audio, orientation';
COMMENT ON COLUMN impression_quality_metrics.location_quality IS 'Location component (15% weight): GPS proximity to store';
COMMENT ON COLUMN impression_quality_metrics.timing_quality IS 'Timing component (10% weight): peak hours, operating hours, weekend';
COMMENT ON COLUMN impression_quality_metrics.quality_tier IS 'PREMIUM: 90-100, STANDARD: 70-89, BASIC: 50-69, POOR: 0-49';

-- ============================================================================
-- TABLE: impression_disputes
-- Description: Advertiser challenges to impression validity
-- Volume: LOW - Target <1% of verified impressions
-- ============================================================================

CREATE TABLE impression_disputes (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    impression_id UUID NOT NULL REFERENCES impressions(id) ON DELETE RESTRICT,
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE RESTRICT,
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE RESTRICT,
    assigned_to UUID REFERENCES users(id), -- Admin investigating

    -- Dispute Details
    dispute_type VARCHAR(50) NOT NULL CHECK (dispute_type IN (
        'INVALID_PROOF', 'DEVICE_OFFLINE', 'WRONG_LOCATION', 'DUPLICATE',
        'CONTENT_MISMATCH', 'TIME_MANIPULATION', 'QUALITY_ISSUE', 'OTHER'
    )),
    reason TEXT NOT NULL,
    evidence JSONB, -- Array of evidence objects with URLs and descriptions

    -- Status & Priority
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'INVESTIGATING', 'RESOLVED', 'REJECTED'
    )),
    priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL' CHECK (priority IN (
        'LOW', 'NORMAL', 'HIGH', 'URGENT'
    )),

    -- Investigation
    investigation_notes TEXT,
    resolution VARCHAR(50) CHECK (resolution IN (
        'CHARGEBACK_APPROVED', 'CHARGEBACK_DENIED', 'PARTIAL_REFUND'
    )),

    -- Financial Impact
    refund_amount DECIMAL(10, 4) CHECK (refund_amount IS NULL OR refund_amount >= 0),
    refund_currency VARCHAR(3) DEFAULT 'USD',
    supplier_penalty DECIMAL(10, 4) CHECK (supplier_penalty IS NULL OR supplier_penalty >= 0),
    supplier_penalty_currency VARCHAR(3) DEFAULT 'USD',

    -- Timestamps
    filed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_at TIMESTAMPTZ,
    investigating_since TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    resolution_time_hours INTEGER, -- computed: (resolved_at - filed_at) in hours

    -- Constraints
    CONSTRAINT disputes_resolution_check CHECK (
        (status = 'RESOLVED' AND resolution IS NOT NULL AND resolved_at IS NOT NULL) OR
        (status != 'RESOLVED' AND resolution IS NULL)
    ),
    CONSTRAINT disputes_refund_check CHECK (
        (resolution = 'CHARGEBACK_APPROVED' AND refund_amount > 0) OR
        (resolution = 'PARTIAL_REFUND' AND refund_amount > 0) OR
        (resolution = 'CHARGEBACK_DENIED' AND refund_amount IS NULL) OR
        (resolution IS NULL)
    )
);

-- Indexes
CREATE INDEX idx_disputes_impression_id ON impression_disputes(impression_id);
CREATE INDEX idx_disputes_campaign_id ON impression_disputes(campaign_id);
CREATE INDEX idx_disputes_advertiser_id ON impression_disputes(advertiser_id);
CREATE INDEX idx_disputes_status ON impression_disputes(status);
CREATE INDEX idx_disputes_assigned_to ON impression_disputes(assigned_to) WHERE assigned_to IS NOT NULL;
CREATE INDEX idx_disputes_filed_at ON impression_disputes(filed_at DESC);
CREATE INDEX idx_disputes_pending ON impression_disputes(priority, filed_at) WHERE status = 'PENDING';
CREATE INDEX idx_disputes_unresolved ON impression_disputes(filed_at) WHERE status IN ('PENDING', 'INVESTIGATING');

-- Comments
COMMENT ON TABLE impression_disputes IS 'Advertiser challenges to impression validity with investigation and resolution tracking';
COMMENT ON COLUMN impression_disputes.dispute_type IS 'Type of dispute: INVALID_PROOF, DEVICE_OFFLINE, WRONG_LOCATION, DUPLICATE, CONTENT_MISMATCH, TIME_MANIPULATION, QUALITY_ISSUE, OTHER';
COMMENT ON COLUMN impression_disputes.evidence IS 'JSONB array of evidence: [{type: "screenshot_comparison", url: "..."}, {type: "description", text: "..."}]';
COMMENT ON COLUMN impression_disputes.resolution IS 'Resolution outcome: CHARGEBACK_APPROVED (full refund), PARTIAL_REFUND (50%), CHARGEBACK_DENIED (no refund)';
COMMENT ON COLUMN impression_disputes.resolution_time_hours IS 'Time from filing to resolution in hours (SLA: 72 hours)';

-- ============================================================================
-- TABLE: fraud_detection_rules
-- Description: Configurable fraud detection rules
-- Volume: LOW - Tens of rules
-- ============================================================================

CREATE TABLE fraud_detection_rules (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Rule Definition
    rule_name VARCHAR(100) NOT NULL UNIQUE,
    rule_type VARCHAR(30) NOT NULL CHECK (rule_type IN (
        'FREQUENCY', 'LOCATION', 'TIMING', 'PATTERN', 'SIGNATURE', 'CONTENT', 'REPUTATION'
    )),
    description TEXT NOT NULL,

    -- Severity & Action
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    threshold_value DECIMAL(10, 2) NOT NULL,
    time_window_minutes INTEGER, -- Rolling time window (if applicable)
    action_on_trigger VARCHAR(20) NOT NULL CHECK (action_on_trigger IN (
        'LOG', 'FLAG', 'HOLD', 'REJECT', 'SUSPEND'
    )),

    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Performance Metrics
    triggered_count BIGINT NOT NULL DEFAULT 0,
    last_triggered_at TIMESTAMPTZ,
    false_positive_rate DECIMAL(5, 2) CHECK (false_positive_rate IS NULL OR false_positive_rate BETWEEN 0 AND 100),
    true_positive_rate DECIMAL(5, 2) CHECK (true_positive_rate IS NULL OR true_positive_rate BETWEEN 0 AND 100),

    -- Audit
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_fraud_rules_rule_type ON fraud_detection_rules(rule_type);
CREATE INDEX idx_fraud_rules_active ON fraud_detection_rules(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_fraud_rules_severity ON fraud_detection_rules(severity);

-- Comments
COMMENT ON TABLE fraud_detection_rules IS 'Configurable fraud detection rules with performance tracking';
COMMENT ON COLUMN fraud_detection_rules.action_on_trigger IS 'Action when rule triggers: LOG (record only), FLAG (mark suspicious), HOLD (manual review), REJECT (auto-reject), SUSPEND (suspend device)';
COMMENT ON COLUMN fraud_detection_rules.false_positive_rate IS 'Percentage of flagged impressions that were actually legitimate (lower is better)';
COMMENT ON COLUMN fraud_detection_rules.true_positive_rate IS 'Percentage of fraudulent impressions successfully detected (higher is better)';

-- ============================================================================
-- TABLE: device_reputation_history
-- Description: Track device reputation changes over time
-- Volume: MEDIUM - One record per reputation change event
-- ============================================================================

CREATE TABLE device_reputation_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    impression_id UUID REFERENCES impressions(id) ON DELETE SET NULL,

    -- Reputation Change
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'INITIAL', 'VERIFIED_IMPRESSION', 'FLAGGED_IMPRESSION', 'HELD_IMPRESSION',
        'REJECTED_IMPRESSION', 'DISPUTED_IMPRESSION', 'CHARGEBACK', 'SUSPENDED',
        'CLEAN_WEEK_BONUS', 'QUALITY_BONUS', 'UPTIME_BONUS', 'MANUAL_ADJUSTMENT'
    )),
    reputation_before INTEGER NOT NULL CHECK (reputation_before BETWEEN 0 AND 100),
    reputation_after INTEGER NOT NULL CHECK (reputation_after BETWEEN 0 AND 100),
    reputation_delta INTEGER NOT NULL, -- Can be positive or negative

    -- Context
    reason VARCHAR(200),
    notes TEXT,

    -- Timestamp
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_reputation_history_device_id ON device_reputation_history(device_id, occurred_at DESC);
CREATE INDEX idx_reputation_history_event_type ON device_reputation_history(event_type);
CREATE INDEX idx_reputation_history_occurred_at ON device_reputation_history(occurred_at DESC);

-- Comments
COMMENT ON TABLE device_reputation_history IS 'Complete audit trail of device reputation score changes';
COMMENT ON COLUMN device_reputation_history.reputation_delta IS 'Change in reputation: positive for improvements, negative for penalties';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Impressions requiring manual review
CREATE OR REPLACE VIEW v_impressions_pending_review AS
SELECT
    i.id,
    i.impression_id,
    i.campaign_id,
    c.name AS campaign_name,
    i.device_id,
    d.device_name,
    i.played_at,
    i.quality_score,
    i.fraud_score,
    i.fraud_flags,
    i.verification_status,
    i.created_at,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - i.created_at)) / 3600 AS hours_waiting
FROM impressions i
JOIN campaigns c ON i.campaign_id = c.id
JOIN devices d ON i.device_id = d.id
WHERE i.verification_status = 'UNDER_REVIEW'
ORDER BY i.created_at ASC;

-- View: Daily impression metrics by campaign
CREATE OR REPLACE VIEW v_daily_impression_metrics AS
SELECT
    campaign_id,
    DATE(played_at) AS metrics_date,
    COUNT(*) AS total_impressions,
    COUNT(*) FILTER (WHERE verification_status = 'VERIFIED') AS verified_impressions,
    COUNT(*) FILTER (WHERE verification_status = 'REJECTED') AS rejected_impressions,
    COUNT(*) FILTER (WHERE verification_status = 'UNDER_REVIEW') AS under_review_impressions,
    COUNT(*) FILTER (WHERE verification_status = 'DISPUTED') AS disputed_impressions,
    COUNT(*) FILTER (WHERE fraud_score >= 50) AS flagged_impressions,
    AVG(quality_score) AS avg_quality_score,
    AVG(fraud_score) AS avg_fraud_score,
    SUM(cost_amount) FILTER (WHERE verification_status = 'VERIFIED') AS total_cost,
    MIN(quality_score) AS min_quality_score,
    MAX(quality_score) AS max_quality_score,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY quality_score) AS median_quality_score
FROM impressions
GROUP BY campaign_id, DATE(played_at);

-- View: Device performance metrics
CREATE OR REPLACE VIEW v_device_impression_metrics AS
SELECT
    device_id,
    COUNT(*) AS total_impressions,
    COUNT(*) FILTER (WHERE verification_status = 'VERIFIED') AS verified_impressions,
    COUNT(*) FILTER (WHERE verification_status = 'REJECTED') AS rejected_impressions,
    ROUND((COUNT(*) FILTER (WHERE verification_status = 'VERIFIED')::DECIMAL / NULLIF(COUNT(*), 0) * 100), 2) AS verification_rate,
    COUNT(*) FILTER (WHERE fraud_score >= 50) AS flagged_impressions,
    COUNT(*) FILTER (WHERE quality_score >= 90) AS premium_impressions,
    COUNT(*) FILTER (WHERE quality_score < 50) AS poor_impressions,
    AVG(quality_score) AS avg_quality_score,
    AVG(fraud_score) AS avg_fraud_score,
    COUNT(DISTINCT dispute_id) FILTER (WHERE dispute_id IS NOT NULL) AS total_disputes,
    COUNT(*) FILTER (WHERE chargeback_at IS NOT NULL) AS total_chargebacks,
    ROUND((COUNT(*) FILTER (WHERE chargeback_at IS NOT NULL)::DECIMAL / NULLIF(COUNT(*) FILTER (WHERE verification_status = 'VERIFIED'), 0) * 100), 4) AS chargeback_rate
FROM impressions
GROUP BY device_id;

-- View: Unresolved disputes with SLA status
CREATE OR REPLACE VIEW v_unresolved_disputes AS
SELECT
    d.id,
    d.impression_id,
    d.campaign_id,
    c.name AS campaign_name,
    d.advertiser_id,
    a.business_name AS advertiser_name,
    d.dispute_type,
    d.status,
    d.priority,
    d.assigned_to,
    d.filed_at,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - d.filed_at)) / 3600 AS hours_open,
    CASE
        WHEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - d.filed_at)) / 3600 > 72 THEN 'SLA_BREACH'
        WHEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - d.filed_at)) / 3600 > 48 THEN 'SLA_WARNING'
        ELSE 'ON_TRACK'
    END AS sla_status
FROM impression_disputes d
JOIN campaigns c ON d.campaign_id = c.id
JOIN advertisers a ON d.advertiser_id = a.id
WHERE d.status IN ('PENDING', 'INVESTIGATING')
ORDER BY d.priority DESC, d.filed_at ASC;

-- View: Fraud detection rule performance
CREATE OR REPLACE VIEW v_fraud_rule_performance AS
SELECT
    rule_name,
    rule_type,
    severity,
    is_active,
    triggered_count,
    last_triggered_at,
    false_positive_rate,
    true_positive_rate,
    CASE
        WHEN false_positive_rate IS NOT NULL AND true_positive_rate IS NOT NULL THEN
            ROUND((true_positive_rate - false_positive_rate) / NULLIF((true_positive_rate + false_positive_rate), 0) * 100, 2)
        ELSE NULL
    END AS effectiveness_score
FROM fraud_detection_rules
WHERE is_active = TRUE
ORDER BY triggered_count DESC;

-- Comments on views
COMMENT ON VIEW v_impressions_pending_review IS 'Impressions awaiting manual review with wait time';
COMMENT ON VIEW v_daily_impression_metrics IS 'Daily aggregated impression metrics per campaign';
COMMENT ON VIEW v_device_impression_metrics IS 'Device performance metrics including verification rate and chargeback rate';
COMMENT ON VIEW v_unresolved_disputes IS 'Active disputes with SLA tracking (target: 72 hours)';
COMMENT ON VIEW v_fraud_rule_performance IS 'Fraud detection rule effectiveness metrics';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_impression_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate completion rate
CREATE OR REPLACE FUNCTION calculate_completion_rate()
RETURNS TRIGGER AS $$
BEGIN
    NEW.completion_rate = ROUND((NEW.duration_actual::DECIMAL / NULLIF(NEW.duration_expected, 0)) * 100, 2);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate time drift
CREATE OR REPLACE FUNCTION calculate_time_drift()
RETURNS TRIGGER AS $$
BEGIN
    NEW.time_drift_seconds = EXTRACT(EPOCH FROM (NEW.device_timestamp - NEW.server_timestamp))::INTEGER;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate impression timestamp
CREATE OR REPLACE FUNCTION validate_impression_timestamp()
RETURNS TRIGGER AS $$
DECLARE
    time_diff_seconds INTEGER;
BEGIN
    -- Calculate time difference between device and server
    time_diff_seconds := ABS(EXTRACT(EPOCH FROM (NEW.device_timestamp - NEW.server_timestamp))::INTEGER);

    -- Reject if time difference > 30 minutes (1800 seconds)
    IF time_diff_seconds > 1800 THEN
        RAISE EXCEPTION 'Device clock drift exceeds maximum (30 minutes): % seconds', time_diff_seconds;
    END IF;

    -- Reject if played_at is in the future (> 5 minutes ahead)
    IF NEW.played_at > CURRENT_TIMESTAMP + INTERVAL '5 minutes' THEN
        RAISE EXCEPTION 'Impression timestamp is in the future: %', NEW.played_at;
    END IF;

    -- Reject if played_at is too old (> 4 hours for backfill)
    IF NEW.played_at < CURRENT_TIMESTAMP - INTERVAL '4 hours' AND NEW.network_outage_backfill = FALSE THEN
        RAISE EXCEPTION 'Impression timestamp too old (not marked as backfill): %', NEW.played_at;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Update device reputation after impression
CREATE OR REPLACE FUNCTION update_device_reputation_on_impression()
RETURNS TRIGGER AS $$
DECLARE
    current_reputation INTEGER;
    new_reputation INTEGER;
    reputation_change INTEGER;
    event VARCHAR(50);
BEGIN
    -- Only process after INSERT or when verification_status changes
    IF (TG_OP = 'INSERT' AND NEW.verification_status != 'PENDING') OR
       (TG_OP = 'UPDATE' AND OLD.verification_status != NEW.verification_status) THEN

        -- Get current device reputation
        SELECT reputation_score INTO current_reputation
        FROM devices
        WHERE id = NEW.device_id;

        -- Calculate reputation change based on verification status
        CASE NEW.verification_status
            WHEN 'VERIFIED' THEN
                reputation_change := 1;
                event := 'VERIFIED_IMPRESSION';
                IF NEW.quality_score >= 90 THEN
                    reputation_change := reputation_change + 2;
                    event := 'QUALITY_BONUS';
                END IF;
            WHEN 'REJECTED' THEN
                reputation_change := -10;
                event := 'REJECTED_IMPRESSION';
            WHEN 'UNDER_REVIEW' THEN
                reputation_change := -5;
                event := 'HELD_IMPRESSION';
            WHEN 'DISPUTED' THEN
                reputation_change := -15;
                event := 'DISPUTED_IMPRESSION';
            ELSE
                reputation_change := 0;
        END CASE;

        -- Additional penalties for fraud/quality issues
        IF NEW.fraud_score >= 50 THEN
            reputation_change := reputation_change - 2;
            event := 'FLAGGED_IMPRESSION';
        END IF;

        -- Calculate new reputation (clamped to 0-100)
        new_reputation := GREATEST(0, LEAST(100, current_reputation + reputation_change));

        -- Update device reputation
        UPDATE devices
        SET reputation_score = new_reputation,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.device_id;

        -- Log reputation change
        INSERT INTO device_reputation_history (
            device_id,
            impression_id,
            event_type,
            reputation_before,
            reputation_after,
            reputation_delta,
            reason
        ) VALUES (
            NEW.device_id,
            NEW.id,
            event,
            current_reputation,
            new_reputation,
            reputation_change,
            'Automatic update based on impression verification'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate dispute resolution time
CREATE OR REPLACE FUNCTION calculate_dispute_resolution_time()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.resolved_at IS NOT NULL AND OLD.resolved_at IS NULL THEN
        NEW.resolution_time_hours := EXTRACT(EPOCH FROM (NEW.resolved_at - NEW.filed_at)) / 3600;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at on impressions
CREATE TRIGGER trigger_impressions_updated_at
    BEFORE UPDATE ON impressions
    FOR EACH ROW
    EXECUTE FUNCTION update_impression_updated_at();

-- Trigger: Calculate completion rate
CREATE TRIGGER trigger_calculate_completion_rate
    BEFORE INSERT OR UPDATE ON impressions
    FOR EACH ROW
    WHEN (NEW.duration_expected > 0)
    EXECUTE FUNCTION calculate_completion_rate();

-- Trigger: Calculate time drift
CREATE TRIGGER trigger_calculate_time_drift
    BEFORE INSERT OR UPDATE ON impressions
    FOR EACH ROW
    EXECUTE FUNCTION calculate_time_drift();

-- Trigger: Validate impression timestamp
CREATE TRIGGER trigger_validate_impression_timestamp
    BEFORE INSERT ON impressions
    FOR EACH ROW
    EXECUTE FUNCTION validate_impression_timestamp();

-- Trigger: Update device reputation
CREATE TRIGGER trigger_update_device_reputation
    AFTER INSERT OR UPDATE OF verification_status ON impressions
    FOR EACH ROW
    EXECUTE FUNCTION update_device_reputation_on_impression();

-- Trigger: Update updated_at on fraud_detection_rules
CREATE TRIGGER trigger_fraud_rules_updated_at
    BEFORE UPDATE ON fraud_detection_rules
    FOR EACH ROW
    EXECUTE FUNCTION update_impression_updated_at();

-- Trigger: Calculate dispute resolution time
CREATE TRIGGER trigger_calculate_resolution_time
    BEFORE UPDATE ON impression_disputes
    FOR EACH ROW
    EXECUTE FUNCTION calculate_dispute_resolution_time();

-- ============================================================================
-- PARTITIONING STRATEGY (For HIGH VOLUME)
-- ============================================================================

-- For production with millions of impressions per day, consider partitioning:
--
-- CREATE TABLE impressions_partitioned (
--     LIKE impressions INCLUDING ALL
-- ) PARTITION BY RANGE (played_at);
--
-- Create monthly partitions:
-- CREATE TABLE impressions_2026_01 PARTITION OF impressions_partitioned
--     FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
-- CREATE TABLE impressions_2026_02 PARTITION OF impressions_partitioned
--     FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
-- ...
--
-- Benefits:
-- - Faster queries (partition pruning)
-- - Easier archival (drop old partitions)
-- - Better vacuum/analyze performance
-- - Reduced index size per partition

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get impressions pending manual review
SELECT * FROM v_impressions_pending_review
ORDER BY hours_waiting DESC
LIMIT 100;

-- Get device performance metrics
SELECT
    d.device_name,
    d.store_id,
    m.*
FROM v_device_impression_metrics m
JOIN devices d ON m.device_id = d.id
WHERE m.chargeback_rate > 2.0 -- Devices with high chargeback rate
ORDER BY m.chargeback_rate DESC;

-- Get campaign daily metrics
SELECT
    c.name AS campaign_name,
    m.metrics_date,
    m.total_impressions,
    m.verified_impressions,
    m.avg_quality_score,
    m.total_cost
FROM v_daily_impression_metrics m
JOIN campaigns c ON m.campaign_id = c.id
WHERE m.metrics_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY m.metrics_date DESC, m.total_impressions DESC;

-- Get unresolved disputes breaching SLA
SELECT * FROM v_unresolved_disputes
WHERE sla_status = 'SLA_BREACH'
ORDER BY hours_open DESC;

-- Detect duplicate impressions (5-minute window)
SELECT
    campaign_id,
    device_id,
    DATE_TRUNC('minute', played_at) AS time_bucket,
    COUNT(*) AS impression_count
FROM impressions
WHERE played_at >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
GROUP BY campaign_id, device_id, DATE_TRUNC('minute', played_at)
HAVING COUNT(*) > 1
ORDER BY impression_count DESC;

-- Get fraud detection rule effectiveness
SELECT * FROM v_fraud_rule_performance
WHERE triggered_count > 100
ORDER BY effectiveness_score DESC NULLS LAST;

-- Get device reputation trends
SELECT
    d.device_name,
    h.occurred_at,
    h.event_type,
    h.reputation_before,
    h.reputation_after,
    h.reputation_delta,
    h.reason
FROM device_reputation_history h
JOIN devices d ON h.device_id = d.id
WHERE h.device_id = 'DEVICE_UUID'
ORDER BY h.occurred_at DESC
LIMIT 50;

-- Hourly impression volume (for monitoring)
SELECT
    DATE_TRUNC('hour', created_at) AS hour,
    COUNT(*) AS total_impressions,
    COUNT(*) FILTER (WHERE verification_status = 'VERIFIED') AS verified,
    COUNT(*) FILTER (WHERE verification_status = 'REJECTED') AS rejected,
    COUNT(*) FILTER (WHERE verification_status = 'UNDER_REVIEW') AS under_review,
    AVG(quality_score) AS avg_quality,
    AVG(fraud_score) AS avg_fraud
FROM impressions
WHERE created_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY DATE_TRUNC('hour', created_at)
ORDER BY hour DESC;
*/

-- ============================================================================
-- STORAGE ESTIMATES (HIGH VOLUME)
-- ============================================================================

/*
Storage estimates for HIGH VOLUME system (1 million impressions per day):

impressions table:
- Row size: ~1.5 KB (with JSONB fields)
- Daily: 1M × 1.5 KB = 1.5 GB
- Monthly: 1.5 GB × 30 = 45 GB
- Yearly: 1.5 GB × 365 = 547.5 GB
- Indexes: ~30% of table size = 164 GB/year
- Total (1 year): ~712 GB

impression_verification_logs:
- Row size: ~400 bytes
- Logs per impression: ~8 logs
- Daily: 1M × 8 × 400 bytes = 3.2 GB
- Yearly: 3.2 GB × 365 = 1,168 GB (1.14 TB)

impression_quality_metrics:
- Row size: ~600 bytes
- Daily: 1M × 600 bytes = 600 MB
- Yearly: 600 MB × 365 = 219 GB

impression_disputes:
- Row size: ~1 KB
- Dispute rate: 1% = 10K disputes/day
- Daily: 10K × 1 KB = 10 MB
- Yearly: 10 MB × 365 = 3.65 GB

device_reputation_history:
- Row size: ~300 bytes
- Events per impression: ~0.2 (20% of impressions trigger reputation change)
- Daily: 1M × 0.2 × 300 bytes = 60 MB
- Yearly: 60 MB × 365 = 21.9 GB

TOTAL STORAGE (1 year, 1M impressions/day):
- Raw data: ~2.1 TB
- Indexes: ~630 GB
- Total: ~2.7 TB (uncompressed)

With PostgreSQL compression (TOAST) and partitioning:
- Expected compression: 40-60%
- Actual storage: ~1.1-1.6 TB/year

Recommendations:
1. Enable table partitioning (by month or week)
2. Archive old partitions to cold storage (> 6 months)
3. Use table compression (pg_compression)
4. Regular VACUUM and ANALYZE
5. Monitor table bloat
6. Consider TimescaleDB for time-series optimization
*/

-- ============================================================================
-- END OF IMPRESSION SCHEMA
-- ============================================================================
