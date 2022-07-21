# frozen_string_literal: true

module Validators
  module Api
    module V1
      # Contract for ExtractContract.
      class ExtractContract < Dry::Validation::Contract
        params do
          required(:provider_identifier).filled(:string)
          optional(:npi).maybe(:string)
          optional(:coverage_start).maybe(:date)
          optional(:coverage_end).maybe(:date)
          optional(:extracted_on).maybe(:date)
          optional(:file_name).maybe(:string)
          optional(:file_type).maybe(:string)
          optional(:transaction_group).maybe(:string)
        end
      end
    end
  end
end
