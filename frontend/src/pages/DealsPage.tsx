import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
import { useDeals } from '@/entities/deal/model/hook'
import { useUpdateDealStatus } from '@/entities/deal/model/hook'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import { CreateDealDrawer } from '@/widgets/deal-drawer/CreateDealDrawer'

export function DealsPage() {
  const { data: deals = [], isLoading } = useDeals()
  const { mutate: updateStatus } = useUpdateDealStatus()

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Deals</h1>
        <CreateDealDrawer />
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="text-sm text-muted-foreground">Loading...</div>
      )}

      {isLoading && (
        <div className="text-sm text-muted-foreground">Loading...</div>
      )}

      <div className="border rounded-lg overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Client</TableHead>
              <TableHead>Property</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Budget</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {deals.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-6">
                  No deals yet
                </TableCell>
              </TableRow>
            ) : (
              deals.map((d) => (
                <TableRow key={d.id}>
                  <TableCell>{d.title}</TableCell>

                  <TableCell>{d.clientName}</TableCell>

                  <TableCell>{d.propertyTitle || '-'}</TableCell>

                  <TableCell>
                    <Select
                      value={d.status}
                      onValueChange={(value) =>
                        updateStatus({ id: d.id, status: value })
                      }
                    >
                      <SelectTrigger className="w-35">
                        <SelectValue />
                      </SelectTrigger>

                      <SelectContent>
                        <SelectItem value="LEAD">Lead</SelectItem>
                        <SelectItem value="NEGOTIATION">Negotiation</SelectItem>
                        <SelectItem value="CLOSED">Closed</SelectItem>
                      </SelectContent>
                    </Select>
                  </TableCell>

                  <TableCell>{d.budget ? `$${d.budget}` : '-'}</TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
