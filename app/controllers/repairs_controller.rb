class RepairsController < ApplicationController
  def index
    @repairs = Repair.order(received_at: :desc)
  end

  def show
    @repair = Repair.find(params[:id])
  end
end
