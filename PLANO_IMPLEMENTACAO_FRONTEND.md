# Plano de implementação — Frontend

## 1. Objetivo da entrega

Entregar até **24/09/2026** a aplicação Flutter do ciclo:

```text
Professor cria e publica uma trilha
→ disponibiliza para uma turma
→ aluno pratica e recebe feedback
→ sistema registra tentativas e progresso
→ professor acompanha os resultados
```

Este arquivo usa exatamente as mesmas etapas do `PLANO_IMPLEMENTACAO_BACKEND.md`. A conclusão de uma etapa exige integração com o backend real e regressão das etapas anteriores.

### Estado em 14/09/2026

As jornadas de aluno, professor e administrador foram conectadas aos services HTTP de produção. O `AuthGate` direciona por perfil, o editor do professor possui três passos, catálogo/caminho/prática usam dados da API e a gestão administrativa cria e lista usuários. `main_preview.dart` e `AlunoPreviewApi` permanecem isolados e não são importados por `main.dart`.

Validação atual: `flutter analyze` sem problemas, 123 testes aprovados, um teste externo opcional ignorado, build Web de debug e APK de debug gerados.

O aceite manual do ciclo inteiro em dispositivo/navegador com PostgreSQL real continua pendente e será feito pela equipe; os testes automatizados não o substituem.

## 2. Regra central de conclusão

Uma tela pronta com dados fixos não conclui uma etapa.

Para concluir uma etapa:

1. o frontend deve consumir o endpoint real da etapa;
2. o backend e o banco reais devem estar em execução;
3. os testes automatizados devem passar;
4. o cenário integrado descrito no aceite deve funcionar;
5. todas as telas e funcionalidades anteriores devem continuar funcionando.

Durante o desenvolvimento, o frontend pode usar um `MockService` com o mesmo JSON combinado com o backend. Isso permite iniciar a tela sem esperar pelo endpoint. Antes do aceite, o mock deve ser substituído pelo service HTTP real.

## 3. Escopo obrigatório e limites

### Obrigatório

- Login e sessão de professor e aluno.
- Home diferente por perfil.
- Editor de trilha, módulo, lição e múltipla escolha.
- Publicação de versão e distribuição para turma.
- Catálogo do aluno.
- Prática, feedback, nova tentativa, retomada e conclusão.
- Painel básico do professor.
- Estados de carregamento, vazio, erro e sucesso.
- Funcionamento em Flutter Web e Android.

### Fora do MVP

- Telas administrativas de usuário, disciplina ou turma.
- Drag-and-drop, editor de texto rico e animações complexas.
- Execução de código, IA, ranking, conquistas e chat.
- Tipos de desafio diferentes de múltipla escolha.
- Riverpod, GoRouter e arquiteturas diferentes do GulaPay.

## 4. Organização da equipe

| Pessoa | Responsabilidade principal | Par integrado |
|---|---|---|
| F1 | fundação, Dio, autenticação, sessão, integração e builds | B1 |
| F2 | home do professor, autoria, publicação e distribuição | B2 |
| F3 | catálogo, prática, progresso e acompanhamento | B3 |

Cada pessoa mantém apenas um item em andamento. A pessoa responsável implementa; o par backend ajuda a validar o contrato e o cenário integrado.

## 5. Estrutura e dependências

Projeto novo seguindo o padrão do GulaPay:

```text
lib/
├── main.dart
├── core/
│   ├── api_client.dart
│   ├── api_error.dart
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
│   └── acompanhamento/
└── shared/
```

Cada módulo pode conter apenas o que precisar:

```text
dto/
page/
service/
widgets/
models/
```

Dependências permitidas:

```yaml
environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  font_awesome_flutter: ^11.0.0
  dio: ^5.9.2
  shared_preferences: ^2.2.2
```

Em `dev_dependencies`, usar apenas `flutter_test` e `flutter_lints`.

## 6. Arquitetura e convenções

- Usar `MaterialApp`, Material 3, `Navigator.push`, `Navigator.pop` e estado local.
- Não usar Riverpod, GoRouter ou geração de código.
- Páginas chamam services; services chamam `ApiClient.dio`.
- DTOs implementam `fromJson` e `toJson` quando houver envio.
- Chamadas HTTP não ficam dentro de widgets de apresentação reutilizáveis.
- Services podem receber um `Dio` opcional no construtor para facilitar testes; o default é `ApiClient.dio`.
- Páginas podem receber um service opcional no construtor; em execução normal usam o service real.
- `ApiClient` é único, possui timeout e adiciona JWT automaticamente.
- `ApiError` converte RFC 7807 em mensagem compreensível.
- `SharedPreferences` guarda `accessToken`, `usuarioId`, `login`, `nome` e `perfil`.
- Na inicialização, consultar `/usuarios/me` para confirmar uma sessão salva.
- Em `401`, remover a sessão e voltar ao login.
- Em `403`, mostrar “Você não tem permissão para acessar este recurso”.
- Botões de envio ficam desabilitados durante requisições.
- Dados digitados são preservados quando a API retorna erro.
- O frontend nunca recebe ou calcula a resposta correta antes do envio.

Base URL:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

Execução local:

```text
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## 7. Contratos consumidos

| Método e rota | Service do frontend | Tela |
|---|---|---|
| `POST /auth/login` | `LoginService` | login |
| `GET /usuarios/me` | `LoginService`/`AuthSession` | inicialização |
| `GET /professor/contexto` | `ProfessorContextoService` | home do professor |
| `GET /trilhas` | `TrilhaService` | rascunhos e publicações do professor |
| `POST /trilhas` | `TrilhaService` | início do editor |
| `GET /trilhas/{id}` | `TrilhaService` | edição |
| `PUT /trilhas/{id}` | `TrilhaService` | salvar árvore |
| `POST /trilhas/{id}/publicacoes` | `TrilhaService` | publicação |
| `POST /distribuicoes` | `DistribuicaoService` | distribuição |
| `GET /distribuicoes?turmaId={id}` | `DistribuicaoService` | histórico da turma |
| `GET /aluno/distribuicoes` | `CatalogoAlunoService` | home do aluno |
| `GET /aluno/distribuicoes/{id}/caminho` | `CatalogoAlunoService` | módulos e lições |
| `POST /aluno/distribuicoes/{id}/sessoes` | `AprendizagemService` | começar/continuar |
| `GET /aluno/sessoes/{id}` | `AprendizagemService` | retomada |
| `POST /aluno/sessoes/{id}/respostas` | `AprendizagemService` | responder |
| `GET /professor/turmas/{id}/indicadores` | `AcompanhamentoService` | painel |

### Login

```json
{
  "login": "professor",
  "senha": "prof123"
}
```

```json
{
  "accessToken": "jwt",
  "tokenType": "Bearer",
  "expiresInMinutes": 480,
  "usuarioId": 2,
  "login": "professor",
  "nome": "Professor Demo",
  "perfil": "PROFESSOR"
}
```

### Rascunho básico

```json
{
  "titulo": "Fundamentos da lógica",
  "descricao": "Trilha piloto",
  "disciplinaId": 1
}
```

### Árvore completa

```json
{
  "titulo": "Fundamentos da lógica",
  "descricao": "Trilha piloto",
  "disciplinaId": 1,
  "modulos": [{
    "titulo": "Estruturas condicionais",
    "ordem": 1,
    "licoes": [{
      "titulo": "If e else",
      "resumo": "Escolhendo caminhos",
      "ordem": 1,
      "desafios": [{
        "enunciado": "Qual saída será exibida?",
        "tipo": "MULTIPLA_ESCOLHA",
        "dificuldade": "FACIL",
        "explicacao": "A condição é verdadeira.",
        "ordem": 1,
        "opcoes": [
          {"texto": "A", "ordem": 1, "correta": true},
          {"texto": "B", "ordem": 2, "correta": false}
        ]
      }]
    }]
  }]
}
```

### Resposta do aluno

```json
{
  "desafioId": 1,
  "opcaoId": 2
}
```

```json
{
  "correta": true,
  "feedback": "Correto. A condição é verdadeira.",
  "progresso": {
    "respondidos": 1,
    "total": 3,
    "percentual": 33,
    "concluida": false
  },
  "proximoDesafio": {
    "id": 2,
    "enunciado": "Próxima questão",
    "tipo": "MULTIPLA_ESCOLHA",
    "opcoes": [{"id": 3, "texto": "Opção"}]
  }
}
```

O DTO de desafio do aluno não pode declarar o campo `correta`. Esse campo existe apenas nos DTOs do editor do professor e na resposta de correção posterior ao envio.

## 8. Desenvolvimento paralelo sem espera

Em cada item:

1. F e B do par leem o contrato JSON correspondente.
2. F cria DTO, service e tela usando temporariamente uma resposta simulada igual ao contrato.
3. B cria endpoint e testes usando o mesmo contrato.
4. Quando o endpoint fica pronto, F liga o service real.
5. O par executa o cenário integrado.
6. Somente depois o item é concluído.

O mock pode ficar nos testes, mas não pode ser selecionado em `main.dart` nem no build entregue.

## 9. Calendário dos incrementos

| Período | Incremento obrigatório |
|---|---|
| 09/09 | 1.1 — projetos executando e conectados pelo health |
| 10–11/09 | 1.2 e 1.3 — login, perfil e navegação reais |
| 12–14/09 | 2.1 a 2.5 — professor cria e publica V1 |
| 15–16/09 | 3.1 e 3.2 — distribuição e catálogo do aluno |
| 17–19/09 | 4.1 a 4.3 — prática, feedback, retomada e conclusão |
| 20–21/09 | 5.1 e 5.2 — acompanhamento e histórico de versões |
| 22/09 | 6.1 — regressão completa |
| 23/09 | 6.2 — builds e correções bloqueadoras |
| 24/09 | apresentação; nenhuma funcionalidade nova |

## 10. Etapas de implementação

### Etapa 1 — Base, login e perfis

#### 1.1 — Criar o frontend

**Responsável:** F1. **Par:** B1.

Implementar:

- projeto Flutter e dependências da seção 5;
- estrutura `core`, `modules` e `shared`;
- `ConstantsApi`, `ApiClient` e `ApiError`;
- Material 3 e página inicial técnica com estado da API;
- consulta real a `/actuator/health`;
- widget compartilhado de loading, erro com retry e estado vazio.

Testar: parse do health, loading, sucesso, erro e base URL por `dart-define`.

Aceite integrado: aplicativo abre e mostra que o backend 1.1 está online.

#### 1.2 — Login e armazenamento da sessão

**Responsável:** F1. **Par:** B1.

Arquivos esperados:

```text
modules/login/dto/login_response.dart
modules/login/service/login_service.dart
modules/login/page/login_page.dart
```

Implementar:

- campos login/senha e mostrar/ocultar senha;
- validação obrigatória;
- botão com loading e bloqueio de duplo clique;
- `LoginService.efetuarLogin` conforme o contrato;
- gravação dos dados da sessão em `SharedPreferences`;
- interceptor `Authorization: Bearer` no `ApiClient`.

Testar: campos vazios, sucesso professor/aluno, credencial inválida e token salvo.

Aceite integrado: professor e aluno entram pela API real; login inválido mostra mensagem compreensível.

#### 1.3 — Perfil corrente e navegação

**Responsável:** F1. **Par:** B1.

Implementar:

- `AuthSession` para carregar, validar e remover sessão;
- consulta a `/usuarios/me` ao iniciar com token salvo;
- `ProfessorHomePage` e `AlunoHomePage` mínimas;
- decisão da home pelo campo `perfil`;
- logout e retorno ao login;
- tratamento global de `401` e bloqueio de navegação para papel errado.

Testar: início sem token, token válido, token inválido, professor, aluno e logout.

Aceite da Etapa 1: aplicativo inicia no login, cada perfil chega à home correta, logout funciona e 1.1/1.2 passam novamente.

### Etapa 2 — Professor cria e publica

#### 2.1 — Mostrar o contexto acadêmico

**Responsável:** F2. **Par:** B2.

Arquivos esperados:

```text
modules/home/dto/professor_contexto.dart
modules/home/service/professor_contexto_service.dart
modules/home/page/professor_home_page.dart
```

Implementar:

- carregar `/professor/contexto`;
- mostrar nome da disciplina e turma;
- ação “Criar trilha”;
- loading, vazio, erro e retry.

Aceite integrado: professor vê apenas sua disciplina/turma real; aluno não acessa a consulta.

#### 2.2 — Criar rascunho básico

**Responsável:** F2. **Par:** B2.

Implementar no módulo `trilha`:

- DTOs de criação/resposta;
- `TrilhaService.criar`;
- formulário com título, descrição e disciplina do contexto;
- validação local e preservação dos campos em erro;
- armazenamento do `trilhaId` retornado para continuar o editor.

Testar: obrigatórios, serialização, sucesso, erro RFC 7807 e clique duplicado.

Aceite integrado: professor cria um rascunho real e vê status `RASCUNHO`.

#### 2.3 — Montar módulo, lição e desafios

**Responsável:** F2. **Par:** B2.

Criar DTOs de módulo, lição, desafio e opção. No editor:

- adicionar/remover módulos;
- adicionar/remover lições dentro do módulo;
- adicionar/remover desafios dentro da lição;
- adicionar/remover opções;
- marcar exatamente uma opção correta;
- atribuir `ordem` conforme a posição visual;
- validar ao menos um item em cada nível e duas opções por desafio;
- enviar a árvore por `PUT /trilhas/{id}`.

Não implementar drag-and-drop. Usar botões simples de adicionar, remover, mover para cima e mover para baixo.

Testar: árvore mínima, opção correta, ordens, serialização e manutenção dos dados após erro.

Aceite integrado: árvore completa é salva e devolvida pelo backend sem perda.

#### 2.4 — Carregar e editar o rascunho

**Responsável:** F2. **Par:** B2.

- Implementar `TrilhaService.buscarPorId` e `atualizar`.
- Preencher o editor com a resposta da API.
- Permitir alterar todos os níveis da árvore.
- Bloquear botões durante o salvamento.
- Mostrar acesso negado e recurso inexistente adequadamente.

Testar: carregar, editar, remover item, erro e retorno ao editor.

Aceite integrado: professor fecha, reabre, altera e salva; 2.2/2.3 continuam funcionando.

#### 2.5 — Publicar uma versão

**Responsável:** F2. **Par:** B2.

- Adicionar “Publicar versão” somente após rascunho completo e salvo.
- Mostrar diálogo informando que a versão publicada será imutável.
- Chamar `/trilhas/{id}/publicacoes`.
- Mostrar `numeroVersao` e `publicadaEm`.
- Manter ação para editar o rascunho depois da publicação.

Testar: cancelar diálogo, sucesso, erro, botão durante envio e publicação repetida.

Aceite da Etapa 2: professor cria e publica V1; editar rascunho não muda a identificação de V1; Etapa 1 passa novamente.

### Etapa 3 — Professor distribui e aluno visualiza

#### 3.1 — Distribuir versão para turma

**Responsável:** F2. **Par:** B2.

Criar módulo `distribuicao` com:

- DTOs e `DistribuicaoService`;
- versão recém-publicada e turma do contexto, sem digitar IDs;
- data inicial e final opcional;
- validação de período;
- confirmação com trilha, versão e turma;
- tratamento de duplicidade e acesso negado.

Aceite integrado: professor distribui V1 pela interface e o backend registra uma única distribuição.

#### 3.2 — Exibir catálogo do aluno

**Responsável:** F3. **Par:** B3, com apoio B2.

Criar módulo `catalogo_aluno` com:

- DTOs e `CatalogoAlunoService`;
- cards com título, disciplina, versão, quantidade de desafios e progresso;
- `sessaoId`, datas de disponibilidade e indicação de prazo encerrado;
- caminho ordenado com a primeira lição incompleta como atual;
- botão “Começar”, “Continuar” ou “Concluída” conforme estado;
- atualização manual, loading, vazio e retry.

O modelo do catálogo não contém opções ou respostas corretas.

Aceite da Etapa 3: professor distribui, aluno entra e vê a mesma trilha; Etapas 1 e 2 passam novamente.

### Etapa 4 — Aluno pratica

#### 4.1 — Iniciar ou retomar sessão

**Responsável:** F3. **Par:** B3.

Criar módulo `aprendizagem` com:

- DTOs de sessão, progresso, desafio e opção do aluno;
- `AprendizagemService.iniciarOuRetomar`;
- página de prática com título, lição, barra de progresso, enunciado e opções;
- navegação a partir do card do catálogo;
- retry sem navegação duplicada.
- retomada de sessão existente depois do prazo e tratamento de `409` para nova sessão vencida;
- bloqueio amigável de sessão incompleta quando a distribuição estiver inativa.

O DTO `OpcaoAluno` possui apenas `id` e `texto`.

Aceite integrado: “Começar” abre o desafio real e nova abertura retoma a sessão.

#### 4.2 — Responder e receber feedback

**Responsável:** F3. **Par:** B3.

- Exigir uma opção antes de habilitar “Responder”.
- Enviar `desafioId` e `opcaoId`.
- Bloquear o botão durante a requisição.
- Mostrar feedback de acerto/erro com texto e ícone, não apenas cor.
- Em erro, liberar nova tentativa no mesmo desafio.
- Em acerto, mostrar “Continuar” e usar `proximoDesafio` da API.
- Não reenviar automaticamente um POST que terminou com timeout.

Testar: sem seleção, erro, acerto, falha de rede, nova tentativa e avanço.

Aceite integrado: erro e acerto reais são registrados uma vez e o aluno avança corretamente.

#### 4.3 — Retomar e concluir

**Responsável:** F3. **Par:** B3.

- Implementar consulta de sessão existente.
- Atualizar a barra somente com `progresso` retornado pelo backend.
- Mostrar resumo quando `concluida=true`.
- Invalidar/recarregar o catálogo ao concluir.
- Após logout/login, mostrar o progresso persistido.
- Sessão concluída abre resumo somente leitura.

Testar: desafio intermediário, último desafio, 100%, retorno ao catálogo e novo login.

Aceite da Etapa 4: aluno erra, acerta, sai, retoma e conclui; Etapas 1 a 3 passam novamente.

### Etapa 5 — Professor acompanha

#### 5.1 — Exibir indicadores

**Responsável:** F3. **Par:** B3.

Criar módulo `acompanhamento` com:

- `AcompanhamentoService` e DTOs;
- cards de matriculados, iniciaram, concluíram, conclusão e acurácia;
- lista de desafios com enunciado, tentativas, erros e taxa de erro;
- atualização manual;
- estado vazio para turma sem tentativas.

Não implementar gráficos complexos ou atualização em tempo real.

Aceite integrado: tentativa do aluno modifica o painel ao atualizar.

#### 5.2 — Mostrar versão e tratar acessos

**Responsável:** F2, revisão F1/F3. **Par:** B2.

- Mostrar `numeroVersao` no catálogo, distribuição e painel.
- Preservar a identificação V1 após publicação de V2.
- Padronizar mensagens para `401`, `403`, `404` e `409`.
- Garantir que aluno não navegue para telas de professor e vice-versa.

Aceite da Etapa 5: V2 não substitui V1 nas telas históricas; ciclo completo anterior passa novamente.

### Etapa 6 — Estabilização

#### 6.1 — Regressão completa

**Responsável:** F1 com todos.

Executar duas vezes, sem mocks:

1. login do professor;
2. criação e publicação de trilha;
3. distribuição;
4. login do aluno;
5. erro, feedback, acerto, retomada e conclusão;
6. retorno ao professor e consulta dos indicadores.

Executar `flutter analyze` e `flutter test`. Testar larguras de 360, 768 e 1366 px.

#### 6.2 — Gerar builds

**Responsável:** F1.

- Confirmar `API_BASE_URL` por `dart-define`.
- Executar `flutter build apk --debug` para o artefato de validação.
- Executar `flutter build web --debug`.
- Confirmar que nenhum `MockService` está ativo.
- Testar o APK e o build Web contra a mesma API.
- Congelar funcionalidades; corrigir apenas bloqueadores.

Aceite final: APK e Web executam todo o ciclo real sem alteração de código ou IDs manuais.

## 11. Definição de pronto de qualquer item

- `flutter analyze` e `flutter test` passam.
- DTO corresponde ao contrato backend.
- Tela possui loading, sucesso e erro relevante.
- Botões não enviam duas vezes.
- Dados digitados não somem em erro de API.
- Layout funciona em 360 px e desktop.
- Endpoint real substituiu o mock.
- Etapas anteriores foram testadas novamente.

## 12. Instrução para delegar um item a uma IA

```text
Implemente somente o item [número e título] deste plano frontend.
Leia as seções de estrutura, arquitetura, contratos e definição de pronto.
Primeiro inspecione o projeto. Depois implemente DTO, service, página, widgets,
navegação e testes necessários. Siga a estrutura do GulaPay, preserve as etapas
anteriores, não adicione Riverpod/GoRouter e não altere contratos sem informar.
Execute flutter analyze e flutter test e relate arquivos, comandos, resultados
e o aceite integrado ainda pendente.
```
