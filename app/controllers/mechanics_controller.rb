class MechanicsController < ApplicationController
  before_action :set_mechanic, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize Mechanic
    @mechanics = policy_scope(Mechanic).by_name
  end

  # The repairs assigned to this member of the staff, as far as the reader may read them: a mechanic
  # looking at a colleague's page sees none of the colleague's repairs.
  def show
    @repairs = policy_scope(Repair).where(mechanic: @mechanic).newest_first
                                   .includes(:bike, :customer, taken_in_by: :mechanic)
                                   .with_attached_photos.with_rich_text_diagnosis
  end

  def new
    @mechanic = authorize Mechanic.new
  end

  def create
    @mechanic = authorize Mechanic.new
    @mechanic.assign_attributes(mechanic_params)

    if @mechanic.save
      redirect_to @mechanic, notice: "Staff member #{@mechanic.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @mechanic.update(mechanic_params)
      redirect_to @mechanic, notice: "Staff member #{@mechanic.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @mechanic.destroy
      redirect_to mechanics_path, notice: "Staff member #{@mechanic.name} was deleted.", status: :see_other
    else
      redirect_to @mechanic, alert: "Staff member #{@mechanic.name} can't be deleted. #{@mechanic.errors.full_messages.to_sentence}",
                             status: :see_other
    end
  end

  private

  # Found and asked about before the action runs, so a refused request reads nothing and writes nothing.
  def set_mechanic
    @mechanic = authorize Mechanic.find(params[:id])
  end

  def mechanic_params
    params.expect(mechanic: policy(@mechanic).permitted_attributes)
  end
end
