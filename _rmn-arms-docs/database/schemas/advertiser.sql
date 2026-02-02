-- ============================================================================
-- RMN-Arms Database Schema: Advertiser Management Module
-- ============================================================================
-- Version: 1.0
-- Last Updated: 2026-01-23
-- Description: Complete database schema for Advertiser Management including
--              advertiser accounts, KYC verification, team management, and tiers
-- ============================================================================

-- ============================================================================
-- TABLE: advertisers
-- Description: Main advertiser entity with business details, tier, and status
-- ============================================================================

CREATE TABLE advertisers (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    account_manager_id UUID REFERENCES users(id) ON DELETE SET NULL,
    referred_by UUID REFERENCES advertisers(id) ON DELETE SET NULL,

    -- Business Information
    company_name VARCHAR(100),
    brand_name VARCHAR(100) NOT NULL CHECK (LENGTH(brand_name) >= 2),
    business_type VARCHAR(50) NOT NULL CHECK (business_type IN (
        'INDIVIDUAL', 'SMALL_BUSINESS', 'MEDIUM_BUSINESS',
        'LARGE_BUSINESS', 'ENTERPRISE', 'AGENCY'
    )),
    industry VARCHAR(50) NOT NULL CHECK (industry IN (
        'RETAIL', 'FOOD_BEVERAGE', 'ELECTRONICS', 'FASHION',
        'HEALTH_BEAUTY', 'HOME_GARDEN', 'AUTOMOTIVE', 'ENTERTAINMENT',
        'FINANCIAL_SERVICES', 'TELECOM', 'REAL_ESTATE',
        'EDUCATION', 'TRAVEL', 'OTHER'
    )),
    website_url VARCHAR(200),
    description TEXT CHECK (LENGTH(description) <= 500),

    -- Account Tier & Verification
    account_tier VARCHAR(20) NOT NULL DEFAULT 'FREE' CHECK (account_tier IN (
        'FREE', 'BASIC', 'PREMIUM', 'ENTERPRISE'
    )),
    verification_status VARCHAR(20) NOT NULL DEFAULT 'UNVERIFIED' CHECK (verification_status IN (
        'UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED'
    )),
    verified_at TIMESTAMPTZ,

    -- Billing Information
    tax_id VARCHAR(50), -- Encrypted EIN/VAT number
    billing_address JSONB NOT NULL,
    billing_contact_name VARCHAR(100) NOT NULL,
    billing_contact_email VARCHAR(100) NOT NULL,
    billing_contact_phone VARCHAR(20),
    payment_terms VARCHAR(20) NOT NULL DEFAULT 'PREPAID' CHECK (payment_terms IN (
        'PREPAID', 'NET30', 'NET60'
    )),
    credit_limit DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    -- Usage Metrics
    total_spent DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_impressions BIGINT NOT NULL DEFAULT 0,
    active_campaigns_count INTEGER NOT NULL DEFAULT 0,

    -- Account Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN (
        'ACTIVE', 'SUSPENDED', 'BANNED', 'CLOSED'
    )),
    suspended_at TIMESTAMPTZ,
    suspension_reason VARCHAR(200),
    banned_at TIMESTAMPTZ,
    ban_reason VARCHAR(200),

    -- Referral System
    referral_code VARCHAR(20) NOT NULL UNIQUE,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT advertisers_company_name_check CHECK (
        company_name IS NULL OR LENGTH(company_name) >= 2
    ),
    CONSTRAINT advertisers_website_url_check CHECK (
        website_url IS NULL OR website_url ~* '^https?://'
    ),
    CONSTRAINT advertisers_email_format_check CHECK (
        billing_contact_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT advertisers_credit_limit_check CHECK (
        credit_limit >= 0
    ),
    CONSTRAINT advertisers_metrics_check CHECK (
        total_spent >= 0 AND total_impressions >= 0 AND active_campaigns_count >= 0
    )
);

-- Indexes
CREATE INDEX idx_advertisers_user_id ON advertisers(user_id);
CREATE INDEX idx_advertisers_status ON advertisers(status);
CREATE INDEX idx_advertisers_account_tier ON advertisers(account_tier);
CREATE INDEX idx_advertisers_verification_status ON advertisers(verification_status);
CREATE INDEX idx_advertisers_industry ON advertisers(industry);
CREATE INDEX idx_advertisers_referral_code ON advertisers(referral_code);
CREATE INDEX idx_advertisers_referred_by ON advertisers(referred_by);
CREATE INDEX idx_advertisers_created_at ON advertisers(created_at DESC);
CREATE INDEX idx_advertisers_status_tier ON advertisers(status, account_tier);
CREATE INDEX idx_advertisers_manager ON advertisers(account_manager_id) WHERE account_manager_id IS NOT NULL;

-- Comments
COMMENT ON TABLE advertisers IS 'Main advertiser account table with business details and tier management';
COMMENT ON COLUMN advertisers.account_tier IS 'Service tier: FREE, BASIC, PREMIUM, ENTERPRISE';
COMMENT ON COLUMN advertisers.verification_status IS 'KYC verification status';
COMMENT ON COLUMN advertisers.business_type IS 'Type of business entity';
COMMENT ON COLUMN advertisers.credit_limit IS 'Credit limit for NET payment terms (requires verification)';
COMMENT ON COLUMN advertisers.referral_code IS 'Unique code for referring other advertisers';
COMMENT ON COLUMN advertisers.billing_address IS 'JSON object with street, city, state, postal_code, country';

-- ============================================================================
-- TABLE: advertiser_kyc
-- Description: KYC verification documents and status tracking
-- ============================================================================

CREATE TABLE advertiser_kyc (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,

    -- Verification Details
    verification_type VARCHAR(20) NOT NULL CHECK (verification_type IN (
        'INDIVIDUAL', 'BUSINESS'
    )),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'APPROVED', 'REJECTED', 'EXPIRED'
    )),

    -- Documents (JSON array of document metadata)
    documents JSONB NOT NULL,

    -- External Verification
    verification_provider VARCHAR(50) CHECK (verification_provider IN (
        'STRIPE_IDENTITY', 'MANUAL'
    )),
    provider_verification_id VARCHAR(100),
    risk_score INTEGER CHECK (risk_score BETWEEN 0 AND 100),

    -- Review Information
    rejection_reason VARCHAR(200),
    notes TEXT,

    -- Timestamps
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_advertiser_kyc_advertiser_id ON advertiser_kyc(advertiser_id);
CREATE INDEX idx_advertiser_kyc_status ON advertiser_kyc(status);
CREATE INDEX idx_advertiser_kyc_submitted_at ON advertiser_kyc(submitted_at DESC);
CREATE INDEX idx_advertiser_kyc_expires_at ON advertiser_kyc(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_advertiser_kyc_provider ON advertiser_kyc(verification_provider, provider_verification_id);
CREATE INDEX idx_advertiser_kyc_pending ON advertiser_kyc(status, submitted_at) WHERE status = 'PENDING';

-- Comments
COMMENT ON TABLE advertiser_kyc IS 'KYC verification records for advertiser accounts';
COMMENT ON COLUMN advertiser_kyc.documents IS 'JSON array of uploaded document metadata (type, file_id, issue_date, expiry_date)';
COMMENT ON COLUMN advertiser_kyc.risk_score IS 'Risk assessment score from 0-100 (higher is riskier)';
COMMENT ON COLUMN advertiser_kyc.expires_at IS 'When verification expires and re-verification is needed (typically 2 years)';

-- ============================================================================
-- TABLE: advertiser_team_members
-- Description: Team member access management with roles and permissions
-- ============================================================================

CREATE TABLE advertiser_team_members (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    invited_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    revoked_by UUID REFERENCES users(id) ON DELETE SET NULL,

    -- Team Member Details
    email VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN (
        'OWNER', 'ADMIN', 'CAMPAIGN_MANAGER',
        'CONTENT_MANAGER', 'ANALYST', 'VIEWER'
    )),

    -- Permissions (granular access control)
    permissions JSONB NOT NULL DEFAULT '{}',

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'ACTIVE', 'REVOKED'
    )),

    -- Timestamps
    invited_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    last_access_at TIMESTAMPTZ,

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT team_members_unique_active UNIQUE(advertiser_id, user_id, status)
        DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT team_members_email_check CHECK (
        email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    )
);

-- Indexes
CREATE INDEX idx_team_members_advertiser_id ON advertiser_team_members(advertiser_id);
CREATE INDEX idx_team_members_user_id ON advertiser_team_members(user_id);
CREATE INDEX idx_team_members_status ON advertiser_team_members(status);
CREATE INDEX idx_team_members_role ON advertiser_team_members(role);
CREATE INDEX idx_team_members_advertiser_status ON advertiser_team_members(advertiser_id, status);
CREATE INDEX idx_team_members_email ON advertiser_team_members(email) WHERE status = 'PENDING';
CREATE INDEX idx_team_members_last_access ON advertiser_team_members(last_access_at DESC) WHERE status = 'ACTIVE';

-- Comments
COMMENT ON TABLE advertiser_team_members IS 'Team member access control and invitation management';
COMMENT ON COLUMN advertiser_team_members.role IS 'Predefined role with standard permissions';
COMMENT ON COLUMN advertiser_team_members.permissions IS 'JSON object with granular permission overrides';
COMMENT ON COLUMN advertiser_team_members.email IS 'Email address for invitation (user_id null until accepted)';

-- ============================================================================
-- TABLE: advertiser_tier_configs
-- Description: Configuration for account tier limits and features
-- ============================================================================

CREATE TABLE advertiser_tier_configs (
    -- Primary Key
    tier VARCHAR(20) PRIMARY KEY CHECK (tier IN (
        'FREE', 'BASIC', 'PREMIUM', 'ENTERPRISE'
    )),

    -- Campaign Limits
    max_campaigns_concurrent INTEGER NOT NULL,
    max_budget_per_campaign DECIMAL(12, 2) NOT NULL,
    max_daily_spend DECIMAL(12, 2) NOT NULL,
    max_monthly_spend DECIMAL(12, 2) NOT NULL,

    -- Resource Limits
    max_content_assets INTEGER NOT NULL,
    max_team_members INTEGER NOT NULL,

    -- Features
    support_level VARCHAR(20) NOT NULL CHECK (support_level IN (
        'COMMUNITY', 'EMAIL', 'PRIORITY', 'DEDICATED'
    )),
    api_access BOOLEAN NOT NULL DEFAULT FALSE,
    advanced_analytics BOOLEAN NOT NULL DEFAULT FALSE,
    white_label BOOLEAN NOT NULL DEFAULT FALSE,
    custom_reporting BOOLEAN NOT NULL DEFAULT FALSE,

    -- Pricing
    monthly_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT tier_configs_limits_positive CHECK (
        max_campaigns_concurrent > 0 AND
        max_budget_per_campaign > 0 AND
        max_daily_spend > 0 AND
        max_monthly_spend > 0 AND
        max_content_assets > 0 AND
        max_team_members > 0
    )
);

-- Indexes
CREATE INDEX idx_tier_configs_monthly_fee ON advertiser_tier_configs(monthly_fee);

-- Comments
COMMENT ON TABLE advertiser_tier_configs IS 'Configuration matrix for account tier limits and features';
COMMENT ON COLUMN advertiser_tier_configs.monthly_fee IS 'Monthly subscription fee in USD (0 for FREE tier)';

-- ============================================================================
-- TABLE: advertiser_tier_history
-- Description: Audit trail for tier changes
-- ============================================================================

CREATE TABLE advertiser_tier_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,

    -- Tier Change
    from_tier VARCHAR(20) NOT NULL,
    to_tier VARCHAR(20) NOT NULL,

    -- Change Details
    reason VARCHAR(200),
    billing_cycle VARCHAR(20) CHECK (billing_cycle IN ('MONTHLY', 'ANNUAL')),
    payment_amount DECIMAL(10, 2),

    -- Timestamp
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    changed_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_tier_history_advertiser_id ON advertiser_tier_history(advertiser_id);
CREATE INDEX idx_tier_history_changed_at ON advertiser_tier_history(changed_at DESC);
CREATE INDEX idx_tier_history_to_tier ON advertiser_tier_history(to_tier);

-- Comments
COMMENT ON TABLE advertiser_tier_history IS 'Complete audit trail of tier upgrades and downgrades';

-- ============================================================================
-- TABLE: advertiser_status_history
-- Description: Audit trail for account status changes
-- ============================================================================

CREATE TABLE advertiser_status_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,

    -- Status Change
    from_status VARCHAR(20),
    to_status VARCHAR(20) NOT NULL,

    -- Change Details
    reason VARCHAR(200),
    notes TEXT,

    -- Timestamp
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    changed_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_status_history_advertiser_id ON advertiser_status_history(advertiser_id);
CREATE INDEX idx_status_history_changed_at ON advertiser_status_history(changed_at DESC);
CREATE INDEX idx_status_history_to_status ON advertiser_status_history(to_status);
CREATE INDEX idx_status_history_advertiser_date ON advertiser_status_history(advertiser_id, changed_at DESC);

-- Comments
COMMENT ON TABLE advertiser_status_history IS 'Audit trail of account status changes (suspensions, bans, reactivations)';

-- ============================================================================
-- TABLE: advertiser_compliance_violations
-- Description: Track compliance violations and policy breaches
-- ============================================================================

CREATE TABLE advertiser_compliance_violations (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id) ON DELETE SET NULL,
    content_id UUID REFERENCES content_assets(id) ON DELETE SET NULL,

    -- Violation Details
    violation_type VARCHAR(50) NOT NULL CHECK (violation_type IN (
        'PROHIBITED_CONTENT', 'MISLEADING_CLAIMS', 'COPYRIGHT_INFRINGEMENT',
        'POLICY_VIOLATION', 'PAYMENT_FAILURE', 'FRAUD_INDICATOR',
        'TERMS_VIOLATION', 'OTHER'
    )),
    severity VARCHAR(20) NOT NULL CHECK (severity IN (
        'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    )),
    description TEXT NOT NULL,

    -- Actions Taken
    action_taken VARCHAR(50) CHECK (action_taken IN (
        'WARNING', 'CONTENT_REMOVED', 'CAMPAIGN_PAUSED',
        'ACCOUNT_SUSPENDED', 'ACCOUNT_BANNED'
    )),
    automatic_action BOOLEAN NOT NULL DEFAULT FALSE,

    -- Resolution
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN (
        'OPEN', 'UNDER_REVIEW', 'RESOLVED', 'APPEALED'
    )),
    resolved_at TIMESTAMPTZ,
    resolution_notes TEXT,

    -- Timestamps
    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    detected_by UUID REFERENCES users(id),
    resolved_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_violations_advertiser_id ON advertiser_compliance_violations(advertiser_id);
CREATE INDEX idx_violations_campaign_id ON advertiser_compliance_violations(campaign_id);
CREATE INDEX idx_violations_status ON advertiser_compliance_violations(status);
CREATE INDEX idx_violations_severity ON advertiser_compliance_violations(severity);
CREATE INDEX idx_violations_type ON advertiser_compliance_violations(violation_type);
CREATE INDEX idx_violations_detected_at ON advertiser_compliance_violations(detected_at DESC);
CREATE INDEX idx_violations_open ON advertiser_compliance_violations(advertiser_id, status) WHERE status IN ('OPEN', 'UNDER_REVIEW');

-- Comments
COMMENT ON TABLE advertiser_compliance_violations IS 'Tracking of all compliance violations and policy breaches';
COMMENT ON COLUMN advertiser_compliance_violations.automatic_action IS 'Whether action was taken automatically by system';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Active Advertisers with Metrics
CREATE OR REPLACE VIEW v_active_advertisers AS
SELECT
    a.id,
    a.brand_name,
    a.company_name,
    a.business_type,
    a.industry,
    a.account_tier,
    a.verification_status,
    a.status,
    a.total_spent,
    a.total_impressions,
    a.active_campaigns_count,
    a.created_at,
    COUNT(DISTINCT atm.id) FILTER (WHERE atm.status = 'ACTIVE') AS team_members_count,
    COUNT(DISTINCT acv.id) FILTER (WHERE acv.status = 'OPEN') AS open_violations_count
FROM advertisers a
LEFT JOIN advertiser_team_members atm ON a.id = atm.advertiser_id
LEFT JOIN advertiser_compliance_violations acv ON a.id = acv.advertiser_id
WHERE a.status = 'ACTIVE'
GROUP BY a.id;

-- View: Advertiser Tier Compliance
CREATE OR REPLACE VIEW v_advertiser_tier_compliance AS
SELECT
    a.id,
    a.brand_name,
    a.account_tier,
    a.active_campaigns_count,
    tc.max_campaigns_concurrent,
    CASE
        WHEN a.active_campaigns_count > tc.max_campaigns_concurrent THEN 'EXCEEDED'
        WHEN a.active_campaigns_count >= (tc.max_campaigns_concurrent * 0.8) THEN 'NEAR_LIMIT'
        ELSE 'WITHIN_LIMIT'
    END AS campaign_limit_status,
    COUNT(DISTINCT atm.id) FILTER (WHERE atm.status = 'ACTIVE') AS team_members_count,
    tc.max_team_members,
    CASE
        WHEN COUNT(DISTINCT atm.id) FILTER (WHERE atm.status = 'ACTIVE') > tc.max_team_members THEN 'EXCEEDED'
        WHEN COUNT(DISTINCT atm.id) FILTER (WHERE atm.status = 'ACTIVE') >= (tc.max_team_members * 0.8) THEN 'NEAR_LIMIT'
        ELSE 'WITHIN_LIMIT'
    END AS team_limit_status
FROM advertisers a
JOIN advertiser_tier_configs tc ON a.account_tier = tc.tier
LEFT JOIN advertiser_team_members atm ON a.id = atm.advertiser_id
WHERE a.status = 'ACTIVE'
GROUP BY a.id, tc.max_campaigns_concurrent, tc.max_team_members;

-- View: Pending KYC Verifications
CREATE OR REPLACE VIEW v_pending_kyc_verifications AS
SELECT
    akc.id,
    akc.advertiser_id,
    a.brand_name,
    a.company_name,
    akc.verification_type,
    akc.submitted_at,
    akc.risk_score,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - akc.submitted_at)) / 3600 AS hours_pending
FROM advertiser_kyc akc
JOIN advertisers a ON akc.advertiser_id = a.id
WHERE akc.status = 'PENDING'
ORDER BY akc.submitted_at ASC;

-- Comments on views
COMMENT ON VIEW v_active_advertisers IS 'Active advertisers with key metrics and counts';
COMMENT ON VIEW v_advertiser_tier_compliance IS 'Advertiser usage vs tier limits monitoring';
COMMENT ON VIEW v_pending_kyc_verifications IS 'KYC verifications awaiting review with SLA tracking';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update advertiser updated_at timestamp
CREATE OR REPLACE FUNCTION update_advertiser_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Generate unique referral code
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.referral_code IS NULL OR NEW.referral_code = '' THEN
        NEW.referral_code = UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.id::TEXT) FROM 1 FOR 10));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate tier limits
CREATE OR REPLACE FUNCTION validate_advertiser_tier_limits()
RETURNS TRIGGER AS $$
DECLARE
    tier_config RECORD;
BEGIN
    SELECT * INTO tier_config
    FROM advertiser_tier_configs
    WHERE tier = NEW.account_tier;

    IF NEW.active_campaigns_count > tier_config.max_campaigns_concurrent THEN
        RAISE WARNING 'Active campaigns (%) exceed tier limit (%) for % tier',
            NEW.active_campaigns_count,
            tier_config.max_campaigns_concurrent,
            NEW.account_tier;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Log status changes
CREATE OR REPLACE FUNCTION log_advertiser_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO advertiser_status_history (
            advertiser_id,
            from_status,
            to_status,
            reason,
            changed_by
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            COALESCE(NEW.suspension_reason, NEW.ban_reason),
            NEW.updated_by
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Log tier changes
CREATE OR REPLACE FUNCTION log_advertiser_tier_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.account_tier IS DISTINCT FROM NEW.account_tier THEN
        INSERT INTO advertiser_tier_history (
            advertiser_id,
            from_tier,
            to_tier,
            changed_by
        ) VALUES (
            NEW.id,
            OLD.account_tier,
            NEW.account_tier,
            NEW.updated_by
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Update team member access tracking
CREATE OR REPLACE FUNCTION update_team_member_access()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_access_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate single owner constraint
CREATE OR REPLACE FUNCTION validate_single_owner()
RETURNS TRIGGER AS $$
DECLARE
    owner_count INTEGER;
BEGIN
    IF NEW.role = 'OWNER' AND NEW.status = 'ACTIVE' THEN
        SELECT COUNT(*) INTO owner_count
        FROM advertiser_team_members
        WHERE advertiser_id = NEW.advertiser_id
          AND role = 'OWNER'
          AND status = 'ACTIVE'
          AND id != NEW.id;

        IF owner_count > 0 THEN
            RAISE EXCEPTION 'Only one OWNER allowed per advertiser account';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at on advertisers
CREATE TRIGGER trigger_advertisers_updated_at
    BEFORE UPDATE ON advertisers
    FOR EACH ROW
    EXECUTE FUNCTION update_advertiser_updated_at();

-- Trigger: Generate referral code
CREATE TRIGGER trigger_generate_referral_code
    BEFORE INSERT ON advertisers
    FOR EACH ROW
    EXECUTE FUNCTION generate_referral_code();

-- Trigger: Validate tier limits
CREATE TRIGGER trigger_validate_tier_limits
    AFTER INSERT OR UPDATE ON advertisers
    FOR EACH ROW
    EXECUTE FUNCTION validate_advertiser_tier_limits();

-- Trigger: Log status changes
CREATE TRIGGER trigger_log_status_change
    AFTER UPDATE ON advertisers
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION log_advertiser_status_change();

-- Trigger: Log tier changes
CREATE TRIGGER trigger_log_tier_change
    AFTER UPDATE ON advertisers
    FOR EACH ROW
    WHEN (OLD.account_tier IS DISTINCT FROM NEW.account_tier)
    EXECUTE FUNCTION log_advertiser_tier_change();

-- Trigger: Update updated_at on advertiser_kyc
CREATE TRIGGER trigger_advertiser_kyc_updated_at
    BEFORE UPDATE ON advertiser_kyc
    FOR EACH ROW
    EXECUTE FUNCTION update_advertiser_updated_at();

-- Trigger: Update updated_at on advertiser_team_members
CREATE TRIGGER trigger_team_members_updated_at
    BEFORE UPDATE ON advertiser_team_members
    FOR EACH ROW
    EXECUTE FUNCTION update_advertiser_updated_at();

-- Trigger: Validate single owner
CREATE TRIGGER trigger_validate_single_owner
    BEFORE INSERT OR UPDATE ON advertiser_team_members
    FOR EACH ROW
    EXECUTE FUNCTION validate_single_owner();

-- ============================================================================
-- INITIAL DATA: Tier Configurations
-- ============================================================================

INSERT INTO advertiser_tier_configs (
    tier, max_campaigns_concurrent, max_budget_per_campaign, max_daily_spend,
    max_monthly_spend, max_content_assets, max_team_members, support_level,
    api_access, advanced_analytics, white_label, custom_reporting, monthly_fee
) VALUES
    ('FREE', 2, 500.00, 100.00, 1000.00, 10, 1, 'COMMUNITY', FALSE, FALSE, FALSE, FALSE, 0.00),
    ('BASIC', 5, 2000.00, 500.00, 5000.00, 50, 3, 'EMAIL', FALSE, TRUE, FALSE, FALSE, 99.00),
    ('PREMIUM', 20, 10000.00, 2000.00, 50000.00, 200, 10, 'PRIORITY', TRUE, TRUE, FALSE, TRUE, 499.00),
    ('ENTERPRISE', 999999, 999999999.99, 999999999.99, 999999999.99, 999999, 999999, 'DEDICATED', TRUE, TRUE, TRUE, TRUE, 2000.00)
ON CONFLICT (tier) DO UPDATE SET
    max_campaigns_concurrent = EXCLUDED.max_campaigns_concurrent,
    max_budget_per_campaign = EXCLUDED.max_budget_per_campaign,
    max_daily_spend = EXCLUDED.max_daily_spend,
    max_monthly_spend = EXCLUDED.max_monthly_spend,
    max_content_assets = EXCLUDED.max_content_assets,
    max_team_members = EXCLUDED.max_team_members,
    support_level = EXCLUDED.support_level,
    api_access = EXCLUDED.api_access,
    advanced_analytics = EXCLUDED.advanced_analytics,
    white_label = EXCLUDED.white_label,
    custom_reporting = EXCLUDED.custom_reporting,
    monthly_fee = EXCLUDED.monthly_fee,
    updated_at = CURRENT_TIMESTAMP;

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get advertiser with tier details
SELECT
    a.*,
    tc.max_campaigns_concurrent,
    tc.max_team_members,
    tc.monthly_fee
FROM advertisers a
JOIN advertiser_tier_configs tc ON a.account_tier = tc.tier
WHERE a.id = 'ADVERTISER_UUID';

-- Get advertiser team members with roles
SELECT
    atm.id,
    atm.email,
    atm.role,
    atm.status,
    u.name AS user_name,
    atm.last_access_at
FROM advertiser_team_members atm
LEFT JOIN users u ON atm.user_id = u.id
WHERE atm.advertiser_id = 'ADVERTISER_UUID'
  AND atm.status = 'ACTIVE'
ORDER BY
    CASE atm.role
        WHEN 'OWNER' THEN 1
        WHEN 'ADMIN' THEN 2
        ELSE 3
    END,
    atm.accepted_at;

-- Get pending KYC verifications older than 48 hours
SELECT * FROM v_pending_kyc_verifications
WHERE hours_pending > 48
ORDER BY hours_pending DESC;

-- Get advertisers near tier limits
SELECT * FROM v_advertiser_tier_compliance
WHERE campaign_limit_status IN ('NEAR_LIMIT', 'EXCEEDED')
   OR team_limit_status IN ('NEAR_LIMIT', 'EXCEEDED');

-- Get advertiser compliance violations summary
SELECT
    a.brand_name,
    COUNT(*) AS total_violations,
    COUNT(*) FILTER (WHERE acv.severity = 'CRITICAL') AS critical_violations,
    MAX(acv.detected_at) AS last_violation_date
FROM advertisers a
JOIN advertiser_compliance_violations acv ON a.id = acv.advertiser_id
WHERE acv.status = 'OPEN'
GROUP BY a.id, a.brand_name
HAVING COUNT(*) FILTER (WHERE acv.severity = 'CRITICAL') > 0
ORDER BY critical_violations DESC, total_violations DESC;

-- Get tier upgrade candidates (FREE users with high activity)
SELECT
    a.id,
    a.brand_name,
    a.account_tier,
    a.total_spent,
    a.active_campaigns_count,
    a.created_at,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - a.created_at)) / 86400 AS days_active
FROM advertisers a
WHERE a.account_tier = 'FREE'
  AND a.status = 'ACTIVE'
  AND a.active_campaigns_count >= 2
  AND a.total_spent > 500
ORDER BY a.total_spent DESC;
*/

-- ============================================================================
-- END OF ADVERTISER SCHEMA
-- ============================================================================
