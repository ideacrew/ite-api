# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :permit_params

      def show
        # will need to adjust this logic so only if an admin see all extracts

        providers = if params[:provider_gateway_identifier]
                      ::Api::V1::Provider.where(provider_gateway_identifier: params[:provider_gateway_identifier].to_i)
                    else
                      ::Api::V1::Provider.where(extracts: { :$elemMatch => { _id: BSON::ObjectId.from_string(params[:id]) } })
                    end
        @extract = providers.first.extracts.find(params[:id])

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
        # will need to adjust this logic so only if an admin see all extracts
        provider = ::Api::V1::Provider.where(provider_gateway_identifier: params[:provider_gateway_identifier].to_i).first
        extracts = provider.present? ? provider.extracts : ::Api::V1::Provider.all.map(&:extracts).flatten
        render json: extracts.sort(&:created_at).reverse.map(&:list_view)
      end

      private

      def permit_params
        params.permit!
      end
    end
  end
end
