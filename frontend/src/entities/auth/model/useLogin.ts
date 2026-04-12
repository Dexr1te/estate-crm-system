import { useMutation } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { loginRequest } from '../api/auth'
import { useAuthStore } from './store'

export const useLogin = () => {
  const navigate = useNavigate()
  const setTokens = useAuthStore((s) => s.setTokens)
  const setUser = useAuthStore((s) => s.setUser)

  return useMutation({
    mutationFn: ({ email, password }: { email: string; password: string }) =>
      loginRequest(email, password),

    onSuccess: (data) => {
      setTokens(data.accessToken, data.refreshToken)

      setUser({
        id: data.userId,
        fullName: data.fullName,
        email: data.email,
        role: data.role
      })

      navigate('/dashboard')
    }
  })
}
