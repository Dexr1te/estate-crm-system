import { api } from '@/shared/api/base'

export interface MeResponse {
  accessToken: string | null
  refreshToken: string | null
  tokenType: string
  userId: number
  fullName: string
  email: string
  role: 'ADMIN' | 'AGENT'
}

export interface UpdateMeRequest {
  fullName: string
  email: string
}

export const getMe = () => api.get<MeResponse>('/auth/me')
export const updateMe = (data: UpdateMeRequest) =>
  api.put<MeResponse>('/auth/me', data)
