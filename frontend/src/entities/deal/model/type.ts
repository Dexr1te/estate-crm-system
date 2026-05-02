export type DealStatus = 'LEAD' | 'NEGOTIATION' | 'CLOSED_WON' | 'CLOSED_LOST'

export type Deal = {
  id: number
  title: string
  status: DealStatus
  budget?: number | null
  dealPrice?: number | null
  notes?: string | null

  clientId?: number
  clientName: string
  propertyId?: number | null
  propertyTitle?: string | null
  propertyAddress?: string | null
  agentId?: number
  agentName?: string
  closedAt?: string | null
  createdAt?: string
  updatedAt?: string
}

export type CreateDealPayload = {
  title: string
  status?: DealStatus
  budget?: number
  dealPrice?: number
  notes?: string
  clientId: number
  propertyId?: number | null
  agentId: number
}

export type DealsFilters = {
  status?: DealStatus
  agentId?: number
}
