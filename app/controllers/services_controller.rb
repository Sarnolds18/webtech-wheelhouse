class ServicesController < ApplicationController
  # The wall list is public: anyone can read the list and a service's page. Creating, editing and
  # deleting a service need a session, and then the policy (only the owner).
  allow_unauthenticated_access only: [ :index, :show ]
  before_action :set_service, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize Service
    @services = policy_scope(Service).by_category_and_name
  end

  def show
  end

  def new
    @service = authorize Service.new
  end

  def create
    @service = authorize Service.new
    @service.assign_attributes(service_params)

    if @service.save
      redirect_to @service, notice: "Service #{@service.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to @service, notice: "Service #{@service.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @service.destroy
      redirect_to services_path, notice: "Service #{@service.name} was deleted.", status: :see_other
    else
      redirect_to @service, alert: "Service #{@service.name} can't be deleted. #{@service.errors.full_messages.to_sentence}",
                            status: :see_other
    end
  end

  private

  # Found and asked about before the action runs, so a refused request reads nothing and writes nothing.
  def set_service
    @service = authorize Service.find(params[:id])
  end

  def service_params
    params.expect(service: policy(@service).permitted_attributes)
  end
end
