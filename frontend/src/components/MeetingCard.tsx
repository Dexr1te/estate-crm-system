import { format, isPast, isToday } from 'date-fns'
import {
  CalendarDays,
  CheckCircle2,
  MapPin,
  User,
  Briefcase,
  Clock
} from 'lucide-react'
import { Badge } from './ui/badge'
import { Spinner } from './ui/spinner'
import { Button } from './ui/button'
import { cn } from '../lib/utils'
import { useCompleteMeeting } from '../hooks/useMeetings'

type Meeting = {
  id: number
  title: string
  description?: string
  scheduledAt: string
  completed?: boolean
  location?: string
  agentName?: string
  dealTitle?: string
}

type MeetingCardProps = {
  meeting: Meeting
  onEdit: (meeting: Meeting) => void
}

export function MeetingCard({ meeting, onEdit }: MeetingCardProps) {
  const { mutate: complete, isPending } = useCompleteMeeting()

  const date = new Date(meeting.scheduledAt)
  const overdue = !meeting.completed && isPast(date) && !isToday(date)
  const today = isToday(date)

  return (
    <div
      className={cn(
        'group relative bg-card border rounded-xl p-5 shadow-sm hover:shadow-md transition-all duration-200',
        meeting.completed && 'opacity-60',
        overdue && 'border-destructive/40',
        today && !meeting.completed && 'border-primary/40 bg-accent/30'
      )}
    >
      {/* Status stripe */}
      <div
        className={cn(
          'absolute left-0 top-0 bottom-0 w-1 rounded-l-xl',
          meeting.completed
            ? 'bg-emerald-400'
            : overdue
            ? 'bg-destructive'
            : today
            ? 'bg-primary'
            : 'bg-border'
        )}
      />

      <div className="pl-3">
        <div className="flex items-start justify-between gap-3 mb-3">
          <div className="flex-1 min-w-0">
            <h3 className="font-display font-semibold text-base leading-tight truncate">
              {meeting.title}
            </h3>

            {meeting.description && (
              <p className="text-sm text-muted-foreground mt-0.5 line-clamp-2">
                {meeting.description}
              </p>
            )}
          </div>

          <div className="flex items-center gap-1.5 shrink-0">
            {meeting.completed && <Badge variant="default">Done</Badge>}
            {overdue && <Badge variant="destructive">Overdue</Badge>}
            {today && !meeting.completed && (
              <Badge variant="default">Today</Badge>
            )}
          </div>
        </div>

        <div className="grid grid-cols-2 gap-x-4 gap-y-1.5 text-xs text-muted-foreground mb-4">
          <span className="flex items-center gap-1.5">
            <CalendarDays className="h-3.5 w-3.5 shrink-0" />
            {format(date, 'MMM d, yyyy')}
          </span>

          <span className="flex items-center gap-1.5">
            <Clock className="h-3.5 w-3.5 shrink-0" />
            {format(date, 'HH:mm')}
          </span>

          {meeting.location && (
            <span className="flex items-center gap-1.5 col-span-2">
              <MapPin className="h-3.5 w-3.5 shrink-0" />
              {meeting.location}
            </span>
          )}

          {meeting.agentName && (
            <span className="flex items-center gap-1.5">
              <User className="h-3.5 w-3.5 shrink-0" />
              {meeting.agentName}
            </span>
          )}

          {meeting.dealTitle && (
            <span className="flex items-center gap-1.5">
              <Briefcase className="h-3.5 w-3.5 shrink-0" />
              {meeting.dealTitle}
            </span>
          )}
        </div>

        <div className="flex items-center gap-2">
          {!meeting.completed && (
            <Button
              size="sm"
              variant="outline"
              className="h-7 text-xs gap-1.5"
              onClick={() => complete(String(meeting.id))}
              disabled={isPending}
            >
              {isPending ? (
                <Spinner className="h-3 w-3" />
              ) : (
                <CheckCircle2 className="h-3.5 w-3.5" />
              )}
              Mark done
            </Button>
          )}

          <Button
            size="sm"
            variant="ghost"
            className="h-7 text-xs ml-auto"
            onClick={() => onEdit(meeting)}
          >
            Edit
          </Button>
        </div>
      </div>
    </div>
  )
}
