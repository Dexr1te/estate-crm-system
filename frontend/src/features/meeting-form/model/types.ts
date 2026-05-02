import type {
  CreateMeetingDto,
  Meeting,
  MeetingEditable,
  UpdateMeetingDto
} from '@/entities/meeting/model/type'

export type MeetingFormPayload = CreateMeetingDto | UpdateMeetingDto

export type MeetingFormProps = {
  initial?: MeetingEditable
  onSubmit: (data: MeetingFormPayload) => void
  onCancel: () => void
  loading?: boolean
}

export type FormState = {
  title: string
  description: string
  scheduledAt: string
  location: string
  dealId: string
  agentId: string
  clientId: string
}

export const DEFAULT_FORM: FormState = {
  title: '',
  description: '',
  scheduledAt: '',
  location: '',
  dealId: '',
  agentId: '',
  clientId: ''
}

export type MeetingCardProps = {
  meeting: Meeting
  onEdit?: (meeting: Meeting) => void
}
