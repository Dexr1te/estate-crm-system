export type ClientType = 'BUYER' | 'SELLER'
export type DealStatus = 'LEAD' | 'NEGOTIATION' | 'CLOSED_WON' | 'CLOSED_LOST'

export type ClientListItem = {
  id: number
  fullName: string
  phone?: string | null
  email?: string | null
  status?: DealStatus | null
  budget?: number | null
  propertyTitle?: string | null
  nextMeetingAt?: string | null
  lastContactAt?: string | null
}

export type ClientRequest = {
  fullName: string
  email?: string
  phone?: string
  type: ClientType
  notes?: string
  agentId?: number
}

export type ClientsQuery = {
  type?: ClientType
  agentId?: number
  search?: string
}
