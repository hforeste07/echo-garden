# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @gardens = current_user.gardens
    @favorite_garden = current_user.gardens.find_by(favorite: true) || current_user.gardens.first
  end
end
