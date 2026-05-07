class PagesController < ApplicationController
  allow_unauthenticated_access only: [:home, :map]

  def home
    redirect_to dashboard_path if authenticated?
  end

  def dashboard
    redirect_to new_session_path unless authenticated?
  end

  def map
  end
end
