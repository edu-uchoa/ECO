class ChatsController < ApplicationController
  before_action :require_authentication

  def index
    @chat_messages = ChatMessage.recent
    @chat_message = ChatMessage.new
  end

  def create
    @chat_message = Current.user.chat_messages.build(chat_message_params)

    if @chat_message.save
      redirect_to chats_path, notice: "Mensagem enviada com sucesso!"
    else
      @chat_messages = ChatMessage.recent
      render :index, status: :unprocessable_entity
    end
  end

  private

  def chat_message_params
    params.require(:chat_message).permit(:content)
  end
end
