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
    <div className="w-full space-y-6 px-4 py-6 text-left sm:px-6 md:px-8 lg:px-10 lg:py-8">
      <div className="flex flex-col gap-4 text-left lg:flex-row lg:items-end lg:justify-between">
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <Badge variant="secondary">Settings</Badge>
            <span className="text-sm text-muted-foreground">
              Appearance and preferences
            </span>
          </div>
          <div>
            <h1 className="text-3xl font-semibold tracking-tight">Settings</h1>
            <p className="mt-2 max-w-2xl text-sm text-muted-foreground">
              Manage the visual mode and the small workspace preferences that
              should feel deliberate on desktop, not squeezed into a
              mobile-style stack.
            </p>
          </div>
        </div>

        <div className="w-full rounded-2xl border bg-card px-4 py-3 shadow-sm lg:w-auto">
          <div className="text-xs uppercase tracking-wide text-muted-foreground">
            Current mode
          </div>
          <div className="mt-1 text-lg font-semibold capitalize">{theme}</div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1.4fr)_minmax(320px,0.7fr)]">
        <Card className="shadow-sm">
          <CardHeader className="space-y-2">
            <CardTitle>Theme</CardTitle>
            <CardDescription>
              Choose how the interface should look. The selection is saved
              locally in the browser.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-3 sm:grid-cols-3">
              <Button
                variant={theme === 'light' ? 'default' : 'outline'}
                onClick={() => setTheme('light')}
                className="justify-start"
              >
                Light
              </Button>
              <Button
                variant={theme === 'dark' ? 'default' : 'outline'}
                onClick={() => setTheme('dark')}
                className="justify-start"
              >
                Dark
              </Button>
              <Button
                variant={theme === 'system' ? 'default' : 'outline'}
                onClick={() => setTheme('system')}
                className="justify-start"
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

        <div className="space-y-6">
          <Card className="shadow-sm">
            <CardHeader>
              <CardTitle>Workspace preferences</CardTitle>
              <CardDescription>
                Reserved for future density, language, and notification options.
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3 text-sm">
              <div className="rounded-xl border bg-muted/30 p-4">
                <div className="font-medium text-foreground">Table density</div>
                <div className="mt-1 text-muted-foreground">
                  Keep default spacing for now. Later this can switch between
                  compact and comfortable.
                </div>
              </div>
              <div className="rounded-xl border bg-muted/30 p-4">
                <div className="font-medium text-foreground">Language</div>
                <div className="mt-1 text-muted-foreground">
                  The UI currently uses English labels and backend data.
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="shadow-sm">
            <CardHeader>
              <CardTitle>Future preferences</CardTitle>
              <CardDescription>
                Space reserved for notifications and productivity options.
              </CardDescription>
            </CardHeader>
            <CardContent className="text-sm leading-6 text-muted-foreground">
              This area stays lightweight, but it now reads as a real settings
              sidebar instead of an empty mobile page.
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
