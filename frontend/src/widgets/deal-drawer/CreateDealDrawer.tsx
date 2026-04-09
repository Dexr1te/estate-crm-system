import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

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
import { useClients } from '@/entities/clients/api/hook'
import { useProperties } from '@/entities/properties/api/hook'

export function CreateDealDrawer() {
  const { mutate, isPending } = useCreateDeal()

  const { data: clients = [] } = useClients()
  const { data: properties = [] } = useProperties()

  const [title, setTitle] = useState('')
  const [clientId, setClientId] = useState<string>('')
  const [propertyId, setPropertyId] = useState<string>('')
  const [status, setStatus] = useState<'LEAD' | 'NEGOTIATION' | 'CLOSED'>(
    'LEAD'
  )
  const [budget, setBudget] = useState('')

  const handleSubmit = () => {
    if (!title || !clientId) return

    mutate(
      {
        title,
        clientId: Number(clientId),
        propertyId: propertyId ? Number(propertyId) : null,
        status,
        budget: budget ? Number(budget) : undefined
      },
      {
        onSuccess: () => {
          setTitle('')
          setClientId('')
          setPropertyId('')
          setStatus('LEAD')
          setBudget('')
        }
      }
    )
  }

  return (
    <Drawer>
      <DrawerTrigger asChild>
        <Button>Add deal</Button>
      </DrawerTrigger>

      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Create deal</DrawerTitle>
        </DrawerHeader>

        <div className="p-4 space-y-4">
          {/* Title */}
          <div className="space-y-2">
            <Label>Title</Label>
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Apartment deal"
            />
          </div>

          {/* Client */}
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

          {/* Property */}
          <div className="space-y-2">
            <Label>Property (optional)</Label>
            <Select value={propertyId} onValueChange={setPropertyId}>
              <SelectTrigger>
                <SelectValue placeholder="Select property" />
              </SelectTrigger>

              <SelectContent>
                {properties.map((p) => (
                  <SelectItem key={p.id} value={String(p.id)}>
                    {p.title}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Status */}
          <div className="space-y-2">
            <Label>Status</Label>
            <Select value={status} onValueChange={(v) => setStatus(v as never)}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>

              <SelectContent>
                <SelectItem value="LEAD">Lead</SelectItem>
                <SelectItem value="NEGOTIATION">Negotiation</SelectItem>
                <SelectItem value="CLOSED">Closed</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Budget */}
          <div className="space-y-2">
            <Label>Budget</Label>
            <Input
              type="number"
              value={budget}
              onChange={(e) => setBudget(e.target.value)}
              placeholder="200000"
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
