export type ClientType = 'BUYER' | 'SELLER'

export type ClientListItem = {
  id: number
  fullName: string
  phone?: string | null
  email?: string | null
  status?: 'LEAD' | 'NEGOTIATION' | 'CLOSED' | null
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
