module Api
  module V1
    # The repairs, for the shop's accounting program. Private: every action needs the token.
    class RepairsController < BaseController
      before_action :require_token

      # GET /api/v1/repairs?state=… answers only the repairs in that state. The states are the
      # enum's, so a new state needs no change here.
      def index
        repairs = repairs_with_their_documents

        if params.key?(:state)
          unless Repair.states.key?(params[:state])
            raise BadRequest, "State must be one of: #{Repair.states.keys.join(', ')}"
          end

          repairs = repairs.where(state: params[:state])
        end

        render json: repairs.map { |repair| repair_document(repair) }
      end

      def show
        render json: repair_document(repairs_with_their_documents.find(params[:id]))
      end

      private

      # Everything the document reads, loaded up front: the count of queries does not grow with the
      # number of repairs or lines.
      def repairs_with_their_documents
        Repair.newest_first.includes(:customer, bike: :bike_model, repair_services: :service)
      end

      # What the accounting program needs, and nothing else (docs/api.md): no foreign key, no phone, no
      # mechanic, no diagnosis, no photos. The total is summed from the lines already loaded, not with
      # Repair#total, which would ask the database once per repair.
      def repair_document(repair)
        lines = repair.repair_services

        {
          id: repair.id,
          state: repair.state,
          received_on: repair.received_at.to_date,
          promised_on: repair.promised_on,
          collected_on: repair.collected_at&.to_date,
          bike: {
            brand: repair.bike.bike_model.brand,
            model: repair.bike.bike_model.name,
            serial_number: repair.bike.serial_number
          },
          customer: { name: repair.customer.name },
          lines: lines.map { |line| { service: line.service.name, charged_price: money(line.charged_price) } },
          total: money(lines.map(&:charged_price).sum),
          overdue: repair.overdue?,
          quote_response: repair.quote_response
        }
      end
    end
  end
end
