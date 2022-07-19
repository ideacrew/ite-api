# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :permit_params

      def ingest
        payload = permit_params.to_h.deep_symbolize_keys
        payload.merge(payload: payload)
        extract = Extract.new(payload)
        extract.save
        render json: {status_text: "ingested payload", status: 200, content_type: "application/json", payload: payload}
      end

      def index
        render json: Extract.all
      end

      private

      def permit_params
        params[:extract].permit!
      end
    end
  end
end