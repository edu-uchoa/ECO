class CollectionPointsController < ApplicationController
  allow_unauthenticated_access only: [:index]
  skip_forgery_protection only: [:create]

  def index
    points = CollectionPoint.includes(:user).all
    render json: points.map(&:as_map_json)
  end

  def create
    unless Current.user.profile_complete?
      render json: { error: "Você precisa completar seu perfil antes de adicionar um ponto de coleta." }, status: :forbidden
      return
    end

    point = Current.user.collection_points.build(collection_point_params)

    if point.save
      render json: point.as_map_json, status: :created
    else
      render json: { error: point.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def collection_point_params
    params.require(:collection_point).permit(:name, :latitude, :longitude)
  end
end
