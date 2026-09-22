class RepairsController < ApplicationController
  def index
    @repairs = Repair.newest_first
  end

  def show
    @repair = Repair.find(params[:id])
  end
end
