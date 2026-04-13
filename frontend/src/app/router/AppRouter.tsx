import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AppLayout } from '../layouts/AppLayout'
import { AuthLayout } from '../layouts/AuthLayout'

import { MeetingsPage } from '@/pages/MeetingsPage'
import { UpcomingPage } from '@/pages/UpcomingPage'
import LoginPage from '@/pages/LoginPage'
import { ProtectedRoute } from './ProtectedRoute'
import { AuthRoute } from './AuthRoute'
import { DashboardPage } from '@/pages/DashboardPage'
import { ClientsPage } from '@/pages/ClientsPage'
import { PropertiesPage } from '@/pages/PropertiesPage'
import { DealsPage } from '@/pages/DealsPage'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        {/* AUTH */}
        <Route element={<AuthLayout />}>
          <Route
            path="/login"
            element={
              <AuthRoute>
                <LoginPage />
              </AuthRoute>
            }
          />
        </Route>

        {/* APP (protected) */}
        <Route element={<ProtectedRoute />}>
          <Route element={<AppLayout />}>
            {/* 👉 главная */}
            <Route path="/dashboard" element={<DashboardPage />} />

            {/* 👉 CRM pages */}
            <Route path="/clients" element={<ClientsPage />} />
            <Route path="/properties" element={<PropertiesPage />} />
            <Route path="/deals" element={<DealsPage />} />
            <Route path="/meetings" element={<MeetingsPage />} />
            <Route path="/upcoming" element={<UpcomingPage />} />
          </Route>
        </Route>

        {/* fallback */}
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
