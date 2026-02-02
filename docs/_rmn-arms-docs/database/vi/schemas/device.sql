-- ============================================================================
-- Schema Cơ sở dữ liệu RMN-Arms: Device Management Module
-- ============================================================================
-- Phiên bản: 1.0
-- Cập nhật lần cuối: 2026-01-23
-- Mô tả: Schema cơ sở dữ liệu đầy đủ for Device Management including
--              devices, heartbeats, content sync, health logs, and maintenance
-- ============================================================================

-- ============================================================================
-- BẢNG: devices
-- Mô tả: Main device entity with hardware specs, status, and metrics
-- ============================================================================

CREATE TABLE devices (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE RESTRICT,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,

    -- Device Identification
    device_code VARCHAR(20) NOT NULL UNIQUE CHECK (LENGTH(device_code) = 16),
    device_name VARCHAR(100),

    -- Device Type & Status
    device_type VARCHAR(50) NOT NULL DEFAULT 'DISPLAY' CHECK (device_type IN (
        'DISPLAY', 'VIDEO_WALL', 'KIOSK', 'TABLET', 'SMART_TV', 'LED_BOARD'
    )),
    status VARCHAR(50) NOT NULL DEFAULT 'REGISTERED' CHECK (status IN (
        'REGISTERED', 'ACTIVE', 'OFFLINE', 'MAINTENANCE', 'DECOMMISSIONED'
    )),

    -- Hardware Specifications
    screen_size_inches INTEGER NOT NULL CHECK (screen_size_inches BETWEEN 32 AND 100),
    screen_resolution VARCHAR(20) NOT NULL CHECK (screen_resolution ~ '^\d{3,4}x\d{3,4}$'),
    screen_orientation VARCHAR(20) NOT NULL DEFAULT 'LANDSCAPE' CHECK (screen_orientation IN ('LANDSCAPE', 'PORTRAIT')),
    hardware_model VARCHAR(50),
    os_type VARCHAR(50) NOT NULL CHECK (os_type IN ('ANDROID', 'WINDOWS', 'LINUX', 'WEBOS', 'TIZEN')),
    os_version VARCHAR(20),
    player_version VARCHAR(20),

    -- Network Information
    mac_address VARCHAR(17) CHECK (mac_address IS NULL OR mac_address ~ '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$'),
    ip_address VARCHAR(45), -- IPv4 or IPv6

    -- Security
    public_key TEXT NOT NULL,
    last_signature_verified_at TIMESTAMPTZ,
    consecutive_signature_failures INTEGER NOT NULL DEFAULT 0,

    -- Location
    location JSONB, -- GeoJSON Point: {"type": "Point", "coordinates": [lng, lat]}
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',

    -- Configuration
    advertising_slots_per_hour INTEGER NOT NULL DEFAULT 12 CHECK (advertising_slots_per_hour BETWEEN 6 AND 60),
    max_content_duration INTEGER NOT NULL DEFAULT 60 CHECK (max_content_duration BETWEEN 10 AND 300),
    operating_hours JSONB NOT NULL DEFAULT '{}', -- {"monday": {"open": "08:00", "close": "22:00"}, ...}
    heartbeat_interval INTEGER NOT NULL DEFAULT 300, -- seconds

    -- Activity Timestamps
    last_heartbeat_at TIMESTAMPTZ,
    last_sync_at TIMESTAMPTZ,
    last_impression_at TIMESTAMPTZ,
    went_offline_at TIMESTAMPTZ,
    came_online_at TIMESTAMPTZ,

    -- Performance Metrics
    total_uptime_minutes BIGINT NOT NULL DEFAULT 0,
    total_downtime_minutes BIGINT NOT NULL DEFAULT 0,
    uptime_percentage DECIMAL(5, 2) NOT NULL DEFAULT 0.00 CHECK (uptime_percentage BETWEEN 0 AND 100),
    total_impressions BIGINT NOT NULL DEFAULT 0,
    total_revenue_generated DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    health_score INTEGER NOT NULL DEFAULT 100 CHECK (health_score BETWEEN 0 AND 100),

    -- Current Metrics (Latest from Heartbeat)
    current_cpu_usage INTEGER CHECK (current_cpu_usage IS NULL OR current_cpu_usage BETWEEN 0 AND 100),
    current_memory_usage INTEGER CHECK (current_memory_usage IS NULL OR current_memory_usage BETWEEN 0 AND 100),
    current_disk_usage INTEGER CHECK (current_disk_usage IS NULL OR current_disk_usage BETWEEN 0 AND 100),
    current_network_latency_ms INTEGER,

    -- Playlist Management
    current_playlist_id UUID,
    current_manifest_version VARCHAR(20),

    -- Flags & Metadata
    flags JSONB NOT NULL DEFAULT '{}', -- {"suspicious": false, "needs_maintenance": false}
    metadata JSONB DEFAULT '{}',

    -- Lifecycle Timestamps
    registered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activated_at TIMESTAMPTZ,
    decommissioned_at TIMESTAMPTZ,
    decommission_reason TEXT,

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),

    -- Ràng buộc
    CONSTRAINT devices_resolution_check CHECK (
        screen_resolution ~ '(1920x1080|2560x1440|3840x2160|7680x4320)'
    )
);

-- Chỉ mục
CREATE INDEX idx_devices_store_id ON devices(store_id);
CREATE INDEX idx_devices_supplier_id ON devices(supplier_id);
CREATE INDEX idx_devices_device_code ON devices(device_code);
CREATE INDEX idx_devices_status ON devices(status);
CREATE INDEX idx_devices_last_heartbeat_at ON devices(last_heartbeat_at DESC);
CREATE INDEX idx_devices_health_score ON devices(health_score);
CREATE INDEX idx_devices_status_heartbeat ON devices(status, last_heartbeat_at);
CREATE INDEX idx_devices_supplier_status ON devices(supplier_id, status);
CREATE INDEX idx_devices_location ON devices USING GIN(location);

-- Comments
COMMENT ON TABLE devices IS 'Physical digital signage devices that display advertising content';
COMMENT ON COLUMN devices.device_code IS 'Unique 16-character alphanumeric device identifier';
COMMENT ON COLUMN devices.status IS 'Device lifecycle status';
COMMENT ON COLUMN devices.health_score IS 'Computed health metric 0-100 based on uptime, performance, reliability';
COMMENT ON COLUMN devices.advertising_slots_per_hour IS 'Number of ad opportunities per hour (6-60)';
COMMENT ON COLUMN devices.heartbeat_interval IS 'Expected heartbeat frequency in seconds';
COMMENT ON COLUMN devices.location IS 'GPS coordinates in GeoJSON format';

-- ============================================================================
-- BẢNG: device_heartbeats
-- Mô tả: Periodic health check records from devices
-- ============================================================================

CREATE TABLE device_heartbeats (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,

    -- Timestamp
    server_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    device_timestamp TIMESTAMPTZ NOT NULL,
    time_skew_seconds INTEGER, -- Calculated difference

    -- Status
    status VARCHAR(50) NOT NULL CHECK (status IN ('ONLINE', 'DEGRADED', 'ERROR')),
    sequence_number BIGINT NOT NULL,

    -- System Metrics
    cpu_usage INTEGER CHECK (cpu_usage BETWEEN 0 AND 100),
    memory_usage INTEGER CHECK (memory_usage BETWEEN 0 AND 100),
    disk_usage INTEGER CHECK (disk_usage BETWEEN 0 AND 100),
    disk_free_gb DECIMAL(10, 2),
    temperature_celsius INTEGER,

    -- Network Metrics
    network_latency_ms INTEGER,
    network_bandwidth_kbps INTEGER,
    network_connection_type VARCHAR(20) CHECK (network_connection_type IN ('ETHERNET', 'WIFI', '4G', '5G')),
    ip_address VARCHAR(45) NOT NULL,

    -- Playback State
    screen_on BOOLEAN NOT NULL DEFAULT FALSE,
    content_playing BOOLEAN NOT NULL DEFAULT FALSE,
    current_content_id UUID REFERENCES content_assets(id),
    current_campaign_id UUID REFERENCES campaigns(id),
    playlist_id UUID,
    playlist_position INTEGER,
    playlist_total INTEGER,
    last_impression_at TIMESTAMPTZ,

    -- Errors
    error_count INTEGER NOT NULL DEFAULT 0,
    error_messages JSONB, -- Array of error objects

    -- Location
    location JSONB, -- GPS coordinates at heartbeat time

    -- Software Versions
    player_version VARCHAR(20),
    os_version VARCHAR(20),

    -- Security
    signature TEXT NOT NULL,
    signature_valid BOOLEAN NOT NULL DEFAULT FALSE,

    -- Ràng buộc
    CONSTRAINT device_heartbeats_sequence_check UNIQUE(device_id, sequence_number)
);

-- Chỉ mục
CREATE INDEX idx_heartbeats_device_id ON device_heartbeats(device_id);
CREATE INDEX idx_heartbeats_server_timestamp ON device_heartbeats(server_timestamp DESC);
CREATE INDEX idx_heartbeats_device_timestamp ON device_heartbeats(device_id, server_timestamp DESC);
CREATE INDEX idx_heartbeats_status ON device_heartbeats(status);
CREATE INDEX idx_heartbeats_signature_valid ON device_heartbeats(signature_valid) WHERE signature_valid = FALSE;

-- Comments
COMMENT ON TABLE device_heartbeats IS 'Health check records sent by devices every 5 minutes';
COMMENT ON COLUMN device_heartbeats.sequence_number IS 'Monotonically increasing number to prevent replay attacks';
COMMENT ON COLUMN device_heartbeats.time_skew_seconds IS 'Difference between device and server time';

-- ============================================================================
-- BẢNG: device_content_cache
-- Mô tả: Content cached locally on devices
-- ============================================================================

CREATE TABLE device_content_cache (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    content_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Cache Information
    cached_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMPTZ,
    access_count BIGINT NOT NULL DEFAULT 0,

    -- File Information
    file_size_bytes BIGINT NOT NULL,
    file_checksum VARCHAR(100) NOT NULL, -- SHA256 hash
    cdn_url TEXT NOT NULL,

    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'CACHED' CHECK (status IN (
        'PENDING', 'DOWNLOADING', 'CACHED', 'CORRUPTED', 'EXPIRED'
    )),

    -- Verification
    checksum_verified_at TIMESTAMPTZ,
    verification_failures INTEGER NOT NULL DEFAULT 0,

    -- Timestamp
    expires_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT device_content_cache_unique UNIQUE(device_id, content_id)
);

-- Chỉ mục
CREATE INDEX idx_content_cache_device_id ON device_content_cache(device_id);
CREATE INDEX idx_content_cache_content_id ON device_content_cache(content_id);
CREATE INDEX idx_content_cache_status ON device_content_cache(status);
CREATE INDEX idx_content_cache_expires_at ON device_content_cache(expires_at);
CREATE INDEX idx_content_cache_device_status ON device_content_cache(device_id, status);

-- Comments
COMMENT ON TABLE device_content_cache IS 'Tracks content cached on each device';
COMMENT ON COLUMN device_content_cache.file_checksum IS 'SHA256 hash for integrity verification';

-- ============================================================================
-- BẢNG: device_content_sync
-- Mô tả: Content synchronization records between server and device
-- ============================================================================

CREATE TABLE device_content_sync (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,

    -- Sync Type
    sync_type VARCHAR(50) NOT NULL CHECK (sync_type IN ('FULL', 'INCREMENTAL', 'FORCED')),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'CANCELLED'
    )),

    -- Progress Tracking
    total_files INTEGER NOT NULL DEFAULT 0,
    synced_files INTEGER NOT NULL DEFAULT 0,
    failed_files INTEGER NOT NULL DEFAULT 0,
    total_bytes BIGINT NOT NULL DEFAULT 0,
    synced_bytes BIGINT NOT NULL DEFAULT 0,

    -- Performance Metrics
    bandwidth_kbps INTEGER,
    duration_seconds INTEGER,

    -- Manifest Version
    from_manifest_version VARCHAR(20),
    to_manifest_version VARCHAR(20),

    -- Content Details
    added_content_ids UUID[], -- Array of content IDs added
    updated_content_ids UUID[], -- Array of content IDs updated
    removed_content_ids UUID[], -- Array of content IDs removed

    -- Error Handling
    error_message TEXT,
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,

    -- Timestamp
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    next_retry_at TIMESTAMPTZ,

    -- Audit
    initiated_by VARCHAR(50) CHECK (initiated_by IN ('DEVICE', 'SERVER', 'ADMIN'))
);

-- Chỉ mục
CREATE INDEX idx_content_sync_device_id ON device_content_sync(device_id);
CREATE INDEX idx_content_sync_status ON device_content_sync(status);
CREATE INDEX idx_content_sync_started_at ON device_content_sync(started_at DESC);
CREATE INDEX idx_content_sync_device_status ON device_content_sync(device_id, status);

-- Comments
COMMENT ON TABLE device_content_sync IS 'Records of content synchronization between server and devices';
COMMENT ON COLUMN device_content_sync.sync_type IS 'FULL=complete resync, INCREMENTAL=updates only, FORCED=admin-triggered';

-- ============================================================================
-- BẢNG: device_health_logs
-- Mô tả: Detailed health and performance metrics over time
-- ============================================================================

CREATE TABLE device_health_logs (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,

    -- Date for aggregation
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    log_hour INTEGER CHECK (log_hour BETWEEN 0 AND 23),

    -- Uptime Metrics
    uptime_minutes INTEGER NOT NULL DEFAULT 0,
    downtime_minutes INTEGER NOT NULL DEFAULT 0,
    uptime_percentage DECIMAL(5, 2),

    -- Performance Metrics (Averages)
    avg_cpu_usage DECIMAL(5, 2),
    avg_memory_usage DECIMAL(5, 2),
    avg_disk_usage DECIMAL(5, 2),
    avg_network_latency_ms INTEGER,
    max_cpu_usage INTEGER,
    max_memory_usage INTEGER,

    -- Activity Metrics
    heartbeats_received INTEGER NOT NULL DEFAULT 0,
    heartbeats_expected INTEGER NOT NULL DEFAULT 0,
    heartbeat_success_rate DECIMAL(5, 2),

    -- Content Metrics
    impressions_served BIGINT NOT NULL DEFAULT 0,
    content_load_errors INTEGER NOT NULL DEFAULT 0,
    playback_errors INTEGER NOT NULL DEFAULT 0,

    -- Error Metrics
    total_errors INTEGER NOT NULL DEFAULT 0,
    error_summary JSONB, -- {"CONTENT_LOAD_FAILED": 3, "NETWORK_TIMEOUT": 1}

    -- Health Score
    health_score INTEGER CHECK (health_score BETWEEN 0 AND 100),

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT device_health_logs_unique UNIQUE(device_id, log_date, log_hour)
);

-- Chỉ mục
CREATE INDEX idx_health_logs_device_id ON device_health_logs(device_id);
CREATE INDEX idx_health_logs_log_date ON device_health_logs(log_date DESC);
CREATE INDEX idx_health_logs_device_date ON device_health_logs(device_id, log_date DESC);
CREATE INDEX idx_health_logs_health_score ON device_health_logs(health_score);

-- Comments
COMMENT ON TABLE device_health_logs IS 'Hourly aggregated health and performance metrics per device';
COMMENT ON COLUMN device_health_logs.log_hour IS 'Hour of day (0-23) for hourly aggregation';

-- ============================================================================
-- BẢNG: device_playlists
-- Mô tả: Content queue scheduled for devices
-- ============================================================================

CREATE TABLE device_playlists (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
    content_asset_id UUID NOT NULL REFERENCES content_assets(id) ON DELETE CASCADE,

    -- Scheduling
    priority INTEGER NOT NULL DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
    weight INTEGER NOT NULL DEFAULT 100 CHECK (weight BETWEEN 1 AND 100),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,

    -- Time Restrictions (Day Parting)
    time_restrictions JSONB, -- {"days": [1,2,3], "hours": [{"start": "09:00", "end": "17:00"}]}

    -- Playback Tracking
    play_count BIGINT NOT NULL DEFAULT 0,
    last_played_at TIMESTAMPTZ,

    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'ACTIVE', 'COMPLETED', 'EXPIRED', 'CANCELLED'
    )),

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ràng buộc
    CONSTRAINT device_playlists_date_range CHECK (end_date > start_date)
);

-- Chỉ mục
CREATE INDEX idx_playlists_device_id ON device_playlists(device_id);
CREATE INDEX idx_playlists_campaign_id ON device_playlists(campaign_id);
CREATE INDEX idx_playlists_content_id ON device_playlists(content_asset_id);
CREATE INDEX idx_playlists_status ON device_playlists(status);
CREATE INDEX idx_playlists_device_status ON device_playlists(device_id, status);
CREATE INDEX idx_playlists_date_range ON device_playlists(start_date, end_date);

-- Comments
COMMENT ON TABLE device_playlists IS 'Content queue scheduled to play on devices';
COMMENT ON COLUMN device_playlists.priority IS 'Display priority 1-10 (10 is highest)';
COMMENT ON COLUMN device_playlists.weight IS 'Relative frequency weight for rotation';

-- ============================================================================
-- BẢNG: device_maintenance_logs
-- Mô tả: Maintenance activity records
-- ============================================================================

CREATE TABLE device_maintenance_logs (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    performed_by UUID NOT NULL REFERENCES users(id),

    -- Maintenance Details
    maintenance_type VARCHAR(50) NOT NULL CHECK (maintenance_type IN (
        'SCHEDULED', 'EMERGENCY', 'FIRMWARE_UPDATE', 'HARDWARE_REPAIR', 'CONFIGURATION'
    )),
    status VARCHAR(50) NOT NULL DEFAULT 'SCHEDULED' CHECK (status IN (
        'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
    )),

    -- Description
    description TEXT NOT NULL,
    notes TEXT,

    -- Parts & Cost
    parts_replaced JSONB, -- [{"part": "Power supply", "cost": 150.00}]
    cost_amount DECIMAL(10, 2),
    cost_currency VARCHAR(3) DEFAULT 'USD',

    -- Timing
    scheduled_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Chỉ mục
CREATE INDEX idx_maintenance_device_id ON device_maintenance_logs(device_id);
CREATE INDEX idx_maintenance_performed_by ON device_maintenance_logs(performed_by);
CREATE INDEX idx_maintenance_status ON device_maintenance_logs(status);
CREATE INDEX idx_maintenance_scheduled_at ON device_maintenance_logs(scheduled_at);
CREATE INDEX idx_maintenance_device_date ON device_maintenance_logs(device_id, scheduled_at DESC);

-- Comments
COMMENT ON TABLE device_maintenance_logs IS 'Records of device maintenance activities';

-- ============================================================================
-- BẢNG: device_activation_keys
-- Mô tả: One-time activation keys for device registration
-- ============================================================================

CREATE TABLE device_activation_keys (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Device Code
    device_code VARCHAR(20) NOT NULL REFERENCES devices(device_code) ON DELETE CASCADE,

    -- Activation Key
    activation_key VARCHAR(50) NOT NULL UNIQUE,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'UNUSED' CHECK (status IN ('UNUSED', 'USED', 'EXPIRED')),

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days'),
    used_at TIMESTAMPTZ,
    used_by UUID REFERENCES users(id)
);

-- Chỉ mục
CREATE INDEX idx_activation_keys_device_code ON device_activation_keys(device_code);
CREATE INDEX idx_activation_keys_status ON device_activation_keys(status);
CREATE INDEX idx_activation_keys_expires_at ON device_activation_keys(expires_at);

-- Comments
COMMENT ON TABLE device_activation_keys IS 'One-time activation keys for device registration (30-day expiry)';

-- ============================================================================
-- BẢNG: device_transfer_logs
-- Mô tả: Audit trail for device transfers between stores
-- ============================================================================

CREATE TABLE device_transfer_logs (
    -- Khóa chính
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Khóa ngoại
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    from_store_id UUID NOT NULL REFERENCES stores(id),
    to_store_id UUID NOT NULL REFERENCES stores(id),
    transferred_by UUID NOT NULL REFERENCES users(id),

    -- Transfer Details
    reason TEXT,
    notes TEXT,

    -- Campaigns Affected
    paused_campaigns_count INTEGER NOT NULL DEFAULT 0,
    affected_campaign_ids UUID[],

    -- Timestamp
    transferred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Chỉ mục
CREATE INDEX idx_transfer_logs_device_id ON device_transfer_logs(device_id);
CREATE INDEX idx_transfer_logs_from_store ON device_transfer_logs(from_store_id);
CREATE INDEX idx_transfer_logs_to_store ON device_transfer_logs(to_store_id);
CREATE INDEX idx_transfer_logs_transferred_at ON device_transfer_logs(transferred_at DESC);

-- Comments
COMMENT ON TABLE device_transfer_logs IS 'Audit trail of device transfers between stores';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Active Devices with Current Health
CREATE OR REPLACE VIEW v_active_devices AS
SELECT
    d.id,
    d.device_code,
    d.device_name,
    d.store_id,
    d.supplier_id,
    d.status,
    d.screen_size_inches,
    d.screen_resolution,
    d.last_heartbeat_at,
    d.health_score,
    d.uptime_percentage,
    d.total_impressions,
    d.advertising_slots_per_hour,
    CASE
        WHEN d.last_heartbeat_at IS NULL THEN 'NEVER_CONNECTED'
        WHEN d.last_heartbeat_at < NOW() - (d.heartbeat_interval || ' seconds')::INTERVAL THEN 'HEARTBEAT_LATE'
        ELSE 'HEALTHY'
    END AS connection_status,
    EXTRACT(EPOCH FROM (NOW() - d.last_heartbeat_at)) / 60 AS minutes_since_heartbeat
FROM devices d
WHERE d.status = 'ACTIVE';

-- View: Offline Devices Needing Attention
CREATE OR REPLACE VIEW v_offline_devices AS
SELECT
    d.id,
    d.device_code,
    d.device_name,
    d.store_id,
    d.supplier_id,
    d.last_heartbeat_at,
    d.went_offline_at,
    EXTRACT(EPOCH FROM (NOW() - d.went_offline_at)) / 60 AS minutes_offline,
    CASE
        WHEN EXTRACT(EPOCH FROM (NOW() - d.went_offline_at)) / 60 >= 120 THEN 'CRITICAL'
        WHEN EXTRACT(EPOCH FROM (NOW() - d.went_offline_at)) / 60 >= 30 THEN 'URGENT'
        ELSE 'WARNING'
    END AS alert_level
FROM devices d
WHERE d.status = 'OFFLINE'
ORDER BY d.went_offline_at ASC;

-- View: Device Health Summary
CREATE OR REPLACE VIEW v_device_health_summary AS
SELECT
    d.id,
    d.device_code,
    d.store_id,
    d.supplier_id,
    d.health_score,
    d.uptime_percentage,
    d.current_cpu_usage,
    d.current_memory_usage,
    d.current_disk_usage,
    CASE
        WHEN d.health_score >= 90 THEN 'EXCELLENT'
        WHEN d.health_score >= 80 THEN 'GOOD'
        WHEN d.health_score >= 70 THEN 'FAIR'
        WHEN d.health_score >= 50 THEN 'POOR'
        ELSE 'CRITICAL'
    END AS health_status,
    d.flags
FROM devices d
WHERE d.status IN ('ACTIVE', 'OFFLINE');

-- Comments on views
COMMENT ON VIEW v_active_devices IS 'Active devices with connection health status';
COMMENT ON VIEW v_offline_devices IS 'Offline devices with downtime duration and alert levels';
COMMENT ON VIEW v_device_health_summary IS 'Device health overview with status categorization';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update device updated_at timestamp
CREATE OR REPLACE FUNCTION update_device_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate uptime percentage
CREATE OR REPLACE FUNCTION calculate_uptime_percentage()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.total_uptime_minutes + NEW.total_downtime_minutes) > 0 THEN
        NEW.uptime_percentage = ROUND(
            (NEW.total_uptime_minutes::DECIMAL /
             (NEW.total_uptime_minutes + NEW.total_downtime_minutes)) * 100,
            2
        );
    ELSE
        NEW.uptime_percentage = 0.00;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate device hardware specs
CREATE OR REPLACE FUNCTION validate_device_hardware()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate screen size
    IF NEW.screen_size_inches < 32 OR NEW.screen_size_inches > 100 THEN
        RAISE EXCEPTION 'Screen size must be between 32 and 100 inches';
    END IF;

    -- Validate advertising slots
    IF NEW.advertising_slots_per_hour < 6 OR NEW.advertising_slots_per_hour > 60 THEN
        RAISE EXCEPTION 'Advertising slots per hour must be between 6 and 60';
    END IF;

    -- Validate max content duration
    IF NEW.max_content_duration < 10 OR NEW.max_content_duration > 300 THEN
        RAISE EXCEPTION 'Max content duration must be between 10 and 300 seconds';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Check for stale heartbeat and mark offline
CREATE OR REPLACE FUNCTION check_device_heartbeat_status(device_uuid UUID)
RETURNS VOID AS $$
DECLARE
    device_record RECORD;
    missed_heartbeats INTEGER;
    downtime_minutes INTEGER;
BEGIN
    SELECT * INTO device_record FROM devices WHERE id = device_uuid;

    IF device_record.status = 'ACTIVE' THEN
        IF device_record.last_heartbeat_at IS NOT NULL THEN
            missed_heartbeats := EXTRACT(EPOCH FROM (NOW() - device_record.last_heartbeat_at)) / device_record.heartbeat_interval;

            IF missed_heartbeats >= 2 THEN
                -- Mark device as offline
                UPDATE devices
                SET
                    status = 'OFFLINE',
                    went_offline_at = NOW()
                WHERE id = device_uuid;
            END IF;
        END IF;
    ELSIF device_record.status = 'OFFLINE' THEN
        IF device_record.went_offline_at IS NOT NULL THEN
            downtime_minutes := EXTRACT(EPOCH FROM (NOW() - device_record.went_offline_at)) / 60;

            -- Update downtime counter
            UPDATE devices
            SET total_downtime_minutes = total_downtime_minutes + 1
            WHERE id = device_uuid;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate time skew from heartbeat
CREATE OR REPLACE FUNCTION calculate_heartbeat_time_skew()
RETURNS TRIGGER AS $$
BEGIN
    NEW.time_skew_seconds = EXTRACT(EPOCH FROM (NEW.server_timestamp - NEW.device_timestamp))::INTEGER;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at on devices
CREATE TRIGGER trigger_devices_updated_at
    BEFORE UPDATE ON devices
    FOR EACH ROW
    EXECUTE FUNCTION update_device_updated_at();

-- Trigger: Calculate uptime percentage
CREATE TRIGGER trigger_calculate_uptime_percentage
    BEFORE INSERT OR UPDATE ON devices
    FOR EACH ROW
    WHEN (OLD.total_uptime_minutes IS DISTINCT FROM NEW.total_uptime_minutes
          OR OLD.total_downtime_minutes IS DISTINCT FROM NEW.total_downtime_minutes)
    EXECUTE FUNCTION calculate_uptime_percentage();

-- Trigger: Validate device hardware
CREATE TRIGGER trigger_validate_device_hardware
    BEFORE INSERT OR UPDATE ON devices
    FOR EACH ROW
    EXECUTE FUNCTION validate_device_hardware();

-- Trigger: Calculate heartbeat time skew
CREATE TRIGGER trigger_calculate_heartbeat_time_skew
    BEFORE INSERT ON device_heartbeats
    FOR EACH ROW
    EXECUTE FUNCTION calculate_heartbeat_time_skew();

-- Trigger: Update updated_at on device_content_cache
CREATE TRIGGER trigger_device_content_cache_updated_at
    BEFORE UPDATE ON device_content_cache
    FOR EACH ROW
    EXECUTE FUNCTION update_device_updated_at();

-- Trigger: Update updated_at on device_playlists
CREATE TRIGGER trigger_device_playlists_updated_at
    BEFORE UPDATE ON device_playlists
    FOR EACH ROW
    EXECUTE FUNCTION update_device_updated_at();

-- Trigger: Update updated_at on device_health_logs
CREATE TRIGGER trigger_device_health_logs_updated_at
    BEFORE UPDATE ON device_health_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_device_updated_at();

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
-- Get devices needing attention (offline or low health score)
SELECT * FROM v_offline_devices
WHERE alert_level IN ('URGENT', 'CRITICAL')
ORDER BY minutes_offline DESC;

-- Get device health summary for a supplier
SELECT
    d.device_code,
    d.device_name,
    vdhs.health_status,
    d.uptime_percentage,
    d.last_heartbeat_at
FROM v_device_health_summary vdhs
JOIN devices d ON vdhs.id = d.id
WHERE d.supplier_id = 'SUPPLIER_UUID'
ORDER BY d.health_score ASC;

-- Get device performance metrics for last 24 hours
SELECT
    d.device_code,
    dhl.log_date,
    dhl.log_hour,
    dhl.uptime_percentage,
    dhl.avg_cpu_usage,
    dhl.impressions_served,
    dhl.health_score
FROM device_health_logs dhl
JOIN devices d ON dhl.device_id = d.id
WHERE d.id = 'DEVICE_UUID'
  AND dhl.log_date >= CURRENT_DATE - INTERVAL '1 day'
ORDER BY dhl.log_date DESC, dhl.log_hour DESC;

-- Get devices with high resource usage
SELECT
    device_code,
    device_name,
    current_cpu_usage,
    current_memory_usage,
    current_disk_usage,
    health_score
FROM devices
WHERE status = 'ACTIVE'
  AND (current_cpu_usage > 90 OR current_memory_usage > 90)
ORDER BY health_score ASC;

-- Get content sync status for device
SELECT
    dcs.sync_type,
    dcs.status,
    dcs.synced_files,
    dcs.total_files,
    ROUND((dcs.synced_files::DECIMAL / NULLIF(dcs.total_files, 0)) * 100, 2) AS progress_percentage,
    dcs.started_at,
    dcs.completed_at
FROM device_content_sync dcs
WHERE dcs.device_id = 'DEVICE_UUID'
ORDER BY dcs.started_at DESC
LIMIT 10;

-- Get maintenance history for device
SELECT
    dml.maintenance_type,
    dml.status,
    dml.description,
    dml.duration_minutes,
    dml.cost_amount,
    dml.scheduled_at,
    dml.completed_at,
    u.name AS performed_by_name
FROM device_maintenance_logs dml
JOIN users u ON dml.performed_by = u.id
WHERE dml.device_id = 'DEVICE_UUID'
ORDER BY dml.scheduled_at DESC;

-- Get active playlist for device
SELECT
    dp.priority,
    dp.weight,
    c.name AS campaign_name,
    ca.title AS content_title,
    dp.play_count,
    dp.last_played_at,
    dp.start_date,
    dp.end_date
FROM device_playlists dp
JOIN campaigns c ON dp.campaign_id = c.id
JOIN content_assets ca ON dp.content_asset_id = ca.id
WHERE dp.device_id = 'DEVICE_UUID'
  AND dp.status = 'ACTIVE'
  AND dp.start_date <= NOW()
  AND dp.end_date >= NOW()
ORDER BY dp.priority DESC, dp.weight DESC;
*/

-- ============================================================================
-- END OF DEVICE SCHEMA
-- ============================================================================
