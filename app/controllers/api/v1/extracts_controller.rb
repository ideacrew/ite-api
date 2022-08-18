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
                      ::Api::V1::Provider.all.select { |p| p.extracts.pluck(:id.to_s).any? BSON::ObjectId.from_string(params[:id]) }
                    end
        @extract = providers.first.extracts.includes(:records).find(params[:id])
        render json: @extract.attributes.merge(records: @extract.records&.map(&:attributes)) if @extract
      end

      def ingest
        result = ::Operations::Api::V1::IngestExtract.new.call(permit_params.to_h)
        if result.success?
          render json: { status_text: 'ingested payload', status: 200, content_type: 'application/json',
                         extract_id: result.value!.id, ingestion_status: result.value!.status,
                         pass_count: result.value!.pass_count,
                         fail_count: result.value!.fail_count,
                         critical_errors: result.value!.record_critical_errors_count,
                         fatal_errors: result.value!.record_fatal_errors_count,
                         warnings: result.value!.record_warning_count }
        else
          render json: { status_text: 'Could not ingest payload', status: 400, content_type: 'application/json',
                         failures: result.failure }
        end
      end

      def index
        # will need to adjust this logic so only if an admin see all extracts
        provider = ::Api::V1::Provider.where(provider_gateway_identifier: params[:provider_gateway_identifier].to_i).first
        extracts = provider.present? ? provider.extracts : ::Api::V1::Provider.all.map(&:extracts).flatten
        render json: extracts&.sort_by(&:created_at)&.reverse&.map(&:list_view)
      end

      private

      def permit_params
        params.permit!
      end
    end
  end
end
