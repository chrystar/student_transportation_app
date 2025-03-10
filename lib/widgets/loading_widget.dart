import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme_extension.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class LoadingListItem extends StatelessWidget {
  final double height;
  final double width;

  const LoadingListItem({
    super.key,
    this.height = 80,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>();

    return Shimmer.fromColors(
      baseColor: customTheme?.cardBackgroundColor ?? Colors.grey[300]!,
      highlightColor: customTheme?.dividerColor ?? Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => LoadingListItem(
        height: itemHeight,
      ),
    );
  }
}

class LoadingCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const LoadingCard({
    super.key,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>();

    return Shimmer.fromColors(
      baseColor: customTheme?.cardBackgroundColor ?? Colors.grey[300]!,
      highlightColor: customTheme?.dividerColor ?? Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class LoadingGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const LoadingGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 4,
    this.itemHeight = 200,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => LoadingCard(
        height: itemHeight,
      ),
    );
  }
}

class LoadingText extends StatelessWidget {
  final double width;
  final double height;

  const LoadingText({
    super.key,
    this.width = 200,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>();

    return Shimmer.fromColors(
      baseColor: customTheme?.cardBackgroundColor ?? Colors.grey[300]!,
      highlightColor: customTheme?.dividerColor ?? Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
