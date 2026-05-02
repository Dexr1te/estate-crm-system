export interface Meeting {
  id: number
  title: string
  description?: string | null
  scheduledAt: string
  location?: string | null
  completed: boolean
  dealId?: number | null
  dealTitle?: string | null
  agentId: number
  agentName: string
  clientId: number
  clientName: string
  createdAt?: string
  updatedAt?: string
}

export interface CreateMeetingDto {
  title: string
  description?: string
  scheduledAt: string
  location?: string
  dealId?: number
  agentId: number
  clientId: number
}

export interface MeetingEditable {
  id: number
  title?: string
  description?: string | null
  scheduledAt?: string
  location?: string | null
  agentId?: number
  dealId?: number | null
  clientId?: number
}

export type UpdateMeetingDto = CreateMeetingDto

export interface UpcomingMeetingItem {
  id: number
  title: string
  scheduledAt: string
  clientName: string
}
