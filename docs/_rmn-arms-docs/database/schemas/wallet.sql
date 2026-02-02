-- ============================================================================
-- RMN-Arms Database Schema: Wallet & Payment Module
-- ============================================================================
-- Version: 1.0
-- Last Updated: 2026-01-23
-- Description: Complete database schema for Wallet & Payment management including
--              wallets, transactions, payment methods, withdrawals, refunds, and reconciliation
-- ============================================================================

-- ============================================================================
-- TABLE: wallets
-- Description: Digital account for managing platform funds (Advertiser & Supplier)
-- ============================================================================

CREATE TABLE wallets (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE RESTRICT,

    -- User Type
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('ADVERTISER', 'SUPPLIER')),

    -- Currency
    currency VARCHAR(3) NOT NULL DEFAULT 'USD', -- ISO 4217 code

    -- Balance Types
    available_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (available_balance >= 0),
    held_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (held_balance >= 0),
    pending_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (pending_balance >= 0),

    -- Lifetime Metrics
    lifetime_deposits DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (lifetime_deposits >= 0),
    lifetime_withdrawals DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (lifetime_withdrawals >= 0),
    lifetime_spent DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (lifetime_spent >= 0),
    lifetime_earned DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (lifetime_earned >= 0),

    -- Balance Limits & Alerts
    min_balance_alert DECIMAL(12, 2),
    max_balance_limit DECIMAL(12, 2),

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'FROZEN', 'SUSPENDED')),
    frozen_reason VARCHAR(200),
    frozen_at TIMESTAMPTZ,

    -- Activity Timestamps
    last_topup_at TIMESTAMPTZ,
    last_withdrawal_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT wallets_balance_limits_check CHECK (
        max_balance_limit IS NULL OR
        (available_balance + held_balance + pending_balance) <= max_balance_limit
    ),
    CONSTRAINT wallets_frozen_check CHECK (
        status != 'FROZEN' OR (frozen_reason IS NOT NULL AND frozen_at IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_user_type ON wallets(user_type);
CREATE INDEX idx_wallets_status ON wallets(status);
CREATE INDEX idx_wallets_currency ON wallets(currency);
CREATE INDEX idx_wallets_created_at ON wallets(created_at DESC);

-- Comments
COMMENT ON TABLE wallets IS 'Digital accounts for managing platform funds';
COMMENT ON COLUMN wallets.user_id IS 'One wallet per user - strict 1:1 relationship';
COMMENT ON COLUMN wallets.available_balance IS 'Funds immediately usable for campaigns or withdrawals';
COMMENT ON COLUMN wallets.held_balance IS 'Funds temporarily locked for pending operations (escrow)';
COMMENT ON COLUMN wallets.pending_balance IS 'Funds in-flight (processing deposits/withdrawals)';
COMMENT ON COLUMN wallets.lifetime_deposits IS 'Total amount ever deposited';
COMMENT ON COLUMN wallets.lifetime_withdrawals IS 'Total amount ever withdrawn';
COMMENT ON COLUMN wallets.lifetime_spent IS 'Total campaign spending (advertiser only)';
COMMENT ON COLUMN wallets.lifetime_earned IS 'Total revenue earned (supplier only)';

-- ============================================================================
-- TABLE: wallet_transactions
-- Description: Immutable record of all balance change events
-- ============================================================================

CREATE TABLE wallet_transactions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,

    -- Transaction Details
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN (
        'DEPOSIT', 'REFUND', 'REVENUE', 'ADJUSTMENT_CREDIT', 'BONUS',
        'CAMPAIGN_HOLD', 'CAMPAIGN_CHARGE', 'WITHDRAWAL', 'FEE',
        'TAX_WITHHOLDING', 'ADJUSTMENT_DEBIT', 'CHARGEBACK',
        'HOLD', 'RELEASE', 'PENDING_DEPOSIT', 'PENDING_WITHDRAWAL'
    )),

    -- Amount (always positive, type indicates direction)
    amount DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Balance Snapshots
    balance_before DECIMAL(12, 2) NOT NULL,
    balance_after DECIMAL(12, 2) NOT NULL,
    balance_type_affected VARCHAR(20) NOT NULL CHECK (balance_type_affected IN ('AVAILABLE', 'HELD', 'PENDING')),

    -- Transaction Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REVERSED')),

    -- Reference to Related Entity
    reference_type VARCHAR(50), -- Campaign, Impression, Withdrawal, Refund, etc.
    reference_id UUID,

    -- Payment Information
    payment_method VARCHAR(50) CHECK (payment_method IN ('CARD', 'BANK_TRANSFER', 'WALLET', 'OTHER')),
    payment_gateway VARCHAR(50) CHECK (payment_gateway IN ('STRIPE', 'PAYPAL', 'BANK', 'MANUAL')),
    gateway_transaction_id VARCHAR(100),

    -- Description
    description TEXT NOT NULL,

    -- Financial Details
    fee_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (fee_amount >= 0),
    tax_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    net_amount DECIMAL(12, 2) NOT NULL,

    -- Metadata
    metadata JSONB,

    -- Reversal Information
    reversed_at TIMESTAMPTZ,
    reversal_reason VARCHAR(200),

    -- Timestamps
    processed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT wallet_transactions_net_amount_check CHECK (
        net_amount = amount - fee_amount - tax_amount
    )
);

-- Indexes
CREATE INDEX idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(transaction_type);
CREATE INDEX idx_wallet_transactions_status ON wallet_transactions(status);
CREATE INDEX idx_wallet_transactions_processed_at ON wallet_transactions(processed_at DESC);
CREATE INDEX idx_wallet_transactions_reference ON wallet_transactions(reference_type, reference_id);
CREATE INDEX idx_wallet_transactions_wallet_date ON wallet_transactions(wallet_id, processed_at DESC);
CREATE INDEX idx_wallet_transactions_gateway ON wallet_transactions(payment_gateway, gateway_transaction_id);

-- Comments
COMMENT ON TABLE wallet_transactions IS 'Immutable audit log of all balance changes';
COMMENT ON COLUMN wallet_transactions.transaction_type IS 'Type of transaction (CREDIT, DEBIT, HOLD, RELEASE, etc.)';
COMMENT ON COLUMN wallet_transactions.amount IS 'Always positive - transaction_type indicates direction';
COMMENT ON COLUMN wallet_transactions.balance_before IS 'Snapshot of balance before transaction';
COMMENT ON COLUMN wallet_transactions.balance_after IS 'Snapshot of balance after transaction';
COMMENT ON COLUMN wallet_transactions.net_amount IS 'amount - fee_amount - tax_amount';

-- ============================================================================
-- TABLE: payment_methods
-- Description: Saved payment methods for users (credit cards, bank accounts)
-- ============================================================================

CREATE TABLE payment_methods (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Payment Method Type
    type VARCHAR(50) NOT NULL CHECK (type IN ('CREDIT_CARD', 'DEBIT_CARD', 'BANK_ACCOUNT')),
    provider VARCHAR(50) NOT NULL CHECK (provider IN ('STRIPE', 'PAYPAL')),
    provider_payment_method_id VARCHAR(100) NOT NULL,

    -- Default Payment Method
    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    -- Card Information (if applicable)
    card_last4 VARCHAR(4),
    card_brand VARCHAR(20), -- Visa, Mastercard, Amex, etc.
    card_exp_month INTEGER CHECK (card_exp_month BETWEEN 1 AND 12),
    card_exp_year INTEGER CHECK (card_exp_year >= EXTRACT(YEAR FROM CURRENT_DATE)),

    -- Bank Information (if applicable)
    bank_name VARCHAR(100),
    bank_account_last4 VARCHAR(4),

    -- Billing Address
    billing_address JSONB,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'FAILED')),

    -- Verification
    verified_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT payment_methods_card_check CHECK (
        type NOT IN ('CREDIT_CARD', 'DEBIT_CARD') OR
        (card_last4 IS NOT NULL AND card_brand IS NOT NULL AND
         card_exp_month IS NOT NULL AND card_exp_year IS NOT NULL)
    ),
    CONSTRAINT payment_methods_bank_check CHECK (
        type != 'BANK_ACCOUNT' OR
        (bank_name IS NOT NULL AND bank_account_last4 IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_payment_methods_user_id ON payment_methods(user_id);
CREATE INDEX idx_payment_methods_status ON payment_methods(status);
CREATE INDEX idx_payment_methods_default ON payment_methods(user_id, is_default) WHERE is_default = TRUE;
CREATE INDEX idx_payment_methods_provider ON payment_methods(provider, provider_payment_method_id);

-- Comments
COMMENT ON TABLE payment_methods IS 'Saved payment methods for top-ups and purchases';
COMMENT ON COLUMN payment_methods.is_default IS 'Default payment method for automatic charges';
COMMENT ON COLUMN payment_methods.provider_payment_method_id IS 'External payment gateway ID';

-- ============================================================================
-- TABLE: withdrawal_requests
-- Description: Supplier requests to transfer funds to bank account
-- ============================================================================

CREATE TABLE withdrawal_requests (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,

    -- Amount Details
    amount DECIMAL(12, 2) NOT NULL CHECK (amount >= 50.00),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    fee_amount DECIMAL(12, 2) NOT NULL CHECK (fee_amount >= 0),
    tax_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    net_amount DECIMAL(12, 2) NOT NULL,

    -- Bank Account Details (encrypted in production)
    bank_account_name VARCHAR(100) NOT NULL,
    bank_account_number VARCHAR(100) NOT NULL, -- Encrypted
    bank_routing_number VARCHAR(50) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    bank_country VARCHAR(2) NOT NULL, -- ISO country code

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'APPROVED', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'RETRY'
    )),

    -- Reference
    reference_number VARCHAR(50), -- Bank reference number
    retry_count INTEGER NOT NULL DEFAULT 0,

    -- Approval
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES users(id),

    -- Processing
    processed_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    -- Failure
    failed_at TIMESTAMPTZ,
    failure_reason VARCHAR(200),

    -- Timestamps
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT withdrawal_requests_net_amount_check CHECK (
        net_amount = amount - fee_amount - tax_amount
    ),
    CONSTRAINT withdrawal_requests_approved_check CHECK (
        status NOT IN ('APPROVED', 'PROCESSING', 'COMPLETED') OR
        (approved_at IS NOT NULL AND approved_by IS NOT NULL)
    ),
    CONSTRAINT withdrawal_requests_failed_check CHECK (
        status != 'FAILED' OR
        (failed_at IS NOT NULL AND failure_reason IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_withdrawal_requests_wallet_id ON withdrawal_requests(wallet_id);
CREATE INDEX idx_withdrawal_requests_supplier_id ON withdrawal_requests(supplier_id);
CREATE INDEX idx_withdrawal_requests_status ON withdrawal_requests(status);
CREATE INDEX idx_withdrawal_requests_requested_at ON withdrawal_requests(requested_at DESC);
CREATE INDEX idx_withdrawal_requests_pending ON withdrawal_requests(status) WHERE status = 'PENDING';

-- Comments
COMMENT ON TABLE withdrawal_requests IS 'Supplier requests to withdraw funds to bank account';
COMMENT ON COLUMN withdrawal_requests.amount IS 'Gross withdrawal amount (minimum $50)';
COMMENT ON COLUMN withdrawal_requests.fee_amount IS 'Withdrawal processing fee';
COMMENT ON COLUMN withdrawal_requests.tax_amount IS 'Tax withholding (if no W-9 form)';
COMMENT ON COLUMN withdrawal_requests.net_amount IS 'Actual amount sent to bank';
COMMENT ON COLUMN withdrawal_requests.retry_count IS 'Number of failed retry attempts';

-- ============================================================================
-- TABLE: refund_requests
-- Description: Advertiser requests for refunds
-- ============================================================================

CREATE TABLE refund_requests (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    advertiser_id UUID NOT NULL REFERENCES advertisers(id) ON DELETE RESTRICT,
    campaign_id UUID REFERENCES campaigns(id),

    -- Amount
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Refund Details
    refund_type VARCHAR(50) NOT NULL CHECK (refund_type IN (
        'CAMPAIGN_CANCELLED', 'UNUSED_BUDGET', 'DISPUTE', 'PLATFORM_ERROR', 'OTHER'
    )),
    reason TEXT NOT NULL,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'APPROVED', 'REJECTED', 'COMPLETED'
    )),

    -- Approval
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES users(id),
    rejection_reason VARCHAR(200),

    -- Processing
    processed_at TIMESTAMPTZ,

    -- Timestamps
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT refund_requests_approved_check CHECK (
        status NOT IN ('APPROVED', 'COMPLETED') OR
        (approved_at IS NOT NULL AND approved_by IS NOT NULL)
    ),
    CONSTRAINT refund_requests_rejected_check CHECK (
        status != 'REJECTED' OR rejection_reason IS NOT NULL
    )
);

-- Indexes
CREATE INDEX idx_refund_requests_wallet_id ON refund_requests(wallet_id);
CREATE INDEX idx_refund_requests_advertiser_id ON refund_requests(advertiser_id);
CREATE INDEX idx_refund_requests_campaign_id ON refund_requests(campaign_id);
CREATE INDEX idx_refund_requests_status ON refund_requests(status);
CREATE INDEX idx_refund_requests_requested_at ON refund_requests(requested_at DESC);
CREATE INDEX idx_refund_requests_pending ON refund_requests(status) WHERE status = 'PENDING';

-- Comments
COMMENT ON TABLE refund_requests IS 'Advertiser requests for refunds';
COMMENT ON COLUMN refund_requests.refund_type IS 'Reason category for refund';
COMMENT ON COLUMN refund_requests.campaign_id IS 'Related campaign if applicable';

-- ============================================================================
-- TABLE: daily_reconciliations
-- Description: Daily financial accuracy checks
-- ============================================================================

CREATE TABLE daily_reconciliations (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Date
    reconciliation_date DATE NOT NULL UNIQUE,

    -- Financial Totals
    total_deposits DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_withdrawals DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_campaign_spending DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_supplier_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    platform_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_fees DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_taxes DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    -- Balance Verification
    expected_balance DECIMAL(12, 2) NOT NULL,
    actual_balance DECIMAL(12, 2) NOT NULL,
    discrepancy DECIMAL(12, 2) NOT NULL,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'BALANCED', 'DISCREPANCY', 'RESOLVED'
    )),

    -- Resolution
    discrepancy_reason TEXT,
    reconciled_by UUID REFERENCES users(id),
    reconciled_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT daily_reconciliations_discrepancy_check CHECK (
        discrepancy = expected_balance - actual_balance
    ),
    CONSTRAINT daily_reconciliations_resolved_check CHECK (
        status != 'RESOLVED' OR
        (reconciled_by IS NOT NULL AND reconciled_at IS NOT NULL AND discrepancy_reason IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_daily_reconciliations_date ON daily_reconciliations(reconciliation_date DESC);
CREATE INDEX idx_daily_reconciliations_status ON daily_reconciliations(status);
CREATE INDEX idx_daily_reconciliations_discrepancy ON daily_reconciliations(status) WHERE status IN ('DISCREPANCY', 'RESOLVED');

-- Comments
COMMENT ON TABLE daily_reconciliations IS 'Daily financial accuracy verification';
COMMENT ON COLUMN daily_reconciliations.expected_balance IS 'Calculated balance from transactions';
COMMENT ON COLUMN daily_reconciliations.actual_balance IS 'Sum of all wallet balances';
COMMENT ON COLUMN daily_reconciliations.discrepancy IS 'expected_balance - actual_balance';
COMMENT ON COLUMN daily_reconciliations.platform_revenue IS 'Platform 20% share';

-- ============================================================================
-- TABLE: wallet_holds
-- Description: Track escrowed funds (campaign budgets, dispute holds, etc.)
-- ============================================================================

CREATE TABLE wallet_holds (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,

    -- Hold Details
    hold_type VARCHAR(50) NOT NULL CHECK (hold_type IN (
        'CAMPAIGN_BUDGET', 'DISPUTE', 'FRAUD_REVIEW', 'COMPLIANCE_HOLD', 'OTHER'
    )),
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',

    -- Reference
    reference_type VARCHAR(50) NOT NULL, -- Campaign, Dispute, etc.
    reference_id UUID NOT NULL,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'RELEASED', 'EXPIRED')),

    -- Hold Period
    held_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    release_scheduled_at TIMESTAMPTZ, -- Auto-release date
    released_at TIMESTAMPTZ,
    release_reason VARCHAR(200),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT wallet_holds_released_check CHECK (
        status != 'RELEASED' OR
        (released_at IS NOT NULL AND release_reason IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_wallet_holds_wallet_id ON wallet_holds(wallet_id);
CREATE INDEX idx_wallet_holds_status ON wallet_holds(status);
CREATE INDEX idx_wallet_holds_reference ON wallet_holds(reference_type, reference_id);
CREATE INDEX idx_wallet_holds_release_scheduled ON wallet_holds(release_scheduled_at) WHERE status = 'ACTIVE';
CREATE INDEX idx_wallet_holds_active ON wallet_holds(wallet_id, status) WHERE status = 'ACTIVE';

-- Comments
COMMENT ON TABLE wallet_holds IS 'Track escrowed funds and hold periods';
COMMENT ON COLUMN wallet_holds.release_scheduled_at IS 'Automatic release date (e.g., 7 days for supplier revenue)';

-- ============================================================================
-- TABLE: aml_flags
-- Description: Anti-Money Laundering (AML) compliance flags
-- ============================================================================

CREATE TABLE aml_flags (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    transaction_id UUID REFERENCES wallet_transactions(id),

    -- Flag Details
    flag_type VARCHAR(50) NOT NULL CHECK (flag_type IN (
        'LARGE_TRANSACTION', 'STRUCTURING', 'RAPID_IN_OUT',
        'UNUSUAL_PATTERN', 'HIGH_RISK_JURISDICTION', 'MANUAL_REVIEW'
    )),
    risk_level VARCHAR(20) NOT NULL CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),

    -- Description
    description TEXT NOT NULL,
    automated_flag BOOLEAN NOT NULL DEFAULT TRUE,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'UNDER_REVIEW', 'CLEARED', 'CONFIRMED', 'ESCALATED'
    )),

    -- Review
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    review_notes TEXT,
    resolution VARCHAR(50), -- APPROVED, REJECTED, ACCOUNT_FROZEN, etc.

    -- Timestamps
    flagged_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT aml_flags_review_check CHECK (
        status NOT IN ('CLEARED', 'CONFIRMED', 'ESCALATED') OR
        (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_aml_flags_wallet_id ON aml_flags(wallet_id);
CREATE INDEX idx_aml_flags_transaction_id ON aml_flags(transaction_id);
CREATE INDEX idx_aml_flags_status ON aml_flags(status);
CREATE INDEX idx_aml_flags_risk_level ON aml_flags(risk_level);
CREATE INDEX idx_aml_flags_pending ON aml_flags(status, risk_level) WHERE status = 'PENDING';
CREATE INDEX idx_aml_flags_flagged_at ON aml_flags(flagged_at DESC);

-- Comments
COMMENT ON TABLE aml_flags IS 'Anti-Money Laundering compliance flags and reviews';
COMMENT ON COLUMN aml_flags.automated_flag IS 'TRUE if flagged by automated system, FALSE if manual';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Wallet Summary
CREATE OR REPLACE VIEW v_wallet_summary AS
SELECT
    w.id,
    w.user_id,
    w.user_type,
    w.currency,
    w.available_balance,
    w.held_balance,
    w.pending_balance,
    (w.available_balance + w.held_balance + w.pending_balance) AS total_balance,
    w.lifetime_deposits,
    w.lifetime_withdrawals,
    w.lifetime_spent,
    w.lifetime_earned,
    w.status,
    w.last_topup_at,
    w.last_withdrawal_at,
    COALESCE(active_holds.total_held, 0) AS active_holds_count,
    COALESCE(pending_txns.total_pending, 0) AS pending_transactions_count
FROM wallets w
LEFT JOIN (
    SELECT wallet_id, COUNT(*) AS total_held
    FROM wallet_holds
    WHERE status = 'ACTIVE'
    GROUP BY wallet_id
) active_holds ON w.id = active_holds.wallet_id
LEFT JOIN (
    SELECT wallet_id, COUNT(*) AS total_pending
    FROM wallet_transactions
    WHERE status = 'PENDING'
    GROUP BY wallet_id
) pending_txns ON w.id = pending_txns.wallet_id;

-- View: Transaction History (last 90 days)
CREATE OR REPLACE VIEW v_recent_transactions AS
SELECT
    wt.id,
    wt.wallet_id,
    w.user_id,
    w.user_type,
    wt.transaction_type,
    wt.amount,
    wt.currency,
    wt.balance_before,
    wt.balance_after,
    wt.balance_type_affected,
    wt.status,
    wt.description,
    wt.fee_amount,
    wt.tax_amount,
    wt.net_amount,
    wt.payment_gateway,
    wt.processed_at
FROM wallet_transactions wt
JOIN wallets w ON wt.wallet_id = w.id
WHERE wt.processed_at >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY wt.processed_at DESC;

-- View: Pending Withdrawals
CREATE OR REPLACE VIEW v_pending_withdrawals AS
SELECT
    wr.id,
    wr.supplier_id,
    s.business_name AS supplier_name,
    wr.amount,
    wr.fee_amount,
    wr.tax_amount,
    wr.net_amount,
    wr.currency,
    wr.bank_name,
    wr.bank_country,
    wr.status,
    wr.requested_at,
    wr.approved_at,
    wr.retry_count,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - wr.requested_at)) AS days_pending
FROM withdrawal_requests wr
JOIN suppliers s ON wr.supplier_id = s.id
WHERE wr.status IN ('PENDING', 'APPROVED', 'PROCESSING', 'RETRY')
ORDER BY wr.requested_at ASC;

-- View: AML Review Queue
CREATE OR REPLACE VIEW v_aml_review_queue AS
SELECT
    af.id,
    af.wallet_id,
    w.user_id,
    w.user_type,
    af.flag_type,
    af.risk_level,
    af.description,
    af.status,
    af.flagged_at,
    EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - af.flagged_at)) AS hours_pending,
    af.transaction_id,
    wt.amount AS transaction_amount,
    wt.transaction_type
FROM aml_flags af
JOIN wallets w ON af.wallet_id = w.id
LEFT JOIN wallet_transactions wt ON af.transaction_id = wt.id
WHERE af.status IN ('PENDING', 'UNDER_REVIEW')
ORDER BY af.risk_level DESC, af.flagged_at ASC;

-- View: Daily Reconciliation Summary
CREATE OR REPLACE VIEW v_reconciliation_summary AS
SELECT
    dr.reconciliation_date,
    dr.total_deposits,
    dr.total_withdrawals,
    dr.total_campaign_spending,
    dr.total_supplier_revenue,
    dr.platform_revenue,
    dr.expected_balance,
    dr.actual_balance,
    dr.discrepancy,
    dr.status,
    CASE
        WHEN ABS(dr.discrepancy) <= 0.01 THEN 'ACCEPTABLE'
        WHEN ABS(dr.discrepancy) <= 10.00 THEN 'MINOR'
        WHEN ABS(dr.discrepancy) <= 100.00 THEN 'MODERATE'
        ELSE 'CRITICAL'
    END AS discrepancy_severity,
    dr.reconciled_at,
    dr.reconciled_by
FROM daily_reconciliations dr
ORDER BY dr.reconciliation_date DESC;

-- Comments on views
COMMENT ON VIEW v_wallet_summary IS 'Comprehensive wallet overview with balances and metrics';
COMMENT ON VIEW v_recent_transactions IS 'Transaction history for last 90 days';
COMMENT ON VIEW v_pending_withdrawals IS 'All pending withdrawal requests with age';
COMMENT ON VIEW v_aml_review_queue IS 'AML flags requiring review, prioritized by risk';
COMMENT ON VIEW v_reconciliation_summary IS 'Daily reconciliation results with severity classification';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update wallet updated_at timestamp
CREATE OR REPLACE FUNCTION update_wallet_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Ensure one default payment method per user
CREATE OR REPLACE FUNCTION ensure_one_default_payment_method()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_default = TRUE THEN
        -- Unset other default payment methods for this user
        UPDATE payment_methods
        SET is_default = FALSE
        WHERE user_id = NEW.user_id
          AND id != NEW.id
          AND is_default = TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate balance integrity
CREATE OR REPLACE FUNCTION validate_wallet_balance_integrity()
RETURNS TRIGGER AS $$
DECLARE
    calculated_total DECIMAL(12, 2);
BEGIN
    calculated_total := NEW.available_balance + NEW.held_balance + NEW.pending_balance;

    -- Check if balances are non-negative
    IF NEW.available_balance < 0 OR NEW.held_balance < 0 OR NEW.pending_balance < 0 THEN
        RAISE EXCEPTION 'Balance cannot be negative';
    END IF;

    -- Check max balance limit
    IF NEW.max_balance_limit IS NOT NULL AND calculated_total > NEW.max_balance_limit THEN
        RAISE EXCEPTION 'Total balance exceeds maximum limit of %', NEW.max_balance_limit;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Auto-release expired holds
CREATE OR REPLACE FUNCTION auto_release_expired_holds()
RETURNS INTEGER AS $$
DECLARE
    released_count INTEGER := 0;
    hold_record RECORD;
BEGIN
    FOR hold_record IN
        SELECT id, wallet_id, amount
        FROM wallet_holds
        WHERE status = 'ACTIVE'
          AND release_scheduled_at IS NOT NULL
          AND release_scheduled_at <= CURRENT_TIMESTAMP
    LOOP
        -- Update hold status
        UPDATE wallet_holds
        SET status = 'RELEASED',
            released_at = CURRENT_TIMESTAMP,
            release_reason = 'Auto-released after hold period expired'
        WHERE id = hold_record.id;

        -- Move funds from held to available
        UPDATE wallets
        SET held_balance = held_balance - hold_record.amount,
            available_balance = available_balance + hold_record.amount
        WHERE id = hold_record.wallet_id;

        -- Create transaction record
        INSERT INTO wallet_transactions (
            wallet_id, transaction_type, amount, currency,
            balance_before, balance_after, balance_type_affected,
            status, description, net_amount, processed_at
        )
        SELECT
            hold_record.wallet_id,
            'RELEASE',
            hold_record.amount,
            currency,
            held_balance + hold_record.amount,
            held_balance,
            'HELD',
            'COMPLETED',
            'Auto-released after hold period',
            hold_record.amount,
            CURRENT_TIMESTAMP
        FROM wallets
        WHERE id = hold_record.wallet_id;

        released_count := released_count + 1;
    END LOOP;

    RETURN released_count;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate withdrawal fee
CREATE OR REPLACE FUNCTION calculate_withdrawal_fee(withdrawal_amount DECIMAL)
RETURNS DECIMAL AS $$
BEGIN
    RETURN CASE
        WHEN withdrawal_amount < 500 THEN 5.00
        WHEN withdrawal_amount < 5000 THEN 10.00
        ELSE 25.00
    END;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at on wallets
CREATE TRIGGER trigger_wallets_updated_at
    BEFORE UPDATE ON wallets
    FOR EACH ROW
    EXECUTE FUNCTION update_wallet_updated_at();

-- Trigger: Validate wallet balance integrity
CREATE TRIGGER trigger_validate_wallet_balance
    BEFORE INSERT OR UPDATE ON wallets
    FOR EACH ROW
    EXECUTE FUNCTION validate_wallet_balance_integrity();

-- Trigger: Ensure one default payment method
CREATE TRIGGER trigger_one_default_payment_method
    BEFORE INSERT OR UPDATE ON payment_methods
    FOR EACH ROW
    WHEN (NEW.is_default = TRUE)
    EXECUTE FUNCTION ensure_one_default_payment_method();

-- Trigger: Update updated_at on payment_methods
CREATE TRIGGER trigger_payment_methods_updated_at
    BEFORE UPDATE ON payment_methods
    FOR EACH ROW
    EXECUTE FUNCTION update_wallet_updated_at();

-- Trigger: Update updated_at on wallet_holds
CREATE TRIGGER trigger_wallet_holds_updated_at
    BEFORE UPDATE ON wallet_holds
    FOR EACH ROW
    EXECUTE FUNCTION update_wallet_updated_at();

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get wallet balance and transaction history
SELECT
    w.user_id,
    w.available_balance,
    w.held_balance,
    w.pending_balance,
    (w.available_balance + w.held_balance + w.pending_balance) AS total_balance,
    COUNT(wt.id) AS transaction_count,
    SUM(CASE WHEN wt.transaction_type = 'DEPOSIT' THEN wt.amount ELSE 0 END) AS total_deposits
FROM wallets w
LEFT JOIN wallet_transactions wt ON w.id = wt.wallet_id
WHERE w.user_id = 'USER_UUID'
GROUP BY w.id;

-- Get pending withdrawals requiring approval
SELECT * FROM v_pending_withdrawals
WHERE status = 'PENDING' AND amount >= 5000.00
ORDER BY requested_at ASC;

-- Get AML flags requiring immediate attention
SELECT * FROM v_aml_review_queue
WHERE risk_level IN ('HIGH', 'CRITICAL')
  AND hours_pending > 24
ORDER BY risk_level DESC, flagged_at ASC;

-- Get daily reconciliation discrepancies
SELECT * FROM v_reconciliation_summary
WHERE status = 'DISCREPANCY'
  AND discrepancy_severity IN ('MODERATE', 'CRITICAL')
ORDER BY reconciliation_date DESC;

-- Get total platform revenue for date range
SELECT
    DATE_TRUNC('month', reconciliation_date) AS month,
    SUM(platform_revenue) AS monthly_platform_revenue,
    SUM(total_supplier_revenue) AS monthly_supplier_revenue,
    SUM(total_campaign_spending) AS monthly_ad_spend
FROM daily_reconciliations
WHERE reconciliation_date BETWEEN '2026-01-01' AND '2026-12-31'
  AND status IN ('BALANCED', 'RESOLVED')
GROUP BY month
ORDER BY month DESC;

-- Get supplier payout history
SELECT
    s.business_name,
    wr.amount,
    wr.fee_amount,
    wr.tax_amount,
    wr.net_amount,
    wr.status,
    wr.requested_at,
    wr.completed_at
FROM withdrawal_requests wr
JOIN suppliers s ON wr.supplier_id = s.id
WHERE wr.supplier_id = 'SUPPLIER_UUID'
  AND wr.status = 'COMPLETED'
ORDER BY wr.completed_at DESC;

-- Get advertiser top-up history
SELECT
    transaction_type,
    amount,
    currency,
    payment_method,
    payment_gateway,
    description,
    processed_at
FROM wallet_transactions
WHERE wallet_id = (SELECT id FROM wallets WHERE user_id = 'ADVERTISER_UUID')
  AND transaction_type IN ('DEPOSIT', 'PENDING_DEPOSIT')
  AND status = 'COMPLETED'
ORDER BY processed_at DESC;
*/

-- ============================================================================
-- END OF WALLET SCHEMA
-- ============================================================================
