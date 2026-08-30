// Constrains site content to readable widths while retaining mobile padding.
import 'package:abdelrhman_protfolio/core/responsive/app_breakpoints.dart';
import 'package:flutter/widgets.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppBreakpoints.contentWidth),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width >= 700 ? 40 : 24,
        ),
        child: child,
      ),
    ),
  );
}
