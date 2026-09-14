import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/widgets/app_message_banner.dart';
import 'package:unipar_trilha_app/core/widgets/app_primary_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_text_field.dart';
import 'package:unipar_trilha_app/core/widgets/auth_shell.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_request.dart';
import 'package:unipar_trilha_app/modules/login/service/login_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.service,
    this.sessionMessage,
    this.onRetrySession,
  });

  final LoginServiceContract? service;
  final String? sessionMessage;
  final Future<void> Function()? onRetrySession;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginServiceContract _service;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? LoginService();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _service.efetuarLogin(
        LoginRequest(
          login: _loginController.text.trim(),
          senha: _passwordController.text,
        ),
      );
      TextInput.finishAutofillContext();
    } on ApiError catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Não foi possível entrar. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      content: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Boas-vindas!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Entre com os dados fornecidos pela sua instituição.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (widget.sessionMessage != null) ...[
                const SizedBox(height: 20),
                AppMessageBanner(
                  key: const Key('session-message'),
                  message: widget.sessionMessage!,
                  kind: AppMessageKind.info,
                  actionLabel: widget.onRetrySession == null
                      ? null
                      : 'Tentar novamente',
                  onAction: widget.onRetrySession == null
                      ? null
                      : () => widget.onRetrySession!(),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                AppMessageBanner(
                  key: const Key('login-error'),
                  message: _errorMessage!,
                ),
              ],
              const SizedBox(height: 26),
              AppTextField(
                key: const Key('login-field'),
                controller: _loginController,
                label: 'Login',
                hint: 'Digite seu login',
                prefixIcon: const Icon(Icons.person_outline, size: 21),
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autofillHints: const [AutofillHints.username],
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe seu login.'
                    : null,
              ),
              const SizedBox(height: 18),
              AppTextField(
                key: const Key('password-field'),
                controller: _passwordController,
                label: 'Senha',
                hint: 'Digite sua senha',
                prefixIcon: const Icon(Icons.lock_outline, size: 21),
                obscureText: true,
                enabled: !_loading,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe sua senha.'
                    : null,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 26),
              AppPrimaryButton(
                key: const Key('login-submit'),
                label: 'Entrar',
                icon: const Icon(Icons.login_rounded),
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
