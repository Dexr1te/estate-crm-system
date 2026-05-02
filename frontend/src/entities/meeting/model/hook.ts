import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { meetingsApi } from '@/entities/meeting/api/meetings'
import type {
  CreateMeetingDto,
  Meeting,
  UpcomingMeetingItem,
  UpdateMeetingDto
} from './type'

export const MEETINGS_KEY = ['meetings']
export const UPCOMING_KEY = ['upcoming-meetings']

export function useMeetings(agentId?: number) {
  return useQuery({
    queryKey: [...MEETINGS_KEY, agentId ?? 'all'],
    queryFn: () => meetingsApi.getAll(agentId)
  })
}

export function useMeeting(id?: number) {
  return useQuery({
    queryKey: [...MEETINGS_KEY, id ?? 'none'],
    queryFn: () => meetingsApi.getById(id as number),
    enabled: !!id
  })
}

export function useUpcomingMeetings(agentId?: number) {
  return useQuery({
    queryKey: [...UPCOMING_KEY, agentId ?? 'all'],
    queryFn: async () => {
      if (agentId != null) {
        return meetingsApi.getUpcomingByAgent(agentId)
      }

      const allUpcoming = await meetingsApi.getUpcomingAll()
      return allUpcoming.map((m): Meeting => ({
        id: m.id,
        title: m.title,
        scheduledAt: m.scheduledAt,
        clientName: m.clientName,
        description: null,
        location: null,
        completed: false,
        dealId: null,
        dealTitle: null,
        agentId: 0,
        agentName: '',
        clientId: 0
      }))
    }
  })
}

function invalidateMeetingQueries(queryClient: ReturnType<typeof useQueryClient>) {
  queryClient.invalidateQueries({ queryKey: MEETINGS_KEY })
  queryClient.invalidateQueries({ queryKey: UPCOMING_KEY })
}

export function useCreateMeeting() {
  const queryClient = useQueryClient()

  return useMutation<Meeting, Error, CreateMeetingDto>({
    mutationFn: meetingsApi.create,
    onSuccess: () => invalidateMeetingQueries(queryClient)
  })
}

export function useUpdateMeeting() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdateMeetingDto }) =>
      meetingsApi.update(id, data),
    onSuccess: () => invalidateMeetingQueries(queryClient)
  })
}

export function useCompleteMeeting() {
  const queryClient = useQueryClient()

  return useMutation<Meeting, Error, number>({
    mutationFn: (id: number) => meetingsApi.complete(id),
    onSuccess: () => invalidateMeetingQueries(queryClient)
  })
}

export function useDeleteMeeting() {
  const queryClient = useQueryClient()

  return useMutation<void, Error, number>({
    mutationFn: (id: number) => meetingsApi.remove(id),
    onSuccess: () => invalidateMeetingQueries(queryClient)
  })
}

export type UpcomingLite = UpcomingMeetingItem
