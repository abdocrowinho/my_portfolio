// Verifies the public portfolio can render before remote project data resolves.
import 'package:abdelrhman_protfolio/core/di/service_locator.dart';
import 'package:abdelrhman_protfolio/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the portfolio hero', (tester) async {
    configureDependencies();

    await tester.pumpWidget(const PortfolioApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('I build Android products\nthat feel intentional.'),
      findsOneWidget,
    );
  });
}

