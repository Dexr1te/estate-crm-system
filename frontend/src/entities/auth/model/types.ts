import type { Role } from '@/shared/store/useAuthStore'

export const BASE_URL = import.meta.env.VITE_API_URL

export interface AuthResponse {
  accessToken: string
  refreshToken: string
  tokenType: string
  userId: number
  fullName: string
  email: string
  role: Role
}
