import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { clientsApi } from '../api/clientsApi'

export const CLIENTS_KEY = ['clients']

export function useClients() {
  return useQuery({
    queryKey: CLIENTS_KEY,
    queryFn: clientsApi.getAll
  })
}

export function useCreateClient() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: clientsApi.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: CLIENTS_KEY })
    }
  })
}

export function useDeleteClient() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => clientsApi.delete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: CLIENTS_KEY })
    }
  })
}
