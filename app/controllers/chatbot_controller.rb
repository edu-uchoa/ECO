class ChatbotController < ApplicationController
  allow_unauthenticated_access only: [:ask]
  skip_forgery_protection only: [:ask]

  def ask
    question = params[:question].to_s.strip

    if question.blank?
      render json: { error: "Pergunta não pode estar vazia." }, status: :unprocessable_entity
      return
    end

    if question.length > 1000
      render json: { error: "Pergunta muito longa." }, status: :unprocessable_entity
      return
    end

    retriever = Chatbot::Retriever.new
    responder = Chatbot::Responder.new

    chunks = retriever.retrieve(question)
    result = responder.answer(question: question, chunks: chunks)

    render json: {
      answer: result[:answer],
      used_context: result[:used_context],
      sources: result[:sources]
    }
  rescue => e
    Rails.logger.error("[ChatbotController] #{e.message}")
    render json: { error: "Erro interno. Tente novamente." }, status: :internal_server_error
  end
end
