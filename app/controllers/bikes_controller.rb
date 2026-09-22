class BikesController < ApplicationController
  def index
    @bikes = Bike.by_serial_number
  end

  def show
    @bike = Bike.find(params[:id])
  end
end
