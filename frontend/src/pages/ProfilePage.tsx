import { useEffect, useState } from 'react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Separator } from '@/components/ui/separator'
import { useMe, useUpdateMe } from '@/entities/user/model/useMe'

export function ProfilePage() {
  const { data, isLoading, isError, error } = useMe()
  const { mutateAsync, isPending } = useUpdateMe()

  const [fullName, setFullName] = useState('')
  const [phone, setPhone] = useState('')
  const [message, setMessage] = useState<string | null>(null)

  useEffect(() => {
    if (data) {
      setFullName(data.fullName ?? '')
      setPhone(data.phone ?? '')
    }
  }, [data])

  const handleSave = async () => {
    setMessage(null)
    await mutateAsync({
      fullName: fullName.trim(),
      phone: phone.trim() ? phone.trim() : null
    })

    setMessage('Profile updated successfully.')
  }

  if (isLoading) {
    return (
      <div className="p-6 text-sm text-muted-foreground">
        Loading profile...
      </div>
    )
  }

  if (isError) {
    return (
      <div className="p-6 text-sm text-destructive">
        Failed to load profile:{' '}
        {error instanceof Error ? error.message : 'Unknown error'}
      </div>
    )
  }

  return (
    <div className="p-6 space-y-6 max-w-4xl">
      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <Badge variant="secondary">Profile</Badge>
          <span className="text-sm text-muted-foreground">
            Your account details
          </span>
        </div>
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">
            Agent profile
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Update the identity data used across the app. Email is shown here
            for reference.
          </p>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Personal information</CardTitle>
          <CardDescription>
            These values appear in the sidebar and in shared records.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-5">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="fullName">Full name</Label>
              <Input
                id="fullName"
                value={fullName}
                onChange={(event) => setFullName(event.target.value)}
                placeholder="Your full name"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="phone">Phone</Label>
              <Input
                id="phone"
                value={phone}
                onChange={(event) => setPhone(event.target.value)}
                placeholder="+7 ..."
              />
            </div>
          </div>

          <Separator />

          <div className="grid gap-4 md:grid-cols-3 text-sm">
            <div className="space-y-1">
              <div className="text-muted-foreground">Email</div>
              <div className="font-medium">{data?.email}</div>
            </div>
            <div className="space-y-1">
              <div className="text-muted-foreground">Role</div>
              <div className="font-medium">{data?.role}</div>
            </div>
            <div className="space-y-1">
              <div className="text-muted-foreground">User ID</div>
              <div className="font-medium">{data?.id}</div>
            </div>
          </div>

          {message && (
            <div className="rounded-lg border border-emerald-500/20 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-600 dark:text-emerald-400">
              {message}
            </div>
          )}

          <div className="flex flex-wrap gap-3">
            <Button
              onClick={handleSave}
              disabled={isPending || !fullName.trim()}
            >
              {isPending ? 'Saving...' : 'Save changes'}
            </Button>
            <Button
              variant="outline"
              onClick={() => {
                if (data) {
                  setFullName(data.fullName ?? '')
                  setPhone(data.phone ?? '')
                }
                setMessage(null)
              }}
            >
              Reset
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
