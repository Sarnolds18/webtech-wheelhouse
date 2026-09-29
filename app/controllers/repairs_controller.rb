class RepairsController < ApplicationController
  before_action :set_repair, only: [ :show, :edit, :update, :destroy ]

  def index
    @repairs = Repair.newest_first.includes(:bike, :customer)
  end

  def show
  end

  # Opened from a bike's page, the bike comes already chosen.
  def new
    @repair = Repair.new(bike: Bike.find_by(id: params[:bike_id]), received_at: Time.current)
  end

  def create
    @repair = Repair.new(repair_params)

    if @repair.save
      redirect_to @repair, notice: "Repair ##{@repair.id} for bike #{@repair.bike.serial_number} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @repair.update(repair_params)
      redirect_to @repair, notice: "Repair ##{@repair.id} for bike #{@repair.bike.serial_number} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @repair.destroy
      redirect_to repairs_path, notice: "Repair ##{@repair.id} for bike #{@repair.bike.serial_number} was deleted.",
                                status: :see_other
    else
      redirect_to @repair, alert: "Repair ##{@repair.id} can't be deleted. #{@repair.errors.full_messages.to_sentence}",
                           status: :see_other
    end
  end

  private

  def set_repair
    @repair = Repair.includes(:bike, :customer, :mechanic, repair_services: :service, invoices: []).find(params[:id])
  end

  def repair_params
    params.expect(repair: [ :bike_id, :mechanic_id, :state, :received_at, :promised_on,
                            :quoted_at, :quoted_amount, :quote_response, :responded_at,
                            :finished_at, :collected_at ])
  end
end
