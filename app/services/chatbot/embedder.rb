# frozen_string_literal: true

module Chatbot
  class Embedder
    MODEL = "text-embedding-3-small"

    def initialize
      @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
    end

    # Returns array of floats
    def embed(text)
      response = @client.embeddings(
        parameters: {
          model: MODEL,
          input: text.strip.gsub(/\s+/, " ").slice(0, 8000)
        }
      )
      response.dig("data", 0, "embedding")
    rescue => e
      Rails.logger.error("[Chatbot::Embedder] #{e.message}")
      nil
    end
  end
end
