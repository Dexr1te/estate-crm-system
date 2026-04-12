import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type Role = 'ADMIN' | 'AGENT'

interface AuthState {
  accessToken: string | null
  refreshToken: string | null

  userId: number | null
  fullName: string | null
  email: string | null
  role: Role | null

  setTokens: (access: string, refresh: string) => void
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
    { name: 'crm-auth' }
  )
)
