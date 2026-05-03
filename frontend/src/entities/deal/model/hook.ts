import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { dealsApi } from '@/entities/deal/api/dealsApi'
import type { CreateDealPayload, DealStatus, DealsFilters } from './type'

export const DEALS_KEY = ['deals']

export function useDeals(filters?: DealsFilters) {
  return useQuery({
    queryKey: [...DEALS_KEY, filters ?? {}],
    queryFn: () => dealsApi.getAll(filters)
  })
}

export function useCreateDeal() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: (payload: CreateDealPayload) => dealsApi.create(payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: DEALS_KEY })
    }
  })
}

export function useUpdateDeal() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: CreateDealPayload }) =>
      dealsApi.update(id, payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: DEALS_KEY })
    }
  })
}

export function useUpdateDealStatus() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: ({ id, status }: { id: number; status: DealStatus }) =>
      dealsApi.updateStatus(id, status),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: DEALS_KEY })
    }
  })
}

export function useDeleteDeal() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => dealsApi.delete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: DEALS_KEY })
    }
  })
}
