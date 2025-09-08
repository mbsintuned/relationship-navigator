import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/app_providers.dart';

class RelationshipNavigatorApp extends ConsumerWidget {
  const RelationshipNavigatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'Relationship Navigator',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Router configuration
      routerConfig: router,
      
      // Localization (future implementation)
      // locale: const Locale('en', 'US'),
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
      
      builder: (context, child) {
        // Global error handling wrapper
        return ErrorBoundary(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class ErrorBoundary extends StatelessWidget {
  final Widget child;
  
  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
