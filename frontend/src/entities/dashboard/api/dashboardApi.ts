import { request } from '@/shared/api/base'
import type { DashboardSummary } from '../model/types'

export const dashboardApi = {
  getSummary: () => request<DashboardSummary>('/dashboard/summary')
}
