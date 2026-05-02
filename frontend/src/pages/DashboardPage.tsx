import { useNavigate } from 'react-router-dom'
import {
  ArrowUpRight,
  Briefcase,
  CalendarClock,
  CheckCircle2,
  Users
} from 'lucide-react'
import { useDashboard } from '@/entities/dashboard/model/hook'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts'

export function DashboardPage() {
  const navigate = useNavigate()
  const { data, isLoading, isError, error } = useDashboard()

  const summary = {
    totalDeals: data?.totalDeals ?? 0,
    activeDeals: data?.activeDeals ?? 0,
    closedDeals: data?.closedDeals ?? 0,
    totalClients: data?.totalClients ?? 0,
    upcomingMeetings: data?.upcomingMeetings ?? 0
  }

  const closedRate =
    summary.totalDeals > 0
      ? Math.round((summary.closedDeals / summary.totalDeals) * 100)
      : 0
  const activityRate =
    summary.totalDeals > 0
      ? Math.round((summary.activeDeals / summary.totalDeals) * 100)
      : 0
  const meetingLoad =
    summary.totalClients > 0
      ? (summary.upcomingMeetings / summary.totalClients).toFixed(2)
      : '0.00'

  const dealsBars = [
    { name: 'Active', value: summary.activeDeals },
    { name: 'Closed', value: summary.closedDeals }
  ]

  const dealsPie = [
    { name: 'Active', value: summary.activeDeals, color: '#2563eb' },
    { name: 'Closed', value: summary.closedDeals, color: '#16a34a' }
  ]

  if (isLoading) {
    return (
      <div className="p-8 text-sm text-muted-foreground">
        Loading dashboard...
      </div>
    )
  }

  if (isError) {
    return (
      <div className="p-8 text-sm text-destructive">
        Failed to load dashboard:{' '}
        {error instanceof Error ? error.message : 'Unknown error'}
      </div>
    )
  }

  return (
    <div className="space-y-6 p-4 md:p-6 lg:p-8">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Dashboard</h1>
          <p className="text-sm text-muted-foreground">
            Live summary from backend business metrics
          </p>
        </div>
        <div className="flex flex-col gap-2 sm:flex-row">
          <Button variant="outline" onClick={() => navigate('/clients')}>
            Clients
            <ArrowUpRight className="ml-2 size-4" />
          </Button>
          <Button onClick={() => navigate('/deals')}>
            Deals
            <ArrowUpRight className="ml-2 size-4" />
          </Button>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Total deals</CardDescription>
            <CardTitle className="text-3xl">{summary.totalDeals}</CardTitle>
          </CardHeader>
          <CardContent className="text-xs text-muted-foreground flex items-center gap-2">
            <Briefcase className="size-4" />
            All pipeline records
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Active deals</CardDescription>
            <CardTitle className="text-3xl">{summary.activeDeals}</CardTitle>
          </CardHeader>
          <CardContent className="text-xs text-muted-foreground">
            {activityRate}% of all deals are still in progress
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Closed deals</CardDescription>
            <CardTitle className="text-3xl">{summary.closedDeals}</CardTitle>
          </CardHeader>
          <CardContent className="text-xs text-muted-foreground flex items-center gap-2">
            <CheckCircle2 className="size-4 text-emerald-600" />
            Closure rate: {closedRate}%
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Total clients</CardDescription>
            <CardTitle className="text-3xl">{summary.totalClients}</CardTitle>
          </CardHeader>
          <CardContent className="text-xs text-muted-foreground flex items-center gap-2">
            <Users className="size-4" />
            Active CRM relationships
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Upcoming meetings</CardDescription>
            <CardTitle className="text-3xl">
              {summary.upcomingMeetings}
            </CardTitle>
          </CardHeader>
          <CardContent className="text-xs text-muted-foreground flex items-center gap-2">
            <CalendarClock className="size-4" />
            {meetingLoad} meetings per client
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Deals by stage</CardTitle>
            <CardDescription>
              Active vs closed in absolute values
            </CardDescription>
          </CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={dealsBars}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="name" />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Bar dataKey="value" radius={[6, 6, 0, 0]}>
                  <Cell fill="#2563eb" />
                  <Cell fill="#16a34a" />
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Pipeline distribution</CardTitle>
            <CardDescription>Share of active and closed deals</CardDescription>
          </CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={dealsPie}
                  dataKey="value"
                  nameKey="name"
                  innerRadius={70}
                  outerRadius={100}
                  paddingAngle={3}
                >
                  {dealsPie.map((item) => (
                    <Cell key={item.name} fill={item.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Operational health</CardTitle>
          <CardDescription>
            Derived from backend summary metrics
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          <div className="rounded-lg border p-4">
            <p className="text-sm text-muted-foreground">Pipeline activity</p>
            <p className="text-2xl font-semibold mt-1">{activityRate}%</p>
            <p className="text-xs text-muted-foreground mt-2">
              Higher means more deals still in motion
            </p>
          </div>
          <div className="rounded-lg border p-4">
            <p className="text-sm text-muted-foreground">Closure efficiency</p>
            <p className="text-2xl font-semibold mt-1">{closedRate}%</p>
            <p className="text-xs text-muted-foreground mt-2">
              Percent of deals that reached closed state
            </p>
          </div>
          <div className="rounded-lg border p-4">
            <p className="text-sm text-muted-foreground">Meeting pressure</p>
            <p className="text-2xl font-semibold mt-1">{meetingLoad}</p>
            <p className="text-xs text-muted-foreground mt-2">
              Upcoming meetings per client
            </p>
          </div>
        </CardContent>
      </Card>

      {summary.totalDeals === 0 && summary.totalClients === 0 && (
        <Card>
          <CardContent className="p-6 text-sm text-muted-foreground">
            No CRM activity yet. Start by adding clients and creating your first
            deal.
          </CardContent>
        </Card>
      )}
    </div>
  )
}
