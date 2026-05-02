# Backend Plan

This document is the working plan for backend development and stabilization.
It focuses on the current business logic, API contract, and the remaining gaps that should be closed next.

## Goals

- Keep the backend API contract aligned with the frontend and mobile clients.
- Make deal, property, meeting, and profile flows consistent and predictable.
- Avoid hidden business-rule regressions when a deal changes status.
- Keep authentication and role-based access behavior explicit.
- Maintain a deployable backend with repeatable builds and migrations.

## Current State

The backend already includes:

- Auth endpoints with token-based flow.
- Profile update endpoint for the current user.
- Deal lifecycle logic with status transitions.
- Property status synchronization with deals.
- Meeting CRUD and upcoming endpoints.
- Admin agent management endpoints.
- Docker-based backend packaging.
- Flyway migrations for schema alignment.

## Immediate Priorities

### 1. Finalize business rules around deals

- Keep `dealPrice` and `closedAt` updated when a deal becomes `CLOSED_WON` or `CLOSED_LOST`.
- Preserve the currently linked property when the same deal is updated after closing.
- Make sure property status changes remain consistent with deal status changes.
- Avoid duplicate logic paths that update the same deal in two separate requests.

### 2. Stabilize profile and auth behavior

- Ensure `GET /auth/me` and `PUT /auth/me` return the same response shape.
- Keep token refresh behavior consistent with login and profile update flows.
- Confirm email uniqueness validation is handled cleanly.
- Keep the auth response model stable for all clients.

### 3. Normalize meeting and upcoming logic

- Keep `agentId` and `clientId` required for meeting creation and update.
- Ensure `upcoming` endpoints are stable for both global and agent-specific views.
- Keep completed meetings and upcoming meetings in sync with update actions.

### 4. Keep property rules predictable

- Preserve property status transitions: `AVAILABLE` → `RESERVED` → `SOLD`.
- Allow a deal update to keep the same property even if it is already `SOLD` by that same deal.
- Keep property search/filter behavior aligned with the frontend contract.

## Contract Work

### Auth

- Confirm response fields are always:
  - `accessToken`
  - `refreshToken`
  - `tokenType`
  - `userId`
  - `fullName`
  - `email`
  - `role`

### Deals

- Keep request fields aligned with frontend/mobile:
  - `title`
  - `status`
  - `dealPrice`
  - `budget`
  - `notes`
  - `clientId`
  - `propertyId`
  - `agentId`
- Keep status enum limited to:
  - `LEAD`
  - `NEGOTIATION`
  - `CLOSED_WON`
  - `CLOSED_LOST`

### Properties

- Keep status enum limited to:
  - `AVAILABLE`
  - `RESERVED`
  - `SOLD`
- Keep type enum limited to:
  - `APARTMENT`
  - `HOUSE`
  - `COMMERCIAL`
  - `LAND`
  - `OFFICE`

### Meetings

- Keep `scheduledAt` as a real datetime field.
- Keep upcoming endpoints stable:
  - global upcoming feed
  - agent-specific upcoming feed

### Admin agents

- Keep agent activation, deactivation, and role change behavior explicit.
- Keep admin-only access restricted in security configuration.

## Technical Debt / Follow-up

- Review null-safety in response mappers for deal/property relations.
- Keep repository queries and service-level normalization consistent.
- Reduce duplicate transformation logic between API layers and services.
- Add or extend tests for:
  - deal close flow
  - property status sync
  - profile update flow
  - upcoming meetings flow
  - admin agent role changes

## Testing Checklist

- Auth login returns valid tokens and user data.
- `GET /auth/me` returns the current user data.
- `PUT /auth/me` updates profile and returns refreshed auth response.
- Creating a deal with a linked property sets the property to reserved.
- Closing a deal with `CLOSED_WON` sets property to sold and fills `closedAt`.
- Closing a deal with `CLOSED_LOST` releases the property and fills `closedAt`.
- Re-updating the same closed deal does not fail when it still references the same property.
- Meeting creation requires the expected agent/client IDs.
- Upcoming endpoints return the expected data for both all-agents and single-agent modes.

## Suggested Order of Work

1. Lock down deal close flow and response mapping.
2. Add or strengthen backend tests for the business rules.
3. Verify auth/profile response consistency.
4. Validate meeting upcoming behavior.
5. Recheck property search and status transitions.
6. Finish security and admin role checks.
