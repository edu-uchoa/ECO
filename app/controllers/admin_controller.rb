class AdminController < ApplicationController
  # CONTROLLER TEMPORÁRIO — remover após uso
  allow_unauthenticated_access only: [:set_moderator]

  def set_moderator
    secret = ENV["ADMIN_SECRET_TOKEN"].presence

    if secret.nil? || params[:token] != secret
      return render plain: "403 Forbidden", status: :forbidden
    end

    user = User.find_by(email_address: params[:email])

    if user.nil?
      return render plain: "Usuário não encontrado: #{params[:email]}", status: :not_found
    end

    user.update!(role: :moderator)
    render plain: "OK: #{user.email_address} agora é moderator."
  end
end
