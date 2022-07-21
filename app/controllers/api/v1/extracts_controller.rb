# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :permit_params

      def ingest
        payload = permit_params.to_h.deep_symbolize_keys

        payload[:extract].merge(payload: payload[:extract])
        # result =
        # result = Contracts::ExtractContract.new.call(payload)

        #  if result.success?
        #    Success(result.to_h)
        #  else
        #    Failure(result)
        #  end
        extract = Extract.new(payload[:extract])
        extract.save
        render json: { status_text: 'ingested payload', status: 200, content_type: 'application/json', payload: payload}
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
