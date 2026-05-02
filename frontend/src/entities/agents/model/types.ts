export type AgentRole = 'ADMIN' | 'AGENT'

export interface Agent {
  id: number
  fullName: string
  email: string
  phone: string | null
  role: AgentRole
  isActive: boolean
  createdAt: string
}

export interface AgentStats {
  agentId: number
  fullName: string
  email: string
  isActive: boolean
  totalClients: number
  totalDeals: number
  activeDeals: number
  closedDeals: number
  upcomingMeetings: number
}

export interface CreateAgentRequest {
  fullName: string
  email: string
  password: string
  phone?: string
  role?: AgentRole
}

export interface CreateAgentResponse extends Agent {}
