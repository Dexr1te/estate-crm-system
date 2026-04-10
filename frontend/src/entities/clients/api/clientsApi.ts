import { request } from '@/shared/api/base'
import type { ClientListItem } from '../model/type'

export const clientsApi = {
  getAll: () => request<ClientListItem[]>('/clients/with-details'),

  create: (data: Partial<ClientListItem>) =>
    request('/clients', {
      method: 'POST',
      body: JSON.stringify(data)
    })
}
