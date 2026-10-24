import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_sync.dart';
import 'features/add_subscription/service_picker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServicePickerScreen.preload();
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // App khulte hi: purani billing dates aage barhao aur reminders dobara schedule karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reminderSyncProvider).syncAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightTheme = ThemeData(
          colorScheme: lightDynamic != null
              ? lightDynamic
              : ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        );
        final darkTheme = ThemeData(
          colorScheme: darkDynamic != null
              ? darkDynamic
              : ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        );

        return MaterialApp.router(
          title: 'Subscription Manager',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode
              .system, // Later we will read this from SharedPreferences
          routerConfig: router,
        );
      },
    );
  }
}