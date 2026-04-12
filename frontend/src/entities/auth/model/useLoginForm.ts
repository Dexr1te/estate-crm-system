import { useState } from 'react'
import { useLogin } from './useLogin'

export const useLoginForm = () => {
  const login = useLogin()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    login.mutate({ email, password })
  }

  return {
    email,
    password,
    showPassword,

    setEmail,
    setPassword,
    setShowPassword,

    handleSubmit,

    loading: login.isPending,
    error: login.error instanceof Error ? login.error.message : null
  }
}
