# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :permit_params

      def ingest
        result = ::Operations::Api::V1::IngestExtract.new.call(permit_params.to_h)
        if result.success?
          render json: { status_text: 'ingested payload', status: 200, content_type: 'application/json',
                         extract_id: result.value!.id, ingestion_status: result.value!.status,
                         failures: result.value!.transaction_failure_count,
                         warnings: result.value!.transaction_warning_count }
        else
          failure_text = if result.failure.instance_of?(String)
                           result.failure
                         else
                           result.failure.errors.map do |_k, _v|
                             '#{k}: #{v}'
                           end
                         end
          transaction_failure_count
          render json: { status_text: 'Could not ingest payload', status: 400, content_type: 'application/json',
                         failures: failure_text }
        end
      end

      def index
        render json: Extract.all
      end

      private

      def permit_params
        params.permit!
      end
    end
  end
end
