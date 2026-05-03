import { useMemo, useState } from 'react'
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle
} from '@/components/ui/dialog'
import { CreateClientDrawer } from '@/features/create-client/CreateClientDrawer'
import { useClients, useDeleteClient } from '@/entities/clients/model/hook'
import { useAuthStore } from '@/entities/auth/model/authStore'
import type { ClientListItem, DealStatus } from '@/entities/clients/model/type'

function formatDateTime(value?: string | null) {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat('en', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(date)
}

function formatBudget(value?: number | null) {
  if (value == null) return '-'
  return new Intl.NumberFormat('en-US').format(value)
}

function StatusBadge({ status }: { status?: DealStatus | null }) {
  if (!status) return <span className="text-muted-foreground">-</span>
  if (status === 'LEAD') return <Badge variant="secondary">Lead</Badge>
  if (status === 'NEGOTIATION')
    return <Badge className="bg-amber-500/15 text-amber-700">Negotiation</Badge>
  if (status === 'CLOSED_WON')
    return (
      <Badge className="bg-emerald-500/15 text-emerald-700">Closed won</Badge>
    )
  return <Badge className="bg-rose-500/15 text-rose-700">Closed lost</Badge>
}

export function ClientsPage() {
  const { data: clients = [], isLoading, isError, error } = useClients()
  const { mutate: deleteClient, isPending: isDeleting } = useDeleteClient()
  const { role } = useAuthStore()

  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState<'ALL' | DealStatus>('ALL')
  const [confirmDeleteId, setConfirmDeleteId] = useState<number | null>(null)

  const filteredClients = useMemo(() => {
    return clients.filter((client) => {
      if (statusFilter !== 'ALL' && client.status !== statusFilter) return false
      if (!search.trim()) return true
      const q = search.toLowerCase().trim()
      const haystack = `${client.fullName} ${client.email ?? ''} ${
        client.phone ?? ''
      } ${client.propertyTitle ?? ''}`.toLowerCase()
      return haystack.includes(q)
    })
  }, [clients, search, statusFilter])

  const handleDelete = () => {
    if (confirmDeleteId == null) return
    deleteClient(confirmDeleteId, {
      onSuccess: () => setConfirmDeleteId(null)
    })
  }

  const confirmingClient = clients.find((c) => c.id === confirmDeleteId)

  return (
    <div className="space-y-6 p-4 md:p-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-xl font-semibold">Clients</h1>
        <CreateClientDrawer />
      </div>

      <div className="grid gap-2 sm:grid-cols-[minmax(0,1fr)_repeat(4,minmax(0,max-content))]">
        <Input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search by name, email, phone, property"
          className="w-full"
        />
        <Button
          variant={statusFilter === 'ALL' ? 'default' : 'outline'}
          onClick={() => setStatusFilter('ALL')}
        >
          All
        </Button>
        <Button
          variant={statusFilter === 'LEAD' ? 'default' : 'outline'}
          onClick={() => setStatusFilter('LEAD')}
        >
          Lead
        </Button>
        <Button
          variant={statusFilter === 'NEGOTIATION' ? 'default' : 'outline'}
          onClick={() => setStatusFilter('NEGOTIATION')}
        >
          Negotiation
        </Button>
        <Button
          variant={statusFilter === 'CLOSED_WON' ? 'default' : 'outline'}
          onClick={() => setStatusFilter('CLOSED_WON')}
        >
          Closed won
        </Button>
        <Button
          variant={statusFilter === 'CLOSED_LOST' ? 'default' : 'outline'}
          onClick={() => setStatusFilter('CLOSED_LOST')}
        >
          Closed lost
        </Button>
      </div>

      {isLoading && (
        <div className="text-sm text-muted-foreground">Loading clients...</div>
      )}

      {isError && (
        <div className="rounded-md border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-600">
          Failed to load clients:{' '}
          {error instanceof Error ? error.message : 'Unknown error'}
        </div>
      )}

      <div className="overflow-hidden rounded-lg border">
        <Table>
          <TableCaption className="py-4">
            {filteredClients.length} of {clients.length} clients
          </TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Budget</TableHead>
              <TableHead>Property</TableHead>
              <TableHead>Next meeting</TableHead>
              <TableHead>Last contact</TableHead>
              {role === 'ADMIN' && <TableHead className="w-20" />}
            </TableRow>
          </TableHeader>

          <TableBody>
            {filteredClients.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={role === 'ADMIN' ? 9 : 8}
                  className="text-center py-6 text-muted-foreground"
                >
                  No clients found
                </TableCell>
              </TableRow>
            ) : (
              filteredClients.map((c: ClientListItem) => (
                <TableRow key={c.id}>
                  <TableCell>{c.fullName}</TableCell>
                  <TableCell>{c.phone || '-'}</TableCell>
                  <TableCell>{c.email || '-'}</TableCell>
                  <TableCell>
                    <StatusBadge status={c.status ?? null} />
                  </TableCell>
                  <TableCell>{formatBudget(c.budget)}</TableCell>
                  <TableCell>{c.propertyTitle || '-'}</TableCell>
                  <TableCell>{formatDateTime(c.nextMeetingAt)}</TableCell>
                  <TableCell>{formatDateTime(c.lastContactAt)}</TableCell>
                  {role === 'ADMIN' && (
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-red-500 hover:text-red-600 hover:bg-red-500/10"
                        onClick={() => setConfirmDeleteId(c.id)}
                      >
                        Delete
                      </Button>
                    </TableCell>
                  )}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Диалог подтверждения удаления */}
      <Dialog
        open={confirmDeleteId !== null}
        onOpenChange={(open) => !open && setConfirmDeleteId(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete client</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete{' '}
              <span className="font-medium text-foreground">
                {confirmingClient?.fullName}
              </span>
              ? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setConfirmDeleteId(null)}
              disabled={isDeleting}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleDelete}
              disabled={isDeleting}
            >
              {isDeleting ? 'Deleting...' : 'Delete'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
