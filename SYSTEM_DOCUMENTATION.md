# 🎁 Sistema de Posts - Documentação Técnica Completa

## 📋 Visão Geral

Sistema de doação de itens onde usuários podem:
- ✅ Cadastrar itens para doação
- ✅ Adicionar múltiplas imagens
- ✅ Especificar localização e condição de uso
- ✅ Categorizar os itens
- ✅ Visualizar posts de outros usuários
- ✅ Editar/deletar seus próprios posts
- ✅ Filtrar itens por categoria e localização

---

## 🗂️ Estrutura de Arquivos

```
app/
├── models/
│   ├── post.rb              (NEW) Modelo principal
│   └── user.rb              (MODIFIED) Adicionado has_many :posts
├── controllers/
│   └── posts_controller.rb   (NEW) CRUD controller
└── views/
    ├── pages/
    │   └── dashboard.html.erb (MODIFIED) Adicionado seções de posts
    └── posts/
        ├── new.html.erb     (NEW) Formulário novo
        ├── edit.html.erb    (NEW) Formulário edição
        ├── show.html.erb    (NEW) Detalhes
        └── index.html.erb   (NEW) Lista com filtros

config/
└── routes.rb                (MODIFIED) Adicionado resources :posts

db/
└── migrate/
    └── 20260330180529_create_posts.rb (NEW) Criação tabela
```

---

## 📊 Diagrama do Modelo de Dados

```
┌─────────────────────┐
│      User           │
│─────────────────────│
│ id (PK)             │
│ name                │
│ email_address       │
│ password_digest     │
│ created_at          │
│ updated_at          │
└──────────┬──────────┘
           │ 1
           │ has_many :posts
           │
           │ N
           ├──────────────────────┐
           │                      │
    ┌──────▼──────────────────┐ ┌─▼────────────────────────┐
    │       Post              │ │ ActiveStorage::Attachment│
    │────────────────────────│ │────────────────────────┐│
    │ id (PK)                │ │ record_id              ││
    │ user_id (FK)           │ │ name: "images"         ││
    │ title                  │ │ blob_id                ││
    │ description            │ │ record_type: "Post"    ││
    │ category               │ └────────────────────────┘│
    │ location               │                          │
    │ condition              │ ┌────────────────────────┐│
    │ created_at             │ │ ActiveStorage::Blob    ││
    │ updated_at             │ │────────────────────────┐│
    └────────────────────────┘ │ id                     ││
                               │ key                    ││
                               │ filename               ││
                               │ content_type           ││
                               │ byte_size              ││
                               └────────────────────────┘│
```

---

## 🔐 Fluxo de Autenticação e Autorização

```
┌─────────────────────────────────────┐
│ Usuário Não Autenticado             │
├─────────────────────────────────────┤
│ ✓ Pode ver: GET /posts              │
│ ✓ Pode ver: GET /posts/:id          │
│ ✗ Não pode: criar/editar/deletar    │
│ ↓ Redireciona para login             │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Usuário Autenticado (Não proprietário)
├─────────────────────────────────────┤
│ ✓ Pode ver: GET /posts              │
│ ✓ Pode ver: GET /posts/:id          │
│ ✓ Pode criar: POST /posts           │
│ ✓ Pode editar: Apenas SEUS posts    │
│ ✓ Pode deletar: Apenas SEUS posts   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Usuário Proprietário do Post        │
├─────────────────────────────────────┤
│ ✓ Pode editar seu post              │
│ ✓ Pode deletar seu post             │
│ ✗ Não pode editar posts de outros   │
│ ✗ Não pode deletar posts de outros  │
└─────────────────────────────────────┘
```

---

## 📝 Validações do Modelo

| Campo | Validações | Exemplos |
|-------|-----------|----------|
| **title** | Obrigatório, 3-100 chars | "Bicicleta azul" |
| **description** | Obrigatório, 10-1000 chars | "Bicicleta em perfeito estado, pouco usada..." |
| **category** | Obrigatório, deve estar na lista | "Eletrônicos", "Móveis", etc. |
| **location** | Obrigatório, 5-100 chars | "Campus CEUB, Bloco A" |
| **condition** | Obrigatório, novo/leve_use/muito_usado | "novo" |
| **images** | Obrigatório, JPEG/PNG/WEBP, ≤5MB | upload de arquivo |

---

## 🔄 Fluxos de Caso de Uso

### Caso 1: Criar Post
```
Usuário
  ↓
Clica "Criar Novo Post"
  ↓
GET /posts/new
  ↓
Preenche formulário
  ↓
POST /posts
  ↓
Validações
  ├─ ✓ Todas passam → Salva no BD → Redireciona /dashboard com sucesso
  └─ ✗ Alguma falha → Renderiza formulário com erros
```

### Caso 2: Visualizar Posts
```
Usuário (autenticado ou não)
  ↓
Acessa Dashboard ou clica "Ver Todos"
  ↓
GET /posts
  ↓
Lista de todos os posts
  └─ Filtra por categoria/localização (opcional)
  └─ Clica "Ver Detalhes" → GET /posts/:id
```

### Caso 3: Editar Post
```
Proprietário do Post
  ↓
Clica "Editar"
  ↓
GET /posts/:id/edit
  ↓
Modifica formulário
  ↓
PATCH /posts/:id
  ↓
Validações
  ├─ ✓ Todas passam → Salva → Redireciona com sucesso
  └─ ✗ Alguma falha → Renderiza com erros

Outro Usuário
  ↓
Tenta acessar /posts/:id/edit
  ↓
Autorização falha
  ↓
Redireciona com "Não autorizado"
```

### Caso 4: Deletar Post
```
Proprietário
  ↓
Clica "Deletar"
  ↓
Confirma exclusão
  ↓
DELETE /posts/:id
  ↓
Deleta do BD
  ↓
Redireciona com sucesso
```

---

## 🎨 Interface do Usuário

### Dashboard (com Posts)
```
┌──────────────────────────────────────────────┐
│ Bem Vindo, [Nome do Usuário] !               │
├──────────────────────────────────────────────┤
│ [Meu Perfil] [Criar Novo Post] [Logout]     │
├──────────────────────────────────────────────┤
│ Meus Posts                                   │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│ │ Imagem   │  │ Imagem   │  │ Imagem   │   │
│ │ Título   │  │ Título   │  │ Título   │   │
│ │ Cat|Cond │  │ Cat|Cond │  │ Cat|Cond │   │
│ │ 📍Local  │  │ 📍Local  │  │ 📍Local  │   │
│ │[Ver][Edit][Del]      (ações)           │   │
│ └──────────┘  └──────────┘  └──────────┘   │
├──────────────────────────────────────────────┤
│ Itens Disponíveis para Doação                │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│ │ Imagem   │  │ Imagem   │  │ Imagem   │   │
│ │ Título   │  │ Título   │  │ Título   │   │
│ │ Por User │  │ Por User │  │ Por User │   │
│ │ Cat|Cond │  │ Cat|Cond │  │ Cat|Cond │   │
│ │ 📍Local  │  │ 📍Local  │  │ 📍Local  │   │
│ │[Ver]              [Ver] [Ver]           │   │
│ └──────────┘  └──────────┘  └──────────┘   │
│ [Ver Todos os Itens]                       │
└──────────────────────────────────────────────┘
```

### Página de Posts (/posts)
```
┌──────────────────────────────────────────────┐
│ Itens para Doação                            │
├──────────────────────────────────────────────┤
│ [Filtrar por Categoria ▼] [Localização   ]  │
│ [Filtrar] [Limpar]                          │
├──────────────────────────────────────────────┤
│ ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│ │ Imagem   │  │ Imagem   │  │ Imagem   │   │
│ │ Título   │  │ Título   │  │ Título   │   │
│ │ Por User │  │ Por User │  │ Por User │   │
│ │ Desc...  │  │ Desc...  │  │ Desc...  │   │
│ │ Cat|Cond │  │ Cat|Cond │  │ Cat|Cond │   │
│ │ 📍Local  │  │ 📍Local  │  │ 📍Local  │   │
│ │[Ver...]  │  │[Ver...]  │  │[Ver...]  │   │
│ └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────────────────────────────┘
```

### Página de Detalhes (/posts/:id)
```
┌──────────────────────────────────────────────┐
│ [Editar] [Deletar]  (se proprietário)       │
├──────────────────────────────────────────────┤
│ Título do Item                               │
│ Por [Nome do Usuário]                        │
├──────────────────────────────────────────────┤
│ ┌──────────────┐  ┌──────────────┐         │
│ │              │  │              │         │
│ │   Imagem 1   │  │   Imagem 2   │         │
│ │              │  │              │         │
│ └──────────────┘  └──────────────┘         │
├──────────────────────────────────────────────┤
│ Categoria      │ Condição      │ Local      │
│ Eletrônicos    │ Novo          │ Campus...  │
├──────────────────────────────────────────────┤
│ Descrição                                    │
│                                              │
│ Texto completo da descrição do item...      │
│                                              │
├──────────────────────────────────────────────┤
│ [Voltar]                                     │
└──────────────────────────────────────────────┘
```

---

## 📱 Responsividade

- **Desktop**: Grid 3 colunas
- **Tablet**: Grid 2 colunas
- **Mobile**: Grid 1 coluna

Todos os componentes usam Tailwind CSS com classes responsivas:
```
grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3
```

---

## 🚀 Rotas HTTP

| Método | Rota | Função | Auth |
|--------|------|--------|------|
| GET | `/posts` | Listar todos | ✗ |
| POST | `/posts` | Criar novo | ✓ |
| GET | `/posts/new` | Formulário novo | ✓ |
| GET | `/posts/:id` | Detalhes | ✗ |
| PATCH | `/posts/:id` | Atualizar | ✓* |
| GET | `/posts/:id/edit` | Formulário editar | ✓* |
| DELETE | `/posts/:id` | Deletar | ✓* |

*Requer que seja proprietário

---

## ✅ Checklist de Implementação

- [x] Criar modelo Post
- [x] Criar tabela de posts no BD
- [x] Associar User com Post
- [x] Criar controller com CRUD
- [x] Criar views (new, edit, show, index)
- [x] Implementar validações
- [x] Implementar autenticação
- [x] Implementar autorização
- [x] Adicionar suporte a imagens (Active Storage)
- [x] Validar tipo de arquivo
- [x] Validar tamanho de arquivo
- [x] Criar categorias
- [x] Criar condições de uso
- [x] Implementar filtros
- [x] Atualizar dashboard
- [x] Adicionar rotas
- [x] Estilizar com Tailwind CSS
- [x] Tornar responsivo
- [x] Documentar
- [x] Testar

---

## 🔧 Tecnologias Utilizadas

- **Rails 8.1.2** - Framework web
- **Ruby 3.4.1** - Linguagem
- **SQLite** - Banco de dados
- **Active Storage** - Upload de imagens
- **Tailwind CSS** - Estilos
- **ERB** - Templates
- **Rails Forms** - Form helpers

---

## 📚 Documentação Adicional

- `POSTS_IMPLEMENTATION.md` - Documentação detalhada
- `TESTING_GUIDE.md` - Guia de testes
- `CHANGES_SUMMARY.md` - Resumo de alterações

---

## 🎯 Próximos Passos Sugeridos

1. **Sistema de Mensagens**: Permitir que usuários se contatet sobre itens
2. **Favorites**: Marcar itens favoritos
3. **Notificações**: Alertar sobre novos itens
4. **Avaliações**: Usuários avaliar uns aos outros
5. **Geolocalização**: Integrar maps/localização precisa
6. **Busca Avançada**: Busca full-text
7. **Admin Panel**: Moderação de posts
8. **Analytics**: Estatísticas de uso

---

**Implementação Concluída com Sucesso! ✨**
