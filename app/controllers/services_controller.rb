class ServicesController < ApplicationController
  def index
    @services = Service.by_category_and_name
  end

  def show
    @service = Service.find(params[:id])
  end
end
