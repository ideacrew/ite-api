# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      before_action :authenticate!
      before_action :permit_params

      def show
        authorize Extract
        @extract = ::Api::V1::Extract.find(params[:id])

        if @extract && (current_user.dbh_user? || (current_user.provider_id == @extract.provider_id.to_s))
          render json: @extract.attributes.merge(records: @extract.records&.map(&:attributes), provider_name: @extract.provider_name)
        else
          render json: { status_text: 'Could not find extract', status: 400, content_type: 'application/json' }
        end
      end

      def ingest
        authorize Extract
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
        authorize Extract, :show?
        begin
          extracts = if current_user.dbh_user?
                       ::Api::V1::Extract.all.limit(10)
                     else
                       ::Api::V1::Extract.where(provider_id: current_user.provider_id).limit(10)
                     end
          render json: extracts&.map(&:list_view)
        rescue StandardError => e
          puts "error in extracts index controller: #{e}"
        end
      end

      private

      def permit_params
        params.permit!
      end
    end
  end
end
