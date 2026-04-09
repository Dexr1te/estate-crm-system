import { useState } from 'react'
import { CalendarClock, AlertCircle } from 'lucide-react'
import { format, isToday, isTomorrow, differenceInHours } from 'date-fns'
import {
  useUpcomingMeetings,
  useUpdateMeeting
} from '@/entities/meeting/model/hook'
import { useAppStore } from '@/shared/store/useAppStore'
import { MeetingCard } from '@/widgets/meeting-card/MeetingCard'
import { MeetingForm } from '@/widgets/meeting-card/MeetingForm'
import { Spinner } from '../components/ui/spinner'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle
} from '../components/ui/dialog'

import type { Meeting, UpdateMeetingDto } from '@/entities/meeting/model/type'

// ==== TYPES ====

type GroupedMeetings = Record<string, Meeting[]>

// ==== HELPERS ====

function groupByDay(meetings: Meeting[]): GroupedMeetings {
  const groups: GroupedMeetings = {}

  for (const m of meetings) {
    const d = new Date(m.scheduledAt)

    let label: string
    if (isToday(d)) label = 'Today'
    else if (isTomorrow(d)) label = 'Tomorrow'
    else label = format(d, 'EEEE, MMMM d')

    if (!groups[label]) groups[label] = []
    groups[label].push(m)
  }

  return groups
}

// ==== COMPONENT ====

export function UpcomingPage() {
  const { agentId } = useAppStore() as { agentId?: string }

  const {
    data: meetings = [],
    isLoading,
    isError
  } = useUpcomingMeetings(agentId)

  const [editTarget, setEditTarget] = useState<Meeting | null>(null)

  const updateMutation = useUpdateMeeting()

  const groups = groupByDay(meetings)

  const nextMeeting = meetings.find((m) => !m.completed)

  const hoursUntilNext =
    nextMeeting != null
      ? differenceInHours(new Date(nextMeeting.scheduledAt), new Date())
      : null

  return (
    <div className="flex-1 flex flex-col min-h-0">
      {/* Header */}
      <div className="px-8 py-6 border-b bg-background">
        <div className="flex items-center justify-between mb-2">
          <div>
            <h1 className="font-display text-2xl font-bold">Upcoming</h1>
            <p className="text-sm text-muted-foreground mt-0.5">Next 7 days</p>
          </div>
          <CalendarClock className="h-8 w-8 text-muted-foreground/30" />
        </div>

        {/* Agent required */}
        {!agentId && (
          <div className="mt-4 flex items-center gap-3 p-3 rounded-lg bg-amber-50 border border-amber-200 text-amber-800 text-sm">
            <AlertCircle className="h-4 w-4 shrink-0" />
            <span>
              Enter an Agent ID in the sidebar to view upcoming meetings.
            </span>
          </div>
        )}

        {/* Next meeting */}
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

      {/* Content */}
      <div className="flex-1 overflow-auto px-8 py-6">
        {isLoading && (
          <div className="flex justify-center py-20">
            <Spinner className="h-8 w-8" />
          </div>
        )}

        {isError && (
          <div className="text-center py-20 text-muted-foreground">
            <p className="font-medium">Failed to load upcoming meetings</p>
          </div>
        )}

        {!isLoading && !isError && agentId && meetings.length === 0 && (
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
                  {items.map((m: Meeting) => (
                    <MeetingCard
                      key={m.id}
                      meeting={m}
                      onEdit={setEditTarget}
                    />
                  ))}
                </div>
              </section>
            ))}
          </div>
        )}
      </div>

      {/* Edit Dialog */}
      <Dialog
        open={!!editTarget}
        onOpenChange={(o) => !o && setEditTarget(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Meeting</DialogTitle>
          </DialogHeader>

          {editTarget && (
            <MeetingForm
              initial={editTarget}
              onSubmit={(data: UpdateMeetingDto) => {
                if (!editTarget) return
                updateMutation.mutate(
                  {
                    id: editTarget.id,
                    data
                  },
                  {
                    onSuccess: () => setEditTarget(null)
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
