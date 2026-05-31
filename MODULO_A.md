# Rotinaeco - Módulo A (Autenticação e Perfil de Usuário)

## Arquivos Criados

### 1. **Schema do Usuário** (`lib/rotinaeco/accounts/user.ex`)
- Campo `name`: string obrigatório (3-100 caracteres)
- Campo `email`: string obrigatório com validação de formato e índice único
- Campo `password`: virtual (nunca armazenado no banco)
- Campo `password_hash`: string com hash PBKDF2 gerado automaticamente
- Campo `bio`: texto opcional
- Changesets específicos: `registration_changeset` (validação completa) e `profile_changeset` (nome + bio)

### 2. **Contexto de Contas** (`lib/rotinaeco/accounts.ex`)
Funções principais:
- `register_user/1`: Registra novo usuário com validações
- `get_user/1`: Busca usuário por ID
- `get_user_by_email/1`: Busca usuário por email (case-insensitive)
- `update_profile/2`: Atualiza nome e bio
- `verify_password/2`: Verifica senha contra hash
- `authenticate/2`: Autentica usuário por email e senha

### 3. **LiveView de Cadastro** (`lib/rotinaeco_web/live/sign_up_live.ex`)
**RF01 - Cadastro de Usuário**
- Renderização reativa com sigil `~H`
- Estado centralizado em `socket.assigns`
- Evento `validate`: Validação em tempo real via `phx-change`
- Evento `save`: Submissão de formulário via `phx-submit`
- Broadcast via PubSub em canal `users` ao registrar
- Feedback visual de sucesso/erro em tempo real

### 4. **LiveView de Perfil** (`lib/rotinaeco_web/live/profile_live.ex`)
**RF03 - Perfil do Usuário**
- Toggle edit mode com botão "Editar/Cancelar"
- Visualização de: nome, email, bio, data de membro
- Modo edição permite alterar nome e bio
- Evento `edit_toggle`: Alterna entre visualização e edição
- Evento `validate`: Validação em tempo real
- Evento `save`: Atualiza perfil com broadcast em canal `users:id`
- Feedback de sucesso/erro

### 5. **Rotas** (`lib/rotinaeco_web/router.ex`)
```
GET  /              → PageController.home
LIVE /sign-up       → SignUpLive
LIVE /profile/:id   → ProfileLive
```

### 6. **Migração** (`priv/repo/migrations/20260531181054_create_users.exs`)
- Tabela `users` com campos: name, email, password_hash, bio, timestamps
- Índice único em email

## Configuração

### Dependências adicionadas (`mix.exs`)
```elixir
{:pbkdf2_elixir, "~> 2.0"}  # Hash de senha
{:ecto_sqlite3, "~> 0.10"}   # Banco de dados SQLite
```

### Banco de Dados
- **Tipo**: SQLite (rotinaeco_dev.db)
- **Adaptador**: Ecto.Adapters.SQLite3

## Princípios Arquiteturais Aplicados

### 1. Lógica 100% Reativa
- Eventos explícitos via `phx-change` (validação) e `phx-submit` (envio)
- Interface re-renderiza automaticamente após cada evento
- Sem callbacks assíncronos complexos

### 2. Estado Centralizado
- Todo estado em `socket.assigns`
- Changeset, modo edição, mensagens de sucesso/erro
- Sem estado local em componentes

### 3. Eventos Explícitos
- `phx-submit="save"`: Persiste dados no banco
- `phx-change="validate"`: Valida em tempo real
- `phx-click="edit_toggle"`: Alternar modos de visualização

### 4. Interface Direta
- HTML gerado diretamente no sigil `~H` dentro do LiveView
- Sem componentes ocultos (CoreComponents)
- Tailwind CSS inline para estilo puro

### 5. Comunicação via PubSub
- Cadastro: Broadcast em `users` quando novo usuário registra
- Perfil: Broadcast em `users:id` quando perfil é atualizado
- Pronto para sincronizar múltiplos clientes em tempo real

## Execução

```bash
# Instalar dependências
mix deps.get

# Criar banco de dados e rodar migrações
mix ecto.create
mix ecto.migrate

# Iniciar servidor
mix phx.server
```

Acesse:
- Cadastro: http://localhost:4000/sign-up
- Perfil (após cadastro): http://localhost:4000/profile/1

## Estrutura de Diretórios

```
lib/
├── rotinaeco/
│   ├── accounts.ex          # Contexto
│   └── accounts/
│       └── user.ex          # Schema
└── rotinaeco_web/
    ├── router.ex            # Rotas
    └── live/
        ├── sign_up_live.ex  # RF01
        └── profile_live.ex  # RF03

priv/
└── repo/
    └── migrations/
        └── 20260531181054_create_users.exs
```

## Validações Implementadas

**Registro:**
- Nome: Obrigatório, 3-100 caracteres
- Email: Obrigatório, formato válido, único no banco
- Senha: Obrigatório, mínimo 6 caracteres
- Bio: Opcional

**Perfil:**
- Nome: Obrigatório, 3-100 caracteres
- Bio: Opcional

## Segurança

- Senhas hashadas com PBKDF2 (padrão bcrypt do Elixir)
- Email com índice único em nível de banco
- Validações server-side via Changesets
- Validações client-side via `phx-change`
