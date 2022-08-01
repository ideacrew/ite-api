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
        provider_params = permit_params.to_h.deep_symbolize_keys
        provider = Provider.new(provider_params)
        provider.save
      end

      def update
        # WIP
      end

      private

      def permit_params
        params[:provider].permit!
      end
    end
  end
end
