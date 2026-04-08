# Documentação - Entidade Posts

## Resumo da Implementação

A entidade Posts foi implementada com sucesso, permitindo que usuários cadastrem itens para doação com todos os recursos solicitados.

## Funcionalidades Implementadas

### 1. **Modelo Post** (`app/models/post.rb`)
- Associação com User (um usuário tem muitos posts)
- Validações de campos obrigatórios (título, descrição, categoria, localização, condição)
- Validações de tamanho de strings
- Suporte a múltiplas imagens usando Active Storage
- Validação de tipo de conteúdo de imagem (JPEG, PNG, WEBP)
- Validação de tamanho de arquivo (máximo 5MB)
- Categorias pré-definidas (Eletrônicos, Móveis, Roupas, Livros, Esportes, Cozinha, Decoração, Brinquedos, Ferramentas, Outro)
- Condições de uso (Novo, Pouco Usado, Muito Usado)
- Escopos para filtragem (recentes, por categoria, por localização)

### 2. **Banco de Dados** (`db/migrate/20260330180529_create_posts.rb`)
- Tabela `posts` com campos:
  - `user_id` (referência para usuário)
  - `title` (string, obrigatório)
  - `description` (text, obrigatório)
  - `category` (string, obrigatório)
  - `location` (string, obrigatório)
  - `condition` (string, obrigatório - novo, leve_use, muito_usado)
  - `created_at` e `updated_at` (timestamps)
- Índices para melhor performance
- Chave estrangeira para usuário com deleção em cascata

### 3. **Controller** (`app/controllers/posts_controller.rb`)
- Actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
- Autenticação obrigatória para criar, editar e deletar posts
- Acesso público para visualizar posts (index e show)
- Autorização para garantir que apenas o proprietário do post possa editá-lo ou deletá-lo
- Tratamento de erros de validação
- Redirecionamentos apropriados

### 4. **Views**

#### `app/views/posts/new.html.erb`
- Formulário para criar novo post
- Campos: título, descrição, categoria, condição, localização, imagens
- Upload de múltiplas imagens
- Exibição de erros de validação
- Estilos Tailwind CSS

#### `app/views/posts/edit.html.erb`
- Formulário para editar post existente
- Exibição das imagens atuais
- Opção de adicionar novas imagens
- Similar ao formulário de criação

#### `app/views/posts/show.html.erb`
- Visualização detalhada do post
- Galeria de imagens
- Informações: categoria, condição, localização, data de criação
- Descrição completa
- Opções de editar/deletar (apenas para proprietário)

#### `app/views/posts/index.html.erb`
- Lista de todos os itens disponíveis
- Grid responsivo (1, 2 ou 3 colunas)
- Filtragem por categoria e localização
- Exibição de primeira imagem como thumbnail
- Informações do post (título, categoria, condição, localização)

### 5. **Dashboard Atualizado** (`app/views/pages/dashboard.html.erb`)
- Seção "Meus Posts" com posts do usuário logado
- Opções para ver, editar e deletar próprios posts
- Seção "Itens Disponíveis para Doação" com posts de outros usuários
- Link para "Ver Todos os Itens" que leva à página de posts
- Link para "Criar Novo Post"

### 6. **Rotas** (`config/routes.rb`)
- `resources :posts` - todas as rotas RESTful para posts

### 7. **Modelo User Atualizado** (`app/models/user.rb`)
- Associação `has_many :posts, dependent: :destroy`
- Posts são deletados quando o usuário é deletado

## Fluxo de Uso

### Para Criar um Post:
1. Usuário acessa o dashboard
2. Clica em "Criar Novo Post"
3. Preenche o formulário com:
   - Nome do item
   - Descrição detalhada
   - Categoria
   - Condição de uso
   - Localização
   - Uma ou mais imagens (máximo 5MB cada)
4. Clica em "Criar Post"

### Para Visualizar Posts:
1. No dashboard, usuários veem:
   - Seus próprios posts (com opções de editar/deletar)
   - Posts de outros usuários (limitado a 6, com opção de ver todos)
2. Podem clicar em "Ver Detalhes" para abrir o post completo
3. Na página de todos os posts, podem filtrar por categoria e localização

### Para Editar um Post:
1. Usuário acessa o post (seu próprio)
2. Clica em "Editar"
3. Modifica as informações desejadas
4. Clica em "Atualizar Post"

### Para Deletar um Post:
1. Usuário clica em "Deletar" (disponível apenas em seus próprios posts)
2. Confirma a deleção

## Validações

- **Título**: Obrigatório, mínimo 3 caracteres, máximo 100
- **Descrição**: Obrigatório, mínimo 10 caracteres, máximo 1000
- **Categoria**: Obrigatória, deve ser uma das categorias pré-definidas
- **Localização**: Obrigatória, mínimo 5 caracteres, máximo 100
- **Condição**: Obrigatória, deve ser "novo", "leve_use" ou "muito_usado"
- **Imagens**: Obrigatória ao menos uma, formato JPEG/PNG/WEBP, máximo 5MB cada

## Segurança

- Autenticação obrigatória para criar/editar/deletar posts
- Autorização para garantir que apenas o proprietário possa editar seu post
- Validação de tipo de arquivo de imagem
- Validação de tamanho de arquivo
- Proteção contra deleção não autorizada

## Melhorias Futuras Sugeridas

- Sistema de comentários/mensagens entre usuários
- Sistema de favorites/bookmarks
- Avaliação/rating de usuários
- Geolocalização mais precisa
- Busca avançada
- Notificações quando alguém tem interesse em um item
- Sistema de imagens em cache/thumbnail
- Paginação na página de posts
- Mobile app
