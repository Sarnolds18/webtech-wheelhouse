module Api
  module V1
    # The wall list, open to anyone: the shop's website reads it from another origin. Adding a service
    # to it needs the token: the owner does it from a script.
    class ServicesController < BaseController
      before_action :require_token, only: :create

      def index
        services = Service.by_category_and_name.preload(:repair_services)
        render json: services.map { |service| service_document(service) }
      end

      def show
        render json: service_document(Service.preload(:repair_services).find(params[:id]))
      end

      def create
        service = Service.new(service_params)

        if service.save
          render json: service_document(service), status: :created, location: api_v1_service_url(service)
        else
          render_errors service.errors.full_messages, :unprocessable_entity
        end
      end

      private

      # The body is { "service": { ... } }, or the attributes alone, which Rails wraps under "service".
      # Anything not on this list is dropped; a body with none of them raises ParameterMissing (400).
      def service_params
        params.expect(service: [ :name, :price, :category ])
      end

      # One shape for every action, so a client parses one document. times_charged counts the repairs
      # the service was charged on, from the lines already loaded.
      def service_document(service)
        {
          id: service.id,
          name: service.name,
          price: money(service.price),
          category: service.category,
          times_charged: service.repair_services.map(&:repair_id).uniq.size
        }
      end
    end
  end
end
