module Api
  module V1
    # The wall list, open to anyone: the shop's website reads it from another origin.
    class ServicesController < BaseController
      def index
        services = Service.by_category_and_name.preload(:repair_services)
        render json: services.map { |service| service_document(service) }
      end

      def show
        render json: service_document(Service.preload(:repair_services).find(params[:id]))
      end

      private

      # One shape for every action, so a client parses one document. The price travels as a string with
      # its two decimals, the exact value of the column (docs/api.md); a JSON number would be a float.
      # times_charged counts the repairs the service was charged on, from the lines already loaded.
      def service_document(service)
        {
          id: service.id,
          name: service.name,
          price: ActiveSupport::NumberHelper.number_to_rounded(service.price, precision: 2),
          category: service.category,
          times_charged: service.repair_services.map(&:repair_id).uniq.size
        }
      end
    end
  end
end
