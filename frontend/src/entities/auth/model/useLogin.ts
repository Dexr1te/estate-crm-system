import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthStore } from '@/shared/store/useAuthStore'
import { loginRequest } from '../api/auth'

export function useLogin() {
  const navigate = useNavigate()
  const setAuth = useAuthStore((s) => s.setAuth)

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setLoading(true)

    try {
      const data = await loginRequest(email, password)

      setAuth({
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        userId: data.userId,
        fullName: data.fullName,
        email: data.email,
        role: data.role
      })

      navigate('/dashboard')
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : 'Something went wrong'

      setError(message)
    } finally {
      setLoading(false)
    }
  }

  return {
    email,
    password,
    showPassword,
    error,
    loading,
    setEmail,
    setPassword,
    setShowPassword,
    handleSubmit
  }
}
