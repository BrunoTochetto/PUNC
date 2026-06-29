import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gerenciamento_punc/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('exibe tela de login quando não há sessão', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GerenciamentoPuncApp());
    await tester.pumpAndSettle();

    expect(find.text('Gerenciamento PUNC'), findsWidgets);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
