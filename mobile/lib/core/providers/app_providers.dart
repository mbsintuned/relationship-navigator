import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core app providers

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    state = ThemeMode.values[themeModeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeMode.index);
  }
}

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// Authentication state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => null,
  );
});

// App initialization provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Initialize any required services, load user preferences, etc.
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate initialization
});

// Connectivity provider
final connectivityProvider = StreamProvider<bool>((ref) {
  // In a real app, this would use connectivity_plus package
  return Stream.periodic(const Duration(seconds: 5), (_) => true);
});

// App state provider for global app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class AppState {
  final bool isLoading;
  final String? error;

  const AppState({
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
