import type { Role } from '@/shared/store/useAuthStore'

const BASE_URL = import.meta.env.VITE_API_URL

interface AuthResponse {
  accessToken: string
  refreshToken: string
  tokenType: string
  userId: number
  fullName: string
  email: string
  role: Role
}

export async function loginRequest(
  email: string,
  password: string
): Promise<AuthResponse> {
  const res = await fetch(`${BASE_URL}/auth/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ email, password })
  })

  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body?.message ?? 'Invalid email or password')
  }

  return res.json()
}
