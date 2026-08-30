// Provides readable breakpoint helpers for responsive portfolio compositions.
import 'package:abdelrhman_protfolio/core/responsive/app_breakpoints.dart';
import 'package:flutter/widgets.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    super.key,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder tablet;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= AppBreakpoints.desktop) {
        return desktop(context);
      }
      if (constraints.maxWidth >= AppBreakpoints.tablet) return tablet(context);
      return mobile(context);
    },
  );
}

extension ResponsiveContext on BuildContext {
  bool get isDesktop => MediaQuery.sizeOf(this).width >= AppBreakpoints.desktop;
}
