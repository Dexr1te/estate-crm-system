import { useState, type ChangeEvent } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { format } from 'date-fns'
import type { CreateMeetingDto } from '@/entities/meeting/model/type'

type Meeting = {
  title: string
  description?: string
  scheduledAt?: string
  location?: string
  dealId?: number | string
  agentId?: number | string
  clientId?: number | string
}

type MeetingFormProps<T = CreateMeetingDto> = {
  initial?: Meeting
  onSubmit: (data: T) => void
  onCancel: () => void
  loading?: boolean
}

type FormState = {
  title: string
  description: string
  scheduledAt: string
  location: string
  dealId: string
  agentId: string
  clientId: string
}

const DEFAULT_FORM: FormState = {
  title: '',
  description: '',
  scheduledAt: '',
  location: '',
  dealId: '',
  agentId: '',
  clientId: ''
}

export function MeetingForm({
  initial,
  onSubmit,
  onCancel,
  loading
}: MeetingFormProps) {
  const [form, setForm] = useState<FormState>(() => {
    if (!initial) return DEFAULT_FORM

    return {
      title: initial.title ?? '',
      description: initial.description ?? '',
      scheduledAt: initial.scheduledAt
        ? format(new Date(initial.scheduledAt), "yyyy-MM-dd'T'HH:mm")
        : '',
      location: initial.location ?? '',
      dealId: initial.dealId ? String(initial.dealId) : '',
      agentId: initial.agentId ? String(initial.agentId) : '',
      clientId: initial.clientId ? String(initial.clientId) : ''
    }
  })

  const set =
    (key: keyof FormState) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      setForm((f) => ({ ...f, [key]: e.target.value }))
    }

  const handleSubmit = (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault()

    onSubmit({
      title: form.title,
      description: form.description || undefined,
      scheduledAt: new Date(form.scheduledAt).toISOString(),
      location: form.location || undefined,
      dealId: form.dealId ? Number(form.dealId) : undefined,
      agentId: form.agentId ? Number(form.agentId) : undefined,
      clientId: form.clientId ? Number(form.clientId) : undefined
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
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

      <div className="grid grid-cols-2 gap-4">
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

      <div className="grid grid-cols-3 gap-4">
        <div className="space-y-1.5">
          <Label htmlFor="agentId">Agent ID</Label>
          <Input
            id="agentId"
            type="number"
            value={form.agentId}
            onChange={set('agentId')}
            placeholder="1"
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="clientId">Client ID</Label>
          <Input
            id="clientId"
            type="number"
            value={form.clientId}
            onChange={set('clientId')}
            placeholder="1"
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="dealId">Deal ID</Label>
          <Input
            id="dealId"
            type="number"
            value={form.dealId}
            onChange={set('dealId')}
            placeholder="1"
          />
        </div>
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
