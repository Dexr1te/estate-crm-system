import { useMemo, useState } from 'react'
import { Plus, Search, SlidersHorizontal } from 'lucide-react'
import {
  useMeetings,
  useCreateMeeting,
  useUpdateMeeting
} from '@/entities/meeting/model/hook'
import { useAuthStore } from '@/entities/auth/model/authStore'
import { useAgentOptions } from '@/entities/user/model/useAgentOptions'
import { MeetingCard } from '@/features/meeting-form/MeetingCard'
import { MeetingForm } from '@/features/meeting-form/MeetingForm'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Spinner } from '@/components/ui/spinner'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import type {
  CreateMeetingDto,
  Meeting,
  UpdateMeetingDto
} from '@/entities/meeting/model/type'

type FilterType = 'all' | 'pending' | 'completed'
type AdminAgentFilter = 'all' | `${number}`

export function MeetingsPage() {
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

  const {
    data: meetings = [],
    isLoading,
    isError,
    error
  } = useMeetings(effectiveAgentId)
  const createMutation = useCreateMeeting()
  const updateMutation = useUpdateMeeting()

  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState<FilterType>('all')
  const [createOpen, setCreateOpen] = useState(false)
  const [editTarget, setEditTarget] = useState<Meeting | null>(null)
  const [actionError, setActionError] = useState<string | null>(null)

  const filtered = useMemo(() => {
    return meetings.filter((m) => {
      const matchSearch =
        !search ||
        m.title.toLowerCase().includes(search.toLowerCase()) ||
        m.agentName.toLowerCase().includes(search.toLowerCase()) ||
        m.clientName.toLowerCase().includes(search.toLowerCase()) ||
        (m.dealTitle ?? '').toLowerCase().includes(search.toLowerCase())

      const matchFilter =
        filter === 'all' ||
        (filter === 'pending' && !m.completed) ||
        (filter === 'completed' && m.completed)

      return matchSearch && matchFilter
    })
  }, [meetings, search, filter])

  const handleCreate = (data: CreateMeetingDto) => {
    setActionError(null)

    if (role === 'AGENT' && !userId) {
      setActionError('User id not found in session. Please re-login.')
      return
    }

    const payload: CreateMeetingDto = {
      ...data,
      agentId: role === 'AGENT' ? (userId as number) : data.agentId
    }

    createMutation.mutate(payload, {
      onSuccess: () => setCreateOpen(false),
      onError: (err) => {
        setActionError(
          err instanceof Error ? err.message : 'Failed to create meeting'
        )
      }
    })
  }

  const handleUpdate = (data: UpdateMeetingDto) => {
    if (!editTarget) return
    setActionError(null)

    if (role === 'AGENT' && !userId) {
      setActionError('User id not found in session. Please re-login.')
      return
    }

    const payload: UpdateMeetingDto = {
      ...data,
      agentId: role === 'AGENT' ? (userId as number) : data.agentId
    }

    updateMutation.mutate(
      {
        id: editTarget.id,
        data: payload
      },
      {
        onSuccess: () => setEditTarget(null),
        onError: (err) => {
          setActionError(
            err instanceof Error ? err.message : 'Failed to update meeting'
          )
        }
      }
    )
  }

  return (
    <div className="flex-1 flex flex-col min-h-0">
      <div className="sticky top-0 z-10 border-b bg-background px-4 py-4 md:px-8 md:py-6">
        <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="font-display text-2xl font-bold">Meetings</h1>
            <p className="text-sm text-muted-foreground mt-0.5">
              {meetings.length} total
            </p>
          </div>

          <Button onClick={() => setCreateOpen(true)} className="gap-2">
            <Plus className="h-4 w-4" /> New meeting
          </Button>
        </div>

        <div className="flex flex-col gap-3 lg:flex-row lg:items-center">
          <div className="relative flex-1 min-w-65 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search meetings…"
              className="pl-9"
            />
          </div>

          {role === 'ADMIN' && (
            <Select
              value={adminAgentFilter}
              onValueChange={(v) => setAdminAgentFilter(v as AdminAgentFilter)}
            >
              <SelectTrigger className="w-52">
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
          )}

          <div className="flex items-center gap-1 overflow-x-auto rounded-lg bg-secondary p-1">
            {(['all', 'pending', 'completed'] as FilterType[]).map((f) => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                className={`px-3 py-1 rounded-md text-sm font-medium capitalize transition-colors ${
                  filter === f
                    ? 'bg-background shadow-sm text-foreground'
                    : 'text-muted-foreground hover:text-foreground'
                }`}
              >
                {f}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-auto px-4 py-4 md:px-8 md:py-6">
        {isLoading && (
          <div className="flex items-center justify-center py-20">
            <Spinner className="h-8 w-8" />
          </div>
        )}

        {isError && (
          <div className="text-center py-20 text-muted-foreground">
            <p className="text-base font-medium">Failed to load meetings</p>
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

        {!isLoading && !isError && filtered.length === 0 && (
          <div className="text-center py-20 text-muted-foreground">
            <SlidersHorizontal className="h-10 w-10 mx-auto mb-3 opacity-30" />
            <p className="font-medium">No meetings found</p>
            <p className="text-sm mt-1">Try adjusting your search or filters</p>
          </div>
        )}

        {!isLoading && !isError && filtered.length > 0 && (
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
            {filtered.map((meeting) => (
              <MeetingCard
                key={meeting.id}
                meeting={meeting}
                onEdit={setEditTarget}
              />
            ))}
          </div>
        )}
      </div>

      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>New Meeting</DialogTitle>
          </DialogHeader>

          <MeetingForm
            onSubmit={handleCreate}
            onCancel={() => setCreateOpen(false)}
            loading={createMutation.isPending}
          />
        </DialogContent>
      </Dialog>

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
              onSubmit={handleUpdate}
              onCancel={() => setEditTarget(null)}
              loading={updateMutation.isPending}
            />
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
