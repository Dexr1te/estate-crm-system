import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Drawer,
  DrawerTrigger,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerFooter,
  DrawerClose
} from '@/components/ui/drawer'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import { useCreateDeal } from '@/entities/deal/model/hook'
import { useClients } from '@/entities/clients/model/hook'
import { useProperties } from '@/entities/properties/model/hook'
import { useAuthStore } from '@/entities/auth/model/authStore'
import { useAgentOptions } from '@/entities/user/model/useAgentOptions'
import type { CreateDealPayload, DealStatus } from '@/entities/deal/model/type'

const NO_PROPERTY = 'NO_PROPERTY'

export function CreateDealDrawer() {
  const { mutate, isPending } = useCreateDeal()
  const { role, userId } = useAuthStore()
  const { data: clients = [] } = useClients()
  const { data: properties = [] } = useProperties()
  const { data: agents = [] } = useAgentOptions()

  const [open, setOpen] = useState(false)
  const [title, setTitle] = useState('')
  const [clientId, setClientId] = useState<string>('')
  const [propertyId, setPropertyId] = useState<string>(NO_PROPERTY)
  const [status, setStatus] = useState<DealStatus>('LEAD')
  const [budget, setBudget] = useState('')
  const [dealPrice, setDealPrice] = useState('')
  const [notes, setNotes] = useState('')
  const [agentId, setAgentId] = useState('')
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = () => {
    setError(null)

    if (!title.trim()) {
      setError('Title is required')
      return
    }

    if (!clientId) {
      setError('Client is required')
      return
    }

    const resolvedAgentId =
      role === 'ADMIN'
        ? (agentId ? Number(agentId) : undefined)
        : (userId ?? undefined)

    if (!resolvedAgentId) {
      setError('Agent is required')
      return
    }

    const payload: CreateDealPayload = {
      title: title.trim(),
      clientId: Number(clientId),
      propertyId: propertyId === NO_PROPERTY ? null : Number(propertyId),
      status,
      budget: budget.trim() ? Number(budget) : undefined,
      dealPrice: dealPrice.trim() ? Number(dealPrice) : undefined,
      notes: notes.trim() || undefined,
      agentId: resolvedAgentId
    }

    if ((payload.budget != null && payload.budget <= 0) ||
        (payload.dealPrice != null && payload.dealPrice <= 0)) {
      setError('Budget and deal price must be positive numbers')
      return
    }

    mutate(payload, {
      onSuccess: () => {
        setTitle('')
        setClientId('')
        setPropertyId(NO_PROPERTY)
        setStatus('LEAD')
        setBudget('')
        setDealPrice('')
        setNotes('')
        setAgentId('')
        setOpen(false)
      },
      onError: (err) => {
        setError(err instanceof Error ? err.message : 'Failed to create deal')
      }
    })
  }

  return (
    <Drawer open={open} onOpenChange={setOpen}>
      <DrawerTrigger asChild>
        <Button>Add deal</Button>
      </DrawerTrigger>

      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Create deal</DrawerTitle>
        </DrawerHeader>

        <div className="p-4 space-y-4">
          {error && (
            <div className="rounded-md border border-red-500/30 bg-red-500/10 px-3 py-2 text-sm text-red-600">
              {error}
            </div>
          )}

          <div className="space-y-2">
            <Label>Title</Label>
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Apartment deal"
            />
          </div>

          <div className="space-y-2">
            <Label>Client</Label>
            <Select value={clientId} onValueChange={setClientId}>
              <SelectTrigger>
                <SelectValue placeholder="Select client" />
              </SelectTrigger>
              <SelectContent>
                {clients.map((c) => (
                  <SelectItem key={c.id} value={String(c.id)}>
                    {c.fullName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>Property (optional)</Label>
            <Select value={propertyId} onValueChange={setPropertyId}>
              <SelectTrigger>
                <SelectValue placeholder="Select property" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={NO_PROPERTY}>No property</SelectItem>
                {properties.map((p) => (
                  <SelectItem key={p.id} value={String(p.id)}>
                    {p.title}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {role === 'ADMIN' && (
            <div className="space-y-2">
              <Label>Agent</Label>
              <Select value={agentId} onValueChange={setAgentId}>
                <SelectTrigger>
                  <SelectValue placeholder="Select agent" />
                </SelectTrigger>
                <SelectContent>
                  {agents.map((a) => (
                    <SelectItem key={a.id} value={String(a.id)}>
                      {a.fullName}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}

          <div className="space-y-2">
            <Label>Status</Label>
            <Select value={status} onValueChange={(v) => setStatus(v as DealStatus)}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="LEAD">Lead</SelectItem>
                <SelectItem value="NEGOTIATION">Negotiation</SelectItem>
                <SelectItem value="CLOSED_WON">Closed won</SelectItem>
                <SelectItem value="CLOSED_LOST">Closed lost</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label>Budget</Label>
              <Input
                type="number"
                min={0}
                value={budget}
                onChange={(e) => setBudget(e.target.value)}
                placeholder="200000"
              />
            </div>
            <div className="space-y-2">
              <Label>Deal price</Label>
              <Input
                type="number"
                min={0}
                value={dealPrice}
                onChange={(e) => setDealPrice(e.target.value)}
                placeholder="180000"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label>Notes</Label>
            <Textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Optional deal details"
              rows={3}
            />
          </div>
        </div>

        <DrawerFooter>
          <Button onClick={handleSubmit} disabled={isPending}>
            {isPending ? 'Creating...' : 'Create'}
          </Button>
          <DrawerClose asChild>
            <Button variant="outline">Cancel</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  )
}
