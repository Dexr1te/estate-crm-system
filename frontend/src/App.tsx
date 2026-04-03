import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { Sidebar, SidebarProvider } from './components/ui/sidebar'
import { MeetingsPage } from './pages/MeetingsPage'
import { UpcomingPage } from './pages/UpcomingPage'

// ==== QUERY CLIENT ====

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
      refetchOnWindowFocus: false // 🔥 полезно для UX
    }
  }
})

// ==== APP ====

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <SidebarProvider>
          <div className="flex h-screen overflow-hidden bg-background">
            <Sidebar />

            <main className="flex-1 flex flex-col overflow-hidden">
              <Routes>
                <Route path="/" element={<MeetingsPage />} />
                <Route path="/upcoming" element={<UpcomingPage />} />
              </Routes>
            </main>
          </div>
        </SidebarProvider>
      </BrowserRouter>

      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
