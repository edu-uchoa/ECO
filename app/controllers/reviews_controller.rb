class ReviewsController < ApplicationController
  before_action :set_post

  def create
    if @post.review.present?
      redirect_to @post, alert: "Este item já foi avaliado."
      return
    end

    if @post.user == Current.user
      redirect_to @post, alert: "Você não pode avaliar seu próprio item."
      return
    end

    if @post.status != "taken"
      redirect_to @post, alert: "Só é possível avaliar itens já doados."
      return
    end

    @review = @post.build_review(review_params)
    @review.user = Current.user

    if @review.save
      redirect_to user_path(@post.user), notice: "Avaliação enviada com sucesso!"
    else
      redirect_to @post, alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    @review = @post.review

    unless @review && (@post.user == Current.user || @review.user == Current.user)
      redirect_to @post, alert: "Não autorizado."
      return
    end

    @review.destroy
    redirect_back fallback_location: @post, notice: "Avaliação removida."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
