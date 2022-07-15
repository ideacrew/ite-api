# frozen_string_literal: true

module Api
  module V1
    # Accepts and processes requests
    class ExtractsController < ApplicationController
      def ingest
        p "got here!"
        render inline: "got payload", status: 200, content_type: "application/json"
      end

      def index

      end

      private

    end
  end
end