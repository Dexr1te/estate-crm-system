import { request } from '@/shared/api/base'
import type { Property, PropertyCreateRequest, PropertyFilters } from '../model/types'

function buildQuery(filters?: PropertyFilters) {
  if (!filters) return ''

  const params = new URLSearchParams()

  if (filters.search?.trim()) params.set('search', filters.search.trim())
  if (filters.status) params.set('status', filters.status)
  if (filters.type) params.set('type', filters.type)
  if (filters.city?.trim()) params.set('city', filters.city.trim())
  if (filters.minPrice != null) params.set('minPrice', String(filters.minPrice))
  if (filters.maxPrice != null) params.set('maxPrice', String(filters.maxPrice))

  const query = params.toString()
  return query ? `?${query}` : ''
}

export const propertiesApi = {
  getAll: (filters?: PropertyFilters) =>
    request<Property[]>(`/properties${buildQuery(filters)}`),

  create: (data: PropertyCreateRequest) =>
    request('/properties', {
      method: 'POST',
      body: JSON.stringify(data)
    }),

  updateStatus: (id: number, status: Property['status']) =>
    request<Property>(`/properties/${id}/status?status=${status}`, {
      method: 'PATCH'
    })
}
