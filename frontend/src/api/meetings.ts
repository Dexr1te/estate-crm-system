const BASE_URL: string =
  import.meta.env.VITE_API_URL || 'http://192.168.100.168:8080/api'

type RequestOptions = RequestInit & {
  headers?: Record<string, string>
}

async function request<T = unknown>(
  path: string,
  options: RequestOptions = {}
): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options
  })

  if (!res.ok) {
    const text = await res.text().catch(() => 'Unknown error')
    throw new Error(text || `HTTP ${res.status}`)
  }

  return res.json() as Promise<T>
}

// ==== Типы данных ====

export interface Meeting {
  id: number
  title: string
  description?: string
  scheduledAt: string
  completed?: boolean
  location?: string
  agentName?: string
  dealTitle?: string
  clientName?: string
}

export interface CreateMeetingDto {
  title: string
  description?: string
  scheduledAt: string
  location?: string
  dealId?: number
  agentId?: number
  clientId?: number
}

// eslint-disable-next-line @typescript-eslint/no-empty-object-type
export interface UpdateMeetingDto extends Partial<CreateMeetingDto> {}

// ==== API ====

export const meetingsApi = {
  getAll: (agentId?: string) => {
    const params = agentId ? `?agentId=${agentId}` : ''
    return request<Meeting[]>(`/meetings${params}`)
  },

  getById: (id: string) => request<Meeting>(`/meetings/${id}`),

  getUpcoming: (agentId: string) =>
    request<Meeting[]>(`/meetings/upcoming?agentId=${agentId}`),

  create: (data: CreateMeetingDto) =>
    request<Meeting>('/meetings', {
      method: 'POST',
      body: JSON.stringify(data)
    }),

  update: (id: string, data: UpdateMeetingDto) =>
    request<Meeting>(`/meetings/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    }),

  complete: (id: string) =>
    request<Meeting>(`/meetings/${id}/complete`, {
      method: 'PATCH'
    })
}
