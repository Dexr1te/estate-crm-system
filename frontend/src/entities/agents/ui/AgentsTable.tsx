import type { Agent } from '../model/types'
import { Button } from '@/components/ui/button'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'
import {
  MoreHorizontal,
  CheckCircle2,
  XCircle,
  Shield,
  UserCheck
} from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'

interface AgentsTableProps {
  agents: Agent[] | undefined
  isPending: boolean
  onDeactivate: (id: number) => void
  onActivate: (id: number) => void
  onChangeRole: (id: number, role: 'ADMIN' | 'AGENT') => void
  isDeactivating?: boolean
  isActivating?: boolean
  isChangingRole?: boolean
}

export function AgentsTable({
  agents,
  isPending,
  onDeactivate,
  onActivate,
  onChangeRole,
  isDeactivating,
  isActivating,
  isChangingRole
}: AgentsTableProps) {
  if (isPending) {
    return (
      <div className="flex items-center justify-center rounded-md border p-8 text-sm text-muted-foreground">
        Loading agents...
      </div>
    )
  }

  if (!agents || agents.length === 0) {
    return (
      <div className="flex items-center justify-center rounded-md border p-8 text-sm text-muted-foreground">
        No agents found. Create one to get started.
      </div>
    )
  }

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Name</TableHead>
            <TableHead>Email</TableHead>
            <TableHead>Phone</TableHead>
            <TableHead>Role</TableHead>
            <TableHead>Status</TableHead>
            <TableHead className="text-right">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {agents.map((agent) => (
            <TableRow key={agent.id}>
              <TableCell className="font-medium">{agent.fullName}</TableCell>
              <TableCell>{agent.email}</TableCell>
              <TableCell>{agent.phone || '—'}</TableCell>
              <TableCell>
                <Badge variant={agent.role === 'ADMIN' ? 'default' : 'outline'}>
                  {agent.role === 'ADMIN' ? (
                    <Shield className="mr-1 size-3" />
                  ) : (
                    <UserCheck className="mr-1 size-3" />
                  )}
                  {agent.role}
                </Badge>
              </TableCell>
              <TableCell>
                {agent.isActive ? (
                  <Badge
                    variant="outline"
                    className="border-green-500 text-green-700"
                  >
                    <CheckCircle2 className="mr-1 size-3" />
                    Active
                  </Badge>
                ) : (
                  <Badge
                    variant="outline"
                    className="border-red-500 text-red-700"
                  >
                    <XCircle className="mr-1 size-3" />
                    Inactive
                  </Badge>
                )}
              </TableCell>
              <TableCell className="text-right">
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" size="sm">
                      <MoreHorizontal className="size-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" className="w-48">
                    <DropdownMenuLabel>Actions</DropdownMenuLabel>
                    <DropdownMenuSeparator />

                    {/* Toggle active status */}
                    {agent.isActive ? (
                      <DropdownMenuItem
                        onClick={() => onDeactivate(agent.id)}
                        disabled={isDeactivating}
                        className="text-red-600"
                      >
                        Deactivate (Fire)
                      </DropdownMenuItem>
                    ) : (
                      <DropdownMenuItem
                        onClick={() => onActivate(agent.id)}
                        disabled={isActivating}
                        className="text-green-600"
                      >
                        Activate (Rehire)
                      </DropdownMenuItem>
                    )}

                    <DropdownMenuSeparator />

                    {/* Change role */}
                    <DropdownMenuLabel className="text-xs font-normal text-muted-foreground">
                      Change Role
                    </DropdownMenuLabel>
                    {agent.role !== 'ADMIN' && (
                      <DropdownMenuItem
                        onClick={() => onChangeRole(agent.id, 'ADMIN')}
                        disabled={isChangingRole}
                      >
                        Make Admin
                      </DropdownMenuItem>
                    )}
                    {agent.role !== 'AGENT' && (
                      <DropdownMenuItem
                        onClick={() => onChangeRole(agent.id, 'AGENT')}
                        disabled={isChangingRole}
                      >
                        Make Agent
                      </DropdownMenuItem>
                    )}
                  </DropdownMenuContent>
                </DropdownMenu>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )
}
