import { Badge } from '@/components/ui/badge'
import type { DealStatus } from '../model/type'

export function DealStatusBadge({ status }: { status: DealStatus }) {
  if (status === 'LEAD') {
    return <Badge className="bg-blue-500/10 text-blue-600">Lead</Badge>
  }

  if (status === 'NEGOTIATION') {
    return (
      <Badge className="bg-yellow-500/10 text-yellow-600">Negotiation</Badge>
    )
  }

  if (status === 'CLOSED_WON') {
    return <Badge className="bg-emerald-500/10 text-emerald-700">Closed won</Badge>
  }

  if (status === 'CLOSED_LOST') {
    return <Badge className="bg-rose-500/10 text-rose-700">Closed lost</Badge>
  }

  return <Badge>{status}</Badge>
}
