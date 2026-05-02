import type { CreateMeetingDto, Meeting, UpdateMeetingDto } from '../model/type'
import { request } from '@/shared/api/base'

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
