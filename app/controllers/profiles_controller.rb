class ProfilesController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def show
    @available_posts = @user.posts.where(status: "available").recent
    @taken_posts = @user.posts.where(status: "taken").recent
  end

  def edit
  end

 def update
  if @user.update(user_params)
    if @user.saved_change_to_password_digest?
      @user.sessions.delete_all
      Current.session = nil
      cookies.delete(:session_id)

      redirect_to new_session_path, notice: "Perfil atualizado! Faça login novamente."
    else
      redirect_to profile_path, notice: "Perfil atualizado com sucesso!"
    end
  else
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
    @user.destroy
    terminate_session
    redirect_to root_path, notice: "Sua conta foi excluída com sucesso!"
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    permitted = params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :cpf, :telefone, :uf, :cidade)

        if permitted[:password].blank?
            permitted.delete(:password)
            permitted.delete(:password_confirmation)
        end

    permitted
    end
end
