import { useQuery } from '@tanstack/react-query'
import { getMe } from '../api/me'
import { useAuthStore } from '@/entities/auth/model/authStore'

export const useMe = () => {
  const token = useAuthStore((s) => s.accessToken)

  return useQuery({
    queryKey: ['me'],
    queryFn: getMe,
    enabled: !!token,
    retry: false
  })
}
