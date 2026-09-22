class MechanicsController < ApplicationController
  def index
    @mechanics = Mechanic.by_name
  end

  def show
    @mechanic = Mechanic.includes(:repairs).find(params[:id])
  end
end
