import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// ==== TYPES ====

interface AppState {
  agentId: string | null
  setAgentId: (id: string | null) => void
}

// ==== STORE ====

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({
      agentId: null,

      setAgentId: (id) => set({ agentId: id })
    }),
    {
      name: 'meetings-crm-store'
    }
  )
)
