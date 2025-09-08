import 'package:flutter/material.dart';

/// A widget to show when there's no content to display
class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Widget? illustration;
  final VoidCallback? onAction;
  final String? actionText;
  final bool showAction;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.illustration,
    this.onAction,
    this.actionText,
    this.showAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration or icon
            if (illustration != null)
              illustration!
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.inbox_outlined,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Description
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Action button
            if (showAction && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText ?? 'Get Started'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specific empty states for different sections
class NoAssessmentsEmpty extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const NoAssessmentsEmpty({
    super.key,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.psychology_outlined,
      title: 'No Assessments Yet',
      description: 'Complete personality assessments to get insights about your relationships and communication style.',
      actionText: 'Explore Assessments',
      onAction: onGetStarted,
    );
  }
}

class NoProfilesEmpty extends StatelessWidget {
  final VoidCallback? onAddProfile;

  const NoProfilesEmpty({
    super.key,
    this.onAddProfile,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.person_add_outlined,
      title: 'No Profiles Added',
      description: 'Add profiles of people in your life to track relationships and get personalized advice.',
      actionText: 'Add First Profile',
      onAction: onAddProfile,
    );
  }
}

class NoInteractionsEmpty extends StatelessWidget {
  final VoidCallback? onAddInteraction;

  const NoInteractionsEmpty({
    super.key,
    this.onAddInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'No Interactions Logged',
      description: 'Start logging your interactions to get insights about relationship patterns and receive advice.',
      actionText: 'Log First Interaction',
      onAction: onAddInteraction,
    );
  }
}

class NoInsightsEmpty extends StatelessWidget {
  final VoidCallback? onGenerateInsights;

  const NoInsightsEmpty({
    super.key,
    this.onGenerateInsights,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.lightbulb_outline,
      title: 'No Insights Available',
      description: 'Complete assessments and log interactions to generate personalized relationship insights.',
      actionText: 'Generate Insights',
      onAction: onGenerateInsights,
    );
  }
}

class NoTasksEmpty extends StatelessWidget {
  final VoidCallback? onCreateTask;

  const NoTasksEmpty({
    super.key,
    this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.task_outlined,
      title: 'No Tasks to Complete',
      description: 'Tasks will appear here when you receive advice that includes actionable steps.',
      showAction: false,
    );
  }
}

/// Error states
class ErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;

  const ErrorState({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
    this.retryText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Description
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error state
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      description: 'Check your connection and try again.',
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }
}

/// Server error state
class ServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.cloud_off,
      title: 'Something Went Wrong',
      description: 'We\'re having trouble loading your data. Please try again.',
      onRetry: onRetry,
    );
  }
}
