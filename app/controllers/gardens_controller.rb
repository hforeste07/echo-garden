class GardensController < ApplicationController
  before_action :authenticate_user!
  before_action :set_garden, only: [:show]

  def index
    @gardens = current_user.gardens
  end

  def new
    @garden = current_user.gardens.new
  end

  def create
    @garden = current_user.gardens.new(garden_params) 
    if @garden.save
      redirect_to @garden, notice: "Garden created successfully."
    else
      render :new, alert: @garden.errors.full_messages.join(", ")
    end
  end

  def show
    # @garden is already set by set_garden
  end

  def update
    @garden = current_user.gardens.find(params[:id])
    plant_id = params[:garden_plot][:plant_id]

    if @garden.update(garden_params.merge(plant_id: plant_id))
      redirect_to @garden, notice: "Garden updated successfully."
    else
      render :show, alert: @garden.errors.full_messages.join(", ")
    end
  end

  def search
    respond_to do |format|
      format.turbo_stream
    end
  end


  private

  def set_garden
    @garden = current_user.gardens.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "Garden not found."
  end

  def garden_params
    params.require(:garden).permit(:name, :rows, :columns)
  end
end
