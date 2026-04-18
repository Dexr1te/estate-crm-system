import { request } from '@/shared/api/base'
import type { ClientListItem, ClientRequest } from '../model/type'

export const clientsApi = {
  getAll: () => request<ClientListItem[]>('/clients/with-details'),

  create: (data: ClientRequest) =>
    request('/clients', {
      method: 'POST',
      body: JSON.stringify(data)
    })
}
