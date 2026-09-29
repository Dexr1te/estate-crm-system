import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';

abstract class AppLockRepository {
  Future<AppLockRecord?> read(int userId);

  Future<void> save(int userId, AppLockRecord record);

  Future<void> delete(int userId);

  /// A fresh salt and the PIN's hash under it.
  Future<PinHash> hash(String pin);

  /// Whether [pin] is the one [stored] was made from.
  Future<bool> matches(String pin, PinHash stored);
}
