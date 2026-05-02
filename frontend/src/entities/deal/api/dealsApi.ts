import { request } from '@/shared/api/base'
import type {
  CreateDealPayload,
  Deal,
  DealStatus,
  DealsFilters
} from '../model/type'

function buildDealsQuery(filters?: DealsFilters) {
  if (!filters) return ''
  const params = new URLSearchParams()
  if (filters.agentId != null) params.set('agentId', String(filters.agentId))
  if (filters.status) params.set('status', filters.status)
  const query = params.toString()
  return query ? `?${query}` : ''
}

export const dealsApi = {
  getAll: (filters?: DealsFilters) =>
    request<Deal[]>(`/deals${buildDealsQuery(filters)}`),

  create: (data: CreateDealPayload) =>
    request<Deal>('/deals', {
      method: 'POST',
      body: JSON.stringify(data)
    }),

  update: (id: number, data: CreateDealPayload) =>
    request<Deal>(`/deals/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    }),

  updateStatus: (id: number, status: DealStatus) =>
    request<Deal>(`/deals/${id}/status?status=${status}`, {
      method: 'PATCH'
    })
}
