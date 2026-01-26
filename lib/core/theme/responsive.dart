import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities
///
/// Provides a unified way to handle responsiveness across the app
/// without unnecessary rebuilds
class Responsive {
  Responsive._();

  // ══════════════════════════════════════════════════════════════════════════
  // BREAKPOINTS
  // ══════════════════════════════════════════════════════════════════════════

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ══════════════════════════════════════════════════════════════════════════
  // DEVICE TYPE CHECKS
  // ══════════════════════════════════════════════════════════════════════════

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  // ══════════════════════════════════════════════════════════════════════════
  // RESPONSIVE VALUES
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns a value based on the current screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Returns padding based on screen size
  static EdgeInsets padding(BuildContext context) {
    return value(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Returns horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    return value(context, mobile: 16.0, tablet: 24.0, desktop: 32.0);
  }

  /// Returns vertical padding based on screen size
  static double verticalPadding(BuildContext context) {
    return value(context, mobile: 16.0, tablet: 20.0, desktop: 24.0);
  }

  /// Returns gap between items based on screen size
  static double gap(BuildContext context) {
    return value(context, mobile: 12.0, tablet: 16.0, desktop: 20.0);
  }

  /// Returns the maximum content width
  static double maxContentWidth(BuildContext context) {
    return value(
      context,
      mobile: double.infinity,
      tablet: 600.0,
      desktop: 800.0,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// RESPONSIVE BUILDER WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// A widget that builds different layouts based on screen size
/// Uses LayoutBuilder for efficiency - only rebuilds when constraints change
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.tabletBreakpoint &&
            desktop != null) {
          return desktop!(context, constraints);
        }
        if (constraints.maxWidth >= Responsive.mobileBreakpoint &&
            tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SPACING CONSTANTS
// ══════════════════════════════════════════════════════════════════════════

/// Standardized spacing values for consistent layout
class AppSpacing {
  AppSpacing._();

  // Base unit: 4px
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double massive = 64;

  // Vertical spacers (const for performance)
  static const SizedBox vXxs = SizedBox(height: xxs);
  static const SizedBox vXs = SizedBox(height: xs);
  static const SizedBox vSm = SizedBox(height: sm);
  static const SizedBox vMd = SizedBox(height: md);
  static const SizedBox vLg = SizedBox(height: lg);
  static const SizedBox vXl = SizedBox(height: xl);
  static const SizedBox vXxl = SizedBox(height: xxl);
  static const SizedBox vXxxl = SizedBox(height: xxxl);

  // Horizontal spacers (const for performance)
  static const SizedBox hXxs = SizedBox(width: xxs);
  static const SizedBox hXs = SizedBox(width: xs);
  static const SizedBox hSm = SizedBox(width: sm);
  static const SizedBox hMd = SizedBox(width: md);
  static const SizedBox hLg = SizedBox(width: lg);
  static const SizedBox hXl = SizedBox(width: xl);
  static const SizedBox hXxl = SizedBox(width: xxl);
  static const SizedBox hXxxl = SizedBox(width: xxxl);
}

// ══════════════════════════════════════════════════════════════════════════
// BORDER RADIUS CONSTANTS
// ══════════════════════════════════════════════════════════════════════════

/// Standardized border radius values
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double round = 100;

  // Pre-built BorderRadius for common use cases
  static const BorderRadius borderRadiusXs = BorderRadius.all(
    Radius.circular(xs),
  );
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(lg),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius borderRadiusXxl = BorderRadius.all(
    Radius.circular(xxl),
  );
  static const BorderRadius borderRadiusRound = BorderRadius.all(
    Radius.circular(round),
  );
}

// ══════════════════════════════════════════════════════════════════════════
// DURATION CONSTANTS
// ══════════════════════════════════════════════════════════════════════════

/// Standardized animation durations
class AppDurations {
  AppDurations._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 700);
}

// ══════════════════════════════════════════════════════════════════════════
// CURVES
// ══════════════════════════════════════════════════════════════════════════

/// Standardized animation curves
class AppCurves {
  AppCurves._();

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve emphasis = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;
}
