import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
import { CreateClientDrawer } from '@/features/create-client/CreateClientDrawer'
import { useClients } from '@/entities/clients/model/hook'

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

export function ClientsPage() {
  const { data: clients = [], isLoading } = useClients()

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Clients</h1>
        <CreateClientDrawer />
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="text-sm text-muted-foreground">Loading...</div>
      )}

      {/* Table */}
      <div className="border rounded-lg overflow-hidden">
        <Table>
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
            </TableRow>
          </TableHeader>

          <TableBody>
            {clients.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={8}
                  className="text-center py-6 text-muted-foreground"
                >
                  No clients yet
                </TableCell>
              </TableRow>
            ) : (
              clients.map((c) => (
                <TableRow key={c.id}>
                  {/* Name */}
                  <TableCell>{c.fullName}</TableCell>

                  {/* Phone */}
                  <TableCell>{c.phone || '-'}</TableCell>

                  {/* Email */}
                  <TableCell>{c.email || '-'}</TableCell>

                  <TableCell>{c.status ? c.status : '-'}</TableCell>

                  <TableCell>{formatBudget(c.budget)}</TableCell>

                  <TableCell>{c.propertyTitle || '-'}</TableCell>

                  <TableCell>{formatDateTime(c.nextMeetingAt)}</TableCell>

                  <TableCell>{formatDateTime(c.lastContactAt)}</TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
