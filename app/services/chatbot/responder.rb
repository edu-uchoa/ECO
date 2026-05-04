# frozen_string_literal: true

module Chatbot
  class Responder
    MODEL = "gpt-4o-mini"
    MAX_TOKENS = 600

    SYSTEM_PROMPT = <<~PROMPT
      Você é o assistente virtual do ECO, uma plataforma de doações de itens entre pessoas.
      Seu objetivo é ajudar usuários a entender como funciona a plataforma, encontrar itens disponíveis e tirar dúvidas.

      Regras:
      1. Se houver contexto relevante fornecido, baseie sua resposta principalmente nele.
      2. Não invente informações sobre itens ou usuários específicos que não estejam no contexto.
      3. Seja simpático, conciso e direto.
      4. Responda sempre em português brasileiro.
      5. Se não souber algo específico da plataforma, oriente o usuário a navegar pelo site.
    PROMPT

    def initialize
      @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
    end

    def answer(question:, chunks: [])
      messages = [{ role: "system", content: SYSTEM_PROMPT }]

      if chunks.any?
        context = chunks.map.with_index(1) do |chunk, i|
          "[#{i}] #{chunk.content}"
        end.join("\n\n")

        messages << {
          role: "user",
          content: <<~MSG
            Use o contexto abaixo para responder à pergunta. Se o contexto não for suficiente, responda com seu conhecimento geral sobre a plataforma.

            CONTEXTO:
            #{context}

            PERGUNTA: #{question}
          MSG
        }
      else
        messages << { role: "user", content: question }
      end

      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: messages,
          max_tokens: MAX_TOKENS,
          temperature: 0.4
        }
      )

      {
        answer: response.dig("choices", 0, "message", "content")&.strip,
        used_context: chunks.any?,
        sources: chunks.map { |c| { source: c.source, source_id: c.source_id } }.uniq
      }
    rescue => e
      Rails.logger.error("[Chatbot::Responder] #{e.message}")
      { answer: "Desculpe, ocorreu um erro ao processar sua pergunta. Tente novamente.", used_context: false, sources: [] }
    end
  end
end
