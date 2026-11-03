class BikesController < ApplicationController
  before_action :set_bike, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize Bike
    @bikes = policy_scope(Bike).by_serial_number.includes(:customer, :bike_model)
  end

  # The bike's repairs follow the reader's scope, like every other list of repairs.
  def show
    @repairs = policy_scope(Repair).where(bike: @bike).newest_first
                                   .includes(:bike, :customer, taken_in_by: :mechanic)
                                   .with_attached_photos.with_rich_text_diagnosis
  end

  # Opened from a customer's page, the owner comes already chosen.
  def new
    @bike = authorize Bike.new(customer: policy_scope(Customer).find_by(id: params[:customer_id]))
  end

  def create
    @bike = authorize Bike.new
    @bike.assign_attributes(bike_params)

    if @bike.save
      redirect_to @bike, notice: "Bike #{@bike.serial_number} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @bike.update(bike_params)
      redirect_to @bike, notice: "Bike #{@bike.serial_number} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @bike.destroy
      redirect_to bikes_path, notice: "Bike #{@bike.serial_number} was deleted.", status: :see_other
    else
      redirect_to @bike, alert: "Bike #{@bike.serial_number} can't be deleted. #{@bike.errors.full_messages.to_sentence}",
                         status: :see_other
    end
  end

  private

  # Found and asked about before the action runs, so a refused request reads nothing and writes nothing.
  def set_bike
    @bike = authorize Bike.includes(:customer, :bike_model).find(params[:id])
  end

  def bike_params
    params.expect(bike: policy(@bike).permitted_attributes)
  end
end
