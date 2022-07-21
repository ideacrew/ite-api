# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :permit_params

      def ingest
        result = ::Operations::Api::V1::IngestExtract.new.call(permit_params)

        if result.success?
          render json: { status_text: 'ingested payload', status: 200, content_type: 'application/json',
                         extract_id: result.value!.id }
        else
          render json: { status_text: 'Could not ingested payload', status: 400, content_type: 'application/json',
                         failures: result }
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
