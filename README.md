# 🌱 RotinaEco

Aplicação web desenvolvida com **Elixir + Phoenix** para a disciplina **T300 — Programação Funcional**.

O RotinaEco permite que usuários registrem e acompanhem hábitos sustentáveis do cotidiano, acumulem pontos por consistência e visualizem o engajamento da comunidade em tempo real.

---

## 📋 Módulos do Projeto

### Módulo A — Autenticação e Perfil
- Cadastro de usuário com validação em tempo real e hash de senha via **Pbkdf2**
- Login com sessão persistente por cookie
- Magic link para login sem senha
- Edição de perfil, troca de email e troca de senha via **LiveView reativa**

### Módulo B — Hábitos
- Criação e gerenciamento de hábitos sustentáveis
- Check-ins diários para registrar a execução dos hábitos
- Acúmulo de pontos por consistência

### Módulo C — Comunidade
- Feed em tempo real com os hábitos da comunidade via **Phoenix PubSub**
- Dashboard com visão geral do engajamento

---

## 🧠 Conceitos de Programação Funcional Aplicados

| Conceito | Onde foi aplicado |
|---|---|
| **Pipeline operator** `\|>` | Encadeamento de validações nos changesets |
| **Imutabilidade** | Cada função retorna um novo changeset sem modificar o original |
| **Pattern matching** | Tratamento de resultados `{:ok, _}` e `{:error, _}` |
| **Múltiplas cláusulas de função** | Controller de sessão distingue login por senha e por magic link |
| **`with`** | Encadeamento de operações que podem falhar (ex: troca de email) |

---

## 🛠 Tecnologias

- [Elixir](https://elixir-lang.org/) `~> 1.15`
- [Phoenix Framework](https://www.phoenixframework.org/) `~> 1.8`
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) `~> 1.1`
- [Ecto](https://hexdocs.pm/ecto) + PostgreSQL
- [Tailwind CSS](https://tailwindcss.com/)
- [Phoenix PubSub](https://hexdocs.pm/phoenix_pubsub)
- [Pbkdf2](https://hexdocs.pm/pbkdf2_elixir) para hash de senhas
- [Swoosh](https://hexdocs.pm/swoosh) para envio de emails
- [Bandit](https://hexdocs.pm/bandit) como servidor HTTP

---

## 🚀 Como executar

### Pré-requisitos

- Elixir `~> 1.15`
- PostgreSQL rodando localmente

### Instalação

```bash
# Instala dependências, cria o banco e compila os assets
mix setup

# Inicia o servidor
mix phx.server
```

Acesse [`http://localhost:4000`](http://localhost:4000).

---

## 🗂 Estrutura do Projeto

```
lib/
├── rotinaeco/              # Lógica de negócio (contextos)
│   ├── accounts/           # Usuários e autenticação
│   ├── habits/             # Hábitos sustentáveis
│   └── check_ins/          # Registros diários
└── rotinaeco_web/          # Camada web
    ├── live/               # LiveViews (tempo real)
    │   ├── habit_live/
    │   ├── user_live/
    │   ├── dashboard_live.ex
    │   ├── profile_live.ex
    │   └── community_feed_live.ex
    ├── controllers/        # Controllers convencionais
    └── router.ex           # Rotas da aplicação
```

---

## 🧪 Testes

```bash
mix test
```

Para rodar lint, formatação e testes juntos:

```bash
mix precommit
```

---

*Projeto acadêmico — T300 Programação Funcional*
