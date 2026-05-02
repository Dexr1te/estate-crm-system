import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'

import { CreatePropertyDrawer } from '@/features/create-property/CreatePropertyDrawer'
import { useProperties } from '@/entities/properties/model/hook'

export function PropertiesPage() {
  const { data: properties = [], isLoading } = useProperties()

  function StatusBadge({ status }: { status: string }) {
    if (status === 'AVAILABLE') {
      return <Badge className="bg-green-500/10 text-green-600">Available</Badge>
    }

    if (status === 'RESERVED') {
      return (
        <Badge className="bg-yellow-500/10 text-yellow-600">Reserved</Badge>
      )
    }

    if (status === 'SOLD') {
      return <Badge className="bg-muted text-muted-foreground">Sold</Badge>
    }

    return <Badge>{status}</Badge>
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Properties</h1>

        <CreatePropertyDrawer />
      </div>
      {isLoading && <div></div>}
      {/* Table */}
      <div className="border rounded-lg overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Price</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>City</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {properties.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={5}
                  className="text-center py-6 text-muted-foreground"
                >
                  No properties yet
                </TableCell>
              </TableRow>
            ) : (
              properties.map((p) => (
                <TableRow key={p.id}>
                  <TableCell>{p.title}</TableCell>

                  <TableCell>
                    <Badge variant="outline">{p.type}</Badge>
                  </TableCell>

                  <TableCell>${p.price.toLocaleString()}</TableCell>

                  <TableCell>
                    <StatusBadge status={p.status} />
                  </TableCell>

                  <TableCell>{p.city || '-'}</TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
