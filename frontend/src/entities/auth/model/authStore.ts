import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type Role = 'AGENT' | 'ADMIN'

interface AuthState {
  accessToken: string | null
  refreshToken: string | null
  userId: number | null
  fullName: string | null
  email: string | null
  role: Role | null
  setAuth: (payload: Omit<AuthState, 'setAuth' | 'clearAuth'>) => void
  clearAuth: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      accessToken: null,
      refreshToken: null,
      userId: null,
      fullName: null,
      email: null,
      role: null,
      setAuth: (payload) => set(payload),
      clearAuth: () =>
        set({
          accessToken: null,
          refreshToken: null,
          userId: null,
          fullName: null,
          email: null,
          role: null
        })
    }),
    { name: 'crm-auth' } // persists to localStorage
  )
)
