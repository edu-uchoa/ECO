# frozen_string_literal: true

module Chatbot
  class Retriever
    RELEVANCE_THRESHOLD = 0.3
    TOP_K = 5

    def initialize
      @embedder = Embedder.new
    end

    # Returns array of KnowledgeChunk, or [] if nothing relevant
    def retrieve(query)
      embedding = @embedder.embed(query)
      return [] if embedding.nil?

      KnowledgeChunk.search(embedding, limit: TOP_K, threshold: RELEVANCE_THRESHOLD)
    end
  end
end
