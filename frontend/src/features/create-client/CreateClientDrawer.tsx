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

import { useCreateClient } from '@/entities/clients/model/hook'

export function CreateClientDrawer() {
  const { mutate, isPending } = useCreateClient()

  const [fullName, setFullName] = useState('')
  const [phone, setPhone] = useState('')
  const [email, setEmail] = useState('')
  const [type, setType] = useState<'BUYER' | 'SELLER'>('BUYER')

  const handleSubmit = () => {
    if (!fullName) return

    mutate(
      {
        fullName,
        email,
        phone,
        type
      },
      {
        onSuccess: () => {
          // reset формы
          setFullName('')
          setPhone('')
          setEmail('')
          setType('BUYER')
        }
      }
    )
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
