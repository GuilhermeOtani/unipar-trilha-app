import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/auth_gate.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/modules/login/service/login_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthSession.instance;
  runApp(const UniparTrilhaApp());
}

class UniparTrilhaApp extends StatelessWidget {
  const UniparTrilhaApp({super.key, this.authSession, this.loginService});

  final AuthSession? authSession;
  final LoginServiceContract? loginService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trail Code',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AuthGate(authSession: authSession, loginService: loginService),
    );
  }
}
