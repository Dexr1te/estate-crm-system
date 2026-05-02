import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { dealsApi } from '@/entities/deal/api/dealsApi'

export const DEALS_KEY = ['deals']

export function useDeals() {
  return useQuery({
    queryKey: DEALS_KEY,
    queryFn: dealsApi.getAll
  })
}

export function useCreateDeal() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: dealsApi.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: DEALS_KEY })
    }
  })
}

export function useUpdateDealStatus() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) =>
      dealsApi.updateStatus(id, status),

    onSuccess: () => {
      qc.invalidateQueries({ queryKey: DEALS_KEY })
    }
  })
}
