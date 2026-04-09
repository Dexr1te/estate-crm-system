// ==== Типы данных ====

export interface Meeting {
  id: number
  title: string
  description?: string
  scheduledAt: string
  completed?: boolean
  location?: string
  agentName?: string
  dealTitle?: string
  clientName?: string
}

export interface CreateMeetingDto {
  title: string
  description?: string
  scheduledAt: string
  location?: string
  dealId?: number
  agentId?: number
  clientId?: number
}

// eslint-disable-next-line @typescript-eslint/no-empty-object-type
export interface UpdateMeetingDto extends Partial<CreateMeetingDto> {}
