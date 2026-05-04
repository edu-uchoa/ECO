# frozen_string_literal: true

module Chatbot
  # Indexes site content into KnowledgeChunk records with embeddings.
  # Call Chatbot::Indexer.new.run to reindex everything.
  class Indexer
    CHUNK_SIZE = 500 # characters per chunk
    OVERLAP    = 50

    def initialize
      @embedder = Embedder.new
    end

    def run
      Rails.logger.info("[Chatbot::Indexer] Starting indexing...")
      index_static_content
      index_posts
      Rails.logger.info("[Chatbot::Indexer] Done. Total chunks: #{KnowledgeChunk.count}")
    end

    private

    # ---------- Static site content ----------

    def index_static_content
      static_pages = [
        {
          source: "faq",
          source_id: 0,
          content: <<~TEXT
            ECO é uma plataforma de doações de itens entre pessoas.
            Qualquer usuário pode cadastrar itens para doação (eletrônicos, móveis, roupas, livros, esportes, cozinha, decoração, brinquedos, ferramentas e outros).
            Para publicar um item é necessário ter perfil completo na plataforma.
            Cada item deve ter título, descrição, categoria, localização, condição (Novo, Pouco Usado, Muito Usado) e pelo menos uma foto.
            Itens disponíveis aparecem na página principal e podem ser filtrados por categoria e localização.
            Qualquer usuário autenticado pode manifestar interesse em um item clicando em "Tenho Interesse", o que inicia uma conversa com o doador.
            O doador pode aceitar ou recusar o pedido de doação diretamente no chat.
            Quando a doação é aceita o item muda para status "Doado" e deixa de aparecer nas listagens.
            Após receber um item o beneficiado pode deixar uma avaliação com nota de 1 a 5 estrelas e um comentário.
            O dono do post pode remover avaliações indesejadas.
            No perfil de cada usuário é possível ver os itens disponíveis e os já doados separadamente.
            O chat permite troca de mensagens privadas entre usuários.
            Na aba Mapa é possível visualizar a localização dos itens disponíveis.
          TEXT
        },
        {
          source: "como_usar",
          source_id: 0,
          content: <<~TEXT
            Como se cadastrar no ECO: clique em "Sign up" na barra de navegação, preencha nome, email e senha.
            Como fazer login: clique em "Login" e informe email e senha.
            Como criar um post de doação: acesse o Dashboard, clique em "Adicionar Item", preencha todos os campos obrigatórios e envie as fotos.
            Como solicitar um item: abra a página do item desejado e clique em "Tenho Interesse".
            Como aceitar uma doação: no chat com o interessado, clique em "Aceitar" na mensagem de interesse.
            Como ver meus posts: acesse "Meu Perfil" na barra de navegação.
            Como avaliar um item recebido: após a doação ser aceita, acesse a página do item e deixe sua avaliação.
            Como ver o mapa de itens: clique na aba "Mapa" na barra de navegação.
          TEXT
        }
      ]

      static_pages.each do |page|
        upsert_chunks(page[:content], page[:source], page[:source_id], page)
      end
    end

    # ---------- Dynamic content: posts ----------

    def index_posts
      Post.available.includes(:user).find_each do |post|
        text = build_post_text(post)
        upsert_chunks(text, "post", post.id, { title: post.title })
      end
    end

    def build_post_text(post)
      <<~TEXT
        Item disponível para doação: #{post.title}
        Categoria: #{post.category}
        Condição: #{post.condition}
        Localização: #{post.location}
        Doador: #{post.user.name}
        Descrição: #{post.description}
        Link: /posts/#{post.id}
      TEXT
    end

    # ---------- Helpers ----------

    def upsert_chunks(text, source, source_id, _meta = {})
      # Remove existing chunks for this source+id
      KnowledgeChunk.where(source: source, source_id: source_id).destroy_all

      chunks = split_into_chunks(text)
      chunks.each do |chunk|
        embedding = @embedder.embed(chunk)
        next if embedding.nil?

        KnowledgeChunk.create!(
          content: chunk,
          embedding: embedding,
          source: source,
          source_id: source_id,
          metadata: { source: source, source_id: source_id }.to_json
        )
        sleep(0.1) # Respect OpenAI rate limits
      end
    end

    def split_into_chunks(text)
      text = text.strip
      return [text] if text.length <= CHUNK_SIZE

      chunks = []
      start = 0
      while start < text.length
        finish = [start + CHUNK_SIZE, text.length].min
        chunks << text[start...finish].strip
        start += CHUNK_SIZE - OVERLAP
      end
      chunks.reject(&:blank?)
    end
  end
end
