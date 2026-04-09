import { useQuery } from '@tanstack/react-query'
import { dashboardApi } from './dashboardApi'

export const DASHBOARD_KEY = ['dashboard']

export function useDashboard() {
  return useQuery({
    queryKey: DASHBOARD_KEY,
    queryFn: dashboardApi.getSummary
  })
}
