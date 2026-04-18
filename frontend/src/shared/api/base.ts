import { useAuthStore } from '@/entities/auth/model/authStore'

const BASE_URL = import.meta.env.VITE_API_URL

export async function request<T>(
  path: string,
  options?: RequestInit
): Promise<T> {
  const headers = new Headers(options?.headers)

  // не ломаем FormData
  if (!(options?.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json')
  }

  const token = useAuthStore.getState().accessToken
  if (token) {
    headers.set('Authorization', `Bearer ${token}`)
  }

  const res = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers
  })

  if (!res.ok) {
    const body = await res.json().catch(() => ({}))

    if (res.status === 401) {
      console.error('Unauthorized')
      // позже сюда refresh token
    }

    throw new Error(body?.message ?? `HTTP ${res.status}`)
  }

  const text = await res.text()
  return text ? JSON.parse(text) : ({} as T)
}

export const api = {
  get: <T>(url: string) => request<T>(url, { method: 'GET' }),

  post: <T>(url: string, body?: unknown) =>
    request<T>(url, {
      method: 'POST',
      body: JSON.stringify(body)
    }),

  put: <T>(url: string, body?: unknown) =>
    request<T>(url, {
      method: 'PUT',
      body: JSON.stringify(body)
    }),

  delete: <T>(url: string) => request<T>(url, { method: 'DELETE' })
}
