import { request } from '@/shared/api/base'

export type Property = {
  id: number
  title: string
  description: string
  type: string
  status: 'AVAILABLE' | 'SOLD' | 'RESERVED'
  address: string
  price: number
  city?: string
}

export const propertiesApi = {
  getAll: () => request<Property[]>('/properties'),

  create: (data: Partial<Property>) =>
    request('/properties', {
      method: 'POST',
      body: JSON.stringify(data)
    })
}
