class CollectionPointsController < ApplicationController
  allow_unauthenticated_access only: [:index]
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? || request.content_type&.include?("multipart/form-data") }

  def index
    points = CollectionPoint.publicly_visible.includes(:user, images_attachments: :blob)
    is_moderator = authenticated? && Current.user.moderator?
    render json: points.map { |p| p.as_map_json(moderator: is_moderator) }
  end

  def create
    unless Current.user.profile_complete?
      render json: { error: "Você precisa completar seu perfil antes de adicionar um ponto de coleta." }, status: :forbidden
      return
    end

    point = Current.user.collection_points.build(collection_point_params)
    point.status = Current.user.moderator? ? :approved : :pending

    if point.save
      render json: {
        message: point.pending? ? "Seu item está em análise." : "Item aprovado e publicado com sucesso.",
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
