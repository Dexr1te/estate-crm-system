import { useMemo, useState } from 'react'
import { CalendarClock, AlertCircle } from 'lucide-react'
import { format, isToday, isTomorrow, differenceInHours } from 'date-fns'
import {
  useUpcomingMeetings,
  useUpdateMeeting
} from '@/entities/meeting/model/hook'
import { useAuthStore } from '@/entities/auth/model/authStore'
import { useAgentOptions } from '@/entities/user/model/useAgentOptions'
import { MeetingCard } from '@/features/meeting-form/MeetingCard'
import { MeetingForm } from '@/features/meeting-form/MeetingForm'
import { Spinner } from '../components/ui/spinner'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle
} from '../components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import type { Meeting, UpdateMeetingDto } from '@/entities/meeting/model/type'

type GroupedMeetings = Record<string, Meeting[]>
type AdminAgentFilter = 'all' | `${number}`

function groupByDay(meetings: Meeting[]): GroupedMeetings {
  const groups: GroupedMeetings = {}

  for (const meeting of meetings) {
    const date = new Date(meeting.scheduledAt)

    let label: string
    if (isToday(date)) label = 'Today'
    else if (isTomorrow(date)) label = 'Tomorrow'
    else label = format(date, 'EEEE, MMMM d')

    if (!groups[label]) groups[label] = []
    groups[label].push(meeting)
  }

  return groups
}

export function UpcomingPage() {
  const { role, userId } = useAuthStore()
  const { data: agents = [] } = useAgentOptions()
  const [adminAgentFilter, setAdminAgentFilter] =
    useState<AdminAgentFilter>('all')

  const effectiveAgentId =
    role === 'AGENT'
      ? userId ?? undefined
      : adminAgentFilter === 'all'
      ? undefined
      : Number(adminAgentFilter)
  const usesAgentUpcomingWindow = effectiveAgentId != null

  const {
    data: meetings = [],
    isLoading,
    isError,
    error
  } = useUpcomingMeetings(effectiveAgentId)

  const [editTarget, setEditTarget] = useState<Meeting | null>(null)
  const [actionError, setActionError] = useState<string | null>(null)
  const updateMutation = useUpdateMeeting()

  const groups = useMemo(() => groupByDay(meetings), [meetings])
  const nextMeeting = meetings.find((m) => !m.completed)
  const hoursUntilNext =
    nextMeeting != null
      ? differenceInHours(new Date(nextMeeting.scheduledAt), new Date())
      : null

  const canEditMeeting = (meeting: Meeting) =>
    meeting.agentId > 0 && meeting.clientId > 0

  return (
    <div className="flex-1 flex flex-col min-h-0">
      <div className="border-b bg-background px-4 py-4 md:px-8 md:py-6">
        <div className="mb-3 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="font-display text-2xl font-bold">Upcoming</h1>
            <p className="text-sm text-muted-foreground mt-0.5">
              {usesAgentUpcomingWindow ? 'Next 7 days' : 'All future meetings'}
            </p>
          </div>
          <CalendarClock className="h-8 w-8 text-muted-foreground/30" />
        </div>

        {role === 'ADMIN' && (
          <div className="mt-4 max-w-sm">
            <Select
              value={adminAgentFilter}
              onValueChange={(v) => setAdminAgentFilter(v as AdminAgentFilter)}
            >
              <SelectTrigger>
                <SelectValue placeholder="All agents" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All agents</SelectItem>
                {agents.map((agent) => (
                  <SelectItem
                    key={agent.id}
                    value={String(agent.id) as `${number}`}
                  >
                    {agent.fullName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {adminAgentFilter === 'all' && (
              <p className="mt-2 text-xs text-muted-foreground">
                Showing global upcoming feed. For editing meetings, select a
                specific agent.
              </p>
            )}
          </div>
        )}

        {role === 'AGENT' && !userId && (
          <div className="mt-4 flex items-center gap-3 p-3 rounded-lg bg-amber-50 border border-amber-200 text-amber-800 text-sm">
            <AlertCircle className="h-4 w-4 shrink-0" />
            <span>User id not found in session. Please re-login.</span>
          </div>
        )}

        {nextMeeting &&
          hoursUntilNext !== null &&
          hoursUntilNext >= 0 &&
          hoursUntilNext <= 24 && (
            <div className="mt-4 p-3 rounded-lg bg-primary/5 border border-primary/20 text-sm">
              <span className="font-medium text-primary">
                {hoursUntilNext === 0
                  ? 'Starting now'
                  : `In ${hoursUntilNext}h`}
                :
              </span>{' '}
              <span className="text-foreground">{nextMeeting.title}</span>
              {nextMeeting.location && (
                <span className="text-muted-foreground">
                  {' '}
                  · {nextMeeting.location}
                </span>
              )}
            </div>
          )}
      </div>

      <div className="flex-1 overflow-auto px-4 py-4 md:px-8 md:py-6">
        {isLoading && (
          <div className="flex justify-center py-20">
            <Spinner className="h-8 w-8" />
          </div>
        )}

        {isError && (
          <div className="text-center py-20 text-muted-foreground">
            <p className="font-medium">Failed to load upcoming meetings</p>
            <p className="text-sm mt-1">
              {error instanceof Error ? error.message : 'Unknown error'}
            </p>
          </div>
        )}

        {actionError && (
          <div className="mb-4 rounded-md border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-600">
            {actionError}
          </div>
        )}

        {!isLoading && !isError && meetings.length === 0 && (
          <div className="text-center py-20 text-muted-foreground">
            <CalendarClock className="h-10 w-10 mx-auto mb-3 opacity-30" />
            <p className="font-medium">All clear for the next 7 days</p>
            <p className="text-sm mt-1">No upcoming meetings scheduled</p>
          </div>
        )}

        {!isLoading && !isError && Object.entries(groups).length > 0 && (
          <div className="space-y-8">
            {Object.entries(groups).map(([label, items]) => (
              <section key={label}>
                <div className="flex items-center gap-3 mb-4">
                  <h2 className="font-display font-semibold text-sm uppercase tracking-wider text-muted-foreground">
                    {label}
                  </h2>
                  <div className="flex-1 h-px bg-border" />
                  <span className="text-xs text-muted-foreground">
                    {items.length}
                  </span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                  {items.map((meeting) => (
                    <MeetingCard
                      key={meeting.id}
                      meeting={meeting}
                      onEdit={
                        canEditMeeting(meeting) ? setEditTarget : undefined
                      }
                    />
                  ))}
                </div>
              </section>
            ))}
          </div>
        )}
      </div>

      <Dialog
        open={!!editTarget}
        onOpenChange={(opened) => !opened && setEditTarget(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Meeting</DialogTitle>
          </DialogHeader>

          {editTarget && (
            <MeetingForm
              initial={editTarget}
              onSubmit={(data: UpdateMeetingDto) => {
                updateMutation.mutate(
                  {
                    id: editTarget.id,
                    data
                  },
                  {
                    onSuccess: () => setEditTarget(null),
                    onError: (err) => {
                      setActionError(
                        err instanceof Error
                          ? err.message
                          : 'Failed to update meeting'
                      )
                    }
                  }
                )
              }}
              onCancel={() => setEditTarget(null)}
              loading={updateMutation.isPending}
            />
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
