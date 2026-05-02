import { useQuery } from '@tanstack/react-query'
import { getAgentOptions } from '../api/agentOptions'
import type { AgentOption } from './types'

export const AGENT_OPTIONS_KEY = ['user', 'agent-options']

export function useAgentOptions() {
  return useQuery<AgentOption[]>({
    queryKey: AGENT_OPTIONS_KEY,
    queryFn: getAgentOptions
  })
}
