export type Deal = {
  id: number
  title: string
  status: 'LEAD' | 'NEGOTIATION' | 'CLOSED'
  budget?: number
  dealPrice?: number

  clientName: string
  propertyTitle?: string
}

export type CreateDealPayload = {
  title: string
  status?: 'LEAD' | 'NEGOTIATION' | 'CLOSED'
  budget?: number
  dealPrice?: number
  clientId: number
  propertyId?: number | null
}
