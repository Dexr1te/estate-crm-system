import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { useTheme } from '@/components/theme-provider'

export function SettingsPage() {
  const { theme, setTheme } = useTheme()

  return (
    <div className="p-6 space-y-6 max-w-4xl">
      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <Badge variant="secondary">Settings</Badge>
          <span className="text-sm text-muted-foreground">
            Appearance and preferences
          </span>
        </div>
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Settings</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Use this page to control the visual mode now and add more
            preferences later.
          </p>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Theme</CardTitle>
          <CardDescription>
            Choose how the interface should look. The selection is saved locally
            in the browser.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-3">
            <Button
              variant={theme === 'light' ? 'default' : 'outline'}
              onClick={() => setTheme('light')}
            >
              Light
            </Button>
            <Button
              variant={theme === 'dark' ? 'default' : 'outline'}
              onClick={() => setTheme('dark')}
            >
              Dark
            </Button>
            <Button
              variant={theme === 'system' ? 'default' : 'outline'}
              onClick={() => setTheme('system')}
            >
              System
            </Button>
          </div>
          <Separator className="my-6" />
          <div className="text-sm text-muted-foreground">
            Current mode:{' '}
            <span className="font-medium text-foreground">{theme}</span>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Future preferences</CardTitle>
          <CardDescription>
            Reserved for notifications, table density, language, and other
            preferences later.
          </CardDescription>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground">
          This section is intentionally lightweight for the first release.
        </CardContent>
      </Card>
    </div>
  )
}
