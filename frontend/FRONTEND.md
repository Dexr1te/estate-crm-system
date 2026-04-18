# Estate CRM Frontend - Quick Reference

## Stack at a Glance

- **React 19** + **TypeScript** + **Vite**
- **TailwindCSS** + **Shadcn/ui** for UI
- **React Router v7** for routing
- **React Query v5** for server state
- **Zustand** for client state (auth only)

## Quick Navigation

```
src/
├── app/                    # App shell (router, providers, layouts)
├── entities/[domain]/      # Feature modules (auth, clients, deals, etc.)
├── features/               # Composable feature components
├── pages/                  # Route-level pages
├── components/ui/          # Shadcn UI components
├── shared/                 # Global utilities, hooks, store
└── styles/                 # Global CSS
```

## Essential Commands

```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run lint         # Run ESLint
npm run preview      # Preview production build
```

## Understanding the Code

### Entity Pattern (Most Important!)

Every domain (clients, properties, deals, meetings) follows this structure:

```
entity/
├── api/[entity].ts       # API calls using the `api` wrapper
├── model/types.ts        # TypeScript interfaces
├── model/use[Entity].ts  # React Query hooks
└── ui/[Entity].tsx       # Components
```

### Data Flow

```
Component
  ↓ (uses hook)
use[Entity]() → React Query
  ↓ (fetches data)
api.get('/endpoint')
  ↓ (with auth header)
Backend
```

### Authentication

- **Store**: Zustand in `src/entities/auth/model/authStore.ts`
- **Persisted**: Yes, to localStorage (`crm-auth`)
- **Token**: Automatically added to all requests
- **Login**: POST `/auth/login` → store token → redirect `/dashboard`

## Critical Files to Understand

| File                                   | Why It Matters                   |
| -------------------------------------- | -------------------------------- |
| `src/shared/api/base.ts`               | All HTTP calls go through here   |
| `src/entities/auth/model/authStore.ts` | How auth state is managed        |
| `src/app/router/AppRouter.tsx`         | All routes defined here          |
| `src/app/providers/AppProvider.tsx`    | React Query + Theme setup        |
| `vite.config.ts`                       | Build config + alias (`@` = src) |

## Common Tasks

### Use React Query to fetch data

```typescript
const { data, isPending } = useQuery({
  queryKey: ['clients'],
  queryFn: () => api.get<Client[]>('/clients')
})
```

### Make an API call

```typescript
// Always use the `api` wrapper (handles auth headers)
const response = await api.post('/clients', { name: 'John' })
```

### Access auth data

```typescript
const { accessToken, userId, role } = useAuthStore()
```

### Add a new page

1. Create in `src/pages/NewPage.tsx`
2. Add route to `AppRouter.tsx`
3. Add navigation item in `src/components/AppSidebar.tsx`

## Environment

Create `.env.local`:

```
VITE_API_URL=http://localhost:8080/api
```

## Important Rules

✅ Always use `api` wrapper for HTTP calls
✅ Use React Query for server state
✅ Use Zustand `useAuthStore()` for auth
✅ Use TailwindCSS utilities for styling
✅ Wrap UI in TypeScript interfaces
❌ Don't fetch directly without React Query
❌ Don't skip TypeScript types
❌ Don't add CSS files (use Tailwind)
❌ Don't bypass auth security

## Debugging

- DevTools: F12 → React Query tab (React Query DevTools)
- Auth: `localStorage.getItem('crm-auth')`
- API: Check Network tab for Authorization header
- Errors: Check Console for auth/query errors

---

**More Details**: See `.context.md` for comprehensive architecture guide.
