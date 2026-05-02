import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { propertiesApi } from '../api/propertiesApi'
import type { PropertyFilters } from './types'

export const PROPERTIES_KEY = ['properties']

export function useProperties(filters?: PropertyFilters) {
  return useQuery({
    queryKey: [...PROPERTIES_KEY, filters ?? {}],
    queryFn: () => propertiesApi.getAll(filters)
  })
}

export function useCreateProperty() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: propertiesApi.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: PROPERTIES_KEY })
    }
  })
}

export function useUpdatePropertyStatus() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: ({ id, status }: { id: number; status: 'AVAILABLE' | 'RESERVED' | 'SOLD' }) =>
      propertiesApi.updateStatus(id, status),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: PROPERTIES_KEY })
    }
  })
}
