class BikesController < ApplicationController
  before_action :set_bike, only: [ :show, :edit, :update, :destroy ]

  def index
    @bikes = Bike.by_serial_number.includes(:customer, :bike_model)
  end

  def show
  end

  # Opened from a customer's page, the owner comes already chosen.
  def new
    @bike = Bike.new(customer: Customer.find_by(id: params[:customer_id]))
  end

  def create
    @bike = Bike.new(bike_params)

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

  def set_bike
    @bike = Bike.includes(:customer, :bike_model, repairs: [ :bike, :customer, :rich_text_diagnosis, { photos_attachments: :blob } ]).find(params[:id])
  end

  def bike_params
    params.expect(bike: [ :serial_number, :bike_model_id, :customer_id ])
  end
end
