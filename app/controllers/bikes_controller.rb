class BikesController < ApplicationController
  def index
    @bikes = Bike.by_serial_number.includes(:customer, :bike_model)
  end

  def show
    @bike = Bike.includes(:customer, :bike_model, :repairs).find(params[:id])
  end
end
