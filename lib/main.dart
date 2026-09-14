import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthSession.instance;
  runApp(const UniparTrilhaApp());
}

class UniparTrilhaApp extends StatelessWidget {
  const UniparTrilhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unipar Trilha',
      theme: AppTheme.dark,
      home: const SizedBox.shrink(),
    );
  }
}
