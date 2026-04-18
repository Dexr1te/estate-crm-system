import { request } from '@/shared/api/base'
import type { Property } from '../model/types'

export const propertiesApi = {
  getAll: () => request<Property[]>('/properties'),

  create: (data: Partial<Property>) =>
    request('/properties', {
      method: 'POST',
      body: JSON.stringify(data)
    })
}
