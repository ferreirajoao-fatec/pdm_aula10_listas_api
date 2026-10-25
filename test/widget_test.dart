import 'package:flutter_test/flutter_test.dart';

import 'package:pdm_aula10_listas_api/main.dart';

void main() {
  testWidgets('Exibe a tela de Feed de Notícias', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());
    expect(find.text('Feed de Notícias'), findsOneWidget);
  });
}
