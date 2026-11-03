class PagesController < ApplicationController
  def home
    authorize :page, :home?
  end

  def visiting
    authorize :page, :visiting?
  end

  def about
    authorize :page, :about?
  end
end
