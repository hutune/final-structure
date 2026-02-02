-- ============================================================================
-- RMN-Arms Database Schema: Authentication & Authorization Module
-- ============================================================================
-- Version: 1.0
-- Last Updated: 2026-01-23
-- Description: Complete database schema for Authentication & Authorization including
--              users, roles, permissions, RBAC, sessions, OAuth, and audit logging
-- ============================================================================

-- ============================================================================
-- TABLE: users
-- Description: Core user entity with authentication credentials
-- ============================================================================

CREATE TABLE users (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Authentication
    email VARCHAR(255) NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified_at TIMESTAMPTZ,
    password_hash VARCHAR(255), -- NULL for OAuth-only accounts
    password_changed_at TIMESTAMPTZ,
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMPTZ,

    -- Profile Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(200) GENERATED ALWAYS AS (
        CASE
            WHEN first_name IS NOT NULL AND last_name IS NOT NULL
            THEN first_name || ' ' || last_name
            WHEN first_name IS NOT NULL THEN first_name
            WHEN last_name IS NOT NULL THEN last_name
            ELSE NULL
        END
    ) STORED,
    phone_number VARCHAR(20),
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    avatar_url TEXT,

    -- User Type & Status
    user_type VARCHAR(30) NOT NULL CHECK (user_type IN (
        'ADMIN', 'ADVERTISER', 'SUPPLIER', 'CONTENT_MODERATOR', 'ANALYST', 'SUPPORT'
    )),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING_VERIFICATION' CHECK (status IN (
        'PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED', 'BANNED'
    )),

    -- Account Metadata
    timezone VARCHAR(50) DEFAULT 'UTC',
    locale VARCHAR(10) DEFAULT 'en-US',
    preferred_language VARCHAR(10) DEFAULT 'en',

    -- Security Settings
    mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    mfa_secret VARCHAR(64),
    mfa_backup_codes TEXT[], -- Encrypted backup codes
    require_password_change BOOLEAN NOT NULL DEFAULT FALSE,

    -- OAuth Integration
    oauth_provider VARCHAR(50), -- 'GOOGLE', 'FACEBOOK', 'MICROSOFT', etc.
    oauth_provider_id VARCHAR(255), -- External OAuth user ID
    oauth_connected_at TIMESTAMPTZ,

    -- Login Tracking
    last_login_at TIMESTAMPTZ,
    last_login_ip INET,
    last_login_user_agent TEXT,
    failed_login_attempts INTEGER NOT NULL DEFAULT 0,
    account_locked_until TIMESTAMPTZ,

    -- Status Metadata
    suspension_reason TEXT,
    suspended_at TIMESTAMPTZ,
    suspended_by UUID REFERENCES users(id),
    deactivated_at TIMESTAMPTZ,
    deactivated_by UUID REFERENCES users(id),
    banned_at TIMESTAMPTZ,
    banned_by UUID REFERENCES users(id),
    banned_reason TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ, -- Soft delete

    -- Audit
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT users_password_or_oauth CHECK (
        password_hash IS NOT NULL OR oauth_provider IS NOT NULL
    ),
    CONSTRAINT users_oauth_provider_id_check CHECK (
        oauth_provider IS NULL OR oauth_provider_id IS NOT NULL
    ),
    CONSTRAINT users_mfa_secret_check CHECK (
        mfa_enabled = FALSE OR mfa_secret IS NOT NULL
    ),
    CONSTRAINT users_suspended_check CHECK (
        status != 'SUSPENDED' OR (suspension_reason IS NOT NULL AND suspended_at IS NOT NULL)
    ),
    CONSTRAINT users_banned_check CHECK (
        status != 'BANNED' OR (banned_reason IS NOT NULL AND banned_at IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_user_type ON users(user_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_last_login_at ON users(last_login_at DESC);
CREATE INDEX idx_users_oauth_provider ON users(oauth_provider, oauth_provider_id) WHERE oauth_provider IS NOT NULL;
CREATE INDEX idx_users_email_verified ON users(email_verified) WHERE email_verified = FALSE;
CREATE INDEX idx_users_password_reset_token ON users(password_reset_token) WHERE password_reset_token IS NOT NULL;

-- Comments
COMMENT ON TABLE users IS 'Core user entity with authentication and profile data';
COMMENT ON COLUMN users.email IS 'Unique email address - primary authentication identifier';
COMMENT ON COLUMN users.password_hash IS 'Bcrypt hashed password - NULL for OAuth-only users';
COMMENT ON COLUMN users.user_type IS 'Primary user role determining access level';
COMMENT ON COLUMN users.status IS 'Account status affecting login and access permissions';
COMMENT ON COLUMN users.mfa_enabled IS 'Multi-factor authentication requirement flag';
COMMENT ON COLUMN users.failed_login_attempts IS 'Counter for rate limiting and account locking';

-- ============================================================================
-- TABLE: roles
-- Description: System and custom roles for RBAC
-- ============================================================================

CREATE TABLE roles (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Role Information
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,

    -- Role Type
    role_type VARCHAR(20) NOT NULL DEFAULT 'CUSTOM' CHECK (role_type IN ('SYSTEM', 'CUSTOM')),

    -- Hierarchy & Scope
    parent_role_id UUID REFERENCES roles(id) ON DELETE SET NULL,
    scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (scope IN (
        'GLOBAL', 'ORGANIZATION', 'CAMPAIGN', 'CONTENT'
    )),

    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_assignable BOOLEAN NOT NULL DEFAULT TRUE,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT roles_system_not_deletable CHECK (
        role_type != 'SYSTEM' OR is_active = TRUE
    )
);

-- Indexes
CREATE INDEX idx_roles_name ON roles(name);
CREATE INDEX idx_roles_role_type ON roles(role_type);
CREATE INDEX idx_roles_is_active ON roles(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_roles_parent_role_id ON roles(parent_role_id);
CREATE INDEX idx_roles_scope ON roles(scope);

-- Comments
COMMENT ON TABLE roles IS 'System and custom roles for role-based access control';
COMMENT ON COLUMN roles.role_type IS 'SYSTEM roles are immutable, CUSTOM roles can be modified';
COMMENT ON COLUMN roles.scope IS 'Determines where role permissions can be applied';
COMMENT ON COLUMN roles.is_assignable IS 'Whether role can be assigned to users';

-- ============================================================================
-- TABLE: permissions
-- Description: Granular permission definitions
-- ============================================================================

CREATE TABLE permissions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Permission Information
    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    description TEXT,

    -- Permission Organization
    resource VARCHAR(50) NOT NULL, -- 'CAMPAIGN', 'CONTENT', 'USER', 'WALLET', etc.
    action VARCHAR(50) NOT NULL, -- 'CREATE', 'READ', 'UPDATE', 'DELETE', 'APPROVE', etc.
    scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (scope IN (
        'GLOBAL', 'ORGANIZATION', 'OWN', 'ASSIGNED'
    )),

    -- Permission Category
    category VARCHAR(50) NOT NULL, -- 'CAMPAIGN_MANAGEMENT', 'CONTENT_MODERATION', 'USER_MANAGEMENT', etc.

    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit
    created_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT permissions_unique_resource_action UNIQUE(resource, action, scope)
);

-- Indexes
CREATE INDEX idx_permissions_name ON permissions(name);
CREATE INDEX idx_permissions_resource ON permissions(resource);
CREATE INDEX idx_permissions_action ON permissions(action);
CREATE INDEX idx_permissions_category ON permissions(category);
CREATE INDEX idx_permissions_is_active ON permissions(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_permissions_resource_action ON permissions(resource, action);

-- Comments
COMMENT ON TABLE permissions IS 'Granular permission definitions for RBAC system';
COMMENT ON COLUMN permissions.name IS 'Unique permission identifier (e.g., campaign:create:global)';
COMMENT ON COLUMN permissions.resource IS 'Entity type the permission applies to';
COMMENT ON COLUMN permissions.action IS 'Operation allowed on the resource';
COMMENT ON COLUMN permissions.scope IS 'Scope of permission application';

-- ============================================================================
-- TABLE: role_permissions
-- Description: Many-to-many mapping of roles to permissions
-- ============================================================================

CREATE TABLE role_permissions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,

    -- Permission Modifiers
    is_granted BOOLEAN NOT NULL DEFAULT TRUE, -- TRUE = grant, FALSE = deny (explicit deny)
    conditions JSONB, -- Additional conditions for permission (e.g., {"budget_limit": 10000})

    -- Timestamps
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT role_permissions_unique UNIQUE(role_id, permission_id)
);

-- Indexes
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);
CREATE INDEX idx_role_permissions_granted ON role_permissions(is_granted);
CREATE INDEX idx_role_permissions_conditions ON role_permissions USING GIN(conditions);

-- Comments
COMMENT ON TABLE role_permissions IS 'Maps permissions to roles with optional conditions';
COMMENT ON COLUMN role_permissions.is_granted IS 'TRUE grants permission, FALSE explicitly denies';
COMMENT ON COLUMN role_permissions.conditions IS 'JSON conditions for conditional permissions';

-- ============================================================================
-- TABLE: user_roles
-- Description: Many-to-many mapping of users to roles
-- ============================================================================

CREATE TABLE user_roles (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,

    -- Assignment Context
    assigned_scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (assigned_scope IN (
        'GLOBAL', 'ORGANIZATION', 'CAMPAIGN', 'CONTENT'
    )),
    scope_resource_id UUID, -- ID of the scoped resource (campaign_id, organization_id, etc.)

    -- Validity Period
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMPTZ,

    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Timestamps
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMPTZ,

    -- Audit
    assigned_by UUID REFERENCES users(id),
    revoked_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT user_roles_unique UNIQUE(user_id, role_id, assigned_scope, scope_resource_id),
    CONSTRAINT user_roles_validity_check CHECK (
        valid_until IS NULL OR valid_until > valid_from
    ),
    CONSTRAINT user_roles_scope_resource_check CHECK (
        assigned_scope = 'GLOBAL' OR scope_resource_id IS NOT NULL
    ),
    CONSTRAINT user_roles_revoked_check CHECK (
        is_active = TRUE OR revoked_at IS NOT NULL
    )
);

-- Indexes
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_user_roles_is_active ON user_roles(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_user_roles_scope ON user_roles(assigned_scope, scope_resource_id);
CREATE INDEX idx_user_roles_validity ON user_roles(valid_from, valid_until);
CREATE INDEX idx_user_roles_user_active ON user_roles(user_id, is_active) WHERE is_active = TRUE;

-- Comments
COMMENT ON TABLE user_roles IS 'Assigns roles to users with optional scope and validity';
COMMENT ON COLUMN user_roles.assigned_scope IS 'Limits role to specific context (global, org, campaign, etc.)';
COMMENT ON COLUMN user_roles.scope_resource_id IS 'ID of resource when scope is not GLOBAL';
COMMENT ON COLUMN user_roles.valid_until IS 'Optional expiration for temporary role assignments';

-- ============================================================================
-- TABLE: user_permissions
-- Description: Direct permission assignments bypassing roles (exceptions)
-- ============================================================================

CREATE TABLE user_permissions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,

    -- Permission Grant/Deny
    is_granted BOOLEAN NOT NULL DEFAULT TRUE,

    -- Assignment Context
    assigned_scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (assigned_scope IN (
        'GLOBAL', 'ORGANIZATION', 'CAMPAIGN', 'CONTENT'
    )),
    scope_resource_id UUID,

    -- Conditions
    conditions JSONB,

    -- Validity Period
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMPTZ,

    -- Reason for Direct Assignment
    reason TEXT NOT NULL,

    -- Timestamps
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMPTZ,

    -- Audit
    assigned_by UUID REFERENCES users(id),
    revoked_by UUID REFERENCES users(id),

    -- Constraints
    CONSTRAINT user_permissions_unique UNIQUE(user_id, permission_id, assigned_scope, scope_resource_id),
    CONSTRAINT user_permissions_validity_check CHECK (
        valid_until IS NULL OR valid_until > valid_from
    )
);

-- Indexes
CREATE INDEX idx_user_permissions_user_id ON user_permissions(user_id);
CREATE INDEX idx_user_permissions_permission_id ON user_permissions(permission_id);
CREATE INDEX idx_user_permissions_granted ON user_permissions(is_granted);
CREATE INDEX idx_user_permissions_validity ON user_permissions(valid_from, valid_until);
CREATE INDEX idx_user_permissions_user_active ON user_permissions(user_id)
    WHERE revoked_at IS NULL AND (valid_until IS NULL OR valid_until > CURRENT_TIMESTAMP);

-- Comments
COMMENT ON TABLE user_permissions IS 'Direct permission assignments to users (overrides role permissions)';
COMMENT ON COLUMN user_permissions.reason IS 'Required justification for direct permission assignment';

-- ============================================================================
-- TABLE: user_sessions
-- Description: Active user sessions with JWT tokens
-- ============================================================================

CREATE TABLE user_sessions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Session Tokens
    access_token_jti VARCHAR(64) NOT NULL UNIQUE, -- JWT ID for access token
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE, -- Hashed refresh token

    -- Token Expiration
    access_token_expires_at TIMESTAMPTZ NOT NULL,
    refresh_token_expires_at TIMESTAMPTZ NOT NULL,

    -- Session Metadata
    session_type VARCHAR(20) NOT NULL DEFAULT 'WEB' CHECK (session_type IN (
        'WEB', 'MOBILE', 'API', 'ADMIN'
    )),
    ip_address INET NOT NULL,
    user_agent TEXT,
    device_fingerprint VARCHAR(255),

    -- Geographic Location (optional)
    country_code VARCHAR(2),
    city VARCHAR(100),

    -- Session Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    revoked_at TIMESTAMPTZ,
    revocation_reason VARCHAR(100),

    -- Activity Tracking
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_activity_ip INET,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT user_sessions_token_expiry_check CHECK (
        refresh_token_expires_at > access_token_expires_at
    ),
    CONSTRAINT user_sessions_revoked_check CHECK (
        is_active = TRUE OR revoked_at IS NOT NULL
    )
);

-- Indexes
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_access_token_jti ON user_sessions(access_token_jti);
CREATE INDEX idx_user_sessions_refresh_token_hash ON user_sessions(refresh_token_hash);
CREATE INDEX idx_user_sessions_is_active ON user_sessions(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_user_sessions_created_at ON user_sessions(created_at DESC);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(refresh_token_expires_at);
CREATE INDEX idx_user_sessions_user_active ON user_sessions(user_id, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_user_sessions_last_activity ON user_sessions(last_activity_at DESC);

-- Comments
COMMENT ON TABLE user_sessions IS 'Active user sessions with JWT access and refresh tokens';
COMMENT ON COLUMN user_sessions.access_token_jti IS 'JWT ID (jti claim) for token revocation';
COMMENT ON COLUMN user_sessions.refresh_token_hash IS 'Hashed refresh token for secure storage';
COMMENT ON COLUMN user_sessions.device_fingerprint IS 'Device identification for security tracking';

-- ============================================================================
-- TABLE: oauth_connections
-- Description: OAuth provider connections and tokens
-- ============================================================================

CREATE TABLE oauth_connections (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- OAuth Provider
    provider VARCHAR(50) NOT NULL, -- 'GOOGLE', 'FACEBOOK', 'MICROSOFT', 'APPLE'
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255),

    -- OAuth Tokens (encrypted at application layer)
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    token_expires_at TIMESTAMPTZ,

    -- Provider Profile Data
    provider_profile JSONB, -- Raw profile data from provider

    -- Scopes Granted
    scopes TEXT[],

    -- Connection Status
    is_primary BOOLEAN NOT NULL DEFAULT FALSE, -- Primary OAuth connection
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    disconnected_at TIMESTAMPTZ,

    -- Timestamps
    connected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_synced_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT oauth_connections_unique UNIQUE(provider, provider_user_id),
    CONSTRAINT oauth_connections_user_provider_unique UNIQUE(user_id, provider)
);

-- Indexes
CREATE INDEX idx_oauth_connections_user_id ON oauth_connections(user_id);
CREATE INDEX idx_oauth_connections_provider ON oauth_connections(provider);
CREATE INDEX idx_oauth_connections_provider_user_id ON oauth_connections(provider, provider_user_id);
CREATE INDEX idx_oauth_connections_is_active ON oauth_connections(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_oauth_connections_is_primary ON oauth_connections(user_id, is_primary) WHERE is_primary = TRUE;

-- Comments
COMMENT ON TABLE oauth_connections IS 'OAuth provider integrations and token storage';
COMMENT ON COLUMN oauth_connections.is_primary IS 'Primary OAuth provider for user';
COMMENT ON COLUMN oauth_connections.provider_profile IS 'Cached profile data from OAuth provider';

-- ============================================================================
-- TABLE: email_verification_tokens
-- Description: Email verification tokens for new users
-- ============================================================================

CREATE TABLE email_verification_tokens (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Token
    token VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,

    -- Expiration
    expires_at TIMESTAMPTZ NOT NULL,

    -- Usage
    verified BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT email_verification_tokens_verified_check CHECK (
        verified = FALSE OR verified_at IS NOT NULL
    )
);

-- Indexes
CREATE INDEX idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX idx_email_verification_tokens_token ON email_verification_tokens(token) WHERE verified = FALSE;
CREATE INDEX idx_email_verification_tokens_expires_at ON email_verification_tokens(expires_at);
CREATE INDEX idx_email_verification_tokens_verified ON email_verification_tokens(verified);

-- Comments
COMMENT ON TABLE email_verification_tokens IS 'One-time tokens for email verification';

-- ============================================================================
-- TABLE: audit_logs
-- Description: Comprehensive audit trail of all user actions
-- ============================================================================

CREATE TABLE audit_logs (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Actor (who performed the action)
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
    impersonator_id UUID REFERENCES users(id) ON DELETE SET NULL, -- If admin impersonating user

    -- Action Details
    action VARCHAR(100) NOT NULL, -- 'USER_LOGIN', 'CAMPAIGN_CREATE', 'CONTENT_APPROVE', etc.
    action_category VARCHAR(50) NOT NULL, -- 'AUTHENTICATION', 'AUTHORIZATION', 'DATA_CHANGE', etc.
    action_status VARCHAR(20) NOT NULL CHECK (action_status IN (
        'SUCCESS', 'FAILURE', 'PARTIAL', 'PENDING'
    )),

    -- Target Resource
    resource_type VARCHAR(50), -- 'USER', 'CAMPAIGN', 'CONTENT', 'WALLET', etc.
    resource_id UUID, -- ID of affected resource
    resource_name VARCHAR(255), -- Human-readable resource identifier

    -- Change Details
    old_values JSONB, -- Previous state (for updates)
    new_values JSONB, -- New state (for creates/updates)
    changes_summary TEXT, -- Human-readable summary of changes

    -- Request Metadata
    ip_address INET NOT NULL,
    user_agent TEXT,
    request_id UUID, -- For tracing related logs
    api_endpoint VARCHAR(255),
    http_method VARCHAR(10),

    -- Geographic Location
    country_code VARCHAR(2),
    city VARCHAR(100),

    -- Error Information
    error_message TEXT,
    error_code VARCHAR(50),
    stack_trace TEXT,

    -- Security Flags
    is_suspicious BOOLEAN NOT NULL DEFAULT FALSE,
    risk_score INTEGER CHECK (risk_score >= 0 AND risk_score <= 100),
    flagged_for_review BOOLEAN NOT NULL DEFAULT FALSE,

    -- Timestamp
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Metadata
    metadata JSONB -- Additional context-specific data
);

-- Indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_session_id ON audit_logs(session_id);
CREATE INDEX idx_audit_logs_occurred_at ON audit_logs(occurred_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_action_category ON audit_logs(action_category);
CREATE INDEX idx_audit_logs_action_status ON audit_logs(action_status);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_user_action ON audit_logs(user_id, action, occurred_at DESC);
CREATE INDEX idx_audit_logs_ip_address ON audit_logs(ip_address);
CREATE INDEX idx_audit_logs_suspicious ON audit_logs(is_suspicious) WHERE is_suspicious = TRUE;
CREATE INDEX idx_audit_logs_flagged ON audit_logs(flagged_for_review) WHERE flagged_for_review = TRUE;
CREATE INDEX idx_audit_logs_request_id ON audit_logs(request_id) WHERE request_id IS NOT NULL;

-- Comments
COMMENT ON TABLE audit_logs IS 'Comprehensive audit trail of all user actions and system events';
COMMENT ON COLUMN audit_logs.action IS 'Specific action performed (e.g., USER_LOGIN, CAMPAIGN_CREATE)';
COMMENT ON COLUMN audit_logs.action_category IS 'High-level category for reporting and filtering';
COMMENT ON COLUMN audit_logs.old_values IS 'Previous state before change (JSON)';
COMMENT ON COLUMN audit_logs.new_values IS 'New state after change (JSON)';
COMMENT ON COLUMN audit_logs.is_suspicious IS 'Flagged by security rules as potentially malicious';
COMMENT ON COLUMN audit_logs.risk_score IS 'Calculated risk score 0-100 based on behavior patterns';

-- ============================================================================
-- TABLE: security_events
-- Description: Security-specific events and incidents
-- ============================================================================

CREATE TABLE security_events (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,

    -- Event Type
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'FAILED_LOGIN', 'ACCOUNT_LOCKED', 'PASSWORD_CHANGED', 'MFA_ENABLED',
        'MFA_DISABLED', 'SESSION_HIJACK_ATTEMPT', 'SUSPICIOUS_ACTIVITY',
        'BRUTE_FORCE_ATTEMPT', 'UNAUTHORIZED_ACCESS', 'DATA_BREACH_ATTEMPT',
        'PRIVILEGE_ESCALATION', 'TOKEN_THEFT'
    )),

    -- Event Severity
    severity VARCHAR(20) NOT NULL CHECK (severity IN (
        'INFO', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    )),

    -- Event Details
    description TEXT NOT NULL,
    details JSONB,

    -- Request Metadata
    ip_address INET NOT NULL,
    user_agent TEXT,
    country_code VARCHAR(2),

    -- Response Actions
    action_taken VARCHAR(100), -- 'ACCOUNT_LOCKED', 'SESSION_TERMINATED', 'IP_BLOCKED', etc.
    automated_response BOOLEAN NOT NULL DEFAULT FALSE,

    -- Investigation
    investigated BOOLEAN NOT NULL DEFAULT FALSE,
    investigated_at TIMESTAMPTZ,
    investigated_by UUID REFERENCES users(id),
    investigation_notes TEXT,
    false_positive BOOLEAN NOT NULL DEFAULT FALSE,

    -- Timestamp
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Metadata
    metadata JSONB
);

-- Indexes
CREATE INDEX idx_security_events_user_id ON security_events(user_id);
CREATE INDEX idx_security_events_occurred_at ON security_events(occurred_at DESC);
CREATE INDEX idx_security_events_event_type ON security_events(event_type);
CREATE INDEX idx_security_events_severity ON security_events(severity);
CREATE INDEX idx_security_events_ip_address ON security_events(ip_address);
CREATE INDEX idx_security_events_investigated ON security_events(investigated) WHERE investigated = FALSE;
CREATE INDEX idx_security_events_false_positive ON security_events(false_positive);

-- Comments
COMMENT ON TABLE security_events IS 'Security incidents and suspicious activities requiring attention';
COMMENT ON COLUMN security_events.event_type IS 'Type of security event detected';
COMMENT ON COLUMN security_events.severity IS 'Risk severity level for prioritization';
COMMENT ON COLUMN security_events.automated_response IS 'Whether system took automatic action';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Active Users with Roles
CREATE OR REPLACE VIEW v_active_users_with_roles AS
SELECT
    u.id,
    u.email,
    u.full_name,
    u.user_type,
    u.status,
    u.email_verified,
    u.mfa_enabled,
    u.last_login_at,
    ARRAY_AGG(DISTINCT r.name) FILTER (WHERE r.name IS NOT NULL) AS assigned_roles,
    ARRAY_AGG(DISTINCT r.display_name) FILTER (WHERE r.display_name IS NOT NULL) AS role_display_names,
    COUNT(DISTINCT ur.role_id) AS role_count,
    COUNT(DISTINCT us.id) FILTER (WHERE us.is_active = TRUE) AS active_session_count
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = TRUE
    AND (ur.valid_until IS NULL OR ur.valid_until > CURRENT_TIMESTAMP)
LEFT JOIN roles r ON ur.role_id = r.id AND r.is_active = TRUE
LEFT JOIN user_sessions us ON u.id = us.user_id AND us.is_active = TRUE
WHERE u.status = 'ACTIVE' AND u.deleted_at IS NULL
GROUP BY u.id;

-- View: User Permissions (resolved from roles)
CREATE OR REPLACE VIEW v_user_permissions AS
SELECT DISTINCT
    ur.user_id,
    p.id AS permission_id,
    p.name AS permission_name,
    p.resource,
    p.action,
    p.scope,
    rp.is_granted,
    r.name AS granted_by_role,
    ur.assigned_scope,
    ur.scope_resource_id
FROM user_roles ur
JOIN roles r ON ur.role_id = r.id AND r.is_active = TRUE
JOIN role_permissions rp ON r.id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id AND p.is_active = TRUE
WHERE ur.is_active = TRUE
    AND (ur.valid_until IS NULL OR ur.valid_until > CURRENT_TIMESTAMP)

UNION

-- Include direct user permissions
SELECT
    up.user_id,
    p.id AS permission_id,
    p.name AS permission_name,
    p.resource,
    p.action,
    p.scope,
    up.is_granted,
    'DIRECT_ASSIGNMENT' AS granted_by_role,
    up.assigned_scope,
    up.scope_resource_id
FROM user_permissions up
JOIN permissions p ON up.permission_id = p.id AND p.is_active = TRUE
WHERE up.revoked_at IS NULL
    AND (up.valid_until IS NULL OR up.valid_until > CURRENT_TIMESTAMP);

-- View: Active Sessions Summary
CREATE OR REPLACE VIEW v_active_sessions AS
SELECT
    us.id AS session_id,
    us.user_id,
    u.email,
    u.full_name,
    us.session_type,
    us.ip_address,
    us.country_code,
    us.city,
    us.created_at AS session_started_at,
    us.last_activity_at,
    us.access_token_expires_at,
    us.refresh_token_expires_at,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - us.last_activity_at)) / 60 AS minutes_since_last_activity,
    CASE
        WHEN us.access_token_expires_at < CURRENT_TIMESTAMP THEN 'EXPIRED'
        WHEN us.refresh_token_expires_at < CURRENT_TIMESTAMP THEN 'REFRESH_EXPIRED'
        WHEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - us.last_activity_at)) > 3600 THEN 'IDLE'
        ELSE 'ACTIVE'
    END AS session_health
FROM user_sessions us
JOIN users u ON us.user_id = u.id
WHERE us.is_active = TRUE;

-- View: Security Dashboard
CREATE OR REPLACE VIEW v_security_dashboard AS
SELECT
    DATE(occurred_at) AS event_date,
    event_type,
    severity,
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_id) AS affected_users,
    COUNT(DISTINCT ip_address) AS unique_ips,
    SUM(CASE WHEN investigated = FALSE THEN 1 ELSE 0 END) AS pending_investigation,
    SUM(CASE WHEN false_positive = TRUE THEN 1 ELSE 0 END) AS false_positives
FROM security_events
WHERE occurred_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(occurred_at), event_type, severity
ORDER BY event_date DESC, event_count DESC;

-- View: Audit Log Summary
CREATE OR REPLACE VIEW v_audit_log_summary AS
SELECT
    DATE(occurred_at) AS audit_date,
    action_category,
    action_status,
    COUNT(*) AS action_count,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(CASE WHEN is_suspicious = TRUE THEN 1 ELSE 0 END) AS suspicious_actions,
    SUM(CASE WHEN flagged_for_review = TRUE THEN 1 ELSE 0 END) AS flagged_for_review
FROM audit_logs
WHERE occurred_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(occurred_at), action_category, action_status
ORDER BY audit_date DESC, action_count DESC;

-- Comments on views
COMMENT ON VIEW v_active_users_with_roles IS 'Active users with their assigned roles and session counts';
COMMENT ON VIEW v_user_permissions IS 'Resolved user permissions from roles and direct assignments';
COMMENT ON VIEW v_active_sessions IS 'Currently active user sessions with health status';
COMMENT ON VIEW v_security_dashboard IS 'Security events summary for monitoring dashboard';
COMMENT ON VIEW v_audit_log_summary IS 'Audit log summary for compliance reporting';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_auth_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Increment failed login attempts
CREATE OR REPLACE FUNCTION increment_failed_login_attempts()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.failed_login_attempts >= 5 THEN
        NEW.account_locked_until = CURRENT_TIMESTAMP + INTERVAL '30 minutes';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Reset failed login attempts on successful login
CREATE OR REPLACE FUNCTION reset_failed_login_attempts()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.last_login_at IS DISTINCT FROM OLD.last_login_at THEN
        NEW.failed_login_attempts = 0;
        NEW.account_locked_until = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Auto-expire sessions
CREATE OR REPLACE FUNCTION expire_old_sessions()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    UPDATE user_sessions
    SET is_active = FALSE,
        revoked_at = CURRENT_TIMESTAMP,
        revocation_reason = 'EXPIRED'
    WHERE is_active = TRUE
        AND refresh_token_expires_at < CURRENT_TIMESTAMP;

    GET DIAGNOSTICS expired_count = ROW_COUNT;
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Function: Check user permissions
CREATE OR REPLACE FUNCTION check_user_permission(
    p_user_id UUID,
    p_permission_name VARCHAR,
    p_resource_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    has_permission BOOLEAN;
BEGIN
    -- Check if user has the permission through roles or direct assignment
    SELECT EXISTS (
        SELECT 1
        FROM v_user_permissions vup
        WHERE vup.user_id = p_user_id
            AND vup.permission_name = p_permission_name
            AND vup.is_granted = TRUE
            AND (
                vup.assigned_scope = 'GLOBAL'
                OR (p_resource_id IS NOT NULL AND vup.scope_resource_id = p_resource_id)
            )
    ) INTO has_permission;

    RETURN has_permission;
END;
$$ LANGUAGE plpgsql;

-- Function: Get user roles
CREATE OR REPLACE FUNCTION get_user_roles(p_user_id UUID)
RETURNS TABLE (
    role_id UUID,
    role_name VARCHAR,
    role_display_name VARCHAR,
    assigned_scope VARCHAR,
    scope_resource_id UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id,
        r.name,
        r.display_name,
        ur.assigned_scope,
        ur.scope_resource_id
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = p_user_id
        AND ur.is_active = TRUE
        AND r.is_active = TRUE
        AND (ur.valid_until IS NULL OR ur.valid_until > CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at on users
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_auth_updated_at();

-- Trigger: Update updated_at on roles
CREATE TRIGGER trigger_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE FUNCTION update_auth_updated_at();

-- Trigger: Update updated_at on permissions
CREATE TRIGGER trigger_permissions_updated_at
    BEFORE UPDATE ON permissions
    FOR EACH ROW
    EXECUTE FUNCTION update_auth_updated_at();

-- Trigger: Increment failed login attempts
CREATE TRIGGER trigger_increment_failed_login
    BEFORE UPDATE ON users
    FOR EACH ROW
    WHEN (NEW.failed_login_attempts > OLD.failed_login_attempts)
    EXECUTE FUNCTION increment_failed_login_attempts();

-- Trigger: Reset failed login attempts on successful login
CREATE TRIGGER trigger_reset_failed_login
    BEFORE UPDATE ON users
    FOR EACH ROW
    WHEN (NEW.last_login_at IS DISTINCT FROM OLD.last_login_at)
    EXECUTE FUNCTION reset_failed_login_attempts();

-- ============================================================================
-- INITIAL DATA: System Roles
-- ============================================================================

INSERT INTO roles (name, display_name, description, role_type, scope, is_assignable) VALUES
('SUPER_ADMIN', 'Super Administrator', 'Full system access with all permissions', 'SYSTEM', 'GLOBAL', TRUE),
('ADMIN', 'Administrator', 'Platform administration and user management', 'SYSTEM', 'GLOBAL', TRUE),
('ADVERTISER_OWNER', 'Advertiser Owner', 'Full access to advertiser account and campaigns', 'SYSTEM', 'ORGANIZATION', TRUE),
('ADVERTISER_MANAGER', 'Advertiser Manager', 'Manage campaigns and view analytics', 'SYSTEM', 'ORGANIZATION', TRUE),
('ADVERTISER_VIEWER', 'Advertiser Viewer', 'Read-only access to campaigns and reports', 'SYSTEM', 'ORGANIZATION', TRUE),
('SUPPLIER_OWNER', 'Supplier Owner', 'Full access to supplier account and inventory', 'SYSTEM', 'ORGANIZATION', TRUE),
('SUPPLIER_MANAGER', 'Supplier Manager', 'Manage inventory and devices', 'SYSTEM', 'ORGANIZATION', TRUE),
('SUPPLIER_VIEWER', 'Supplier Viewer', 'Read-only access to inventory and revenue', 'SYSTEM', 'ORGANIZATION', TRUE),
('CONTENT_MODERATOR', 'Content Moderator', 'Review and approve/reject content submissions', 'SYSTEM', 'GLOBAL', TRUE),
('ANALYST', 'Data Analyst', 'Access to analytics and reporting features', 'SYSTEM', 'GLOBAL', TRUE),
('SUPPORT_AGENT', 'Support Agent', 'Customer support and basic troubleshooting', 'SYSTEM', 'GLOBAL', TRUE);

-- ============================================================================
-- INITIAL DATA: System Permissions
-- ============================================================================

-- User Management Permissions
INSERT INTO permissions (name, display_name, description, resource, action, scope, category, is_system) VALUES
('user:create:global', 'Create User', 'Create new user accounts', 'USER', 'CREATE', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:read:global', 'Read All Users', 'View all user information', 'USER', 'READ', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:read:own', 'Read Own User', 'View own user information', 'USER', 'READ', 'OWN', 'USER_MANAGEMENT', TRUE),
('user:update:global', 'Update Any User', 'Update any user account', 'USER', 'UPDATE', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:update:own', 'Update Own User', 'Update own user information', 'USER', 'UPDATE', 'OWN', 'USER_MANAGEMENT', TRUE),
('user:delete:global', 'Delete User', 'Delete user accounts', 'USER', 'DELETE', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:suspend:global', 'Suspend User', 'Suspend user accounts', 'USER', 'SUSPEND', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:ban:global', 'Ban User', 'Ban user accounts permanently', 'USER', 'BAN', 'GLOBAL', 'USER_MANAGEMENT', TRUE),

-- Role & Permission Management
('role:create:global', 'Create Role', 'Create new roles', 'ROLE', 'CREATE', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:read:global', 'Read Roles', 'View all roles', 'ROLE', 'READ', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:update:global', 'Update Role', 'Update existing roles', 'ROLE', 'UPDATE', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:delete:global', 'Delete Role', 'Delete custom roles', 'ROLE', 'DELETE', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:assign:global', 'Assign Role', 'Assign roles to users', 'ROLE', 'ASSIGN', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('permission:read:global', 'Read Permissions', 'View all permissions', 'PERMISSION', 'READ', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('permission:assign:global', 'Assign Permission', 'Assign permissions to roles', 'PERMISSION', 'ASSIGN', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),

-- Campaign Management Permissions
('campaign:create:global', 'Create Any Campaign', 'Create campaigns for any advertiser', 'CAMPAIGN', 'CREATE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:create:own', 'Create Own Campaign', 'Create campaigns for own account', 'CAMPAIGN', 'CREATE', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:read:global', 'Read All Campaigns', 'View all campaigns', 'CAMPAIGN', 'READ', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:read:own', 'Read Own Campaigns', 'View own campaigns', 'CAMPAIGN', 'READ', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:update:global', 'Update Any Campaign', 'Update any campaign', 'CAMPAIGN', 'UPDATE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:update:own', 'Update Own Campaign', 'Update own campaigns', 'CAMPAIGN', 'UPDATE', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:delete:global', 'Delete Any Campaign', 'Delete any campaign', 'CAMPAIGN', 'DELETE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:delete:own', 'Delete Own Campaign', 'Delete own campaigns', 'CAMPAIGN', 'DELETE', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:approve:global', 'Approve Campaign', 'Approve campaigns for activation', 'CAMPAIGN', 'APPROVE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:reject:global', 'Reject Campaign', 'Reject campaign submissions', 'CAMPAIGN', 'REJECT', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),

-- Content Management Permissions
('content:create:global', 'Create Any Content', 'Create content for any advertiser', 'CONTENT', 'CREATE', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:create:own', 'Create Own Content', 'Create own content', 'CONTENT', 'CREATE', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:read:global', 'Read All Content', 'View all content', 'CONTENT', 'READ', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:read:own', 'Read Own Content', 'View own content', 'CONTENT', 'READ', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:update:global', 'Update Any Content', 'Update any content', 'CONTENT', 'UPDATE', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:update:own', 'Update Own Content', 'Update own content', 'CONTENT', 'UPDATE', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:delete:global', 'Delete Any Content', 'Delete any content', 'CONTENT', 'DELETE', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:delete:own', 'Delete Own Content', 'Delete own content', 'CONTENT', 'DELETE', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:approve:global', 'Approve Content', 'Approve content for campaigns', 'CONTENT', 'APPROVE', 'GLOBAL', 'CONTENT_MODERATION', TRUE),
('content:reject:global', 'Reject Content', 'Reject content submissions', 'CONTENT', 'REJECT', 'GLOBAL', 'CONTENT_MODERATION', TRUE),

-- Wallet & Payment Permissions
('wallet:read:global', 'Read All Wallets', 'View all wallet balances', 'WALLET', 'READ', 'GLOBAL', 'WALLET_MANAGEMENT', TRUE),
('wallet:read:own', 'Read Own Wallet', 'View own wallet balance', 'WALLET', 'READ', 'OWN', 'WALLET_MANAGEMENT', TRUE),
('wallet:deposit:own', 'Deposit to Own Wallet', 'Add funds to own wallet', 'WALLET', 'DEPOSIT', 'OWN', 'WALLET_MANAGEMENT', TRUE),
('wallet:withdraw:own', 'Withdraw from Own Wallet', 'Withdraw funds from own wallet', 'WALLET', 'WITHDRAW', 'OWN', 'WALLET_MANAGEMENT', TRUE),
('wallet:transfer:global', 'Transfer Funds', 'Transfer funds between wallets', 'WALLET', 'TRANSFER', 'GLOBAL', 'WALLET_MANAGEMENT', TRUE),

-- Analytics & Reporting Permissions
('analytics:read:global', 'Read All Analytics', 'View all analytics and reports', 'ANALYTICS', 'READ', 'GLOBAL', 'ANALYTICS', TRUE),
('analytics:read:own', 'Read Own Analytics', 'View own performance analytics', 'ANALYTICS', 'READ', 'OWN', 'ANALYTICS', TRUE),
('analytics:export:global', 'Export All Reports', 'Export reports for any account', 'ANALYTICS', 'EXPORT', 'GLOBAL', 'ANALYTICS', TRUE),
('analytics:export:own', 'Export Own Reports', 'Export own reports', 'ANALYTICS', 'EXPORT', 'OWN', 'ANALYTICS', TRUE),

-- Device & Inventory Permissions
('device:create:global', 'Create Device', 'Register new devices', 'DEVICE', 'CREATE', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:create:own', 'Create Own Device', 'Register devices for own account', 'DEVICE', 'CREATE', 'OWN', 'DEVICE_MANAGEMENT', TRUE),
('device:read:global', 'Read All Devices', 'View all devices', 'DEVICE', 'READ', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:read:own', 'Read Own Devices', 'View own devices', 'DEVICE', 'READ', 'OWN', 'DEVICE_MANAGEMENT', TRUE),
('device:update:global', 'Update Any Device', 'Update any device', 'DEVICE', 'UPDATE', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:update:own', 'Update Own Device', 'Update own devices', 'DEVICE', 'UPDATE', 'OWN', 'DEVICE_MANAGEMENT', TRUE),
('device:delete:global', 'Delete Any Device', 'Delete any device', 'DEVICE', 'DELETE', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:delete:own', 'Delete Own Device', 'Delete own devices', 'DEVICE', 'DELETE', 'OWN', 'DEVICE_MANAGEMENT', TRUE),

-- Audit & Security Permissions
('audit:read:global', 'Read Audit Logs', 'View all audit logs', 'AUDIT', 'READ', 'GLOBAL', 'AUDIT', TRUE),
('audit:read:own', 'Read Own Audit Logs', 'View own audit logs', 'AUDIT', 'READ', 'OWN', 'AUDIT', TRUE),
('security:read:global', 'Read Security Events', 'View security events and incidents', 'SECURITY', 'READ', 'GLOBAL', 'SECURITY', TRUE),
('security:investigate:global', 'Investigate Security Events', 'Investigate security incidents', 'SECURITY', 'INVESTIGATE', 'GLOBAL', 'SECURITY', TRUE);

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get active users with their roles
SELECT * FROM v_active_users_with_roles
ORDER BY last_login_at DESC NULLS LAST;

-- Check if user has specific permission
SELECT check_user_permission(
    'USER_UUID',
    'campaign:create:own',
    NULL
);

-- Get all permissions for a user
SELECT * FROM v_user_permissions
WHERE user_id = 'USER_UUID'
ORDER BY resource, action;

-- Get active sessions for a user
SELECT * FROM v_active_sessions
WHERE user_id = 'USER_UUID'
ORDER BY session_started_at DESC;

-- Get recent security events
SELECT * FROM security_events
WHERE severity IN ('HIGH', 'CRITICAL')
    AND occurred_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
ORDER BY occurred_at DESC;

-- Get audit trail for specific resource
SELECT
    al.action,
    al.action_status,
    u.email AS performed_by,
    al.occurred_at,
    al.old_values,
    al.new_values,
    al.changes_summary
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.resource_type = 'CAMPAIGN'
    AND al.resource_id = 'CAMPAIGN_UUID'
ORDER BY al.occurred_at DESC;

-- Find users with failed login attempts
SELECT
    email,
    failed_login_attempts,
    account_locked_until,
    last_login_at
FROM users
WHERE failed_login_attempts > 0
    AND status = 'ACTIVE'
ORDER BY failed_login_attempts DESC;

-- Get security dashboard summary
SELECT * FROM v_security_dashboard
WHERE event_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY event_date DESC, severity DESC;

-- Expire old sessions (run as scheduled job)
SELECT expire_old_sessions();
*/

-- ============================================================================
-- END OF AUTHENTICATION & AUTHORIZATION SCHEMA
-- ============================================================================
