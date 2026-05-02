import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { agentsApi } from '../api/agents'
import type { Agent, AgentStats, CreateAgentRequest } from './types'

const AGENTS_QUERY_KEY = ['admin', 'agents'] as const

type AgentsCache = Agent[] | undefined

function updateAgentsCache(
  queryClient: ReturnType<typeof useQueryClient>,
  updater: (agent: Agent) => Agent
) {
  queryClient.setQueryData<AgentsCache>(AGENTS_QUERY_KEY, (current) =>
    current?.map(updater)
  )
}

// Fetch all agents
export function useAgents() {
  return useQuery({
    queryKey: AGENTS_QUERY_KEY,
    queryFn: () => agentsApi.getAll()
  })
}

// Fetch agent stats by ID
export function useAgentStats(agentId: number) {
  return useQuery({
    queryKey: ['admin', 'agents', agentId, 'stats'],
    queryFn: () => agentsApi.getStats(agentId),
    enabled: !!agentId
  })
}

// Create agent mutation
export function useCreateAgent() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (request: CreateAgentRequest) => agentsApi.create(request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: AGENTS_QUERY_KEY })
    }
  })
}

// Deactivate agent mutation
export function useDeactivateAgent() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (agentId: number) => agentsApi.deactivate(agentId),
    onMutate: async (agentId) => {
      await queryClient.cancelQueries({ queryKey: AGENTS_QUERY_KEY })
      const previousAgents = queryClient.getQueryData<Agent[]>(AGENTS_QUERY_KEY)

      updateAgentsCache(queryClient, (agent) =>
        agent.id === agentId ? { ...agent, isActive: false } : agent
      )

      return { previousAgents }
    },
    onError: (_error, _agentId, context) => {
      if (context?.previousAgents) {
        queryClient.setQueryData(AGENTS_QUERY_KEY, context.previousAgents)
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: AGENTS_QUERY_KEY })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: AGENTS_QUERY_KEY })
    }
  })
}

// Activate agent mutation
export function useActivateAgent() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (agentId: number) => agentsApi.activate(agentId),
    onMutate: async (agentId) => {
      await queryClient.cancelQueries({ queryKey: AGENTS_QUERY_KEY })
      const previousAgents = queryClient.getQueryData<Agent[]>(AGENTS_QUERY_KEY)

      updateAgentsCache(queryClient, (agent) =>
        agent.id === agentId ? { ...agent, isActive: true } : agent
      )

      return { previousAgents }
    },
    onError: (_error, _agentId, context) => {
      if (context?.previousAgents) {
        queryClient.setQueryData(AGENTS_QUERY_KEY, context.previousAgents)
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: AGENTS_QUERY_KEY })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: AGENTS_QUERY_KEY })
    }
  })
}

// Change role mutation
export function useChangeRole() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({
      agentId,
      role
    }: {
      agentId: number
      role: 'ADMIN' | 'AGENT'
    }) => agentsApi.changeRole(agentId, role),
    onMutate: async ({ agentId, role }) => {
      await queryClient.cancelQueries({ queryKey: AGENTS_QUERY_KEY })
      const previousAgents = queryClient.getQueryData<Agent[]>(AGENTS_QUERY_KEY)

      updateAgentsCache(queryClient, (agent) =>
        agent.id === agentId ? { ...agent, role } : agent
      )

      return { previousAgents }
    },
    onError: (_error, _variables, context) => {
      if (context?.previousAgents) {
        queryClient.setQueryData(AGENTS_QUERY_KEY, context.previousAgents)
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: AGENTS_QUERY_KEY })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: AGENTS_QUERY_KEY })
    }
  })
}
