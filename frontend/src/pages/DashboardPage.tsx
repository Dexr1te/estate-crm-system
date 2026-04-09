import { useNavigate } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
import { useDashboard } from '@/entities/dashboard/api/hook'

export function DashboardPage() {
  const navigate = useNavigate()
  const { data, isLoading } = useDashboard()

  if (isLoading) {
    return <div className="p-8 text-sm text-muted-foreground">Loading...</div>
  }

  return (
    <div className="p-8 space-y-10">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Dashboard</h1>
        <p className="text-sm text-muted-foreground">
          Overview of your activity
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="space-y-1">
          <p className="text-sm text-muted-foreground">Total deals</p>
          <p className="text-3xl font-semibold">{data?.totalDeals ?? 0}</p>
        </div>

        <div className="space-y-1">
          <p className="text-sm text-muted-foreground">Active deals</p>
          <p className="text-3xl font-semibold">{data?.activeDeals ?? 0}</p>
        </div>

        <div className="space-y-1">
          <p className="text-sm text-muted-foreground">Closed deals</p>
          <p className="text-3xl font-semibold">{data?.closedDeals ?? 0}</p>
        </div>
      </div>

      {/* Quick actions */}
      <div className="flex gap-3">
        <button
          onClick={() => navigate('/clients')}
          className="text-sm underline underline-offset-4 hover:opacity-70 flex items-center gap-1"
        >
          Go to clients <ArrowUpRight size={14} />
        </button>

        <button
          onClick={() => navigate('/deals')}
          className="text-sm underline underline-offset-4 hover:opacity-70 flex items-center gap-1"
        >
          View deals <ArrowUpRight size={14} />
        </button>
      </div>

      {/* Upcoming meetings */}
      <div className="space-y-4">
        <h2 className="text-sm font-medium text-muted-foreground uppercase tracking-wide">
          Upcoming meetings
        </h2>

        <div className="border rounded-lg p-4 text-sm text-muted-foreground">
          {data?.upcomingMeetings
            ? `${data.upcomingMeetings} upcoming meetings`
            : 'No upcoming meetings'}
        </div>
      </div>
    </div>
  )
}
