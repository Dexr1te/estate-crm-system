import { useState } from 'react'
import { Plus, Search, SlidersHorizontal } from 'lucide-react'
import {
  useMeetings,
  useCreateMeeting,
  useUpdateMeeting
} from '@/entities/meeting/model/hook'
import { useAppStore } from '@/shared/store/useAppStore'
import { MeetingCard } from '@/widgets/meeting-card/MeetingCard'
import { MeetingForm } from '@/widgets/meeting-card/MeetingForm'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Spinner } from '@/components/ui/spinner'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle
} from '../components/ui/dialog'

import type {
  Meeting,
  CreateMeetingDto,
  UpdateMeetingDto
} from '@/entities/meeting/model/type'

// ==== TYPES ====

type FilterType = 'all' | 'pending' | 'completed'

// ==== COMPONENT ====

export function MeetingsPage() {
  const { agentId } = useAppStore() as { agentId?: string }

  const { data: meetings = [], isLoading, isError } = useMeetings(agentId)

  const createMutation = useCreateMeeting()

  const [search, setSearch] = useState<string>('')
  const [filter, setFilter] = useState<FilterType>('all')
  const [createOpen, setCreateOpen] = useState<boolean>(false)
  const [editTarget, setEditTarget] = useState<Meeting | null>(null)

  const updateMutation = useUpdateMeeting()

  const handleUpdate = (data: UpdateMeetingDto) => {
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
  }

  // ==== FILTER ====

  const filtered = meetings.filter((m: Meeting) => {
    const matchSearch =
      !search ||
      m.title?.toLowerCase().includes(search.toLowerCase()) ||
      m.agentName?.toLowerCase().includes(search.toLowerCase()) ||
      m.clientName?.toLowerCase().includes(search.toLowerCase()) ||
      m.dealTitle?.toLowerCase().includes(search.toLowerCase())

    const matchFilter =
      filter === 'all' ||
      (filter === 'pending' && !m.completed) ||
      (filter === 'completed' && m.completed)

    return matchSearch && matchFilter
  })

  // ==== HANDLERS ====

  const handleCreate = (data: CreateMeetingDto) => {
    createMutation.mutate(data, {
      onSuccess: () => setCreateOpen(false)
    })
  }

  // ==== UI ====

  return (
    <div className="flex-1 flex flex-col min-h-0">
      {/* Header */}
      <div className="px-8 py-6 border-b bg-background sticky top-0 z-10">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="font-display text-2xl font-bold">Meetings</h1>
            <p className="text-sm text-muted-foreground mt-0.5">
              {meetings.length} total
              {agentId ? ` · Agent ${agentId}` : ''}
            </p>
          </div>

          <Button onClick={() => setCreateOpen(true)} className="gap-2">
            <Plus className="h-4 w-4" /> New meeting
          </Button>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              value={search}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                setSearch(e.target.value)
              }
              placeholder="Search meetings…"
              className="pl-9"
            />
          </div>

          <div className="flex items-center gap-1 p-1 bg-secondary rounded-lg">
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

      {/* Content */}
      <div className="flex-1 overflow-auto px-8 py-6">
        {isLoading && (
          <div className="flex items-center justify-center py-20">
            <Spinner className="h-8 w-8" />
          </div>
        )}

        {isError && (
          <div className="text-center py-20 text-muted-foreground">
            <p className="text-base font-medium">Failed to load meetings</p>
            <p className="text-sm mt-1">Check your API connection</p>
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
            {filtered.map((m: Meeting) => (
              <MeetingCard key={m.id} meeting={m} onEdit={setEditTarget} />
            ))}
          </div>
        )}
      </div>

      {/* Create Dialog */}
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
