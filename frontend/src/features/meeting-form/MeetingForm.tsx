import { useMemo, useState, type ChangeEvent } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import { useClients } from '@/entities/clients/model/hook'
import { useDeals } from '@/entities/deal/model/hook'
import { useAgentOptions } from '@/entities/user/model/useAgentOptions'
import { useAuthStore } from '@/entities/auth/model/authStore'
import {
  DEFAULT_FORM,
  type FormState,
  type MeetingFormProps
} from './model/types'

const NO_DEAL = 'NO_DEAL'

function toDatetimeLocalValue(value?: string) {
  if (!value) return ''
  const normalized = value.replace('Z', '')
  return normalized.length >= 16 ? normalized.slice(0, 16) : normalized
}

function toBackendLocalDateTime(value: string) {
  if (!value) return value
  return value.length === 16 ? `${value}:00` : value
}

export function MeetingForm({ initial, onSubmit, onCancel, loading }: MeetingFormProps) {
  const { role, userId, fullName } = useAuthStore()
  const { data: clients = [] } = useClients()
  const { data: deals = [] } = useDeals()
  const { data: agentOptions = [] } = useAgentOptions()

  const [form, setForm] = useState<FormState>(() => {
    if (!initial) {
      return {
        ...DEFAULT_FORM,
        agentId: role === 'AGENT' && userId ? String(userId) : ''
      }
    }

    return {
      title: initial.title ?? '',
      description: initial.description ?? '',
      scheduledAt: toDatetimeLocalValue(initial.scheduledAt),
      location: initial.location ?? '',
      dealId: initial.dealId ? String(initial.dealId) : NO_DEAL,
      agentId:
        initial.agentId != null
          ? String(initial.agentId)
          : role === 'AGENT' && userId
          ? String(userId)
          : '',
      clientId: initial.clientId != null ? String(initial.clientId) : ''
    }
  })
  const [error, setError] = useState<string | null>(null)

  const set =
    (key: keyof FormState) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      setForm((f) => ({ ...f, [key]: e.target.value }))
    }

  const selectedAgentName = useMemo(() => {
    const selected = agentOptions.find((a) => String(a.id) === form.agentId)
    return selected?.fullName ?? fullName ?? `ID ${form.agentId || '-'}`
  }, [agentOptions, form.agentId, fullName])

  const handleSubmit = (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(null)

    if (!form.title.trim()) {
      setError('Title is required')
      return
    }
    if (!form.scheduledAt) {
      setError('Date and time are required')
      return
    }
    if (!form.clientId) {
      setError('Client is required')
      return
    }
    if (!form.agentId) {
      setError('Agent is required')
      return
    }

    onSubmit({
      title: form.title.trim(),
      description: form.description.trim() || undefined,
      scheduledAt: toBackendLocalDateTime(form.scheduledAt),
      location: form.location.trim() || undefined,
      dealId: form.dealId && form.dealId !== NO_DEAL ? Number(form.dealId) : undefined,
      agentId: Number(form.agentId),
      clientId: Number(form.clientId)
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {error && (
        <div className="rounded-md border border-red-500/30 bg-red-500/10 px-3 py-2 text-sm text-red-600">
          {error}
        </div>
      )}

      <div className="space-y-1.5">
        <Label htmlFor="title">Title *</Label>
        <Input
          id="title"
          value={form.title}
          onChange={set('title')}
          required
          placeholder="Meeting title"
        />
      </div>

      <div className="space-y-1.5">
        <Label htmlFor="description">Description</Label>
        <Textarea
          id="description"
          value={form.description}
          onChange={set('description')}
          placeholder="What is this meeting about?"
          rows={3}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div className="space-y-1.5">
          <Label htmlFor="scheduledAt">Date & Time *</Label>
          <Input
            id="scheduledAt"
            type="datetime-local"
            value={form.scheduledAt}
            onChange={set('scheduledAt')}
            required
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="location">Location</Label>
          <Input
            id="location"
            value={form.location}
            onChange={set('location')}
            placeholder="Office, Zoom, etc."
          />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
        <div className="space-y-1.5">
          <Label>Client *</Label>
          <Select
            value={form.clientId}
            onValueChange={(value) => setForm((f) => ({ ...f, clientId: value }))}
          >
            <SelectTrigger>
              <SelectValue placeholder="Select client" />
            </SelectTrigger>
            <SelectContent>
              {clients.map((client) => (
                <SelectItem key={client.id} value={String(client.id)}>
                  {client.fullName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-1.5 min-w-0">
          <Label>Deal</Label>
          <Select
            value={form.dealId || NO_DEAL}
            onValueChange={(value) => setForm((f) => ({ ...f, dealId: value }))}
          >
            <SelectTrigger className="w-full min-w-0">
              <SelectValue placeholder="Optional deal" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value={NO_DEAL}>No deal</SelectItem>
              {deals.map((deal) => (
                <SelectItem key={deal.id} value={String(deal.id)}>
                  <span className="block max-w-[240px] truncate" title={deal.title}>
                    {deal.title}
                  </span>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        {role === 'ADMIN' ? (
          <div className="space-y-1.5">
            <Label>Agent *</Label>
            <Select
              value={form.agentId}
              onValueChange={(value) => setForm((f) => ({ ...f, agentId: value }))}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select agent" />
              </SelectTrigger>
              <SelectContent>
                {agentOptions.map((agent) => (
                  <SelectItem key={agent.id} value={String(agent.id)}>
                    {agent.fullName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        ) : (
          <div className="space-y-1.5">
            <Label>Agent</Label>
            <Input value={selectedAgentName} disabled />
          </div>
        )}
      </div>

      <div className="flex justify-end gap-2 pt-2">
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? 'Saving…' : initial ? 'Save changes' : 'Create meeting'}
        </Button>
      </div>
    </form>
  )
}
