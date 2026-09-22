class ServicesController < ApplicationController
  def index
    @services = Service.order(:category, :name)
  end

  def show
    @service = Service.find(params[:id])
  end
end
