# Design Document: {PROJECT_NAME}

> React + Vite + Supabase Web Application Design Specification

## Overview

| Field | Value |
|-------|-------|
| **Project** | {PROJECT_NAME} |
| **Type** | Web Application |
| **Platform** | React + Vite + Supabase |
| **Author** | {AUTHOR} |
| **Created** | {DATE} |

## Purpose

{One paragraph describing what this application does and why it's needed}

## Requirements

### Functional Requirements

1. **FR-1**: {Requirement description}
   - Acceptance: {How to verify}

2. **FR-2**: {Requirement description}
   - Acceptance: {How to verify}

### Non-Functional Requirements

> Baseline NFRs from `templates/nfr/COMMON.md` and `templates/nfr/react-supabase.md` apply.
> Document any overrides in `NFR_OVERRIDES.md`.

| Category | Key Requirements | Status |
|----------|-----------------|--------|
| **Operability** | Structured logging, error boundaries, environment config | [ ] |
| **User Experience** | Graceful errors, toast notifications, loading states | [ ] |
| **Performance** | React Query caching, realtime subscription cleanup | [ ] |
| **Security** | RLS policies, auth guards, no secrets in frontend | [ ] |
| **Alerting** | Edge function alerts, error boundary reporting | [ ] |

**Project-Specific NFRs:**
1. {Additional NFR if needed}

**NFR Overrides:** {Reference NFR_OVERRIDES.md if deviations exist}

## Architecture

### Component Structure

```
src/
├── components/
│   ├── ui/           # Reusable UI components
│   ├── layout/       # Layout components
│   └── features/     # Feature-specific components
├── hooks/            # Custom React hooks
├── lib/              # Utilities and Supabase client
├── pages/            # Page components
├── types/            # TypeScript types
└── config/           # Environment configuration
```

### Page Components

| Page | Route | Description |
|------|-------|-------------|
| {Page1} | `/` | {Description} |
| {Page2} | `/{path}` | {Description} |

### Database Schema

| Table | Purpose | RLS |
|-------|---------|-----|
| {table1} | {Purpose} | {Policy description} |
| {table2} | {Purpose} | {Policy description} |

### Authentication

| Auth Method | Configuration |
|-------------|--------------|
| {Method} | {Details} |

## Data Flow

### State Management

| State Type | Approach |
|------------|----------|
| Server state | React Query |
| Global state | {Context / Zustand / etc.} |
| Local state | useState |

### API Integration

| Endpoint | Method | Purpose |
|----------|--------|---------|
| {/api/...} | {GET/POST} | {Description} |

## Error Handling

### Error Boundaries

| Level | Fallback |
|-------|----------|
| App root | Full error page |
| Route | Route-specific error |
| Component | Component placeholder |

### Error Messages

| Error Type | User Message |
|------------|--------------|
| Auth error | {User-friendly message} |
| API error | {User-friendly message} |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `VITE_SUPABASE_URL` | Yes | Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | Yes | Supabase anonymous key |
| {Additional vars} | | |

## Verification Strategy

### Pre-Implementation
- [ ] Database schema designed
- [ ] RLS policies defined
- [ ] Component hierarchy documented
- [ ] Error handling strategy specified

### Post-Implementation
- [ ] All pages render without errors
- [ ] Auth flow works end-to-end
- [ ] Error boundaries catch errors gracefully
- [ ] RLS policies enforce access control
- [ ] Lighthouse score acceptable

## Handoff Notes

### For Implementation Agent

1. **TypeScript**: Use strict mode, no `any` types
2. **Styling**: {Tailwind / CSS Modules / etc.}
3. **Components**: Prefer composition over inheritance
4. **Testing**: {Testing approach if any}

### Deployment

1. Supabase migrations in `supabase/migrations/`
2. Vercel deployment on push to main
3. Environment variables configured in Vercel dashboard

### Known Constraints

- {Any platform-specific constraints}
- {Browser support requirements}
