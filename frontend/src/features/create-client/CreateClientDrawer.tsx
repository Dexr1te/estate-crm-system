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

import { useCreateClient } from '@/entities/clients/model/hook'
import type { ClientRequest, ClientType } from '@/entities/clients/model/type'

export function CreateClientDrawer() {
  const { mutate, isPending } = useCreateClient()

  const [fullName, setFullName] = useState('')
  const [phone, setPhone] = useState('')
  const [email, setEmail] = useState('')
  const [notes, setNotes] = useState('')
  const [agentId, setAgentId] = useState('')
  const [type, setType] = useState<ClientType>('BUYER')

  const buildRequest = (): ClientRequest => {
    const trimmedFullName = fullName.trim()

    return {
      fullName: trimmedFullName,
      email: email.trim() || undefined,
      phone: phone.trim() || undefined,
      type,
      notes: notes.trim() || undefined,
      agentId: agentId.trim() ? Number(agentId) : undefined
    }
  }

  const handleSubmit = () => {
    if (!fullName.trim()) return

    mutate(buildRequest(), {
      onSuccess: () => {
        setFullName('')
        setPhone('')
        setEmail('')
        setNotes('')
        setAgentId('')
        setType('BUYER')
      }
    })
  }

  return (
    <Drawer>
      <DrawerTrigger asChild>
        <Button>Add client</Button>
      </DrawerTrigger>

      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Create client</DrawerTitle>
        </DrawerHeader>

        <div className="p-4 space-y-4">
          {/* Full name */}
          <div className="space-y-2">
            <Label>Full name</Label>
            <Input
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="John Doe"
            />
          </div>

          {/* Phone */}
          <div className="space-y-2">
            <Label>Phone</Label>
            <Input
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="+7 777 123 4567"
            />
          </div>

          {/* Email */}
          <div className="space-y-2">
            <Label>Email</Label>
            <Input
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="client@mail.com"
            />
          </div>

          {/* Notes */}
          <div className="space-y-2">
            <Label>Notes</Label>
            <Textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Important context about the client"
              rows={4}
            />
          </div>

          {/* Agent ID */}
          <div className="space-y-2">
            <Label>Agent ID</Label>
            <Input
              type="number"
              value={agentId}
              onChange={(e) => setAgentId(e.target.value)}
              disabled
              placeholder="Optional"
            />
          </div>

          {/* Type (ВАЖНО) */}
          <div className="space-y-2">
            <Label>Client type</Label>
            <Select value={type} onValueChange={(v) => setType(v as never)}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>

              <SelectContent>
                <SelectItem value="BUYER">Buyer</SelectItem>
                <SelectItem value="SELLER">Seller</SelectItem>
              </SelectContent>
            </Select>
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
