class PagesController < ApplicationController
  def home
  end

  def services
    @services = Service.order(:category, :name)
  end

  def visiting
  end

  def about
  end
end
