import 'package:flutter/material.dart';

/// A customizable card widget with consistent styling across the app
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// A card with a loading state
class LoadingCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;

  const LoadingCard({
    super.key,
    this.height = 120,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: margin,
      child: Container(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card that shows error state
class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final EdgeInsets? margin;

  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: margin,
      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.1),
      border: Border.all(
        color: theme.colorScheme.error.withOpacity(0.3),
        width: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
