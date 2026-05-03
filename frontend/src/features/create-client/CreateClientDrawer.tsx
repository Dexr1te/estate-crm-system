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
import { useAuthStore } from '@/entities/auth/model/authStore'
import { useAgentOptions } from '@/entities/user/model/useAgentOptions'

export function CreateClientDrawer() {
  const { mutate, isPending } = useCreateClient()
  const { role, userId } = useAuthStore()
  const { data: agents = [] } = useAgentOptions()

  const [open, setOpen] = useState(false)
  const [fullName, setFullName] = useState('')
  const [phone, setPhone] = useState('')
  const [email, setEmail] = useState('')
  const [notes, setNotes] = useState('')
  const [agentId, setAgentId] = useState('')
  const [type, setType] = useState<ClientType>('BUYER')
  const [error, setError] = useState<string | null>(null)
  // После других useState
  const [phoneError, setPhoneError] = useState<string | null>(null)

  // Функция валидации — только цифры, +, -, пробелы, скобки, 7-20 символов
  function validatePhone(value: string): string | null {
    if (!value.trim()) return null // телефон необязателен
    if (!/^\+?[\d\s\-(). ]{7,20}$/.test(value.trim()))
      return 'Invalid phone number format'
    return null
  }

  const buildRequest = (): ClientRequest => {
    const trimmedFullName = fullName.trim()
    const selectedAgentId =
      role === 'AGENT'
        ? userId ?? undefined
        : agentId.trim()
        ? Number(agentId)
        : undefined

    return {
      fullName: trimmedFullName,
      email: email.trim() || undefined,
      phone: phone.trim() || undefined,
      type,
      notes: notes.trim() || undefined,
      agentId: selectedAgentId
    }
  }

  const handleSubmit = () => {
    setError(null)
    if (!fullName.trim()) {
      setError('Full name is required')
      return
    }

    const phoneProblem = validatePhone(phone)
    if (phoneProblem) {
      setPhoneError(phoneProblem)
      return
    }

    mutate(buildRequest(), {
      onSuccess: () => {
        setFullName('')
        setPhone('')
        setPhoneError(null)
        setEmail('')
        setNotes('')
        setAgentId('')
        setType('BUYER')
        setOpen(false)
      },
      onError: (err) => {
        setError(err instanceof Error ? err.message : 'Failed to create client')
      }
    })
  }

  return (
    <Drawer open={open} onOpenChange={setOpen}>
      <DrawerTrigger asChild>
        <Button>Add client</Button>
      </DrawerTrigger>

      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Create client</DrawerTitle>
        </DrawerHeader>

        <div className="p-4 space-y-4">
          {error && (
            <div className="rounded-md border border-red-500/30 bg-red-500/10 px-3 py-2 text-sm text-red-600">
              {error}
            </div>
          )}

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
              onChange={(e) => {
                setPhone(e.target.value)
                setPhoneError(validatePhone(e.target.value))
              }}
              placeholder="+7 777 123 4567"
              className={
                phoneError ? 'border-red-500 focus-visible:ring-red-500' : ''
              }
            />
            {phoneError && (
              <p
                style={{
                  fontSize: 12,
                  color: 'var(--color-text-danger)',
                  marginTop: 4
                }}
              >
                {phoneError}
              </p>
            )}
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

          {role === 'ADMIN' && (
            <div className="space-y-2">
              <Label>Agent (optional)</Label>
              <Select value={agentId} onValueChange={setAgentId}>
                <SelectTrigger>
                  <SelectValue placeholder="Unassigned" />
                </SelectTrigger>
                <SelectContent>
                  {agents.map((agent) => (
                    <SelectItem key={agent.id} value={String(agent.id)}>
                      {agent.fullName}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}

          <div className="space-y-2">
            <Label>Client type</Label>
            <Select
              value={type}
              onValueChange={(v) => setType(v as ClientType)}
            >
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
