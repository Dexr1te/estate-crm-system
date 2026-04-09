import { request } from '@/shared/api/base'

export type DashboardSummary = {
  totalDeals: number
  activeDeals: number
  closedDeals: number
  totalClients: number
  upcomingMeetings: number
}

export const dashboardApi = {
  getSummary: () => request<DashboardSummary>('/dashboard/summary')
}
