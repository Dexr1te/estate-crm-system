import { AppProviders } from '@/app/providers/AppProvider'
import { AppRouter } from './router/AppRouter'

export default function App() {
  return (
    <AppProviders>
      <AppRouter />
    </AppProviders>
  )
}
