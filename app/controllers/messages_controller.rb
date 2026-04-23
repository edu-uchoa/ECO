class MessagesController < ApplicationController
  before_action :set_conversation_and_message, only: [:accept_claim, :reject_claim]

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

  def accept_claim
    unless @message.claim_message? && @message.post.user == Current.user
      redirect_to @conversation, alert: "Ação não permitida."
      return
    end

    post = @message.post
    post.update!(status: "taken")

    @conversation.messages.create!(
      user: Current.user,
      content: "✅ Doação aceita! Combinamos a entrega de \"#{post.title}\"."
    )

    redirect_to @conversation, notice: "Doação aceita! O item foi marcado como doado."
  end

  def reject_claim
    unless @message.claim_message? && @message.post.user == Current.user
      redirect_to @conversation, alert: "Ação não permitida."
      return
    end

    post_title = @message.post.title
    @conversation.messages.create!(
      user: Current.user,
      content: "❌ Infelizmente não posso aceitar seu pedido pelo item \"#{post_title}\" no momento."
    )

    redirect_to @conversation, notice: "Pedido recusado."
  end

  private

  def set_conversation_and_message
    @conversation = PrivateConversation.find(params[:private_conversation_id])
    @message = @conversation.messages.find(params[:id])

    unless [@conversation.sender, @conversation.receiver].include?(Current.user)
      redirect_to root_path, alert: "Acesso negado."
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
