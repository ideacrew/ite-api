# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :permit_params

      def show
        @extract = Api::V1::Extract.find(params[:id])

        render json: @extract if @extract
      end

      def ingest
        result = ::Operations::Api::V1::IngestExtract.new.call(permit_params.to_h)
        if result.success?
          render json: { status_text: 'ingested payload', status: 200, content_type: 'application/json',
                         extract_id: result.value!.id, ingestion_status: result.value!.status,
                         failures: result.value!.failed_record_count,
                         warnings: result.value!.warned_record_count }
        else
          failure_text = if result.failure.instance_of?(String)
                           result.failure
                         else
                           result.failure.errors.map do |_k, _v|
                             "#{k}: #{v}"
                           end
                         end
          render json: { status_text: 'Could not ingest payload', status: 400, content_type: 'application/json',
                         failures: failure_text }
        end
      end

      def index
        extracts = Api::V1::Extract.all
        render json: extracts.order(&:created_at).reverse.map(&:list_view)
      end

      private

      def permit_params
        params.permit!
      end
    end
  end
end
