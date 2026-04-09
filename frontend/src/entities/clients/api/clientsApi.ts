import { request } from '@/shared/api/base'

export type ClientListItem = {
  id: number
  fullName: string
  email?: string
  phone?: string
  type: 'BUYER' | 'SELLER'
  notes?: string
}

export const clientsApi = {
  getAll: () => request<ClientListItem[]>('/clients/with-details'),

  create: (data: Partial<ClientListItem>) =>
    request('/clients', {
      method: 'POST',
      body: JSON.stringify(data)
    })
}
