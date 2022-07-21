# frozen_string_literal: true

require './app/models/types'

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
          required(:transaction_group).filled(::Types::TransactionGroups)
        end

        rule(:coverage_start) do
          if key && value && value > Date.today
            key.failure(text: 'invalid coverage start date - Date should be today or in the past.',
                        error_level: 'failure')
          end
        end

        rule(:coverage_end) do
          if key && value && value > Date.today
            key.failure(text: 'invalid coverage end date - Date should be today or in the past.',
                        error_level: 'failure')
          end
        end

        rule(:coverage_end, :coverage_start) do
          if key && value && value > Date.today
            key.failure(text: 'invalid coverage end date - Date should be today or in the past.',
                        error_level: 'failure')
          end
        end

        rule(:coverage_start, :coverage_end) do
          if key && values[:coverage_start] && values[:coverage_end] && values[:coverage_end] < values[:coverage_start]
            key.failure(text: 'invalid coverage dates - coverage end date should be later than start date.',
                        error_level: 'failure')
          end
        end

        rule(:extracted_on) do
          if key && value && value > Date.today
            key.failure(text: 'invalid extraction date - Date should be today or in the past.', error_level: 'failure')
          end
        end
      end
    end
  end
end
