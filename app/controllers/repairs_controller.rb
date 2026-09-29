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
    build_blank_lines
  end

  def create
    @repair = Repair.new(repair_params)

    if @repair.save
      redirect_to @repair, notice: "Repair ##{@repair.id} for bike #{@repair.bike.serial_number} was created."
    else
      build_blank_lines
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    build_blank_lines
  end

  def update
    if @repair.update(repair_params)
      redirect_to @repair, notice: "Repair ##{@repair.id} for bike #{@repair.bike.serial_number} was updated."
    else
      build_blank_lines
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
                            :finished_at, :collected_at,
                            repair_services_attributes: [ [ :id, :service_id, :charged_price, :_destroy ] ] ])
  end

  # The form works without JavaScript, so it offers spare empty lines: 3 on a new repair, 2 more on an
  # existing one (save and edit again for more). Called again after a refused save, because the
  # empty lines were skipped by then and the form would come back with fewer.
  def build_blank_lines
    wanted = @repair.new_record? ? 3 : 2
    blank = @repair.repair_services.to_a.count { |line| line.new_record? && line.service_id.blank? }
    (wanted - blank).times { @repair.repair_services.build }
  end
end
