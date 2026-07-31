import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';

extension RoleContext on BuildContext {
  Role? get currentRole => read<AuthBloc>().currentUser?.role;
  bool get isAdmin => currentRole == Role.ADMIN;
  bool get isManager => currentRole == Role.MANAGER;
  bool get isAdminOrManager => isAdmin || isManager;
}
