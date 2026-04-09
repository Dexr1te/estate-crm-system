import { Navigate, Outlet } from 'react-router-dom'
import { useAuthStore } from '@/shared/store/useAuthStore'

type Props = {
  redirectPath?: string
}

export function ProtectedRoute({ redirectPath = '/login' }: Props) {
  const token = useAuthStore((state) => state.accessToken)

  if (!token) {
    return <Navigate to={redirectPath} replace />
  }
  return <Outlet />
}
