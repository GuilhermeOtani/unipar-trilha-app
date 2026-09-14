# Unipar Trilha App

Frontend Flutter do **Trail Code**, organizado pelo mesmo padrão modular do GulaPay e adaptado ao domínio, ao design system e aos contratos reais deste projeto.

Esta entrega reúne a fundação técnica, a jornada visual de login, o design system (FE-002) e as telas do aluno dos wireframes (home, catálogo, caminho, prática e perfil). Catálogo e prática já consomem os contratos do backend por services. O cadastro, a home do professor, a autoria e o acompanhamento permanecem fora do escopo.

## Estado da implementação

| Item | Entrega | Estado |
|---|---|---|
| 1.1 | Projeto Android/Web, estrutura modular e configuração | concluído |
| 1.2 | Cliente HTTP, health, DTO, service e tela de login | concluído em código |
| 1.3 | Persistência, `AuthGate`, restauração, invalidação e logout | concluído com página temporária |
| FE-002 | Design system: tokens, tema, ativos e widgets compartilhados | concluído |
| Telas do aluno | Home, catálogo, caminho, prática e perfil (wireframes 1–7) | layout pronto, visível em `main_preview.dart` |
| 3.2 / 4.1–4.3 técnico | DTOs e services de catálogo e aprendizagem, estados de carregamento/erro | concluído sem aceite integrado |
| Cadastro | Não faz parte desta entrega | fora do escopo |
| Módulos restantes | Autoria, distribuição, painel e home do professor | não iniciado |

A tela utiliza a API real em produção. A validação automatizada usa serviços simulados somente em `test/`; a execução opcional contra o backend real permanece pendente quando a API local não estiver ligada.

## Tecnologias

- Flutter 3.41.2 utilizado na criação.
- Dart compatível com `^3.9.2`.
- `dio` para HTTP.
- `shared_preferences` para dados locais da sessão.
- `font_awesome_flutter` e `cupertino_icons` disponíveis para os próximos módulos; o login usa Material Icons para renderização consistente em Web e Android.
- `flutter_test` e `flutter_lints` para qualidade.

## Estrutura

```text
lib/
├── main.dart
├── core/
│   ├── api_client.dart
│   ├── api_error.dart
│   ├── auth_session.dart
│   ├── constants_api.dart
│   ├── health_service.dart
│   ├── theme/          # tokens e ThemeData (FE-002)
│   └── widgets/        # componentes visuais compartilhados
├── modules/
│   ├── login/
│   │   ├── dto/
│   │   ├── page/
│   │   └── service/
│   ├── home/page/session_placeholder_page.dart
│   ├── trilha/
│   ├── distribuicao/
│   ├── catalogo_aluno/
│   ├── aprendizagem/
│   ├── acompanhamento/
│   └── perfil/                  # tela 7 (FE-002)
├── shared/
│   ├── models/ e widgets/       # cabeçalho do aluno usado por várias telas
│   └── preview/                 # conteúdo de exemplo das telas
└── main_preview.dart            # pré-visualização das telas 1–7

assets/images/                   # ícones, ilustrações e mascote do kit
assets/fonts/                    # fontes OFL usadas pelo design system
```

Pastas vazias possuem `.gitkeep`. Os módulos de negócio foram apenas reservados; nenhum contrato foi antecipado neles.

## Tela de login

O `MaterialApp` inicia em um `AuthGate`, que decide entre carregamento, login e sessão autenticada. A tela de login possui:

- campos obrigatórios de login e senha, sem credenciais fixas;
- envio pelo botão ou pela tecla Enter;
- controle para mostrar e ocultar a senha;
- bloqueio de múltiplos envios e indicador de carregamento;
- mensagens para credenciais inválidas, timeout, indisponibilidade e falha de restauração;
- preservação dos campos após erro;
- layout empilhado em celular e lado a lado em desktop;
- suporte aos perfis `ADMINISTRADOR`, `PROFESSOR` e `ALUNO`.

Após autenticar, uma página propositalmente temporária apresenta nome, perfil e o botão **Sair**. Ela será substituída pelas homes específicas sem alterar o contrato de autenticação.

Os componentes `AppTextField`, `AppPrimaryButton`, `AppMessageBanner` e `AuthShell` ficam em `core/widgets` para reutilização e usam os tokens do design system. O mascote do login é `assets/images/mascot/iguana-phone.png`; “Trail Code” é texto, não uma logo inventada. O mapa completo de tokens, ativos e componentes está em [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md).

## Comunicação com a API

A URL é definida em compilação:

```dart
const String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

Não acrescentar `/api`. O cliente possui timeout de 15 segundos, envia e recebe JSON, injeta `Authorization: Bearer <token>` somente em rotas protegidas e nunca repete POST automaticamente.

`ApiError` interpreta o Problem Details RFC 7807 do backend, incluindo `detail` e `errors`. Também diferencia timeout e falha de conexão.

Rotas implementadas na fundação:

| Método | Rota | Responsabilidade |
|---|---|---|
| `GET` | `/actuator/health` | confirma `status=UP` |
| `POST` | `/auth/login` | autentica e persiste a sessão |
| `GET` | `/usuarios/me` | valida uma sessão restaurada |
| `GET` | `/aluno/distribuicoes` | catálogo do aluno (`CatalogoAlunoService`) |
| `POST` | `/aluno/distribuicoes/{id}/sessoes` | inicia ou retoma a prática (`AprendizagemService`) |
| `GET` | `/aluno/sessoes/{id}` | consulta a sessão (`AprendizagemService`) |
| `POST` | `/aluno/sessoes/{id}/respostas` | envia a resposta (`AprendizagemService`) |

O token não é enviado no health ou no login. A senha é enviada apenas ao endpoint de login e nunca é persistida.

## Sessão

`AuthSession` é a fonte única do estado de autenticação:

- armazena token, ID, login, nome, perfil e situação ativa;
- reconhece `ADMINISTRADOR`, `PROFESSOR` e `ALUNO`;
- valida dados salvos consultando `/usuarios/me`;
- limpa a sessão em `401` de rota protegida;
- mantém os dados salvos, mas não libera estado autenticado, quando a validação falha por rede;
- impede resposta atrasada de restaurar dados depois do logout;
- notifica futuros consumidores por `ChangeNotifier`.

O frontend não decodifica o JWT para decidir se uma sessão é válida.

## Como executar

Na raiz deste projeto:

```powershell
flutter pub get
flutter analyze
flutter test
```

Web com backend na mesma máquina:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Emulador Android padrão:

```powershell
flutter run -d <ID_DO_EMULADOR> --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Aparelho físico: use o IPv4 da máquina na mesma rede, por exemplo `http://192.168.0.10:8080`, e permita a porta no firewall. `localhost` no aparelho aponta para o próprio celular.

O Android possui permissão de internet em todos os builds. Tráfego HTTP sem TLS é permitido somente no manifesto `debug`; a configuração de produção deverá utilizar HTTPS. No Web, o backend precisa permitir a origem usada pelo navegador via CORS.

## Teste opcional com backend real

Com a API em execução, informe credenciais somente no comando:

```powershell
flutter test test/integration/backend_integration_test.dart `
  --dart-define=RUN_BACKEND_INTEGRATION=true `
  --dart-define=API_BASE_URL=http://localhost:8080 `
  --dart-define=BACKEND_TEST_LOGIN=<LOGIN> `
  --dart-define=BACKEND_TEST_PASSWORD=<SENHA>
```

O teste executa health → login → `/usuarios/me` → logout. Sem essas opções ele fica ignorado, portanto a suíte comum não depende de PostgreSQL nem de uma API ligada.

## Decisões e próximos passos

- **FE-001:** adaptado conforme solicitado; o aplicativo inicia na jornada de autenticação, sem página técnica nem cadastro.
- **FE-002:** concluído com tokens, tema, ativos e componentes compartilhados; o login foi integrado a esse design system.
- **FE-003:** login, estados de erro e integração de produção estão implementados. A execução contra a API real segue pendente nesta validação porque o backend local estava desligado.
- **FE-004:** parcialmente realizado pelo `AuthGate`, restauração, logout e página provisória. As telas do aluno existem em pré-visualização, mas a navegação autenticada por perfil ainda será ligada em incremento posterior.
- A única simulação em `lib/` é `shared/preview/aluno_preview_api.dart`, usada apenas por `main_preview.dart` e testes. Não foram adicionadas dependências extras nem regras comerciais do GulaPay.
- O plano original está em `PLANO_IMPLEMENTACAO_FRONTEND.md` neste repositório.
- O próximo incremento deve substituir a página provisória pelas homes por perfil, preservando o `AuthGate`.
- Para reencontrar rascunhos e versões em qualquer dispositivo, a decisão FE-005 adotada exige endpoints autenticados adicionais no backend. Essa alteração permanece separada desta fundação.
- Não houve alteração no backend, commit ou push durante esta entrega.

## Validação realizada em 14/09/2026

```text
flutter analyze: No issues found
flutter test: 39 testes passaram e 1 integração opcional foi ignorada
flutter build web --debug: concluído
flutter build apk --debug: concluído
```

A inspeção visual foi feita em desktop e em viewport de 360 × 800 px, sem overflow. O teste opcional com a API real não foi executado porque `localhost:8080` não estava disponível.

Artefatos locais gerados para conferência:

- `build/web/`;
- `build/app/outputs/flutter-apk/app-debug.apk`.

As pastas de build são temporárias e já estão ignoradas pelo Git. Não havia emulador ou aparelho Android conectado, portanto o APK foi compilado, mas não executado em dispositivo nesta validação.
