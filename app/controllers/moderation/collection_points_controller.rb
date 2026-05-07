class Moderation::CollectionPointsController < ApplicationController
  before_action :require_moderation_access!
  before_action :set_collection_point, only: [:approve, :reject]

  def index
    @pending_points = CollectionPoint.pending_review.includes(:user)
    @recently_moderated = CollectionPoint.where(status: %w[approved rejected]).includes(:user).order(updated_at: :desc).limit(20)
    @moderation_logs = ModerationLog.includes(:collection_point, :moderator).order(created_at: :desc).limit(50)
  end

  def approve
    unless @collection_point.pending?
      redirect_to moderation_collection_points_path, alert: "Apenas itens pendentes podem ser aprovados."
      return
    end

    @collection_point.approve!(Current.user)
    redirect_to moderation_collection_points_path, notice: "Ponto aprovado com sucesso."
  end

  def reject
    unless @collection_point.pending?
      redirect_to moderation_collection_points_path, alert: "Apenas itens pendentes podem ser rejeitados."
      return
    end

    reason = params[:rejection_reason].to_s.strip

    if reason.blank?
      redirect_to moderation_collection_points_path, alert: "Informe o motivo da rejeição."
      return
    end

    @collection_point.reject!(Current.user, reason)
    redirect_to moderation_collection_points_path, notice: "Ponto rejeitado com sucesso."
  end

  private

  def require_moderation_access!
    return if Current.user&.moderator?

    redirect_to root_path, alert: "Você não tem permissão para acessar a moderação."
  end

  def set_collection_point
    @collection_point = CollectionPoint.find(params[:id])
  end
end
