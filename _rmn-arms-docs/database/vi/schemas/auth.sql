-- ============================================================================
-- RMN-Arms Database Schema: Mô-đun Xác thực & Phân quyền
-- ============================================================================
-- Phiên bản: 1.0
-- Cập nhật lần cuối: 2026-01-23
-- Mô tả: Schema cơ sở dữ liệu đầy đủ cho Xác thực & Phân quyền bao gồm
--              người dùng, vai trò, quyền hạn, RBAC, phiên, OAuth, và ghi nhật ký kiểm toán
-- ============================================================================

-- ============================================================================
-- BẢNG: users
-- Mô tả: Thực thể người dùng chính với thông tin xác thực
-- ============================================================================

CREATE TABLE users (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Xác thực
    email VARCHAR(255) NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified_at TIMESTAMPTZ,
    password_hash VARCHAR(255), -- NULL cho tài khoản chỉ OAuth
    password_changed_at TIMESTAMPTZ,
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMPTZ,

    -- Thông tin hồ sơ
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

    -- Loại và Trạng thái người dùng
    user_type VARCHAR(30) NOT NULL CHECK (user_type IN (
        'ADMIN', 'ADVERTISER', 'SUPPLIER', 'CONTENT_MODERATOR', 'ANALYST', 'SUPPORT'
    )),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING_VERIFICATION' CHECK (status IN (
        'PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED', 'BANNED'
    )),

    -- Metadata tài khoản
    timezone VARCHAR(50) DEFAULT 'UTC',
    locale VARCHAR(10) DEFAULT 'en-US',
    preferred_language VARCHAR(10) DEFAULT 'en',

    -- Cài đặt bảo mật
    mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    mfa_secret VARCHAR(64),
    mfa_backup_codes TEXT[], -- Mã dự phòng đã mã hóa
    require_password_change BOOLEAN NOT NULL DEFAULT FALSE,

    -- Tích hợp OAuth
    oauth_provider VARCHAR(50), -- 'GOOGLE', 'FACEBOOK', 'MICROSOFT', v.v.
    oauth_provider_id VARCHAR(255), -- ID người dùng OAuth bên ngoài
    oauth_connected_at TIMESTAMPTZ,

    -- Theo dõi đăng nhập
    last_login_at TIMESTAMPTZ,
    last_login_ip INET,
    last_login_user_agent TEXT,
    failed_login_attempts INTEGER NOT NULL DEFAULT 0,
    account_locked_until TIMESTAMPTZ,

    -- Metadata trạng thái
    suspension_reason TEXT,
    suspended_at TIMESTAMPTZ,
    suspended_by UUID REFERENCES users(id),
    deactivated_at TIMESTAMPTZ,
    deactivated_by UUID REFERENCES users(id),
    banned_at TIMESTAMPTZ,
    banned_by UUID REFERENCES users(id),
    banned_reason TEXT,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ, -- Xóa mềm

    -- Kiểm toán
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Ràng buộc
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

-- Chỉ mục
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_user_type ON users(user_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_last_login_at ON users(last_login_at DESC);
CREATE INDEX idx_users_oauth_provider ON users(oauth_provider, oauth_provider_id) WHERE oauth_provider IS NOT NULL;
CREATE INDEX idx_users_email_verified ON users(email_verified) WHERE email_verified = FALSE;
CREATE INDEX idx_users_password_reset_token ON users(password_reset_token) WHERE password_reset_token IS NOT NULL;

-- Chú thích
COMMENT ON TABLE users IS 'Thực thể người dùng chính với dữ liệu xác thực và hồ sơ';
COMMENT ON COLUMN users.email IS 'Địa chỉ email duy nhất - định danh xác thực chính';
COMMENT ON COLUMN users.password_hash IS 'Mật khẩu đã băm Bcrypt - NULL cho người dùng chỉ OAuth';
COMMENT ON COLUMN users.user_type IS 'Vai trò người dùng chính xác định cấp độ truy cập';
COMMENT ON COLUMN users.status IS 'Trạng thái tài khoản ảnh hưởng đến quyền đăng nhập và truy cập';
COMMENT ON COLUMN users.mfa_enabled IS 'Cờ yêu cầu xác thực đa yếu tố';
COMMENT ON COLUMN users.failed_login_attempts IS 'Bộ đếm để giới hạn tốc độ và khóa tài khoản';

-- ============================================================================
-- BẢNG: roles
-- Mô tả: Vai trò hệ thống và tùy chỉnh cho RBAC
-- ============================================================================

CREATE TABLE roles (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Thông tin vai trò
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,

    -- Loại vai trò
    role_type VARCHAR(20) NOT NULL DEFAULT 'CUSTOM' CHECK (role_type IN ('SYSTEM', 'CUSTOM')),

    -- Phân cấp & Phạm vi
    parent_role_id UUID REFERENCES roles(id) ON DELETE SET NULL,
    scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (scope IN (
        'GLOBAL', 'ORGANIZATION', 'CAMPAIGN', 'CONTENT'
    )),

    -- Trạng thái
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_assignable BOOLEAN NOT NULL DEFAULT TRUE,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Kiểm toán
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT roles_system_not_deletable CHECK (
        role_type != 'SYSTEM' OR is_active = TRUE
    )
);

-- Chỉ mục
CREATE INDEX idx_roles_name ON roles(name);
CREATE INDEX idx_roles_role_type ON roles(role_type);
CREATE INDEX idx_roles_is_active ON roles(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_roles_parent_role_id ON roles(parent_role_id);
CREATE INDEX idx_roles_scope ON roles(scope);

-- Chú thích
COMMENT ON TABLE roles IS 'Vai trò hệ thống và tùy chỉnh cho kiểm soát truy cập dựa trên vai trò';
COMMENT ON COLUMN roles.role_type IS 'Vai trò SYSTEM không thể thay đổi, vai trò CUSTOM có thể sửa đổi';
COMMENT ON COLUMN roles.scope IS 'Xác định nơi quyền vai trò có thể được áp dụng';
COMMENT ON COLUMN roles.is_assignable IS 'Vai trò có thể được gán cho người dùng hay không';

-- ============================================================================
-- BẢNG: permissions
-- Mô tả: Định nghĩa quyền chi tiết
-- ============================================================================

CREATE TABLE permissions (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Thông tin quyền
    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    description TEXT,

    -- Tổ chức quyền
    resource VARCHAR(50) NOT NULL, -- 'CAMPAIGN', 'CONTENT', 'USER', 'WALLET', v.v.
    action VARCHAR(50) NOT NULL, -- 'CREATE', 'READ', 'UPDATE', 'DELETE', 'APPROVE', v.v.
    scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (scope IN (
        'GLOBAL', 'ORGANIZATION', 'OWN', 'ASSIGNED'
    )),

    -- Danh mục quyền
    category VARCHAR(50) NOT NULL, -- 'CAMPAIGN_MANAGEMENT', 'CONTENT_MODERATION', 'USER_MANAGEMENT', v.v.

    -- Trạng thái
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Kiểm toán
    created_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT permissions_unique_resource_action UNIQUE(resource, action, scope)
);

-- Chỉ mục
CREATE INDEX idx_permissions_name ON permissions(name);
CREATE INDEX idx_permissions_resource ON permissions(resource);
CREATE INDEX idx_permissions_action ON permissions(action);
CREATE INDEX idx_permissions_category ON permissions(category);
CREATE INDEX idx_permissions_is_active ON permissions(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_permissions_resource_action ON permissions(resource, action);

-- Chú thích
COMMENT ON TABLE permissions IS 'Định nghĩa quyền chi tiết cho hệ thống RBAC';
COMMENT ON COLUMN permissions.name IS 'Định danh quyền duy nhất (ví dụ: campaign:create:global)';
COMMENT ON COLUMN permissions.resource IS 'Loại thực thể mà quyền áp dụng';
COMMENT ON COLUMN permissions.action IS 'Thao tác được phép trên tài nguyên';
COMMENT ON COLUMN permissions.scope IS 'Phạm vi áp dụng quyền';

-- ============================================================================
-- BẢNG: role_permissions
-- Mô tả: Ánh xạ nhiều-nhiều vai trò với quyền
-- ============================================================================

CREATE TABLE role_permissions (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,

    -- Bộ chỉnh sửa quyền
    is_granted BOOLEAN NOT NULL DEFAULT TRUE, -- TRUE = cấp, FALSE = từ chối (từ chối rõ ràng)
    conditions JSONB, -- Điều kiện bổ sung cho quyền (ví dụ: {"budget_limit": 10000})

    -- Dấu thời gian
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT role_permissions_unique UNIQUE(role_id, permission_id)
);

-- Chỉ mục
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);
CREATE INDEX idx_role_permissions_granted ON role_permissions(is_granted);
CREATE INDEX idx_role_permissions_conditions ON role_permissions USING GIN(conditions);

-- Chú thích
COMMENT ON TABLE role_permissions IS 'Ánh xạ quyền với vai trò với điều kiện tùy chọn';
COMMENT ON COLUMN role_permissions.is_granted IS 'TRUE cấp quyền, FALSE từ chối rõ ràng';
COMMENT ON COLUMN role_permissions.conditions IS 'Điều kiện JSON cho quyền có điều kiện';

-- ============================================================================
-- BẢNG: user_roles
-- Mô tả: Ánh xạ nhiều-nhiều người dùng với vai trò
-- ============================================================================

CREATE TABLE user_roles (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,

    -- Ngữ cảnh gán
    assigned_scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (assigned_scope IN (
        'GLOBAL', 'ORGANIZATION', 'CAMPAIGN', 'CONTENT'
    )),
    scope_resource_id UUID, -- ID của tài nguyên có phạm vi (campaign_id, organization_id, v.v.)

    -- Thời gian hiệu lực
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMPTZ,

    -- Trạng thái
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Dấu thời gian
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMPTZ,

    -- Kiểm toán
    assigned_by UUID REFERENCES users(id),
    revoked_by UUID REFERENCES users(id),

    -- Ràng buộc
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

-- Chỉ mục
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_user_roles_is_active ON user_roles(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_user_roles_scope ON user_roles(assigned_scope, scope_resource_id);
CREATE INDEX idx_user_roles_validity ON user_roles(valid_from, valid_until);
CREATE INDEX idx_user_roles_user_active ON user_roles(user_id, is_active) WHERE is_active = TRUE;

-- Chú thích
COMMENT ON TABLE user_roles IS 'Gán vai trò cho người dùng với phạm vi và hiệu lực tùy chọn';
COMMENT ON COLUMN user_roles.assigned_scope IS 'Giới hạn vai trò cho ngữ cảnh cụ thể (toàn cục, tổ chức, chiến dịch, v.v.)';
COMMENT ON COLUMN user_roles.scope_resource_id IS 'ID của tài nguyên khi phạm vi không phải GLOBAL';
COMMENT ON COLUMN user_roles.valid_until IS 'Hết hạn tùy chọn cho gán vai trò tạm thời';

-- ============================================================================
-- BẢNG: user_permissions
-- Mô tả: Gán quyền trực tiếp bỏ qua vai trò (ngoại lệ)
-- ============================================================================

CREATE TABLE user_permissions (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,

    -- Cấp/Từ chối quyền
    is_granted BOOLEAN NOT NULL DEFAULT TRUE,

    -- Ngữ cảnh gán
    assigned_scope VARCHAR(30) NOT NULL DEFAULT 'GLOBAL' CHECK (assigned_scope IN (
        'GLOBAL', 'ORGANIZATION', 'CAMPAIGN', 'CONTENT'
    )),
    scope_resource_id UUID,

    -- Điều kiện
    conditions JSONB,

    -- Thời gian hiệu lực
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMPTZ,

    -- Lý do gán trực tiếp
    reason TEXT NOT NULL,

    -- Dấu thời gian
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMPTZ,

    -- Kiểm toán
    assigned_by UUID REFERENCES users(id),
    revoked_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT user_permissions_unique UNIQUE(user_id, permission_id, assigned_scope, scope_resource_id),
    CONSTRAINT user_permissions_validity_check CHECK (
        valid_until IS NULL OR valid_until > valid_from
    )
);

-- Chỉ mục
CREATE INDEX idx_user_permissions_user_id ON user_permissions(user_id);
CREATE INDEX idx_user_permissions_permission_id ON user_permissions(permission_id);
CREATE INDEX idx_user_permissions_granted ON user_permissions(is_granted);
CREATE INDEX idx_user_permissions_validity ON user_permissions(valid_from, valid_until);
CREATE INDEX idx_user_permissions_user_active ON user_permissions(user_id)
    WHERE revoked_at IS NULL AND (valid_until IS NULL OR valid_until > CURRENT_TIMESTAMP);

-- Chú thích
COMMENT ON TABLE user_permissions IS 'Gán quyền trực tiếp cho người dùng (ghi đè quyền vai trò)';
COMMENT ON COLUMN user_permissions.reason IS 'Lý do bắt buộc cho việc gán quyền trực tiếp';

-- ============================================================================
-- BẢNG: user_sessions
-- Mô tả: Phiên người dùng hoạt động với token JWT
-- ============================================================================

CREATE TABLE user_sessions (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Token phiên
    access_token_jti VARCHAR(64) NOT NULL UNIQUE, -- JWT ID cho access token
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE, -- Refresh token đã băm

    -- Hết hạn token
    access_token_expires_at TIMESTAMPTZ NOT NULL,
    refresh_token_expires_at TIMESTAMPTZ NOT NULL,

    -- Metadata phiên
    session_type VARCHAR(20) NOT NULL DEFAULT 'WEB' CHECK (session_type IN (
        'WEB', 'MOBILE', 'API', 'ADMIN'
    )),
    ip_address INET NOT NULL,
    user_agent TEXT,
    device_fingerprint VARCHAR(255),

    -- Vị trí địa lý (tùy chọn)
    country_code VARCHAR(2),
    city VARCHAR(100),

    -- Trạng thái phiên
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    revoked_at TIMESTAMPTZ,
    revocation_reason VARCHAR(100),

    -- Theo dõi hoạt động
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_activity_ip INET,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT user_sessions_token_expiry_check CHECK (
        refresh_token_expires_at > access_token_expires_at
    ),
    CONSTRAINT user_sessions_revoked_check CHECK (
        is_active = TRUE OR revoked_at IS NOT NULL
    )
);

-- Chỉ mục
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_access_token_jti ON user_sessions(access_token_jti);
CREATE INDEX idx_user_sessions_refresh_token_hash ON user_sessions(refresh_token_hash);
CREATE INDEX idx_user_sessions_is_active ON user_sessions(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_user_sessions_created_at ON user_sessions(created_at DESC);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(refresh_token_expires_at);
CREATE INDEX idx_user_sessions_user_active ON user_sessions(user_id, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_user_sessions_last_activity ON user_sessions(last_activity_at DESC);

-- Chú thích
COMMENT ON TABLE user_sessions IS 'Phiên người dùng hoạt động với JWT access và refresh token';
COMMENT ON COLUMN user_sessions.access_token_jti IS 'JWT ID (jti claim) để thu hồi token';
COMMENT ON COLUMN user_sessions.refresh_token_hash IS 'Refresh token đã băm để lưu trữ an toàn';
COMMENT ON COLUMN user_sessions.device_fingerprint IS 'Định danh thiết bị để theo dõi bảo mật';

-- ============================================================================
-- BẢNG: oauth_connections
-- Mô tả: Kết nối nhà cung cấp OAuth và token
-- ============================================================================

CREATE TABLE oauth_connections (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Nhà cung cấp OAuth
    provider VARCHAR(50) NOT NULL, -- 'GOOGLE', 'FACEBOOK', 'MICROSOFT', 'APPLE'
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255),

    -- Token OAuth (mã hóa ở tầng ứng dụng)
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    token_expires_at TIMESTAMPTZ,

    -- Dữ liệu hồ sơ nhà cung cấp
    provider_profile JSONB, -- Dữ liệu hồ sơ thô từ nhà cung cấp

    -- Phạm vi được cấp
    scopes TEXT[],

    -- Trạng thái kết nối
    is_primary BOOLEAN NOT NULL DEFAULT FALSE, -- Kết nối OAuth chính
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    disconnected_at TIMESTAMPTZ,

    -- Dấu thời gian
    connected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_synced_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT oauth_connections_unique UNIQUE(provider, provider_user_id),
    CONSTRAINT oauth_connections_user_provider_unique UNIQUE(user_id, provider)
);

-- Chỉ mục
CREATE INDEX idx_oauth_connections_user_id ON oauth_connections(user_id);
CREATE INDEX idx_oauth_connections_provider ON oauth_connections(provider);
CREATE INDEX idx_oauth_connections_provider_user_id ON oauth_connections(provider, provider_user_id);
CREATE INDEX idx_oauth_connections_is_active ON oauth_connections(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_oauth_connections_is_primary ON oauth_connections(user_id, is_primary) WHERE is_primary = TRUE;

-- Chú thích
COMMENT ON TABLE oauth_connections IS 'Tích hợp nhà cung cấp OAuth và lưu trữ token';
COMMENT ON COLUMN oauth_connections.is_primary IS 'Nhà cung cấp OAuth chính cho người dùng';
COMMENT ON COLUMN oauth_connections.provider_profile IS 'Dữ liệu hồ sơ đã lưu từ nhà cung cấp OAuth';

-- ============================================================================
-- BẢNG: email_verification_tokens
-- Mô tả: Token xác minh email cho người dùng mới
-- ============================================================================

CREATE TABLE email_verification_tokens (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Token
    token VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,

    -- Hết hạn
    expires_at TIMESTAMPTZ NOT NULL,

    -- Sử dụng
    verified BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at TIMESTAMPTZ,

    -- Dấu thời gian
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT email_verification_tokens_verified_check CHECK (
        verified = FALSE OR verified_at IS NOT NULL
    )
);

-- Chỉ mục
CREATE INDEX idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX idx_email_verification_tokens_token ON email_verification_tokens(token) WHERE verified = FALSE;
CREATE INDEX idx_email_verification_tokens_expires_at ON email_verification_tokens(expires_at);
CREATE INDEX idx_email_verification_tokens_verified ON email_verification_tokens(verified);

-- Chú thích
COMMENT ON TABLE email_verification_tokens IS 'Token một lần để xác minh email';

-- ============================================================================
-- BẢNG: audit_logs
-- Mô tả: Nhật ký kiểm toán toàn diện của tất cả hành động người dùng
-- ============================================================================

CREATE TABLE audit_logs (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Người thực hiện (ai thực hiện hành động)
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
    impersonator_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Nếu quản trị viên mạo danh người dùng

    -- Chi tiết hành động
    action VARCHAR(100) NOT NULL, -- 'USER_LOGIN', 'CAMPAIGN_CREATE', 'CONTENT_APPROVE', v.v.
    action_category VARCHAR(50) NOT NULL, -- 'AUTHENTICATION', 'AUTHORIZATION', 'DATA_CHANGE', v.v.
    action_status VARCHAR(20) NOT NULL CHECK (action_status IN (
        'SUCCESS', 'FAILURE', 'PARTIAL', 'PENDING'
    )),

    -- Tài nguyên mục tiêu
    resource_type VARCHAR(50), -- 'USER', 'CAMPAIGN', 'CONTENT', 'WALLET', v.v.
    resource_id UUID, -- ID của tài nguyên bị ảnh hưởng
    resource_name VARCHAR(255), -- Định danh tài nguyên có thể đọc

    -- Chi tiết thay đổi
    old_values JSONB, -- Trạng thái trước (cho cập nhật)
    new_values JSONB, -- Trạng thái mới (cho tạo/cập nhật)
    changes_summary TEXT, -- Tóm tắt thay đổi có thể đọc

    -- Metadata yêu cầu
    ip_address INET NOT NULL,
    user_agent TEXT,
    request_id UUID, -- Để truy vết nhật ký liên quan
    api_endpoint VARCHAR(255),
    http_method VARCHAR(10),

    -- Vị trí địa lý
    country_code VARCHAR(2),
    city VARCHAR(100),

    -- Thông tin lỗi
    error_message TEXT,
    error_code VARCHAR(50),
    stack_trace TEXT,

    -- Cờ bảo mật
    is_suspicious BOOLEAN NOT NULL DEFAULT FALSE,
    risk_score INTEGER CHECK (risk_score >= 0 AND risk_score <= 100),
    flagged_for_review BOOLEAN NOT NULL DEFAULT FALSE,

    -- Dấu thời gian
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Metadata
    metadata JSONB -- Dữ liệu ngữ cảnh bổ sung
);

-- Chỉ mục
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

-- Chú thích
COMMENT ON TABLE audit_logs IS 'Nhật ký kiểm toán toàn diện của tất cả hành động người dùng và sự kiện hệ thống';
COMMENT ON COLUMN audit_logs.action IS 'Hành động cụ thể được thực hiện (ví dụ: USER_LOGIN, CAMPAIGN_CREATE)';
COMMENT ON COLUMN audit_logs.action_category IS 'Danh mục cấp cao để báo cáo và lọc';
COMMENT ON COLUMN audit_logs.old_values IS 'Trạng thái trước khi thay đổi (JSON)';
COMMENT ON COLUMN audit_logs.new_values IS 'Trạng thái mới sau khi thay đổi (JSON)';
COMMENT ON COLUMN audit_logs.is_suspicious IS 'Được đánh dấu bởi quy tắc bảo mật là có khả năng độc hại';
COMMENT ON COLUMN audit_logs.risk_score IS 'Điểm rủi ro tính toán 0-100 dựa trên mẫu hành vi';

-- ============================================================================
-- BẢNG: security_events
-- Mô tả: Sự kiện và sự cố bảo mật cụ thể
-- ============================================================================

CREATE TABLE security_events (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,

    -- Loại sự kiện
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'FAILED_LOGIN', 'ACCOUNT_LOCKED', 'PASSWORD_CHANGED', 'MFA_ENABLED',
        'MFA_DISABLED', 'SESSION_HIJACK_ATTEMPT', 'SUSPICIOUS_ACTIVITY',
        'BRUTE_FORCE_ATTEMPT', 'UNAUTHORIZED_ACCESS', 'DATA_BREACH_ATTEMPT',
        'PRIVILEGE_ESCALATION', 'TOKEN_THEFT'
    )),

    -- Mức độ nghiêm trọng sự kiện
    severity VARCHAR(20) NOT NULL CHECK (severity IN (
        'INFO', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    )),

    -- Chi tiết sự kiện
    description TEXT NOT NULL,
    details JSONB,

    -- Metadata yêu cầu
    ip_address INET NOT NULL,
    user_agent TEXT,
    country_code VARCHAR(2),

    -- Hành động phản hồi
    action_taken VARCHAR(100), -- 'ACCOUNT_LOCKED', 'SESSION_TERMINATED', 'IP_BLOCKED', v.v.
    automated_response BOOLEAN NOT NULL DEFAULT FALSE,

    -- Điều tra
    investigated BOOLEAN NOT NULL DEFAULT FALSE,
    investigated_at TIMESTAMPTZ,
    investigated_by UUID REFERENCES users(id),
    investigation_notes TEXT,
    false_positive BOOLEAN NOT NULL DEFAULT FALSE,

    -- Dấu thời gian
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Metadata
    metadata JSONB
);

-- Chỉ mục
CREATE INDEX idx_security_events_user_id ON security_events(user_id);
CREATE INDEX idx_security_events_occurred_at ON security_events(occurred_at DESC);
CREATE INDEX idx_security_events_event_type ON security_events(event_type);
CREATE INDEX idx_security_events_severity ON security_events(severity);
CREATE INDEX idx_security_events_ip_address ON security_events(ip_address);
CREATE INDEX idx_security_events_investigated ON security_events(investigated) WHERE investigated = FALSE;
CREATE INDEX idx_security_events_false_positive ON security_events(false_positive);

-- Chú thích
COMMENT ON TABLE security_events IS 'Sự cố bảo mật và hoạt động đáng ngờ cần chú ý';
COMMENT ON COLUMN security_events.event_type IS 'Loại sự kiện bảo mật được phát hiện';
COMMENT ON COLUMN security_events.severity IS 'Mức độ nghiêm trọng rủi ro để ưu tiên';
COMMENT ON COLUMN security_events.automated_response IS 'Hệ thống có thực hiện hành động tự động hay không';

-- ============================================================================
-- VIEWS - CHẾ ĐỘ XEM
-- ============================================================================

-- View: Người dùng hoạt động với vai trò
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

-- View: Quyền người dùng (giải quyết từ vai trò)
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

-- Bao gồm quyền người dùng trực tiếp
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

-- View: Tóm tắt phiên hoạt động
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

-- View: Bảng điều khiển bảo mật
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

-- View: Tóm tắt nhật ký kiểm toán
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

-- Chú thích trên views
COMMENT ON VIEW v_active_users_with_roles IS 'Người dùng hoạt động với vai trò được gán và số lượng phiên';
COMMENT ON VIEW v_user_permissions IS 'Quyền người dùng đã giải quyết từ vai trò và gán trực tiếp';
COMMENT ON VIEW v_active_sessions IS 'Phiên người dùng hiện đang hoạt động với trạng thái sức khỏe';
COMMENT ON VIEW v_security_dashboard IS 'Tóm tắt sự kiện bảo mật cho bảng điều khiển giám sát';
COMMENT ON VIEW v_audit_log_summary IS 'Tóm tắt nhật ký kiểm toán để báo cáo tuân thủ';

-- ============================================================================
-- FUNCTIONS - HÀM
-- ============================================================================

-- Hàm: Cập nhật dấu thời gian updated_at
CREATE OR REPLACE FUNCTION update_auth_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Hàm: Tăng số lần đăng nhập thất bại
CREATE OR REPLACE FUNCTION increment_failed_login_attempts()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.failed_login_attempts >= 5 THEN
        NEW.account_locked_until = CURRENT_TIMESTAMP + INTERVAL '30 minutes';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Hàm: Đặt lại số lần đăng nhập thất bại khi đăng nhập thành công
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

-- Hàm: Tự động hết hạn phiên cũ
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

-- Hàm: Kiểm tra quyền người dùng
CREATE OR REPLACE FUNCTION check_user_permission(
    p_user_id UUID,
    p_permission_name VARCHAR,
    p_resource_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    has_permission BOOLEAN;
BEGIN
    -- Kiểm tra người dùng có quyền thông qua vai trò hoặc gán trực tiếp
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

-- Hàm: Lấy vai trò người dùng
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
-- TRIGGERS - TRIGGER
-- ============================================================================

-- Trigger: Cập nhật updated_at trên users
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_auth_updated_at();

-- Trigger: Cập nhật updated_at trên roles
CREATE TRIGGER trigger_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE FUNCTION update_auth_updated_at();

-- Trigger: Cập nhật updated_at trên permissions
CREATE TRIGGER trigger_permissions_updated_at
    BEFORE UPDATE ON permissions
    FOR EACH ROW
    EXECUTE FUNCTION update_auth_updated_at();

-- Trigger: Tăng số lần đăng nhập thất bại
CREATE TRIGGER trigger_increment_failed_login
    BEFORE UPDATE ON users
    FOR EACH ROW
    WHEN (NEW.failed_login_attempts > OLD.failed_login_attempts)
    EXECUTE FUNCTION increment_failed_login_attempts();

-- Trigger: Đặt lại số lần đăng nhập thất bại khi đăng nhập thành công
CREATE TRIGGER trigger_reset_failed_login
    BEFORE UPDATE ON users
    FOR EACH ROW
    WHEN (NEW.last_login_at IS DISTINCT FROM OLD.last_login_at)
    EXECUTE FUNCTION reset_failed_login_attempts();

-- ============================================================================
-- INITIAL DATA - DỮ LIỆU BAN ĐẦU: Vai trò hệ thống
-- ============================================================================

INSERT INTO roles (name, display_name, description, role_type, scope, is_assignable) VALUES
('SUPER_ADMIN', 'Quản trị viên cấp cao', 'Quyền truy cập hệ thống đầy đủ với tất cả quyền', 'SYSTEM', 'GLOBAL', TRUE),
('ADMIN', 'Quản trị viên', 'Quản trị nền tảng và quản lý người dùng', 'SYSTEM', 'GLOBAL', TRUE),
('ADVERTISER_OWNER', 'Chủ sở hữu nhà quảng cáo', 'Quyền truy cập đầy đủ vào tài khoản nhà quảng cáo và chiến dịch', 'SYSTEM', 'ORGANIZATION', TRUE),
('ADVERTISER_MANAGER', 'Quản lý nhà quảng cáo', 'Quản lý chiến dịch và xem phân tích', 'SYSTEM', 'ORGANIZATION', TRUE),
('ADVERTISER_VIEWER', 'Người xem nhà quảng cáo', 'Quyền chỉ đọc chiến dịch và báo cáo', 'SYSTEM', 'ORGANIZATION', TRUE),
('SUPPLIER_OWNER', 'Chủ sở hữu nhà cung cấp', 'Quyền truy cập đầy đủ vào tài khoản nhà cung cấp và kho', 'SYSTEM', 'ORGANIZATION', TRUE),
('SUPPLIER_MANAGER', 'Quản lý nhà cung cấp', 'Quản lý kho và thiết bị', 'SYSTEM', 'ORGANIZATION', TRUE),
('SUPPLIER_VIEWER', 'Người xem nhà cung cấp', 'Quyền chỉ đọc kho và doanh thu', 'SYSTEM', 'ORGANIZATION', TRUE),
('CONTENT_MODERATOR', 'Người kiểm duyệt nội dung', 'Xem xét và phê duyệt/từ chối nội dung gửi', 'SYSTEM', 'GLOBAL', TRUE),
('ANALYST', 'Nhà phân tích dữ liệu', 'Truy cập tính năng phân tích và báo cáo', 'SYSTEM', 'GLOBAL', TRUE),
('SUPPORT_AGENT', 'Đại lý hỗ trợ', 'Hỗ trợ khách hàng và khắc phục sự cố cơ bản', 'SYSTEM', 'GLOBAL', TRUE);

-- ============================================================================
-- INITIAL DATA - DỮ LIỆU BAN ĐẦU: Quyền hệ thống
-- ============================================================================

-- Quyền quản lý người dùng
INSERT INTO permissions (name, display_name, description, resource, action, scope, category, is_system) VALUES
('user:create:global', 'Tạo người dùng', 'Tạo tài khoản người dùng mới', 'USER', 'CREATE', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:read:global', 'Đọc tất cả người dùng', 'Xem tất cả thông tin người dùng', 'USER', 'READ', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:read:own', 'Đọc người dùng riêng', 'Xem thông tin người dùng riêng', 'USER', 'READ', 'OWN', 'USER_MANAGEMENT', TRUE),
('user:update:global', 'Cập nhật bất kỳ người dùng', 'Cập nhật bất kỳ tài khoản người dùng', 'USER', 'UPDATE', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:update:own', 'Cập nhật người dùng riêng', 'Cập nhật thông tin người dùng riêng', 'USER', 'UPDATE', 'OWN', 'USER_MANAGEMENT', TRUE),
('user:delete:global', 'Xóa người dùng', 'Xóa tài khoản người dùng', 'USER', 'DELETE', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:suspend:global', 'Đình chỉ người dùng', 'Đình chỉ tài khoản người dùng', 'USER', 'SUSPEND', 'GLOBAL', 'USER_MANAGEMENT', TRUE),
('user:ban:global', 'Cấm người dùng', 'Cấm tài khoản người dùng vĩnh viễn', 'USER', 'BAN', 'GLOBAL', 'USER_MANAGEMENT', TRUE),

-- Quản lý vai trò & quyền
('role:create:global', 'Tạo vai trò', 'Tạo vai trò mới', 'ROLE', 'CREATE', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:read:global', 'Đọc vai trò', 'Xem tất cả vai trò', 'ROLE', 'READ', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:update:global', 'Cập nhật vai trò', 'Cập nhật vai trò hiện có', 'ROLE', 'UPDATE', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:delete:global', 'Xóa vai trò', 'Xóa vai trò tùy chỉnh', 'ROLE', 'DELETE', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('role:assign:global', 'Gán vai trò', 'Gán vai trò cho người dùng', 'ROLE', 'ASSIGN', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('permission:read:global', 'Đọc quyền', 'Xem tất cả quyền', 'PERMISSION', 'READ', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),
('permission:assign:global', 'Gán quyền', 'Gán quyền cho vai trò', 'PERMISSION', 'ASSIGN', 'GLOBAL', 'RBAC_MANAGEMENT', TRUE),

-- Quyền quản lý chiến dịch
('campaign:create:global', 'Tạo bất kỳ chiến dịch', 'Tạo chiến dịch cho bất kỳ nhà quảng cáo', 'CAMPAIGN', 'CREATE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:create:own', 'Tạo chiến dịch riêng', 'Tạo chiến dịch cho tài khoản riêng', 'CAMPAIGN', 'CREATE', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:read:global', 'Đọc tất cả chiến dịch', 'Xem tất cả chiến dịch', 'CAMPAIGN', 'READ', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:read:own', 'Đọc chiến dịch riêng', 'Xem chiến dịch riêng', 'CAMPAIGN', 'READ', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:update:global', 'Cập nhật bất kỳ chiến dịch', 'Cập nhật bất kỳ chiến dịch', 'CAMPAIGN', 'UPDATE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:update:own', 'Cập nhật chiến dịch riêng', 'Cập nhật chiến dịch riêng', 'CAMPAIGN', 'UPDATE', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:delete:global', 'Xóa bất kỳ chiến dịch', 'Xóa bất kỳ chiến dịch', 'CAMPAIGN', 'DELETE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:delete:own', 'Xóa chiến dịch riêng', 'Xóa chiến dịch riêng', 'CAMPAIGN', 'DELETE', 'OWN', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:approve:global', 'Phê duyệt chiến dịch', 'Phê duyệt chiến dịch để kích hoạt', 'CAMPAIGN', 'APPROVE', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),
('campaign:reject:global', 'Từ chối chiến dịch', 'Từ chối gửi chiến dịch', 'CAMPAIGN', 'REJECT', 'GLOBAL', 'CAMPAIGN_MANAGEMENT', TRUE),

-- Quyền quản lý nội dung
('content:create:global', 'Tạo bất kỳ nội dung', 'Tạo nội dung cho bất kỳ nhà quảng cáo', 'CONTENT', 'CREATE', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:create:own', 'Tạo nội dung riêng', 'Tạo nội dung riêng', 'CONTENT', 'CREATE', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:read:global', 'Đọc tất cả nội dung', 'Xem tất cả nội dung', 'CONTENT', 'READ', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:read:own', 'Đọc nội dung riêng', 'Xem nội dung riêng', 'CONTENT', 'READ', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:update:global', 'Cập nhật bất kỳ nội dung', 'Cập nhật bất kỳ nội dung', 'CONTENT', 'UPDATE', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:update:own', 'Cập nhật nội dung riêng', 'Cập nhật nội dung riêng', 'CONTENT', 'UPDATE', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:delete:global', 'Xóa bất kỳ nội dung', 'Xóa bất kỳ nội dung', 'CONTENT', 'DELETE', 'GLOBAL', 'CONTENT_MANAGEMENT', TRUE),
('content:delete:own', 'Xóa nội dung riêng', 'Xóa nội dung riêng', 'CONTENT', 'DELETE', 'OWN', 'CONTENT_MANAGEMENT', TRUE),
('content:approve:global', 'Phê duyệt nội dung', 'Phê duyệt nội dung cho chiến dịch', 'CONTENT', 'APPROVE', 'GLOBAL', 'CONTENT_MODERATION', TRUE),
('content:reject:global', 'Từ chối nội dung', 'Từ chối gửi nội dung', 'CONTENT', 'REJECT', 'GLOBAL', 'CONTENT_MODERATION', TRUE),

-- Quyền ví & thanh toán
('wallet:read:global', 'Đọc tất cả ví', 'Xem tất cả số dư ví', 'WALLET', 'READ', 'GLOBAL', 'WALLET_MANAGEMENT', TRUE),
('wallet:read:own', 'Đọc ví riêng', 'Xem số dư ví riêng', 'WALLET', 'READ', 'OWN', 'WALLET_MANAGEMENT', TRUE),
('wallet:deposit:own', 'Nạp tiền vào ví riêng', 'Thêm tiền vào ví riêng', 'WALLET', 'DEPOSIT', 'OWN', 'WALLET_MANAGEMENT', TRUE),
('wallet:withdraw:own', 'Rút tiền từ ví riêng', 'Rút tiền từ ví riêng', 'WALLET', 'WITHDRAW', 'OWN', 'WALLET_MANAGEMENT', TRUE),
('wallet:transfer:global', 'Chuyển tiền', 'Chuyển tiền giữa các ví', 'WALLET', 'TRANSFER', 'GLOBAL', 'WALLET_MANAGEMENT', TRUE),

-- Quyền phân tích & báo cáo
('analytics:read:global', 'Đọc tất cả phân tích', 'Xem tất cả phân tích và báo cáo', 'ANALYTICS', 'READ', 'GLOBAL', 'ANALYTICS', TRUE),
('analytics:read:own', 'Đọc phân tích riêng', 'Xem phân tích hiệu suất riêng', 'ANALYTICS', 'READ', 'OWN', 'ANALYTICS', TRUE),
('analytics:export:global', 'Xuất tất cả báo cáo', 'Xuất báo cáo cho bất kỳ tài khoản', 'ANALYTICS', 'EXPORT', 'GLOBAL', 'ANALYTICS', TRUE),
('analytics:export:own', 'Xuất báo cáo riêng', 'Xuất báo cáo riêng', 'ANALYTICS', 'EXPORT', 'OWN', 'ANALYTICS', TRUE),

-- Quyền thiết bị & kho
('device:create:global', 'Tạo thiết bị', 'Đăng ký thiết bị mới', 'DEVICE', 'CREATE', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:create:own', 'Tạo thiết bị riêng', 'Đăng ký thiết bị cho tài khoản riêng', 'DEVICE', 'CREATE', 'OWN', 'DEVICE_MANAGEMENT', TRUE),
('device:read:global', 'Đọc tất cả thiết bị', 'Xem tất cả thiết bị', 'DEVICE', 'READ', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:read:own', 'Đọc thiết bị riêng', 'Xem thiết bị riêng', 'DEVICE', 'READ', 'OWN', 'DEVICE_MANAGEMENT', TRUE),
('device:update:global', 'Cập nhật bất kỳ thiết bị', 'Cập nhật bất kỳ thiết bị', 'DEVICE', 'UPDATE', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:update:own', 'Cập nhật thiết bị riêng', 'Cập nhật thiết bị riêng', 'DEVICE', 'UPDATE', 'OWN', 'DEVICE_MANAGEMENT', TRUE),
('device:delete:global', 'Xóa bất kỳ thiết bị', 'Xóa bất kỳ thiết bị', 'DEVICE', 'DELETE', 'GLOBAL', 'DEVICE_MANAGEMENT', TRUE),
('device:delete:own', 'Xóa thiết bị riêng', 'Xóa thiết bị riêng', 'DEVICE', 'DELETE', 'OWN', 'DEVICE_MANAGEMENT', TRUE),

-- Quyền kiểm toán & bảo mật
('audit:read:global', 'Đọc nhật ký kiểm toán', 'Xem tất cả nhật ký kiểm toán', 'AUDIT', 'READ', 'GLOBAL', 'AUDIT', TRUE),
('audit:read:own', 'Đọc nhật ký kiểm toán riêng', 'Xem nhật ký kiểm toán riêng', 'AUDIT', 'READ', 'OWN', 'AUDIT', TRUE),
('security:read:global', 'Đọc sự kiện bảo mật', 'Xem sự kiện và sự cố bảo mật', 'SECURITY', 'READ', 'GLOBAL', 'SECURITY', TRUE),
('security:investigate:global', 'Điều tra sự kiện bảo mật', 'Điều tra sự cố bảo mật', 'SECURITY', 'INVESTIGATE', 'GLOBAL', 'SECURITY', TRUE);

-- ============================================================================
-- SAMPLE QUERIES - CÂU TRUY VẤN MẪU
-- ============================================================================

/*
-- Lấy người dùng hoạt động với vai trò của họ
SELECT * FROM v_active_users_with_roles
ORDER BY last_login_at DESC NULLS LAST;

-- Kiểm tra người dùng có quyền cụ thể hay không
SELECT check_user_permission(
    'USER_UUID',
    'campaign:create:own',
    NULL
);

-- Lấy tất cả quyền cho một người dùng
SELECT * FROM v_user_permissions
WHERE user_id = 'USER_UUID'
ORDER BY resource, action;

-- Lấy phiên hoạt động cho người dùng
SELECT * FROM v_active_sessions
WHERE user_id = 'USER_UUID'
ORDER BY session_started_at DESC;

-- Lấy sự kiện bảo mật gần đây
SELECT * FROM security_events
WHERE severity IN ('HIGH', 'CRITICAL')
    AND occurred_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
ORDER BY occurred_at DESC;

-- Lấy nhật ký kiểm toán cho tài nguyên cụ thể
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

-- Tìm người dùng có số lần đăng nhập thất bại
SELECT
    email,
    failed_login_attempts,
    account_locked_until,
    last_login_at
FROM users
WHERE failed_login_attempts > 0
    AND status = 'ACTIVE'
ORDER BY failed_login_attempts DESC;

-- Lấy tóm tắt bảng điều khiển bảo mật
SELECT * FROM v_security_dashboard
WHERE event_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY event_date DESC, severity DESC;

-- Hết hạn phiên cũ (chạy như công việc theo lịch)
SELECT expire_old_sessions();
*/

-- ============================================================================
-- KẾT THÚC SCHEMA XÁC THỰC & PHÂN QUYỀN
-- ============================================================================
