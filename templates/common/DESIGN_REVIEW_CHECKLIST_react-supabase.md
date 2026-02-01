# Design Review Checklist - React/Vite/Supabase

> Validates DESIGN.md and IMPLEMENTATION.md completeness for React applications with Supabase backend before implementation begins.

## Pre-Review Verification

- [ ] DESIGN.md exists and is readable
- [ ] IMPLEMENTATION.md exists and is readable
- [ ] FRONTEND_SPEC.md exists (if applicable)
- [ ] API_SPEC.md exists (if applicable)
- [ ] DATABASE_SCHEMA.md exists (if applicable)
- [ ] All referenced files exist

---

## 1. React Architecture Requirements

### 1.1 Component Structure
- [ ] Component hierarchy is defined
- [ ] Page components are identified
- [ ] Shared/reusable components are specified
- [ ] Layout components are defined

### 1.2 State Management
- [ ] React Query is specified for server state
- [ ] Local state management approach is defined (useState, useReducer, Context)
- [ ] Global state needs are identified

---

## 2. Supabase Integration

### 2.1 Client Configuration
- [ ] Supabase client initialization is specified
- [ ] Environment variables for Supabase URL and anon key are documented
- [ ] Client is configured with proper options

### 2.2 Database Schema
- [ ] All tables are defined with columns and types
- [ ] Relationships (foreign keys) are specified
- [ ] Row Level Security (RLS) policies are documented
- [ ] Indexes are defined for performance

### 2.3 TypeScript Types
- [ ] Database types are generated or defined
- [ ] Type definitions match schema
- [ ] Type safety is enforced throughout

---

## 3. API and Data Fetching

### 3.1 API Structure
- [ ] API routes follow RESTful conventions
- [ ] Supabase functions are defined (if using Edge Functions)
- [ ] Webhook endpoints are specified

### 3.2 Data Fetching Patterns
- [ ] React Query hooks are defined for each data operation
- [ ] Loading states are handled
- [ ] Error states are handled
- [ ] Caching strategy is specified

---

## 4. Authentication

### 4.1 Auth Flow
- [ ] Authentication method is specified (email, OAuth, etc.)
- [ ] Protected routes are identified
- [ ] Auth state management is defined

### 4.2 Authorization
- [ ] Role-based access is specified (if applicable)
- [ ] RLS policies enforce authorization rules

---

## 5. Environment and Configuration

### 5.1 Environment Variables
- [ ] .env.example file is documented
- [ ] All required env vars are listed
- [ ] Default values are specified where appropriate

### 5.2 Vercel Configuration
- [ ] vercel.json is specified (if needed)
- [ ] Build settings are defined
- [ ] Environment variables for deployment are documented

---

## 6. Error Handling

### 6.1 Error Boundaries
- [ ] Error boundaries are implemented at appropriate levels
- [ ] Fallback UI is specified

### 6.2 API Error Handling
- [ ] API errors are caught and handled
- [ ] User-friendly error messages are defined
- [ ] Retry logic is specified where appropriate

---

## 7. Implementation Plan Validation

### 7.1 Phase Completeness
- [ ] Phase 1: Project setup (Vite config, TypeScript, folder structure)
- [ ] Phase 2: Supabase integration (client, types, auth)
- [ ] Phase 3: Core components (pages, layouts, shared)
- [ ] Phase 4: API integration (hooks, services)
- [ ] Phase 5: n8n webhook integration (if applicable)
- [ ] Phase 6: Styling and UI polish
- [ ] Phase 7: Build and deployment config

### 7.2 Deployment Considerations
- [ ] Git commit triggers Vercel deployment
- [ ] Supabase migrations are in supabase/migrations/
- [ ] n8n workflows deployment is documented (if applicable)

---

## 8. Common React/Supabase Pitfalls

### 8.1 Type Safety
- [ ] Supabase types are properly generated
- [ ] No `any` types for database operations
- [ ] Props are properly typed

### 8.2 Performance
- [ ] React Query cache configuration is appropriate
- [ ] Unnecessary re-renders are minimized
- [ ] Large lists use virtualization (if needed)

### 8.3 Security
- [ ] No sensitive data in client-side code
- [ ] API keys are in environment variables
- [ ] RLS policies are properly configured

---

## Review Decision

**Status**: [ ] DESIGN_APPROVED / [ ] DESIGN_ISSUES_FOUND

### If APPROVED:
- Create `DESIGN_APPROVED.md`
- Implementation can proceed

### If ISSUES_FOUND:
- Create `DESIGN_ISSUES.md` with:
  - Issue description
  - Location (file, section)
  - Severity (Critical/Medium/Low)
  - Recommendation
  - Example fix

---

## Review Output Checklist

- [ ] DESIGN_REVIEW_RESULTS.md created with detailed findings
- [ ] All Critical issues documented (if any)
- [ ] All Medium issues documented (if any)
- [ ] DESIGN_APPROVED.md OR DESIGN_ISSUES.md created
- [ ] Human notified if Critical issues found
