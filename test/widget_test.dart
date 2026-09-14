import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/main.dart';
import 'package:unipar_trilha_app/modules/login/page/login_page.dart';

import 'support/fake_login_service.dart';
import 'support/memory_auth_storage.dart';

void main() {
  testWidgets('inicializa no login quando não existe sessão', (tester) async {
    final session = AuthSession.forTesting(
      storage: MemoryAuthStorage(),
      dio: Dio(),
    );

    await tester.pumpWidget(
      UniparTrilhaApp(authSession: session, loginService: FakeLoginService()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Trail Code'), findsOneWidget);
  });
}
