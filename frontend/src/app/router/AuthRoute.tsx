import { useAuthStore } from '@/shared/store/useAuthStore'
import React from 'react'
import { Navigate } from 'react-router-dom'

export const AuthRoute = ({ children }: { children: React.ReactNode }) => {
  const accessToken = useAuthStore((state) => state.accessToken)

  if (accessToken) {
    return <Navigate to="/" replace />
  }

  return children
}
