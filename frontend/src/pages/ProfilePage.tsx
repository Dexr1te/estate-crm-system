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
import { useMe, useUpdateMe } from '@/entities/user/model/useMe'
import { useAuthStore } from '@/entities/auth/model/authStore'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'

function getInitials(value?: string | null) {
  if (!value) return 'U'
  return value
    .split(' ')
    .slice(0, 2)
    .map((part) => part[0])
    .join('')
    .toUpperCase()
}

export function ProfilePage() {
  const { data, isLoading, isError, error } = useMe()
  const { mutateAsync, isPending } = useUpdateMe()
  const authUserId = useAuthStore((s) => s.userId)
  const [fullName, setFullName] = useState('')
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [saveError, setSaveError] = useState<string | null>(null)

  useEffect(() => {
    if (data) {
      setFullName(data.fullName ?? '')
      setEmail(data.email ?? '')
    }
  }, [data])

  const handleSave = async () => {
    try {
      setMessage(null)
      setSaveError(null)
      await mutateAsync({
        fullName: fullName.trim(),
        email: email.trim()
      })
      setMessage('Profile updated successfully.')
    } catch (err) {
      setSaveError(
        err instanceof Error ? err.message : 'Failed to update profile'
      )
    }
  }

  if (isLoading) {
    return (
      <div className="p-6 text-sm text-muted-foreground md:p-8 lg:p-10">
        Loading profile...
      </div>
    )
  }

  if (isError) {
    return (
      <div className="p-6 text-sm text-destructive md:p-8 lg:p-10">
        Failed to load profile:{' '}
        {error instanceof Error ? error.message : 'Unknown error'}
      </div>
    )
  }

  return (
    <div className="w-full space-y-6 px-4 py-6 text-left sm:px-6 md:px-8 lg:px-10 lg:py-8">
      <div className="flex flex-col gap-4 text-left lg:flex-row lg:items-end lg:justify-between">
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <Badge variant="secondary">Profile</Badge>
            <span className="text-sm text-muted-foreground">
              Your account details
            </span>
          </div>
          <div>
            <h1 className="text-3xl font-semibold tracking-tight">
              Agent profile
            </h1>
            <p className="mt-2 max-w-2xl text-sm text-muted-foreground">
              Update the identity data used across the app. This page is now
              laid out for desktop, so the form feels like a proper account
              workspace instead of a narrow mobile card.
            </p>
          </div>
        </div>

        <div className="w-full rounded-2xl border bg-card px-4 py-3 shadow-sm lg:w-auto">
          <Avatar className="h-12 w-12 rounded-xl">
            <AvatarFallback className="rounded-xl bg-primary/10 text-sm font-semibold text-primary">
              {getInitials(data?.fullName ?? fullName)}
            </AvatarFallback>
          </Avatar>
          <div className="min-w-0">
            <div className="truncate text-sm font-semibold">
              {data?.fullName ?? fullName ?? 'Agent'}
            </div>
            <div className="truncate text-sm text-muted-foreground">
              {data?.email ?? email ?? 'No email'}
            </div>
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1.4fr)_minmax(320px,0.7fr)]">
        <Card className="shadow-sm">
          <CardHeader className="space-y-2">
            <CardTitle>Personal information</CardTitle>
            <CardDescription>
              Edit the name and email tied to your account.
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
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="you@example.com"
                />
              </div>
            </div>

            {saveError && (
              <div className="rounded-md border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-500">
                {saveError}
              </div>
            )}

            {message && (
              <div className="rounded-md border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-700 dark:text-emerald-400">
                {message}
              </div>
            )}

            <div className="flex flex-col gap-2 sm:flex-row">
              <Button
                onClick={handleSave}
                disabled={isPending || !fullName.trim() || !email.trim()}
              >
                {isPending ? 'Saving...' : 'Save changes'}
              </Button>
              <Button
                variant="outline"
                onClick={() => {
                  setFullName(data?.fullName ?? '')
                  setEmail(data?.email ?? '')
                  setMessage(null)
                  setSaveError(null)
                }}
                disabled={isPending}
              >
                Reset
              </Button>
            </div>
          </CardContent>
        </Card>

        <div className="space-y-6">
          <Card className="shadow-sm">
            <CardHeader>
              <CardTitle>Account summary</CardTitle>
              <CardDescription>
                Quick read-only info pulled from the session and backend.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4 text-sm">
              <div className="rounded-xl border bg-muted/30 p-4">
                <div className="text-muted-foreground">Role</div>
                <div className="mt-1 text-base font-medium">{data?.role}</div>
              </div>
              <div className="rounded-xl border bg-muted/30 p-4">
                <div className="text-muted-foreground">User ID</div>
                <div className="mt-1 text-base font-medium">
                  {data?.userId ?? authUserId ?? '-'}
                </div>
              </div>
              <div className="rounded-xl border bg-muted/30 p-4">
                <div className="text-muted-foreground">Primary email</div>
                <div className="mt-1 text-base font-medium break-all">
                  {data?.email ?? email ?? '-'}
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="shadow-sm">
            <CardHeader>
              <CardTitle>Notes</CardTitle>
              <CardDescription>
                This page is intentionally focused on identity data only.
              </CardDescription>
            </CardHeader>
            <CardContent className="text-sm leading-6 text-muted-foreground">
              Name and email are the fields that affect how your account appears
              in the sidebar, activity trails, and backend user records.
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
