import { useState } from 'react'
import { useAuthStore } from '@/entities/auth/model/authStore'
import { Navigate } from 'react-router-dom'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { AgentsTable } from '@/entities/agents/ui/AgentsTable'
import { CreateAgentDialog } from '@/entities/agents/ui/CreateAgentDialog'
import {
  useAgents,
  useCreateAgent,
  useDeactivateAgent,
  useActivateAgent,
  useChangeRole
} from '@/entities/agents/model/useAgents'
import type { CreateAgentRequest } from '@/entities/agents/model/types'

export function AgentsPage() {
  const { role } = useAuthStore()
  const [createDialogOpen, setCreateDialogOpen] = useState(false)

  // Queries & mutations
  const { data: agents, isPending, isError, error } = useAgents()
  const {
    mutateAsync: createAgent,
    isPending: isCreating,
    error: createError
  } = useCreateAgent()
  const {
    mutate: deactivateAgent,
    isPending: isDeactivating,
    error: deactivateError
  } = useDeactivateAgent()
  const {
    mutate: activateAgent,
    isPending: isActivating,
    error: activateError
  } = useActivateAgent()
  const {
    mutate: changeRole,
    isPending: isChangingRole,
    error: changeRoleError
  } = useChangeRole()

  const mutationError =
    (createError as Error | null) ??
    (deactivateError as Error | null) ??
    (activateError as Error | null) ??
    (changeRoleError as Error | null) ??
    null

  // Protect route if user is not admin
  if (role !== 'ADMIN') {
    return <Navigate to="/dashboard" replace />
  }

  const handleCreateAgent = async (data: CreateAgentRequest) => {
    await createAgent(data)
  }

  return (
    <div className="flex-1 space-y-6 p-6">
      <div className="flex items-center justify-between">
        <h2 className="text-3xl font-bold tracking-tight">Agent Management</h2>
        <Button onClick={() => setCreateDialogOpen(true)}>
          <Plus className="mr-2 size-4" />
          Create Agent
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Agents</CardTitle>
          <CardDescription>
            Manage real estate agents in your system. You can view their stats,
            change roles, and deactivate/activate accounts.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {(isError || mutationError) && (
            <div className="mb-4 rounded-md border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-400">
              {mutationError?.message ??
                (error instanceof Error
                  ? error.message
                  : 'Failed to load agents')}
            </div>
          )}
          <AgentsTable
            agents={agents}
            isPending={isPending}
            onDeactivate={(id) => deactivateAgent(id)}
            onActivate={(id) => activateAgent(id)}
            onChangeRole={(id, role) => changeRole({ agentId: id, role })}
            isDeactivating={isDeactivating}
            isActivating={isActivating}
            isChangingRole={isChangingRole}
          />
        </CardContent>
      </Card>

      <CreateAgentDialog
        open={createDialogOpen}
        onOpenChange={setCreateDialogOpen}
        onSubmit={handleCreateAgent}
        isPending={isCreating}
      />
    </div>
  )
}
