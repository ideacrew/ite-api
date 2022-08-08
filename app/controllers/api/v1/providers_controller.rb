# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ProvidersController < ApplicationController
      before_action :permit_params

      def index
        Provider.all
      end

      def create
        _result = ::Operations::Api::V1::CreateProvider.new.call(permit_params.to_h)
        # if result.success?
        #   render json: { status_text: 'ingested payload', status: 200, content_type: 'application/json',
        #                  extract_id: result.value!.id, ingestion_status: result.value!.status,
        #                  failures: result.value!.failed_record_count,
        #                  warnings: result.value!.warned_record_count }
        # else
        #   failure_text = if result.failure.instance_of?(String)
        #                    result.failure
        #                  else
        #                    result.failure.errors.map do |_k, _v|
        #                      "#{k}: #{v}"
        #                    end
        #                  end
        #   render json: { status_text: 'Could not ingest payload', status: 400, content_type: 'application/json',
        #                  failures: failure_text }
        # end

        # provider_params = permit_params.to_h.deep_symbolize_keys
        # provider = Provider.new(provider_params)
        # provider.save
      end

      def update
        # WIP
      end

      private

      def permit_params
        params.permit!.except(:controller, :action, :provider)
      end
    end
  end
end
