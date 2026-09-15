# Unipar Trilha App

Frontend Flutter do **Trail Code**, organizado por módulos e integrado à API Spring Boot do projeto.

O aplicativo entrega o ciclo principal:

```text
Administrador gerencia usuários
→ professor cria, edita, publica e distribui uma trilha
→ aluno encontra, pratica, retoma e conclui
→ professor acompanha os indicadores da turma
```

## Estado da implementação

| Área | Entrega | Estado |
|---|---|---|
| Autenticação | login, sessão persistida, restauração, Bearer, `401` global e logout | concluído |
| Roteamento por perfil | áreas de `ALUNO`, `PROFESSOR` e `ADMINISTRADOR` | concluído |
| Aluno | home, catálogo, caminho, prática, retomada, conclusão, desempenho vazio e perfil | concluído |
| Professor | contexto, rascunhos, editor em três passos, publicação, distribuição e indicadores | concluído |
| Administrador | listagem filtrável e criação de usuários | concluído |
| Design system | tokens, tema, assets e widgets compartilhados responsivos | concluído |
| Preview | demonstração visual isolada em `main_preview.dart` | mantido, fora da produção |

`main.dart` não importa mocks. Os dados simulados permanecem exclusivamente no preview e nos testes automatizados.

## Tecnologias

- Flutter 3.41.2 e Dart compatível com `^3.9.2`.
- `dio` para comunicação HTTP.
- `shared_preferences` para persistência da sessão.
- `cupertino_icons` e `font_awesome_flutter` disponíveis; as novas jornadas priorizam Material Icons e os assets existentes.
- `flutter_test` e `flutter_lints` para qualidade.

## Estrutura

```text
lib/
├── main.dart
├── main_preview.dart
├── core/
│   ├── api_client.dart
│   ├── api_error.dart
│   ├── auth_gate.dart
│   ├── auth_session.dart
│   ├── constants_api.dart
│   ├── theme/
│   └── widgets/
├── modules/
│   ├── login/
│   ├── home/
│   ├── trilha/
│   ├── distribuicao/
│   ├── catalogo_aluno/
│   ├── aprendizagem/
│   ├── acompanhamento/
│   ├── usuarios/
│   └── perfil/
└── shared/
    ├── models/
    ├── preview/
    └── widgets/
```

Cada módulo separa, quando necessário, `dto`, `service`, `page`, `models` e `widgets`. Os services possuem contratos injetáveis para testes sem substituir a implementação HTTP de produção.

## Jornadas autenticadas

### Aluno

- A identidade vem de `/usuarios/me`; o `login` é exibido como identificação e não como RA.
- Catálogo, progresso e caminho usam somente dados da API.
- A primeira lição incompleta é a atual; as posteriores permanecem bloqueadas.
- A sessão só é aberta ao iniciar a lição.
- Catálogo e caminho são recarregados após prática e conclusão.
- Meta diária, sequência, XP, pontos, ranking, turma e professores ficam ocultos por não possuírem contrato real.
- “Desempenho” permanece como estado vazio.

### Professor

- Home com contexto acadêmico e navegação para trilhas, distribuição, acompanhamento e perfil.
- Listagem e retomada dos próprios rascunhos.
- Editor em três passos: dados básicos; árvore de módulos/lições/desafios/opções; revisão e publicação.
- Validação de ao menos um módulo, uma lição e um desafio, duas opções e exatamente uma correta.
- Distribuição seleciona versão publicada e turma do contexto, sem pedir IDs manualmente.
- Painel usa os indicadores calculados pelo backend.

### Administrador

- Lista os três perfis por `/usuarios?perfil=` e permite filtro local.
- Cria usuário com login, nome, senha e perfil por `POST /usuarios`.
- A senha é limpa após o sucesso e nunca é persistida.
- Não existe cadastro público.

## Comunicação com a API

A URL é definida em compilação e não recebe o prefixo `/api`:

```dart
const String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

O Dio compartilhado usa timeouts de 15 segundos, envia Bearer apenas em rotas protegidas, não repete POST automaticamente e não registra token ou senha. `ApiError` interpreta Problem Details RFC 7807, inclusive `detail`, `errors`, timeout, indisponibilidade e respostas não JSON.

| Método | Rota | Uso |
|---|---|---|
| `GET` | `/actuator/health` | disponibilidade da API |
| `POST` | `/auth/login` | autenticação |
| `GET` | `/usuarios/me` | restauração e identidade |
| `GET/POST` | `/usuarios?perfil=` e `/usuarios` | gestão administrativa |
| `GET` | `/professor/contexto` | turmas e disciplinas do professor |
| `GET/POST` | `/trilhas` | listar e criar rascunhos |
| `GET/PUT` | `/trilhas/{id}` | carregar e salvar a árvore |
| `POST` | `/trilhas/{id}/publicacoes` | publicar snapshot |
| `GET/POST` | `/distribuicoes?turmaId=` e `/distribuicoes` | histórico e nova distribuição |
| `GET` | `/aluno/distribuicoes` | catálogo e progresso |
| `GET` | `/aluno/distribuicoes/{id}/caminho` | módulos e lições ordenados |
| `POST` | `/aluno/distribuicoes/{id}/sessoes` | iniciar ou retomar |
| `GET` | `/aluno/sessoes/{id}` | recuperar sessão |
| `POST` | `/aluno/sessoes/{id}/respostas` | responder desafio |
| `GET` | `/professor/turmas/{id}/indicadores` | acompanhamento |

## Sessão e segurança

`AuthSession` é a fonte única da autenticação. Ele armazena token e identificação do usuário, valida dados restaurados consultando `/usuarios/me`, invalida uma sessão uma única vez em `401` protegido e impede respostas atrasadas de restaurarem uma sessão encerrada. A senha nunca é armazenada e o JWT não é decodificado localmente para autorizar telas.

O `AuthGate` direciona cada perfil para sua área. O logout limpa a sessão e retorna ao login sem empilhar uma rota autenticada.

## Como executar

```powershell
flutter pub get
flutter analyze
flutter test
```

Web, com a API na mesma máquina:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Emulador Android padrão:

```powershell
flutter run -d <ID_DO_EMULADOR> --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Em aparelho físico, use o IPv4 da máquina na mesma rede, por exemplo `http://192.168.0.10:8080`, e libere a porta no firewall. `localhost` no aparelho aponta para o próprio celular.

HTTP local é permitido apenas no manifesto Android de debug; produção deve usar HTTPS. No Web, o backend deve permitir a origem do navegador via CORS.

## Preview visual

O preview continua disponível para demonstrar estados visuais sem backend:

```powershell
flutter run -d chrome -t lib/main_preview.dart
```

`main_preview.dart` e `AlunoPreviewApi` não são importados por `main.dart`.

## Teste opcional com backend real

```powershell
flutter test test/integration/backend_integration_test.dart `
  --dart-define=RUN_BACKEND_INTEGRATION=true `
  --dart-define=API_BASE_URL=http://localhost:8080 `
  --dart-define=BACKEND_TEST_LOGIN=<LOGIN> `
  --dart-define=BACKEND_TEST_PASSWORD=<SENHA>
```

Sem as opções, esse teste é ignorado e a suíte comum não depende de uma API ligada.

## Validação realizada em 14/09/2026

```text
Backend: 24 testes, 0 falhas
flutter analyze: No issues found
flutter test: 123 passaram, 1 integração opcional ignorada
flutter build web --debug: concluído
flutter build apk --debug: concluído
```

Foram cobertos roteamento dos três perfis, DTOs/services, autenticação, Problem Details, editor e bloqueio de POST duplicado, gestão administrativa, catálogo, prática, retomada, conclusão e layouts de 360 px e desktop, incluindo a distribuição do professor.

Artefatos locais:

- `build/web/`;
- `build/app/outputs/flutter-apk/app-debug.apk`.

As pastas de build são temporárias e ignoradas pelo Git. Não houve commit nem push nesta entrega. O plano sincronizado está em `PLANO_IMPLEMENTACAO_FRONTEND.md`.
