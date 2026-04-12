import { api } from '@/shared/api/base'

export interface MeResponse {
  id: number
  fullName: string
  email: string
  role: 'ADMIN' | 'AGENT'
}

export const getMe = () => api.get<MeResponse>('/auth/me')
