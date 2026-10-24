import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import 'main_shell.dart';
import '../../features/add_subscription/service_picker_screen.dart';
import '../../features/add_subscription/add_subscription_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/deleted_subscriptions_screen.dart';
import '../../features/details/details_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Codec required by go_router 18+ to serialise custom [extra] objects.
class _AppExtraCodec extends Codec<Object?, Object?> {
  const _AppExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();
}

class _AppExtraEncoder extends Converter<Object?, Object?> {
  const _AppExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is PredefinedService) {
      return {'__type': 'PredefinedService', 'data': input.toJson()};
    }
    throw UnsupportedError('Cannot encode type: ${input.runtimeType}');
  }
}

class _AppExtraDecoder extends Converter<Object?, Object?> {
  const _AppExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is Map<String, dynamic>) {
      final type = input['__type'] as String?;
      if (type == 'PredefinedService') {
        return PredefinedService.fromJson(
          input['data'] as Map<String, dynamic>,
        );
      }
    }
    return input;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    extraCodec: const _AppExtraCodec(),
    routes: [
      // Bottom tab bar wale 4 main screens
      // (order tab bar jaisa: Home, Analytics, Recently deleted, Settings)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/deleted',
                builder: (context, state) => const DeletedSubscriptionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Ye screens tab bar ke upar full screen khulti hain
      GoRoute(
        path: '/add',
        builder: (context, state) => const ServicePickerScreen(),
      ),
      GoRoute(
        path: '/add/custom',
        builder: (context, state) {
          final service = state.extra as PredefinedService?;
          return AddSubscriptionScreen(initialService: service);
        },
      ),
      GoRoute(
        path: '/details/:id',
        builder: (context, state) =>
            DetailsScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});