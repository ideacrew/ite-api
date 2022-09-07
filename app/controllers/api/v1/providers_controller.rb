# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes providers
    class ProvidersController < ApplicationController
      before_action :authenticate!
      before_action :permit_params

      def index
        authorize Provider, :show_dbh?
        providers = Api::V1::Provider.all
        render json: providers
      end

      def create
        authorize Provider, :show_dbh?
        result = ::Operations::Api::V1::CreateProvider.new.call(permit_params.to_h)
        if result.success?
          render json: { status_text: 'created provider', status: 200, content_type: 'application/json',
                         provider_id: result.value!.id, provider_gateway_id: result.value!.provider_gateway_identifier }
        else
          failure_text = if result.failure.instance_of?(String)
                           result.failure
                         else
                           result.failure.errors.map do |_k, _v|
                             "#{k}: #{v}"
                           end
                         end
          render json: { status_text: 'Could not create provider', status: 400, content_type: 'application/json',
                         failures: failure_text }
        end
      end

      def update
        # WIP
      end

      def show
        authorize Provider, :show?
        @provider = if current_user.dbh_user?
                      Api::V1::Provider.find(params[:id])
                    else
                      Api::V1::Provider.find(current_user.provider_id)
                    end

        render json: @provider.attributes.to_h.except('extracts') if @provider
      end

      def submission_summary
        authorize Provider, :show_dbh?

        provider = Api::V1::Provider.find(permit_params[:id])
        extract = provider.extracts.last
        records = extract.records
        render json: { provider_name: provider.provider_name, status: provider.submission_status, submitted_on: extract.created_at,
                       total_records: records.count, pass: records.where(status: 'Pass').count, fail: records.where(status: 'Fail').count }
      rescue StandardError => e
        render json: { status_text: 'Could not get the submission status', status: 400, failure: e.message }
      end

      private

      def permit_params
        params.permit!.except(:controller, :action, :provider)
      end
    end
  end
end
