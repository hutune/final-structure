# 👤 User & Authentication Domain - Business Rules

**Version**: 1.0  
**Date**: 2026-02-05  
**Status**: Consolidated  
**Domain**: 01-User & Authentication

---

## Table of Contents

1. [Overview](#overview)
2. [User Identity](#user-identity)
3. [Authentication Flow](#authentication-flow)
4. [Authorization (RBAC)](#authorization-rbac)
5. [Multi-Tenant Isolation](#multi-tenant-isolation)
6. [Account Types](#account-types)

---

## Overview

### Purpose
This document defines business rules for User Identity, Authentication, and Authorization. This is a **cross-cutting domain** that affects both Advertiser and Supplier modules.

### Scope
- User account creation and management
- Authentication (login, logout, sessions)
- Authorization (roles, permissions)
- Multi-factor authentication (2FA)
- Account security

### Out of Scope
- Advertiser-specific logic (see Advertiser module)
- Supplier-specific logic (see Supplier module)
- Platform admin users (see Admin module)

---

## User Identity

### Core User Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `email` | String(100) | Yes | Primary identifier, must be verified |
| `password_hash` | String | Yes | Hashed password |
| `display_name` | String(100) | Yes | Display name |
| `avatar_url` | String | No | Profile picture |
| `phone` | String(20) | No | Contact phone |
| `status` | Enum | Yes | UNVERIFIED, ACTIVE, SUSPENDED, DELETED |
| `email_verified_at` | DateTime | No | When email was verified |
| `created_at` | DateTime | Yes | Account creation time |
| `updated_at` | DateTime | Yes | Last update time |

### User Status

| Status | Description |
|--------|-------------|
| UNVERIFIED | Email not yet verified |
| ACTIVE | Normal operation |
| SUSPENDED | Temporarily disabled |
| DELETED | Soft-deleted |

### Password Requirements

| Requirement | Value |
|-------------|-------|
| Minimum length | 12 characters |
| Character types | Uppercase + Lowercase + Number + Symbol |
| History check | Cannot reuse last 5 passwords |
| Expiry | No mandatory expiry (following NIST guidelines) |

---

## Authentication Flow

### Registration

**Steps**:
1. User enters email + password
2. System validates email uniqueness
3. System validates password requirements
4. System sends verification email
5. User clicks verification link
6. Email marked as verified → Status = ACTIVE

**Business Rules**:
- Email must be unique across all users
- Verification link expires in 24 hours
- Maximum 3 verification emails per hour
- Failed verifications logged for security

### Employee Registration (Invitation Flow)

> **Note**: Based on whiteboard EmployeeRegistrationAggregate - used for inviting team members.

**Steps** (Invitation → Verification → Input → Success):

1. **Invitation**: Admin/Owner sends invitation to email
2. **OTP Verification**: Invitee receives email with verification link
3. **Input Personal Data**: User fills in required profile information
4. **Account Created**: Status = ACTIVE, linked to company

**Invitation Entity**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `email` | String(100) | Yes | Invitee email |
| `invited_by` | UUID | Yes | Inviter user ID |
| `company_id` | UUID | Yes | Target company |
| `role` | Enum | Yes | Assigned role |
| `invitation_token` | String | Yes | Unique token for acceptance |
| `expires_at` | DateTime | Yes | Token expiration (7 days) |
| `status` | Enum | Yes | PENDING, ACCEPTED, EXPIRED, REVOKED |
| `accepted_at` | DateTime | No | When invitation was accepted |

**Business Rules**:
- Invitation expires after 7 days
- Only one active invitation per email per company
- Expired invitations can be resent
- Invitation can be revoked before acceptance


### Login

**Steps**:
1. User enters email + password
2. System validates credentials
3. If 2FA enabled: Prompt for OTP
4. System creates session (JWT)
5. User redirected to dashboard

**Business Rules**:
- Account lockout after 5 failed attempts (30-minute lock)
- Lockout notification via email
- Session duration: 1 hour (access token)
- Refresh token: 7 days

### Session Management

| Token Type | Duration | Renewal |
|------------|----------|---------|
| Access Token | 1 hour | Via refresh token |
| Refresh Token | 7 days | On each use |
| Remember Me | 30 days | Requires re-authentication for sensitive actions |

**Business Rules**:
- Single active session by default (can configure multi-session)
- New login invalidates previous sessions
- Force logout from all devices available
- Session terminated on password change

### Password Reset

**Steps**:
1. User requests password reset
2. System sends reset link (expires in 30 minutes)
3. User clicks link → enters new password
4. Password updated → all sessions invalidated
5. Confirmation email sent

---

## Authorization (RBAC)

### Role Hierarchy

| Role | Description | Account Type |
|------|-------------|--------------|
| Advertiser Owner | Full control of advertiser account | Advertiser |
| Advertiser Admin | Full control except billing | Advertiser |
| Advertiser User | Limited by assigned permissions | Advertiser |
| Supplier Owner | Full control of supplier account | Supplier |
| Supplier Admin | Full control except payouts | Supplier |
| Supplier User | Limited by assigned permissions | Supplier |
| Platform Admin | Global platform access | Platform |
| Support Agent | Read-only for support purposes | Platform |

### Permission Model

Permissions are granted at resource level:

| Permission | Description |
|------------|-------------|
| create | Can create new resources |
| read | Can view resources |
| update | Can modify resources |
| delete | Can remove resources |

**Business Rules**:
- Owner role cannot be revoked (must transfer ownership)
- Admin can grant roles up to their level
- Permissions checked at every action
- Denied actions logged

---

## Multi-Factor Authentication (2FA)

### Methods Supported

| Method | Priority | Recovery |
|--------|----------|----------|
| Authenticator App | Primary | Yes |
| SMS OTP | Secondary (backup) | Yes |
| Recovery Codes | Emergency only | One-time use |

### 2FA Requirements

| User Type | 2FA Required |
|-----------|--------------|
| Platform Admin | Mandatory |
| Advertiser (Enterprise) | Mandatory |
| Supplier (Enterprise) | Mandatory |
| Other users | Optional (recommended) |

---

## Multi-Tenant Isolation

### Data Access Rules

| Principle | Description |
|-----------|-------------|
| Tenant Boundary | Users cannot access data outside their Advertiser/Supplier |
| Cross-tenant Query | Not allowed at database level |
| Shared Resources | Only platform-level content (e.g., templates) |

### Admin Override

**For Support Purposes**:
- Platform Admin can "act on behalf of" a user
- All actions fully logged in audit trail
- Requires justification (support ticket reference)
- Time-limited session (1 hour max)

---

## Account Types

### User → Account Relationship

| Account Type | Description | Linked Entity |
|--------------|-------------|---------------|
| Advertiser | Runs advertising campaigns | Advertiser profile |
| Supplier | Provides store locations & devices | Supplier profile |

**Business Rules**:
- One user can have both Advertiser and Supplier accounts
- Each account type has separate profile
- User must select context when logging in (if multiple accounts)
- Permissions are context-specific

### Account Linking

| Scenario | Allowed |
|----------|---------|
| User creates Advertiser account | Yes |
| Same user creates Supplier account | Yes |
| Switch between accounts | Yes (context selection) |
| Transfer account to another user | Yes (ownership transfer) |
