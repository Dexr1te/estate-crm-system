import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
import { CreateClientDrawer } from '@/widgets/clients-drawer/CreateClientDrawer'
import { useClients } from '@/entities/clients/api/hook'
import { Badge } from '@/components/ui/badge'

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
              <TableHead>Type</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {clients.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={4}
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

                  {/* Type */}
                  <TableCell>
                    <Badge variant="outline">
                      {c.type === 'BUYER' ? 'Buyer' : 'Seller'}
                    </Badge>
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
