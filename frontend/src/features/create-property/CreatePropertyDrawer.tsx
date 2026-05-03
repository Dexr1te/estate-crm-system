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

import { useCreateProperty } from '@/entities/properties/model/hook'
import { useAuthStore } from '@/entities/auth/model/authStore'
import { useAgentOptions } from '@/entities/user/model/useAgentOptions'
import type { PropertyType } from '@/entities/properties/model/types'

// ── Валидация ──────────────────────────────────────────────
function validatePrice(value: string): string | null {
  if (!value.trim()) return 'Price is required'
  const num = Number(value)
  if (!Number.isFinite(num) || num <= 0)
    return 'Price must be a positive number'
  return null
}

function validateRequired(value: string, fieldName: string): string | null {
  if (!value.trim()) return `${fieldName} is required`
  return null
}
// ───────────────────────────────────────────────────────────

export function CreatePropertyDrawer() {
  const { mutate, isPending } = useCreateProperty()
  const { role, userId } = useAuthStore()
  const { data: agents = [] } = useAgentOptions()

  const [open, setOpen] = useState(false)
  const [description, setDescription] = useState('')
  const [title, setTitle] = useState('')
  const [city, setCity] = useState('')
  const [address, setAddress] = useState('')
  const [price, setPrice] = useState('')
  const [type, setType] = useState<PropertyType>('APARTMENT')
  const [agentId, setAgentId] = useState('')

  // Ошибки полей
  const [error, setError] = useState<string | null>(null)
  const [titleError, setTitleError] = useState<string | null>(null)
  const [addressError, setAddressError] = useState<string | null>(null)
  const [priceError, setPriceError] = useState<string | null>(null)

  const handleSubmit = () => {
    setError(null)

    const titleProblem = validateRequired(title, 'Title')
    const addressProblem = validateRequired(address, 'Address')
    const priceProblem = validatePrice(price)

    setTitleError(titleProblem)
    setAddressError(addressProblem)
    setPriceError(priceProblem)

    if (titleProblem || addressProblem || priceProblem) return

    const selectedAgentId =
      role === 'AGENT'
        ? userId ?? undefined
        : agentId
        ? Number(agentId)
        : undefined

    mutate(
      {
        description: description.trim() || undefined,
        title: title.trim(),
        city: city.trim() || undefined,
        address: address.trim(),
        price: Number(price),
        type,
        agentId: selectedAgentId
      },
      {
        onSuccess: () => {
          setDescription('')
          setTitle('')
          setCity('')
          setAddress('')
          setPrice('')
          setType('APARTMENT')
          setAgentId('')
          setTitleError(null)
          setAddressError(null)
          setPriceError(null)
          setOpen(false)
        },
        onError: (err) => {
          setError(
            err instanceof Error ? err.message : 'Failed to create property'
          )
        }
      }
    )
  }

  return (
    <Drawer open={open} onOpenChange={setOpen}>
      <DrawerTrigger asChild>
        <Button>Add property</Button>
      </DrawerTrigger>

      <DrawerContent className="max-h-[90dvh] flex flex-col">
        <DrawerHeader className="shrink-0">
          <DrawerTitle>Create property</DrawerTitle>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto px-4 pb-2 space-y-4">
          {error && (
            <div className="rounded-md border border-red-500/30 bg-red-500/10 px-3 py-2 text-sm text-red-600">
              {error}
            </div>
          )}

          {/* Title */}
          <div className="space-y-2">
            <Label>Title</Label>
            <Input
              value={title}
              onChange={(e) => {
                setTitle(e.target.value)
                setTitleError(validateRequired(e.target.value, 'Title'))
              }}
              placeholder="2-room apartment in city center"
              className={
                titleError ? 'border-red-500 focus-visible:ring-red-500' : ''
              }
            />
            {titleError && <p className="text-xs text-red-500">{titleError}</p>}
          </div>

          {/* Description */}
          <div className="space-y-2">
            <Label>Description</Label>
            <Textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Short property description"
              rows={3}
            />
          </div>

          {/* Address */}
          <div className="space-y-2">
            <Label>Address</Label>
            <Input
              value={address}
              onChange={(e) => {
                setAddress(e.target.value)
                setAddressError(validateRequired(e.target.value, 'Address'))
              }}
              placeholder="Abay 123"
              className={
                addressError ? 'border-red-500 focus-visible:ring-red-500' : ''
              }
            />
            {addressError && (
              <p className="text-xs text-red-500">{addressError}</p>
            )}
          </div>

          {/* City — необязательное, без валидации */}
          <div className="space-y-2">
            <Label>City</Label>
            <Input
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Almaty"
            />
          </div>

          {/* Price */}
          <div className="space-y-2">
            <Label>Price</Label>
            <Input
              type="number"
              min={0}
              value={price}
              onChange={(e) => {
                setPrice(e.target.value)
                setPriceError(validatePrice(e.target.value))
              }}
              placeholder="250000"
              className={
                priceError ? 'border-red-500 focus-visible:ring-red-500' : ''
              }
            />
            {priceError && <p className="text-xs text-red-500">{priceError}</p>}
          </div>

          {/* Type */}
          <div className="space-y-2">
            <Label>Type</Label>
            <Select
              value={type}
              onValueChange={(v) => setType(v as PropertyType)}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="APARTMENT">Apartment</SelectItem>
                <SelectItem value="HOUSE">House</SelectItem>
                <SelectItem value="COMMERCIAL">Commercial</SelectItem>
                <SelectItem value="LAND">Land</SelectItem>
                <SelectItem value="OFFICE">Office</SelectItem>
              </SelectContent>
            </Select>
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
        </div>

        <DrawerFooter className="shrink-0 pt-2">
          <Button
            onClick={handleSubmit}
            disabled={
              isPending || !!titleError || !!addressError || !!priceError
            }
          >
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
