import 'package:real_estate_crm/core/models/models.dart';

/// Clients going cold: nobody has spoken to them in `days`, and they are
/// still worth the call. The rule lives on the backend.
abstract class ColdClientsRepository {
  static const defaultDays = 14;
  static const thresholds = [7, 14, 30];

  Future<List<ColdClient>> getColdClients({
    int days = defaultDays,
    int limit = 20,
  });
}
