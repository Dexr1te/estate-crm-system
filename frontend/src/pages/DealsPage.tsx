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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle
} from '@/components/ui/dialog'
import { CreateDealDrawer } from '@/features/create-deal/CreateDealDrawer'
import {
  useDeals,
  useUpdateDeal,
  useUpdateDealStatus
} from '@/entities/deal/model/hook'
import { DealStatusBadge } from '@/entities/deal/ui/DealStatusBadge'
import type {
  CreateDealPayload,
  Deal,
  DealStatus
} from '@/entities/deal/model/type'

const STATUS_OPTIONS: DealStatus[] = [
  'LEAD',
  'NEGOTIATION',
  'CLOSED_WON',
  'CLOSED_LOST'
]

function formatCurrency(value?: number | null) {
  if (value == null) return '-'
  return `$${new Intl.NumberFormat('en-US').format(value)}`
}

function formatDate(value?: string | null) {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat('en', { dateStyle: 'medium' }).format(date)
}

function statusLabel(status: DealStatus) {
  if (status === 'LEAD') return 'Lead'
  if (status === 'NEGOTIATION') return 'Negotiation'
  if (status === 'CLOSED_WON') return 'Closed won'
  return 'Closed lost'
}

export function DealsPage() {
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState<'ALL' | DealStatus>('ALL')
  const [closeWonDeal, setCloseWonDeal] = useState<Deal | null>(null)
  const [closeWonPrice, setCloseWonPrice] = useState('')
  const [actionError, setActionError] = useState<string | null>(null)

  const {
    data: deals = [],
    isLoading,
    isError,
    error
  } = useDeals(statusFilter === 'ALL' ? undefined : { status: statusFilter })
  const { mutateAsync: updateStatus, isPending: isUpdatingStatus } =
    useUpdateDealStatus()
  const { mutateAsync: updateDeal, isPending: isUpdatingDeal } = useUpdateDeal()

  const filteredDeals = useMemo(() => {
    if (!search.trim()) return deals
    const q = search.toLowerCase().trim()
    return deals.filter((deal) => {
      const haystack = `${deal.title} ${deal.clientName} ${
        deal.propertyTitle ?? ''
      } ${deal.agentName ?? ''}`.toLowerCase()
      return haystack.includes(q)
    })
  }, [deals, search])

  const isUpdating = isUpdatingStatus || isUpdatingDeal

  const buildUpdatePayload = (
    deal: Deal,
    nextStatus: DealStatus,
    nextDealPrice?: number
  ): CreateDealPayload | null => {
    if (!deal.clientId || !deal.agentId) return null

    return {
      title: deal.title,
      status: nextStatus,
      budget: deal.budget ?? undefined,
      dealPrice: nextDealPrice ?? deal.dealPrice ?? undefined,
      notes: deal.notes ?? undefined,
      clientId: deal.clientId,
      propertyId: deal.propertyId ?? null,
      agentId: deal.agentId
    }
  }

  const handleStatusChange = async (deal: Deal, nextStatus: DealStatus) => {
    setActionError(null)

    if (nextStatus === 'CLOSED_WON') {
      setCloseWonDeal(deal)
      setCloseWonPrice(
        deal.dealPrice != null && Number.isFinite(deal.dealPrice)
          ? String(deal.dealPrice)
          : ''
      )
      return
    }

    await updateStatus({ id: deal.id, status: nextStatus }).catch((err) => {
      setActionError(
        err instanceof Error ? err.message : 'Failed to update status'
      )
    })
  }

  const confirmCloseWon = async () => {
    if (!closeWonDeal) return

    const numericPrice = Number(closeWonPrice)
    if (!Number.isFinite(numericPrice) || numericPrice <= 0) {
      setActionError(
        'Deal Price is required for Closed won and must be positive'
      )
      return
    }

    const payload = buildUpdatePayload(closeWonDeal, 'CLOSED_WON', numericPrice)
    if (!payload) {
      setActionError('Cannot update deal: missing client or agent')
      return
    }

    try {
      setActionError(null)
      await updateDeal({ id: closeWonDeal.id, payload })
      setCloseWonDeal(null)
      setCloseWonPrice('')
    } catch (err) {
      setActionError(
        err instanceof Error ? err.message : 'Failed to close deal'
      )
    }
  }

  return (
    <div className="space-y-6 p-4 md:p-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-xl font-semibold">Deals</h1>
        <CreateDealDrawer />
      </div>

      <div className="grid grid-cols-1 gap-2 md:grid-cols-2">
        <Input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search by title, client, property, agent"
        />
        <Select
          value={statusFilter}
          onValueChange={(v) => setStatusFilter(v as 'ALL' | DealStatus)}
        >
          <SelectTrigger>
            <SelectValue placeholder="All statuses" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All statuses</SelectItem>
            <SelectItem value="LEAD">Lead</SelectItem>
            <SelectItem value="NEGOTIATION">Negotiation</SelectItem>
            <SelectItem value="CLOSED_WON">Closed won</SelectItem>
            <SelectItem value="CLOSED_LOST">Closed lost</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {isLoading && (
        <div className="text-sm text-muted-foreground">Loading deals...</div>
      )}

      {isError && (
        <div className="rounded-md border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-600">
          Failed to load deals:{' '}
          {error instanceof Error ? error.message : 'Unknown error'}
        </div>
      )}

      {actionError && (
        <div className="rounded-md border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-600">
          {actionError}
        </div>
      )}

      <div className="overflow-hidden rounded-lg border">
        <Table>
          <TableCaption className="py-4">
            {filteredDeals.length} of {deals.length} deals
          </TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Client</TableHead>
              <TableHead>Property</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Budget</TableHead>
              <TableHead>Deal price</TableHead>
              <TableHead>Closed at</TableHead>
              <TableHead className="w-48">Change status</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {filteredDeals.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={8}
                  className="text-center py-6 text-muted-foreground"
                >
                  No deals found
                </TableCell>
              </TableRow>
            ) : (
              filteredDeals.map((deal) => (
                <TableRow key={deal.id}>
                  <TableCell>{deal.title}</TableCell>
                  <TableCell>{deal.clientName}</TableCell>
                  <TableCell>{deal.propertyTitle || '-'}</TableCell>
                  <TableCell>
                    <DealStatusBadge status={deal.status} />
                  </TableCell>
                  <TableCell>{formatCurrency(deal.budget)}</TableCell>
                  <TableCell>{formatCurrency(deal.dealPrice)}</TableCell>
                  <TableCell>{formatDate(deal.closedAt)}</TableCell>
                  <TableCell>
                    <Select
                      value={deal.status}
                      onValueChange={(value) =>
                        handleStatusChange(deal, value as DealStatus)
                      }
                      disabled={isUpdating}
                    >
                      <SelectTrigger className="w-44">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {STATUS_OPTIONS.map((status) => (
                          <SelectItem key={status} value={status}>
                            {statusLabel(status)}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      <Dialog
        open={!!closeWonDeal}
        onOpenChange={(open) => !open && setCloseWonDeal(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Close Deal As Won</DialogTitle>
            <DialogDescription>
              Enter final deal price to move this deal to closed won.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2">
            <Label htmlFor="deal-price">Deal Price</Label>
            <Input
              id="deal-price"
              type="number"
              min={0}
              value={closeWonPrice}
              onChange={(e) => setCloseWonPrice(e.target.value)}
              placeholder="Enter final price"
            />
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setCloseWonDeal(null)
                setCloseWonPrice('')
              }}
              disabled={isUpdating}
            >
              Cancel
            </Button>
            <Button onClick={confirmCloseWon} disabled={isUpdating}>
              {isUpdating ? 'Saving...' : 'Confirm'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
