import { Badge } from '@/components/ui/badge'

export function DealStatusBadge({ status }: { status: string }) {
  if (status === 'LEAD') {
    return <Badge className="bg-blue-500/10 text-blue-600">Lead</Badge>
  }

  if (status === 'NEGOTIATION') {
    return (
      <Badge className="bg-yellow-500/10 text-yellow-600">Negotiation</Badge>
    )
  }

  if (status === 'CLOSED') {
    return <Badge className="bg-green-500/10 text-green-600">Closed</Badge>
  }

  return <Badge>{status}</Badge>
}
