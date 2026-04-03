import {
  useMutation,
  useQuery,
  useQueryClient,
  type UseQueryResult,
  type UseMutationResult
} from '@tanstack/react-query'
import { meetingsApi } from '../api/meetings'
import type {
  Meeting,
  CreateMeetingDto,
  UpdateMeetingDto
} from '../api/meetings'

// ==== KEYS ====

export const MEETINGS_KEY = 'meetings'
export const UPCOMING_KEY = 'upcoming-meetings'

// ==== QUERIES ====

export function useMeetings(
  agentId?: string
): UseQueryResult<Meeting[], Error> {
  return useQuery({
    queryKey: [MEETINGS_KEY, agentId],
    queryFn: () => meetingsApi.getAll(agentId)
  })
}

export function useMeeting(id?: string): UseQueryResult<Meeting, Error> {
  return useQuery({
    queryKey: [MEETINGS_KEY, id],
    queryFn: () => meetingsApi.getById(id as string),
    enabled: !!id
  })
}

export function useUpcomingMeetings(
  agentId?: string
): UseQueryResult<Meeting[], Error> {
  return useQuery({
    queryKey: [UPCOMING_KEY, agentId],
    queryFn: () => meetingsApi.getUpcoming(agentId as string),
    enabled: !!agentId
  })
}

// ==== MUTATIONS ====

export function useCreateMeeting(): UseMutationResult<
  Meeting,
  Error,
  CreateMeetingDto
> {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: meetingsApi.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [MEETINGS_KEY] })
    }
  })
}

export const useUpdateMeeting = () => {
  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdateMeetingDto }) =>
      meetingsApi.update(String(id), data)
  })
}

export function useCompleteMeeting(): UseMutationResult<
  Meeting,
  Error,
  string
> {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => meetingsApi.complete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [MEETINGS_KEY] })
      qc.invalidateQueries({ queryKey: [UPCOMING_KEY] })
    }
  })
}
