class PrivateConversationsController < ApplicationController
  before_action :set_conversation, only: [:show]

  def index
    @conversations = Current.user.conversations.includes(:sender, :receiver, :messages).order(updated_at: :desc)
  end

  def create
    user = User.find(params[:user_id])

    if user == Current.user
      redirect_back fallback_location: root_path, alert: "Você não pode conversar consigo mesmo."
      return
    end

    @conversation = PrivateConversation.between(Current.user, user)

    if @conversation.nil?
      @conversation = PrivateConversation.create!(
        sender: Current.user,
        receiver: user
      )
    end

    redirect_to @conversation
  end

  def show
    unless [@conversation.sender, @conversation.receiver].include?(Current.user)
      redirect_to root_path, alert: "Acesso negado."
      return
    end

    @messages = @conversation.messages.includes(:user)
    @message = Message.new
  end

  private

  def set_conversation
    @conversation = PrivateConversation.find(params[:id])
  end
end
