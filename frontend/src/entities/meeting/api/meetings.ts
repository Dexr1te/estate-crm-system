import { request } from '@/shared/api/base'
import type {
  CreateMeetingDto,
  Meeting,
  UpcomingMeetingItem,
  UpdateMeetingDto
} from '../model/type'

export const meetingsApi = {
  getAll: (agentId?: number) => {
    const params = agentId != null ? `?agentId=${agentId}` : ''
    return request<Meeting[]>(`/meetings${params}`)
  },

  getById: (id: number) => request<Meeting>(`/meetings/${id}`),

  getUpcomingByAgent: (agentId: number) =>
    request<Meeting[]>(`/meetings/upcoming/agent/${agentId}`),

  getUpcomingAll: () => request<UpcomingMeetingItem[]>('/meetings/upcoming'),

  create: (data: CreateMeetingDto) =>
    request<Meeting>('/meetings', {
      method: 'POST',
      body: JSON.stringify(data)
    }),

  update: (id: number, data: UpdateMeetingDto) =>
    request<Meeting>(`/meetings/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    }),

  complete: (id: number) =>
    request<Meeting>(`/meetings/${id}/complete`, {
      method: 'PATCH'
    }),

  remove: (id: number) =>
    request<void>(`/meetings/${id}`, {
      method: 'DELETE'
    })
}
