import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { getMe, updateMe, type UpdateMeRequest } from '../api/me'
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

export const useUpdateMe = () => {
  const queryClient = useQueryClient()
  const setAuth = useAuthStore((s) => s.setAuth)
  const setUser = useAuthStore((s) => s.setUser)

  return useMutation({
    mutationFn: (data: UpdateMeRequest) => updateMe(data),
    onSuccess: (updated) => {
      if (updated.accessToken && updated.refreshToken) {
        setAuth({
          accessToken: updated.accessToken,
          refreshToken: updated.refreshToken,
          userId: updated.userId,
          fullName: updated.fullName,
          email: updated.email,
          role: updated.role
        })
      }
      setUser({
        id: updated.userId,
        fullName: updated.fullName,
        email: updated.email,
        role: updated.role
      })
      queryClient.setQueryData(['me'], updated)
    }
  })
}
