class PagesController < ApplicationController
  allow_unauthenticated_access only: [:home, :map]

  def home
    redirect_to dashboard_path if authenticated?
  end

  def dashboard
    redirect_to new_session_path unless authenticated?
  end

  def map
    return unless authenticated?

    @my_collection_points = Current.user.collection_points.order(created_at: :desc).limit(10)
  end
end
