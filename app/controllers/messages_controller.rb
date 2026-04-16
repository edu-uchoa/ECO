class MessagesController < ApplicationController
  def create
    @conversation = PrivateConversation.find(params[:private_conversation_id])

    unless [@conversation.sender, @conversation.receiver].include?(Current.user)
      redirect_to root_path, alert: "Acesso negado."
      return
    end

    @message = @conversation.messages.build(message_params)
    @message.user = Current.user

    if @message.save
      @conversation.touch # update timestamp for ordering
      redirect_to @conversation
    else
      @messages = @conversation.messages.includes(:user)
      render "private_conversations/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
