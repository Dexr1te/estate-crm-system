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
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
// import {
//   Select,
//   SelectContent,
//   SelectItem,
//   SelectTrigger,
//   SelectValue
// } from '@/components/ui/select'
import { Button } from '@/components/ui/button'

import { CreatePropertyDrawer } from '@/features/create-property/CreatePropertyDrawer'
import {
  useProperties,
  useUpdatePropertyStatus
} from '@/entities/properties/model/hook'
import type {
  PropertyFilters,
  PropertyStatus,
  PropertyType
} from '@/entities/properties/model/types'

function formatPrice(value: number) {
  return `$${new Intl.NumberFormat('en-US').format(value)}`
}

function statusTone(status: PropertyStatus) {
  if (status === 'AVAILABLE') return 'bg-emerald-500/15 text-emerald-700'
  if (status === 'RESERVED') return 'bg-amber-500/15 text-amber-700'
  return 'bg-muted text-muted-foreground'
}

export function PropertiesPage() {
  const [search, setSearch] = useState('')
  const [status] = useState<'ALL' | PropertyStatus>('ALL')
  const [type] = useState<'ALL' | PropertyType>('ALL')
  const [city, setCity] = useState('')

  const filters = useMemo<PropertyFilters>(() => {
    return {
      search: search.trim() || undefined,
      status: status === 'ALL' ? undefined : status,
      type: type === 'ALL' ? undefined : type,
      city: city.trim() || undefined
    }
  }, [search, status, type, city])

  const {
    data: properties = [],
    isLoading,
    isError,
    error
  } = useProperties(filters)
  const { mutate: updateStatus, isPending: isUpdatingStatus } =
    useUpdatePropertyStatus()

  function nextStatus(current: PropertyStatus): PropertyStatus {
    if (current === 'AVAILABLE') return 'RESERVED'
    if (current === 'RESERVED') return 'SOLD'
    return 'AVAILABLE'
  }

  return (
    <div className="space-y-6 p-4 md:p-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-xl font-semibold">Properties</h1>
        <CreatePropertyDrawer />
      </div>

      <div className="grid gap-2 md:grid-cols-4">
        <Input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search title, address, city"
        />
        <Input
          value={city}
          onChange={(e) => setCity(e.target.value)}
          placeholder="City"
        />
      </div>

      {isLoading && (
        <div className="text-sm text-muted-foreground">
          Loading properties...
        </div>
      )}
      {isError && (
        <div className="rounded-md border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-600">
          Failed to load properties:{' '}
          {error instanceof Error ? error.message : 'Unknown error'}
        </div>
      )}

      <div className="overflow-hidden rounded-lg border">
        <Table>
          <TableCaption className="py-4">
            {properties.length} properties
          </TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Address</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Price</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>City</TableHead>
              <TableHead className="w-32 text-right">Action</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {properties.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={7}
                  className="text-center py-6 text-muted-foreground"
                >
                  No properties found
                </TableCell>
              </TableRow>
            ) : (
              properties.map((p) => (
                <TableRow key={p.id}>
                  <TableCell>{p.title}</TableCell>
                  <TableCell>{p.address}</TableCell>

                  <TableCell>
                    <Badge variant="outline">{p.type}</Badge>
                  </TableCell>

                  <TableCell>{formatPrice(p.price)}</TableCell>

                  <TableCell>
                    <Badge className={statusTone(p.status)}>
                      {p.status.toLowerCase()}
                    </Badge>
                  </TableCell>

                  <TableCell>{p.city || '-'}</TableCell>
                  <TableCell className="text-right">
                    <Button
                      variant="ghost"
                      size="sm"
                      disabled={isUpdatingStatus}
                      onClick={() =>
                        updateStatus({ id: p.id, status: nextStatus(p.status) })
                      }
                    >
                      Mark {nextStatus(p.status).toLowerCase()}
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
