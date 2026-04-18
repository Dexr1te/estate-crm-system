import { api } from '@/shared/api/base'

export interface LoginDto {
  email: string
  password: string
}

export interface LoginResponse {
  accessToken: string
  refreshToken: string
  user: {
    id: number
    fullName: string
    email: string
    role: 'ADMIN' | 'AGENT'
  }
}

export const loginApi = async (data: LoginDto) => {
  const res = await api.post<LoginResponse>('/auth/login', data)
  return res
}
