import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';

import 'fakes.dart';

/// A flat sale at the start of the pipeline, its checklist, and the one
/// document uploaded to it — shared by the checklist tests.

const checklistAgent = AuthResponse(
    userId: 5, fullName: 'Aigul Bekova', role: Role.AGENT, teamId: 1);
const checklistColleague = AuthResponse(
    userId: 9, fullName: 'Timur Aliev', role: Role.AGENT, teamId: 1);

const checklistDeal = DealResponse(
  id: 1,
  title: 'Dostyk 5, flat 12',
  status: DealStatus.LEAD,
  clientId: 1,
  clientName: 'Irina Sokolova',
  agentId: 5,
  agentName: 'Aigul Bekova',
  dealPrice: 42000000,
  checklistDone: 1,
  checklistTotal: 3,
  openRequiredByStage: {'LEAD': 1, 'NEGOTIATION': 1, 'CLOSED_WON': 1},
);

List<ChecklistItem> checklistItems() => [
      const ChecklistItem(
          id: 1,
          stage: ChecklistStage.LEAD,
          title: "Copy of the buyer's ID",
          required: true),
      ChecklistItem(
          id: 2,
          stage: ChecklistStage.LEAD,
          title:
              'Bank pre-approval from Halyk Bank for the full mortgage amount',
          position: 1,
          done: true,
          doneAt: DateTime(2026, 9, 12, 10),
          doneById: 9,
          doneByName: 'Timur Aliev',
          documentId: 70,
          documentName: 'halyk-preapproval.pdf'),
      const ChecklistItem(
          id: 5,
          stage: ChecklistStage.LEAD,
          title: 'Parking permit',
          position: 2,
          custom: true),
      const ChecklistItem(
          id: 3,
          stage: ChecklistStage.NEGOTIATION,
          title: 'Signed deposit agreement',
          required: true),
      const ChecklistItem(
          id: 4,
          stage: ChecklistStage.CLOSED_WON,
          title: 'Signed sale contract',
          required: true),
    ];

const checklistDocuments = [
  DocumentResponse(
      id: 70,
      fileName: 'halyk-preapproval.pdf',
      fileType: 'pdf',
      fileSize: 1200,
      dealId: 1),
  DocumentResponse(
      id: 71,
      fileName: 'passport.pdf',
      fileType: 'pdf',
      fileSize: 900,
      dealId: 1),
];

class RecordingChecklistDeals extends FakeDealsRepository {
  final moves = <(int, DealStatus)>[];
  final updates = <Map<String, dynamic>>[];

  RecordingChecklistDeals([List<DealResponse>? deals])
      : super(deals ?? [checklistDeal]);

  @override
  Future<DealResponse> updateDealStatus(int id, DealStatus status,
      {DealLostReason? lostReason, String? lostNote}) async {
    moves.add((id, status));
    final i = deals.indexWhere((d) => d.id == id);
    return deals[i] = deals[i].copyWith(status: status);
  }

  @override
  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) async {
    updates.add(data);
    return deals.firstWhere((d) => d.id == id);
  }
}

Widget withChecklistBlocs(Widget child, RecordingChecklistDeals deals,
        {AuthResponse user = checklistAgent}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => AuthBloc(FakeAuthRepository(user: user))
              ..add(AuthCheckEvent())),
        BlocProvider(create: (_) => DealsBloc(deals)),
      ],
      child: child,
    );
