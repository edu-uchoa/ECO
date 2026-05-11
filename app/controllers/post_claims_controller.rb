class PostClaimsController < ApplicationController
  before_action :set_post
  before_action :set_claim, only: [:accept, :reject]
  before_action :authorize_owner!

  def accept
    if @post.status == "taken"
      redirect_to @post, alert: "Este item já foi doado."
      return
    end

    # Accept this claim and reject all others
    @claim.update!(status: "accepted")
    @post.post_claims.where.not(id: @claim.id).update_all(status: "rejected")
    @post.update!(status: "taken")

    # Notify the requester via chat
    notify_requester(@claim.user, "✅ Sua solicitação para \"#{@post.title}\" foi aceita! Entre em contato para combinar a entrega.")

    # Notify rejected requesters
    @post.post_claims.rejected.where.not(id: @claim.id).each do |rejected|
      notify_requester(rejected.user, "❌ Infelizmente sua solicitação para \"#{@post.title}\" não foi aceita desta vez.")
    end

    redirect_to @post, notice: "Solicitação aceita! O item foi marcado como doado."
  end

  def reject
    @claim.update!(status: "rejected")

    notify_requester(@claim.user, "❌ Infelizmente sua solicitação para \"#{@post.title}\" não foi aceita desta vez.")

    redirect_to @post, notice: "Solicitação recusada."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_claim
    @claim = @post.post_claims.find(params[:id])
  end

  def authorize_owner!
    unless @post.user == Current.user
      redirect_to @post, alert: "Acesso negado."
    end
  end

  def notify_requester(requester, message_text)
    conversation = PrivateConversation.between(requester, @post.user)
    if conversation.nil?
      conversation = PrivateConversation.create!(sender: requester, receiver: @post.user)
    end
    conversation.messages.create!(user: Current.user, content: message_text)
  end
end
