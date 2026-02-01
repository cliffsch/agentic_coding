# React/Supabase NFRs

> Platform-specific non-functional requirements for React + Vite + Supabase applications.
> These extend the common NFRs in `COMMON.md`.

## Platform Context

React/Supabase applications are web-based with both frontend and backend considerations. The frontend runs in browsers with varying capabilities; Supabase provides backend services including database, auth, and edge functions. Security is critical due to public exposure.

---

## React/Supabase Operability (RS-OPS)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| RS-OPS-1 | Structured logging | Console methods with JSON objects or logging library | Required |
| RS-OPS-2 | Error boundaries | React ErrorBoundary at route level minimum | Required |
| RS-OPS-3 | Environment-based config | All config via environment variables | Required |

### RS-OPS Implementation Patterns

**RS-OPS-1 Structured Logging:**
```typescript
// Simple structured logging
const log = {
  info: (message: string, data?: Record<string, unknown>) =>
    console.log(JSON.stringify({ level: 'INFO', message, ...data, timestamp: new Date().toISOString() })),
  warn: (message: string, data?: Record<string, unknown>) =>
    console.warn(JSON.stringify({ level: 'WARN', message, ...data, timestamp: new Date().toISOString() })),
  error: (message: string, data?: Record<string, unknown>) =>
    console.error(JSON.stringify({ level: 'ERROR', message, ...data, timestamp: new Date().toISOString() })),
};

// Usage
log.info('User logged in', { userId: user.id });
log.error('API call failed', { endpoint: '/api/data', status: 500 });
```

**RS-OPS-2 Error Boundary:**
```typescript
import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    log.error('React error boundary caught error', {
      error: error.message,
      componentStack: errorInfo.componentStack,
    });
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? <div>Something went wrong. Please refresh.</div>;
    }
    return this.props.children;
  }
}
```

**RS-OPS-3 Environment Configuration:**
```typescript
// src/config/env.ts
export const config = {
  supabaseUrl: import.meta.env.VITE_SUPABASE_URL,
  supabaseAnonKey: import.meta.env.VITE_SUPABASE_ANON_KEY,
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL,
  isDev: import.meta.env.DEV,
  logLevel: import.meta.env.VITE_LOG_LEVEL ?? 'INFO',
} as const;

// Validate required env vars
const required = ['supabaseUrl', 'supabaseAnonKey'] as const;
for (const key of required) {
  if (!config[key]) throw new Error(`Missing required env var: ${key}`);
}
```

---

## React/Supabase User Experience (RS-UX)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| RS-UX-1 | Graceful error handling | User-friendly messages, not raw exceptions | Required |
| RS-UX-2 | Toast notifications | Project chooses library (sonner, react-hot-toast) | Required |
| RS-UX-3 | Loading states | Skeleton or spinner during async operations | Required |
| RS-UX-4 | Optimistic updates | Where appropriate for perceived performance | Recommended |

### RS-UX Implementation Patterns

**RS-UX-1 User-Friendly Errors:**
```typescript
// Error message mapping
const userMessages: Record<string, string> = {
  'PGRST116': 'Record not found',
  'AUTH_INVALID_CREDENTIALS': 'Invalid email or password',
  'RATE_LIMITED': 'Too many requests. Please wait a moment.',
  default: 'Something went wrong. Please try again.',
};

function getUserMessage(error: unknown): string {
  if (error instanceof Error) {
    return userMessages[error.message] ?? userMessages.default;
  }
  return userMessages.default;
}
```

**RS-UX-2 Toast Notifications:**
```typescript
// Using sonner (recommended)
import { toast } from 'sonner';

// Success feedback
toast.success('Changes saved');

// Error with user-friendly message
toast.error(getUserMessage(error));

// With action
toast('Item deleted', {
  action: {
    label: 'Undo',
    onClick: () => undoDelete(),
  },
});
```

---

## React/Supabase Security (RS-SEC)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| RS-SEC-1 | RLS policies | All tables require Row Level Security | Required |
| RS-SEC-2 | Auth state validation | Check auth before protected operations | Required |
| RS-SEC-3 | No sensitive data in client | API keys only; no secrets in frontend | Required |
| RS-SEC-4 | Input sanitization | Validate/sanitize user inputs | Required |

### RS-SEC Implementation Patterns

**RS-SEC-1 RLS Policy Example:**
```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can only read their own profile
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
```

**RS-SEC-2 Auth Guard:**
```typescript
// Route protection
function ProtectedRoute({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth();

  if (loading) return <LoadingSpinner />;
  if (!user) return <Navigate to="/login" />;

  return <>{children}</>;
}

// API call protection
async function fetchUserData() {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  return supabase.from('profiles').select('*').eq('id', user.id);
}
```

---

## React/Supabase Alerting (RS-ALT)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| RS-ALT-1 | Backend operator alerts | Supabase Edge Function → webhook/email | Required |
| RS-ALT-2 | Frontend error reporting | Error boundary sends to monitoring | Recommended |
| RS-ALT-3 | Rate limit alerts | Notify when approaching API limits | Recommended |

### RS-ALT Implementation Patterns

**RS-ALT-1 Edge Function Alert:**
```typescript
// supabase/functions/alert/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const { level, message, context } = await req.json();

  // Send to webhook (Slack, Discord, etc.)
  await fetch(Deno.env.get('ALERT_WEBHOOK_URL')!, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      text: `[${level}] ${message}`,
      attachments: [{ fields: Object.entries(context).map(([k, v]) => ({ title: k, value: v })) }],
    }),
  });

  return new Response(JSON.stringify({ success: true }));
});
```

**RS-ALT-2 Error Boundary Reporting:**
```typescript
componentDidCatch(error: Error, errorInfo: ErrorInfo) {
  // Log locally
  log.error('React error', { error: error.message, stack: errorInfo.componentStack });

  // Send to monitoring (if configured)
  if (config.errorReportingEndpoint) {
    fetch(config.errorReportingEndpoint, {
      method: 'POST',
      body: JSON.stringify({ error: error.message, stack: error.stack, component: errorInfo.componentStack }),
    }).catch(() => {}); // Don't throw on reporting failure
  }
}
```

---

## React/Supabase Performance (RS-PRF)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| RS-PRF-1 | Query caching | React Query with appropriate staleTime | Required |
| RS-PRF-2 | Bundle optimization | Code splitting, lazy loading | Recommended |
| RS-PRF-3 | Realtime subscription cleanup | Unsubscribe on unmount | Required |

### RS-PRF Implementation Patterns

**RS-PRF-1 React Query Configuration:**
```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 30, // 30 minutes
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});
```

**RS-PRF-3 Realtime Cleanup:**
```typescript
useEffect(() => {
  const channel = supabase
    .channel('changes')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'items' }, handleChange)
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
}, []);
```

---

## Compliance Checklist for Design Review

- [ ] Error boundaries wrap route components
- [ ] Structured logging is implemented
- [ ] Environment variables used for all config
- [ ] RLS policies defined for all tables
- [ ] Toast notifications for user feedback
- [ ] Loading states for async operations
- [ ] Auth guards on protected routes
- [ ] Operator alerting mechanism in place
- [ ] React Query configured with caching
- [ ] Realtime subscriptions cleaned up on unmount
