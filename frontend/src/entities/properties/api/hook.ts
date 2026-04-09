import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { propertiesApi } from './propertiesApi'

export const PROPERTIES_KEY = ['properties']

export function useProperties() {
  return useQuery({
    queryKey: PROPERTIES_KEY,
    queryFn: propertiesApi.getAll
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
