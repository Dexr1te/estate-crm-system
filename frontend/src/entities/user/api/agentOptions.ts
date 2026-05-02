import { api } from '@/shared/api/base'
import type { AgentOption } from '../model/types'

export const getAgentOptions = () => api.get<AgentOption[]>('/users/agents')
