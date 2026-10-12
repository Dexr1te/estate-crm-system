import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool usesCupertinoPages(TargetPlatform platform) =>
    platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

Page<void> platformPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final key = state.pageKey;
  final name = state.name ?? state.path;
  final arguments = <String, String>{
    ...state.pathParameters,
    ...state.uri.queryParameters,
  };
  if (usesCupertinoPages(Theme.of(context).platform)) {
    return CupertinoPage<void>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: key.value,
      child: child,
    );
  }
  return MaterialPage<void>(
    key: key,
    name: name,
    arguments: arguments,
    restorationId: key.value,
    child: child,
  );
}
