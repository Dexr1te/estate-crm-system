import { useNavigate, useLocation } from 'react-router-dom'
import {
  LayoutDashboard,
  Users,
  Building2,
  Handshake,
  Calendar,
  Bell,
  ShieldCheck,
  Settings,
  HelpCircle,
  LogOut,
  UserCircle,
  ChevronUp
} from 'lucide-react'

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar
} from '@/components/ui/sidebar'

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'

import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { useAuthStore } from '@/entities/auth/model/authStore'

// ─── Nav config ──────────────────────────────────────────────────────────────

const navMain = [
  { title: 'Dashboard', url: '/dashboard', icon: LayoutDashboard },
  { title: 'Clients', url: '/clients', icon: Users },
  { title: 'Properties', url: '/properties', icon: Building2 },
  { title: 'Deals', url: '/deals', icon: Handshake },
  { title: 'Meetings', url: '/meetings', icon: Calendar },
  { title: 'Upcoming', url: '/upcoming', icon: Bell }
]

const navSecondary = [
  { title: 'Settings', url: '/settings', icon: Settings },
  { title: 'Help', url: '/help', icon: HelpCircle }
]

// ─── Helpers ─────────────────────────────────────────────────────────────────

function initials(name: string | null) {
  if (!name) return 'U'
  return name
    .split(' ')
    .slice(0, 2)
    .map((n) => n[0])
    .join('')
    .toUpperCase()
}

// ─── Component ───────────────────────────────────────────────────────────────

export function AppSidebar() {
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const { isMobile } = useSidebar()

  const { fullName, email, role, clearAuth } = useAuthStore()
  const navItems = [
    ...navMain,
    ...(role === 'ADMIN'
      ? [{ title: 'Agents', url: '/agents', icon: ShieldCheck }]
      : [])
  ]

  const handleLogout = () => {
    clearAuth()
    navigate('/login', { replace: true })
  }

  return (
    <Sidebar collapsible="offcanvas">
      {/* ── Header / Brand ── */}
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              size="lg"
              onClick={() => navigate('/dashboard')}
              className="gap-3"
            >
              {/* Diamond brand mark */}
              <div className="flex size-8 items-center justify-center rounded-md bg-primary/10 shrink-0">
                <div className="size-3 rotate-45 bg-primary rounded-xs" />
              </div>
              <div className="flex flex-col leading-tight">
                <span className="text-sm font-semibold">Estate CRM</span>
                <span className="text-[11px] text-muted-foreground capitalize">
                  {role?.toLowerCase() ?? 'agent'}
                </span>
              </div>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      {/* ── Main Nav ── */}
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Navigation</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {navItems.map((item) => {
                const active = pathname === item.url
                return (
                  <SidebarMenuItem key={item.url}>
                    <SidebarMenuButton
                      tooltip={item.title}
                      isActive={active}
                      onClick={() => navigate(item.url)}
                    >
                      <item.icon className="size-4" />
                      <span>{item.title}</span>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* ── Secondary Nav ── */}
        <SidebarGroup className="mt-auto">
          <SidebarGroupContent>
            <SidebarMenu>
              {navSecondary.map((item) => (
                <SidebarMenuItem key={item.url}>
                  <SidebarMenuButton
                    tooltip={item.title}
                    isActive={pathname === item.url}
                    onClick={() => navigate(item.url)}
                  >
                    <item.icon className="size-4" />
                    <span>{item.title}</span>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      {/* ── Footer / User ── */}
      <SidebarFooter>
        <SidebarMenu>
          <SidebarMenuItem>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <SidebarMenuButton
                  size="lg"
                  className="data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground"
                >
                  <Avatar className="h-8 w-8 rounded-lg">
                    <AvatarFallback className="rounded-lg bg-primary/15 text-primary text-xs font-medium">
                      {initials(fullName)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="grid flex-1 text-left text-sm leading-tight">
                    <span className="truncate font-medium">
                      {fullName ?? 'Agent'}
                    </span>
                    <span className="truncate text-xs text-muted-foreground">
                      {email ?? ''}
                    </span>
                  </div>
                  <ChevronUp className="ml-auto size-4" />
                </SidebarMenuButton>
              </DropdownMenuTrigger>

              <DropdownMenuContent
                className="w-(--radix-dropdown-menu-trigger-width) min-w-52 rounded-lg"
                side={isMobile ? 'bottom' : 'right'}
                align="end"
                sideOffset={4}
              >
                <DropdownMenuLabel className="p-0 font-normal">
                  <div className="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
                    <Avatar className="h-8 w-8 rounded-lg">
                      <AvatarFallback className="rounded-lg bg-primary/15 text-primary text-xs font-medium">
                        {initials(fullName)}
                      </AvatarFallback>
                    </Avatar>
                    <div className="grid flex-1 text-left text-sm leading-tight">
                      <span className="truncate font-medium">
                        {fullName ?? 'Agent'}
                      </span>
                      <span className="truncate text-xs text-muted-foreground">
                        {email ?? ''}
                      </span>
                    </div>
                  </div>
                </DropdownMenuLabel>

                <DropdownMenuSeparator />

                <DropdownMenuGroup>
                  <DropdownMenuItem onClick={() => navigate('/profile')}>
                    <UserCircle className="mr-2 size-4" />
                    Profile
                  </DropdownMenuItem>
                </DropdownMenuGroup>

                <DropdownMenuSeparator />

                <DropdownMenuItem
                  onClick={handleLogout}
                  className="text-destructive focus:text-destructive"
                >
                  <LogOut className="mr-2 size-4" />
                  Log out
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  )
}
