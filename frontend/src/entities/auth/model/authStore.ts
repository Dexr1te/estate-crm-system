import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type Role = 'AGENT' | 'ADMIN'

interface AuthData {
  accessToken: string | null
  refreshToken: string | null
  userId: number | null
  fullName: string | null
  email: string | null
  role: Role | null
}

interface AuthState {
  accessToken: string | null
  refreshToken: string | null
  userId: number | null
  fullName: string | null
  email: string | null
  role: Role | null
  setAuth: (payload: AuthData) => void
  setTokens: (accessToken: string, refreshToken: string) => void
  setUser: (user: {
    id: number
    fullName: string
    email: string
    role: Role
  }) => void
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
      setTokens: (accessToken, refreshToken) =>
        set({ accessToken, refreshToken }),
      setUser: (user) =>
        set({
          userId: user.id,
          fullName: user.fullName,
          email: user.email,
          role: user.role
        }),
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
