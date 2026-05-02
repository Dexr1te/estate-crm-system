import type {
  CreateMeetingDto,
  Meeting,
  MeetingEditable
} from '@/entities/meeting/model/type'

export type MeetingFormProps<T = CreateMeetingDto> = {
  initial?: MeetingEditable
  onSubmit: (data: T) => void
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
  onEdit: (meeting: Meeting) => void
}
