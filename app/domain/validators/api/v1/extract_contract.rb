# frozen_string_literal: true

module Validators
  module Api
    module V1
      # Contract for ExtractContract.
      class ExtractContract < Dry::Validation::Contract
        params do
          required(:provider_gateway_identifier).filled(:string)
          required(:coverage_start).filled(:date)
          required(:coverage_end).filled(:date)
          required(:extracted_on).filled(:date)
          optional(:file_name).maybe(:string)
          required(:file_type).filled(:string)
          required(:transaction_group).filled(:string)
        end
      end
    end
  end
end
