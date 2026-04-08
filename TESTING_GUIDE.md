# Guia de Teste - Sistema de Posts

## Como Testar a Implementação

### Pré-requisitos
- Servidor Rails rodando em `http://localhost:3000`
- Usuário cadastrado no sistema

### Passos para Testar

#### 1. Login
1. Acesse `http://localhost:3000`
2. Clique em "Login"
3. Use credenciais de um usuário existente
   - Email: seu email registrado
   - Senha: sua senha

#### 2. Acessar o Dashboard
1. Após login, você será redirecionado para `/dashboard`
2. Você verá:
   - Saudação personalizada
   - Botões de ação (Meu Perfil, Criar Novo Post, Logout)
   - Seção "Meus Posts" (vazia se for primeira vez)
   - Seção "Itens Disponíveis para Doação"

#### 3. Criar um Novo Post
1. Na página do dashboard, clique em "Criar Novo Post"
2. Você será levado para `/posts/new`
3. Preencha o formulário:
   - **Título**: Nome do item (ex: "Bicicleta azul")
   - **Descrição**: Detalhes do item (mínimo 10 caracteres)
   - **Categoria**: Selecione uma das opções disponíveis
   - **Condição de Uso**: Novo, Pouco Usado ou Muito Usado
   - **Localização**: Onde o item está (ex: "Campus CEUB, Bloco A")
   - **Imagens**: Adicione uma ou mais fotos (JPEG, PNG ou WEBP, máximo 5MB cada)
4. Clique em "Criar Post"
5. Se tudo estiver correto, você será redirecionado para o dashboard com mensagem de sucesso

#### 4. Visualizar Todos os Posts
1. No dashboard, clique em "Ver Todos os Itens"
2. Você será levado para `/posts`
3. Veja a grade de todos os itens disponíveis
4. Use os filtros:
   - Categoria: filtra por categoria específica
   - Localização: filtra por localização
5. Clique em "Ver Detalhes" para abrir um post

#### 5. Visualizar Detalhes de um Post
1. Clique em qualquer post
2. Na página `/posts/:id` você verá:
   - Galeria de imagens
   - Título e criador
   - Informações (Categoria, Condição, Localização, Data)
   - Descrição completa
   - Botões de ação (se for seu post: Editar e Deletar)

#### 6. Editar um Post
1. No dashboard ou na página do post, clique em "Editar"
2. Você será levado para `/posts/:id/edit`
3. Modifique os campos desejados
4. Você pode adicionar novas imagens
5. Clique em "Atualizar Post"

#### 7. Deletar um Post
1. No dashboard ou na página do post, clique em "Deletar"
2. Confirme a deleção
3. O post será removido e você será redirecionado

### Testes de Validação

#### Teste 1: Título Obrigatório e Tamanho
1. Tente criar um post deixando o título em branco
2. Resultado: Erro "Título não pode ficar em branco"
3. Tente criar um post com título de 1 caractere
4. Resultado: Erro "Título é muito curto (mínimo 3 caracteres)"

#### Teste 2: Descrição Obrigatória
1. Tente criar um post deixando descrição em branco
2. Resultado: Erro "Descrição não pode ficar em branco"
3. Tente com descrição de 5 caracteres
4. Resultado: Erro "Descrição é muito curta (mínimo 10 caracteres)"

#### Teste 3: Categoria Obrigatória
1. Tente criar um post sem selecionar categoria
2. Resultado: Erro "Categoria não pode ficar em branco"

#### Teste 4: Localização Obrigatória
1. Tente criar um post deixando localização em branco
2. Resultado: Erro "Localização não pode ficar em branco"

#### Teste 5: Imagem Obrigatória
1. Tente criar um post sem adicionar imagens
2. Resultado: Erro "Imagens não pode ficar em branco"

#### Teste 6: Tipo de Arquivo
1. Tente fazer upload de um arquivo que não seja imagem (ex: .pdf, .txt)
2. Resultado: Erro "Imagens deve ser um arquivo JPEG, PNG ou WEBP"

#### Teste 7: Tamanho de Arquivo
1. Tente fazer upload de uma imagem maior que 5MB
2. Resultado: Erro "Imagens não pode exceder 5MB"

### Testes de Autorização

#### Teste 1: Editar Post de Outro Usuário
1. Faça login com usuário A
2. Crie um post
3. Faça logout
4. Faça login com usuário B
5. Abra o post do usuário A
6. Tente acessar manualmente `/posts/:id/edit` do post de A
7. Resultado: Redirecionado com mensagem "Não autorizado"

#### Teste 2: Deletar Post de Outro Usuário
1. Abra post de outro usuário
2. Não haverá botão "Deletar" visível
3. Tente acessar manualmente a rota DELETE
4. Resultado: Redirecionado com mensagem "Não autorizado"

### Testes de Filtragem

#### Teste 1: Filtrar por Categoria
1. Vá para `/posts`
2. Selecione uma categoria no filtro
3. Clique em "Filtrar"
4. Resultado: Apenas posts da categoria selecionada aparecem

#### Teste 2: Filtrar por Localização
1. Vá para `/posts`
2. Digite uma localização
3. Clique em "Filtrar"
4. Resultado: Apenas posts com aquela localização aparecem

#### Teste 3: Limpar Filtros
1. Aplique um filtro
2. Clique em "Limpar"
3. Resultado: Todos os posts aparecem novamente

### Checklist de Funcionalidades

- [ ] Usuário pode criar post com título, descrição, categoria, condição, localização e imagens
- [ ] Posts aparecem no dashboard do criador
- [ ] Posts aparecem na página de todos os itens
- [ ] Imagens são exibidas corretamente
- [ ] Usuário pode editar seus próprios posts
- [ ] Usuário pode deletar seus próprios posts
- [ ] Usuário NÃO pode editar/deletar posts de outros
- [ ] Filtros funcionam corretamente
- [ ] Validações funcionam
- [ ] Mensagens de erro aparecem
- [ ] Mensagens de sucesso aparecem
- [ ] Layout responsivo funciona em mobile
- [ ] Estilos Tailwind CSS estão aplicados

## Endpoints da API

| Método | Rota | Descrição | Autenticação |
|--------|------|-----------|---------------|
| GET | `/posts` | Listar todos posts | Não |
| POST | `/posts` | Criar novo post | Sim |
| GET | `/posts/new` | Formulário novo post | Sim |
| GET | `/posts/:id` | Visualizar post | Não |
| GET | `/posts/:id/edit` | Formulário editar post | Sim* |
| PATCH/PUT | `/posts/:id` | Atualizar post | Sim* |
| DELETE | `/posts/:id` | Deletar post | Sim* |

*Requer que o usuário seja o proprietário do post
