# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :permit_params

      def ingest
        payload = params.to_h.deep_symbolize_keys
        extract = Extract.new(payload: payload, provider_identifier: payload[:provider_identifier], extract_type: payload[:extract_type])
        extract.save
        render json: { response_text: "got payload", status: 200 }
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