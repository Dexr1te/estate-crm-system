import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

abstract class ClientDatesState {
  const ClientDatesState();
}

class ClientDatesInitial extends ClientDatesState {
  const ClientDatesInitial();
}

class ClientDatesLoading extends ClientDatesState {
  const ClientDatesLoading();
}

/// Today first, as the server sends them; kinds the app does not know are
/// left out.
class ClientDatesLoaded extends ClientDatesState {
  final List<UpcomingClientDate> dates;
  const ClientDatesLoaded(this.dates);
}

class ClientDatesError extends ClientDatesState {
  final ApiFailure failure;
  const ClientDatesError(this.failure);
}
