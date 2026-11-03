class RepairsController < ApplicationController
  before_action :set_repair, only: [ :show, :edit, :update, :destroy ]

  # Built from the reader's scope, with the filters and the order chained on it: a mechanic who filters
  # by state or asks for the overdue ones still sees only their own repairs.
  def index
    authorize Repair
    @state = params[:state].presence_in(Repair.states.keys)
    @overdue = params[:overdue] == "1"

    @repairs = policy_scope(Repair).newest_first
    @repairs = @repairs.where(state: @state) if @state
    @repairs = @repairs.overdue if @overdue
    @repairs = @repairs.includes(:bike, :customer, taken_in_by: :mechanic).with_attached_photos.with_rich_text_diagnosis
  end

  def show
  end

  # Opened from a bike's page, the bike comes already chosen.
  def new
    @repair = authorize Repair.new(bike: policy_scope(Bike).find_by(id: params[:bike_id]), received_at: Time.current)
    build_blank_lines
  end

  def create
    @repair = authorize Repair.new
    assign_repair_params
    # From the session, never from the form: whoever is signed in took the repair in.
    @repair.taken_in_by = Current.user

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
    assign_repair_params

    if @repair.save
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

  # Found and asked about before the action runs, so a refused request reads nothing and writes nothing.
  # The policy is asked about the repair as it is stored: a repair already handed back is refused to
  # the counter even if the form sends another state.
  def set_repair
    @repair = authorize Repair.includes(:bike, :customer, :mechanic, { taken_in_by: :mechanic }, repair_services: :service, invoices: [])
                    .with_attached_photos.with_rich_text_diagnosis_and_embeds.find(params[:id])
  end

  # The fields come from the policy, according to who asks: a mechanic's list has only the state, the
  # diagnosis and new photos, so a mechanic_id or a charged price sent by hand is dropped like any field
  # outside the list. The account that took the repair in is never among them.
  def repair_params
    params.expect(repair: policy(@repair).permitted_attributes)
  end

  # Photos chosen in the form are added to the ones the repair already has. Assigning them as an
  # attribute would replace them all, and an empty file field would remove them all.
  def assign_repair_params
    @repair.assign_attributes(repair_params.except(:photos))
    new_photos = Array(repair_params[:photos]).compact_blank
    @repair.photos.attach(new_photos) if new_photos.any?
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
