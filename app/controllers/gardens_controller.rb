class GardensController < ApplicationController
  before_action :authenticate_user!
  before_action :set_garden, only: [:show]

  def index
    @gardens = current_user.gardens
  end

  def show
    # @garden is already set by set_garden
  end

  private

  def set_garden
    @garden = current_user.gardens.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "Garden not found."
  end
end
