import { api } from '@/shared/api/base'
import type {
  Agent,
  AgentStats,
  CreateAgentRequest,
  CreateAgentResponse
} from '../model/types'

export const agentsApi = {
  // Get all agents
  getAll: () => api.get<Agent[]>('/admin/agents'),

  // Get agent stats by ID
  getStats: (agentId: number) =>
    api.get<AgentStats>(`/admin/agents/${agentId}/stats`),

  // Create new agent or admin
  create: (request: CreateAgentRequest) =>
    api.post<CreateAgentResponse>('/admin/agents', request),

  // Deactivate (fire) agent
  deactivate: (agentId: number) =>
    api.patch<Agent>(`/admin/agents/${agentId}/deactivate`, {}),

  // Activate (rehire) agent
  activate: (agentId: number) =>
    api.patch<Agent>(`/admin/agents/${agentId}/activate`, {}),

  // Change agent role
  changeRole: (agentId: number, role: 'ADMIN' | 'AGENT') =>
    api.put<Agent>(`/admin/agents/${agentId}/role?role=${role}`, {})
}
