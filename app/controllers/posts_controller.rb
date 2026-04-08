class PostsController < ApplicationController
  allow_unauthenticated_access only: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :require_authentication, only: [:show, :new, :create, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @posts = Post.recent
    @posts = @posts.by_category(params[:category]) if params[:category].present?
    @posts = @posts.by_location(params[:location]) if params[:location].present?
  end

  def show
  end

  def new
    @post = Current.user.posts.build
  end

  def create
    @post = Current.user.posts.build(post_params)

    if @post.save
      redirect_to dashboard_path, notice: "Post criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to dashboard_path, notice: "Post deletado com sucesso!"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to root_path, alert: "Não autorizado" unless @post.user == Current.user
  end

  def post_params
    params.require(:post).permit(:title, :description, :category, :location, :condition, images: [])
  end
end
