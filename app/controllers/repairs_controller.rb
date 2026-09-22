class RepairsController < ApplicationController
  def index
    @repairs = Repair.newest_first.includes(:bike, :customer)
  end

  def show
    @repair = Repair.includes(:bike, :customer, :mechanic, repair_services: :service, invoices: []).find(params[:id])
  end
end
