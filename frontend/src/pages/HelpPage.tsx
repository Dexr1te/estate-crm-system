import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Badge } from '@/components/ui/badge'

const sections = [
  {
    title: 'Dashboard',
    description:
      'Start here for a quick snapshot of deals, clients, and upcoming meetings.',
    items: ['Total deals', 'Active vs closed deals', 'Upcoming meetings']
  },
  {
    title: 'Clients',
    description:
      'Track people you are working with and keep contact details up to date.',
    items: [
      'Buyer / seller records',
      'Notes and contact history',
      'Linked deal and property context'
    ]
  },
  {
    title: 'Properties',
    description:
      'Manage the catalog and track which objects are available, reserved, or sold.',
    items: [
      'Status badges',
      'Filters by type and city',
      'Price and agent ownership'
    ]
  },
  {
    title: 'Deals',
    description:
      'Move opportunities through the sales pipeline and close them when ready.',
    items: [
      'LEAD → NEGOTIATION → CLOSED',
      'Close won / lost actions',
      'Property status sync'
    ]
  },
  {
    title: 'Meetings',
    description:
      'Schedule conversations and mark them complete after they happen.',
    items: ['All meetings', 'Upcoming list', 'Complete action']
  }
]

const steps = [
  'Create or open a client record.',
  'Attach a property and create a deal.',
  'Move the deal through negotiation to closed won or closed lost.',
  'Use meetings to track calls, viewings, and follow-ups.',
  'Check the dashboard for totals and next actions.'
]

export function HelpPage() {
  return (
    <div className="p-6 space-y-8">
      <div className="space-y-3 max-w-3xl">
        <div className="flex items-center gap-2">
          <Badge variant="secondary">Help</Badge>
          <span className="text-sm text-muted-foreground">
            Quick walkthrough
          </span>
        </div>
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">
            How Estate CRM works
          </h1>
          <p className="mt-2 text-sm text-muted-foreground">
            This short guide explains the normal workflow inside the app and
            where to do the main agent actions.
          </p>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Workflow overview</CardTitle>
          <CardDescription>
            Estate CRM is organized around the client → property → deal →
            meeting loop.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4 text-sm text-muted-foreground">
          <p>
            Use the sidebar to move between the core CRM pages. The dashboard
            gives the high-level numbers, clients store the relationship data,
            properties track the real estate inventory, and deals connect
            everything into a pipeline.
          </p>
          <Separator />
          <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
            {steps.map((step, index) => (
              <div
                key={step}
                className="rounded-xl border bg-muted/30 p-4 text-foreground"
              >
                <div className="text-xs uppercase tracking-wide text-muted-foreground">
                  Step {index + 1}
                </div>
                <div className="mt-2 text-sm leading-6">{step}</div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-6 xl:grid-cols-2">
        {sections.map((section) => (
          <Card key={section.title}>
            <CardHeader>
              <CardTitle>{section.title}</CardTitle>
              <CardDescription>{section.description}</CardDescription>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm text-muted-foreground">
                {section.items.map((item) => (
                  <li key={item} className="flex items-start gap-2">
                    <span className="mt-1 size-2 rounded-full bg-primary" />
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}
