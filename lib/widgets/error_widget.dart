import 'package:flutter/material.dart';
import '../config/theme_extension.dart';
import '../config/constants.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    this.message = AppConstants.defaultErrorMessage,
    this.onRetry,
    this.retryText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: customTheme?.errorColor ?? theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: customTheme?.secondaryTextColor,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: AppConstants.networkErrorMessage,
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData? icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.onAction,
    this.actionText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox,
              size: 64,
              color: customTheme?.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: customTheme?.secondaryTextColor,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText ?? 'Action'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const PermissionErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: AppConstants.permissionErrorMessage,
      onRetry: onRetry,
      icon: Icons.no_accounts,
    );
  }
}

class LocationErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const LocationErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: AppConstants.locationErrorMessage,
      onRetry: onRetry,
      icon: Icons.location_off,
    );
  }
}
