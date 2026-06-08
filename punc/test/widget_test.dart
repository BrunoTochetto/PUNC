import 'package:flutter_test/flutter_test.dart';
import 'package:punc/main.dart';

void main() {
  testWidgets('abre fluxo inicial de localizacao', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Confirmar localizacao'), findsOneWidget);
    expect(find.text('Usar esta localizacao'), findsOneWidget);
  });
}
