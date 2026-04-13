import { useAuthStore } from '@/entities/auth/model/authStore'
import React from 'react'
import { Navigate } from 'react-router-dom'

export const AuthRoute = ({ children }: { children: React.ReactNode }) => {
  const accessToken = useAuthStore((state) => state.accessToken)

  if (accessToken) {
    return <Navigate to="/dashboard" replace />
  }

  return children
}
