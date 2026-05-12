class CollectionPointsController < ApplicationController
  allow_unauthenticated_access only: [:index, :create, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  def index
    points = CollectionPoint.publicly_visible.includes(:user, images_attachments: :blob)
    is_moderator = authenticated? && Current.user.moderator?
    render json: points.map { |p| p.as_map_json(moderator: is_moderator) }
  end

  def create
    point = CollectionPoint.new(collection_point_params)

    if authenticated?
      point.user = Current.user
      point.status = Current.user.moderator? ? :approved : :pending
    else
      point.status = :pending
    end

    if point.save
      render json: {
        message: "Seu ponto foi enviado para moderação!",
        point: point.as_map_json
      }, status: :created
    else
      render json: { error: point.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def destroy
    unless Current.user.moderator?
      render json: { error: "Acesso negado." }, status: :forbidden
      return
    end

    point = CollectionPoint.find(params[:id])
    point.destroy!
    render json: { message: "Ponto de coleta removido com sucesso." }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Ponto não encontrado." }, status: :not_found
  end

  private

  def collection_point_params
    params.require(:collection_point).permit(
      :title,
      :description,
      :address,
      :latitude,
      :longitude,
      :opening_hours,
      :contact_name,
      :contact_phone,
      :contact_email,
      categories: [],
      images: []
    )
  end
end
