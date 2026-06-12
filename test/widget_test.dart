import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dia_organizado/main.dart';
import 'package:dia_organizado/services/data_service.dart';
import 'package:dia_organizado/services/local_data_service.dart';

void main() {
  testWidgets('App abre no splash em modo local', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('pt_BR', null);
    final local = LocalDataService();
    await local.init();
    DataService.instance = local;

    await tester.pumpWidget(const DiaOrganizadoApp(localMode: true));
    await tester.pump();

    expect(find.text('Dia Organizado'), findsOneWidget);

    // Avança o timer do splash (2s) e deixa a navegação acontecer
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
