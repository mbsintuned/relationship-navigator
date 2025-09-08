import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/assessment/screens/assessment_list_screen.dart';
import '../../features/assessment/screens/assessment_detail_screen.dart';
import '../../features/profile/screens/profile_list_screen.dart';
import '../../features/profile/screens/profile_detail_screen.dart';
import '../../features/interaction/screens/interaction_list_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../providers/app_providers.dart';
import 'main_navigation.dart';

// App router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (context, state) {
      return authState.when(
        data: (auth) {
          final isAuthenticated = auth.session != null;
          final isOnAuthPage = state.location.startsWith('/auth') || 
                              state.location == '/onboarding';
          
          if (!isAuthenticated && !isOnAuthPage) {
            return '/auth/login';
          }
          
          if (isAuthenticated && isOnAuthPage) {
            return '/';
          }
          
          return null;
        },
        loading: () => null,
        error: (_, __) => '/auth/login',
      );
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          // Home/Dashboard
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Profiles
          GoRoute(
            path: '/profiles',
            builder: (context, state) => const ProfileListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const ProfileCreateScreen(),
              ),
              GoRoute(
                path: ':profileId',
                builder: (context, state) {
                  final profileId = state.pathParameters['profileId']!;
                  return ProfileDetailScreen(profileId: profileId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final profileId = state.pathParameters['profileId']!;
                      return ProfileEditScreen(profileId: profileId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Assessments
          GoRoute(
            path: '/assessments',
            builder: (context, state) => const AssessmentListScreen(),
            routes: [
              GoRoute(
                path: ':assessmentId',
                builder: (context, state) {
                  final assessmentId = state.pathParameters['assessmentId']!;
                  return AssessmentDetailScreen(assessmentId: assessmentId);
                },
                routes: [
                  GoRoute(
                    path: 'take',
                    builder: (context, state) {
                      final assessmentId = state.pathParameters['assessmentId']!;
                      final personId = state.uri.queryParameters['personId'];
                      return AssessmentTakeScreen(
                        assessmentId: assessmentId,
                        personId: personId,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'results/:resultId',
                    builder: (context, state) {
                      final resultId = state.pathParameters['resultId']!;
                      return AssessmentResultScreen(resultId: resultId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Interactions
          GoRoute(
            path: '/interactions',
            builder: (context, state) => const InteractionListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final personId = state.uri.queryParameters['personId'];
                  return InteractionCreateScreen(personId: personId);
                },
              ),
              GoRoute(
                path: ':interactionId',
                builder: (context, state) {
                  final interactionId = state.pathParameters['interactionId']!;
                  return InteractionDetailScreen(interactionId: interactionId);
                },
              ),
            ],
          ),
          
          // Insights
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          
          // Tasks
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// Placeholder screens - these would be implemented in their respective feature modules
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Text('Dashboard - Coming Soon'),
      ),
    );
  }
}

class ProfileListScreen extends StatelessWidget {
  const ProfileListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profiles')),
      body: const Center(
        child: Text('Profiles - Coming Soon'),
      ),
    );
  }
}

class ProfileCreateScreen extends StatelessWidget {
  const ProfileCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: const Center(
        child: Text('Create Profile - Coming Soon'),
      ),
    );
  }
}

class ProfileDetailScreen extends StatelessWidget {
  final String profileId;
  
  const ProfileDetailScreen({
    super.key,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Details')),
      body: Center(
        child: Text('Profile Details - $profileId'),
      ),
    );
  }
}

class ProfileEditScreen extends StatelessWidget {
  final String profileId;
  
  const ProfileEditScreen({
    super.key,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: Text('Edit Profile - $profileId'),
      ),
    );
  }
}

class AssessmentDetailScreen extends StatelessWidget {
  final String assessmentId;
  
  const AssessmentDetailScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment Details')),
      body: Center(
        child: Text('Assessment Details - $assessmentId'),
      ),
    );
  }
}

class AssessmentTakeScreen extends StatelessWidget {
  final String assessmentId;
  final String? personId;
  
  const AssessmentTakeScreen({
    super.key,
    required this.assessmentId,
    this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Assessment')),
      body: Center(
        child: Text('Take Assessment - $assessmentId${personId != null ? ' for $personId' : ''}'),
      ),
    );
  }
}

class AssessmentResultScreen extends StatelessWidget {
  final String resultId;
  
  const AssessmentResultScreen({
    super.key,
    required this.resultId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment Results')),
      body: Center(
        child: Text('Assessment Results - $resultId'),
      ),
    );
  }
}

class InteractionListScreen extends StatelessWidget {
  const InteractionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactions')),
      body: const Center(
        child: Text('Interactions - Coming Soon'),
      ),
    );
  }
}

class InteractionCreateScreen extends StatelessWidget {
  final String? personId;
  
  const InteractionCreateScreen({
    super.key,
    this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Interaction')),
      body: Center(
        child: Text('Log Interaction${personId != null ? ' with $personId' : ''}'),
      ),
    );
  }
}

class InteractionDetailScreen extends StatelessWidget {
  final String interactionId;
  
  const InteractionDetailScreen({
    super.key,
    required this.interactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interaction Details')),
      body: Center(
        child: Text('Interaction Details - $interactionId'),
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: const Center(
        child: Text('Insights - Coming Soon'),
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const Center(
        child: Text('Tasks - Coming Soon'),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Login Screen - Coming Soon'),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Onboarding Screen - Coming Soon'),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({
    super.key,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
