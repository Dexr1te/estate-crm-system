import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/dashboard_hero.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/meeting_row.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/pipeline_card.dart';

import 'responsive_harness.dart';

final _meeting = MeetingResponse(
  id: 1,
  title: 'Viewing · Severny Residence, apartment 84 with a very long title',
  scheduledAt: DateTime.now().add(const Duration(minutes: 40)),
  agentId: 5,
  agentName: 'Maria Kim-Doroshenko',
  clientId: 9,
  clientName: 'Irina Alexandrovna Sokolova',
  dealId: 3,
);

Widget _page(Widget child) => Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
            child: child,
          ),
        ),
      ),
    );

void main() {
  forEachAcceptanceCase('next-meeting hero',
      (t, size, brightness, scale) async {
    await expectNoOverflow(
      t,
      _page(NextMeetingHero(
        meeting: _meeting,
        eyebrow: 'Next meeting',
        primaryLabel: 'Open',
        onPrimary: () {},
        secondaryLabel: 'Call',
        onSecondary: () {},
      )),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  forEachAcceptanceCase('metrics card', (t, size, brightness, scale) async {
    await expectNoOverflow(
      t,
      _page(const MetricsCard(metrics: [
        Metric(value: '248', caption: 'Active deals'),
        Metric(value: '1 384', caption: 'Clients'),
        Metric(value: '92', caption: 'Closed won'),
        Metric(value: '15', caption: 'Meetings', delta: '2 today'),
      ])),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  forEachAcceptanceCase('pipeline card', (t, size, brightness, scale) async {
    await expectNoOverflow(
      t,
      _page(PipelineCard(
        pipeline: const PipelineBreakdown(
            leads: 11, negotiation: 8, won: 9, lost: 2, totalValue: 412000000),
        onStageTap: (_) {},
      )),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  forEachAcceptanceCase('meeting row', (t, size, brightness, scale) async {
    await expectNoOverflow(
      t,
      _page(const MeetingRow(
        time: '21:00',
        dayOrType: 'tomorrow',
        title: 'Price alignment · Romashkovo house',
        meta: 'A. Petrov · negotiation',
      )),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  forEachAcceptanceCase('bottom nav (6 items)',
      (t, size, brightness, scale) async {
    await expectNoOverflow(
      t,
      Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: const [
            AppNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard'),
            AppNavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Clients'),
            AppNavItem(
                icon: Icons.home_work_outlined,
                activeIcon: Icons.home_work,
                label: 'Properties'),
            AppNavItem(
                icon: Icons.handshake_outlined,
                activeIcon: Icons.handshake,
                label: 'Deals'),
            AppNavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Meetings'),
            AppNavItem(
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield,
                label: 'Admin'),
          ],
        ),
      ),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  forEachAcceptanceCase('empty state', (t, size, brightness, scale) async {
    await expectNoOverflow(
      t,
      const Scaffold(
        body: EmptyState(
          icon: Icons.description_outlined,
          title: 'Nothing here yet',
          subtitle:
              'Team activity will show up here: deals created, status changes, invitations.',
        ),
      ),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });
}
