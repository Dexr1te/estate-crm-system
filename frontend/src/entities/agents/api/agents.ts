import { api } from '@/shared/api/base'
import type {
  Agent,
  AgentStats,
  CreateAgentRequest,
  CreateAgentResponse
} from '../model/types'

type RawAgent = Omit<Agent, 'isActive'> & {
  isActive?: boolean
  active?: boolean
}

type RawAgentStats = Omit<AgentStats, 'isActive'> & {
  isActive?: boolean
  active?: boolean
}

function normalizeAgent(agent: RawAgent): Agent {
  return {
    ...agent,
    isActive: agent.isActive ?? agent.active ?? false
  }
}

function normalizeStats(stats: RawAgentStats): AgentStats {
  return {
    ...stats,
    isActive: stats.isActive ?? stats.active ?? false
  }
}

export const agentsApi = {
  // Get all agents
  getAll: async () => {
    const agents = await api.get<RawAgent[]>('/admin/agents')
    return agents.map(normalizeAgent)
  },

  // Get agent stats by ID
  getStats: async (agentId: number) => {
    const stats = await api.get<RawAgentStats>(`/admin/agents/${agentId}/stats`)
    return normalizeStats(stats)
  },

  // Create new agent or admin
  create: async (request: CreateAgentRequest) => {
    const created = await api.post<RawAgent>('/admin/agents', request)
    return normalizeAgent(created) as CreateAgentResponse
  },

  // Deactivate (fire) agent
  deactivate: async (agentId: number) => {
    const updated = await api.patch<RawAgent>(`/admin/agents/${agentId}/deactivate`, {})
    return normalizeAgent(updated)
  },

  // Activate (rehire) agent
  activate: async (agentId: number) => {
    const updated = await api.patch<RawAgent>(`/admin/agents/${agentId}/activate`, {})
    return normalizeAgent(updated)
  },

  // Change agent role
  changeRole: async (agentId: number, role: 'ADMIN' | 'AGENT') => {
    const updated = await api.put<RawAgent>(`/admin/agents/${agentId}/role?role=${role}`, {})
    return normalizeAgent(updated)
  }
}
