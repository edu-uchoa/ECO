class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create show]
  # Optional: protect against mass signup abuse
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to signup_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to new_session_path, notice: "Account created. Please sign in."
    else
      flash.now[:alert] = "Please fix the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    @available_posts = @user.posts.where(status: "available").recent
    @taken_posts = @user.posts.where(status: "taken").recent
  end

  private

  def user_params
    # Your sign-in uses :email_address, so permit the same attribute
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end