import { useLocation } from 'react-router-dom'
import { SidebarProvider, SidebarInset } from '@/components/ui/sidebar'
import { AppSidebar } from '@/components/AppSidebar'
import { SidebarTrigger } from '@/components/ui/sidebar'
import { Outlet } from 'react-router-dom'

const PAGE_TITLES: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/clients': 'Clients',
  '/properties': 'Properties',
  '/deals': 'Deals',
  '/meetings': 'Meetings',
  '/upcoming': 'Upcoming',
  '/agents': 'Agents',
  '/help': 'Help',
  '/profile': 'Profile',
  '/settings': 'Settings'
}

export function AppLayout() {
  const { pathname } = useLocation()
  const pageTitle = PAGE_TITLES[pathname] ?? 'Estate CRM'

  return (
    <SidebarProvider>
      <AppSidebar />

      <SidebarInset className="min-w-0">
        <div className="sticky top-0 z-30 flex h-14 items-center gap-3 border-b bg-background/95 px-4 backdrop-blur md:hidden">
          <SidebarTrigger />
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold">Estate CRM</p>
            <p className="truncate text-xs text-muted-foreground">
              {pageTitle}
            </p>
          </div>
        </div>

        <main className="flex-1 flex min-h-0 flex-col overflow-auto">
          <Outlet />
        </main>
      </SidebarInset>
    </SidebarProvider>
  )
}
