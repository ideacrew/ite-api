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
          required(:record_group).filled(::Types::RecordGroups)
        end

        rule(:coverage_start) do
          key.failure(text: 'invalid coverage start date - Date should be today or in the past.') if key && value && value > Date.today
        end

        rule(:coverage_end) do
          key.failure(text: 'invalid coverage end date - Date should be today or in the past.') if key && value && value > Date.today
        end

        rule(:coverage_end, :coverage_start) do
          if key && (values[:coverage_start] && values[:coverage_end]) &&
             ((values[:coverage_end] - values[:coverage_start]) > 365)
            key.failure(text: 'invalid coverage end date - Date should be within 12 months of start date.')
          end
        end

        rule(:coverage_start, :coverage_end) do
          if key && (values[:coverage_start] && values[:coverage_end]) &&
             (values[:coverage_end] < values[:coverage_start])
            key.failure(text: 'invalid coverage dates - coverage end date should be later than start date.')
          end
        end

        rule(:extracted_on) do
          key.failure(text: 'invalid extraction date - Date should be today or in the past.') if key && value && value > Date.today
        end
      end
    end
  end
end
