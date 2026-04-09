import { request } from '@/shared/api/base'
import { useAuthStore } from '@/shared/store/useAuthStore'
import type { Deal } from '../model/type'

export const dealsApi = {
  getAll: () => request<Deal[]>('/deals'),

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  create: (data: any) => {
    const agentId = useAuthStore.getState().userId

    return request('/deals', {
      method: 'POST',
      body: JSON.stringify({
        ...data,
        agentId
      })
    })
  },

  updateStatus: (id: number, status: string) =>
    request(`/deals/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status })
    })
}
