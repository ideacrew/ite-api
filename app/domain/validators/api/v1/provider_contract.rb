# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for ProviderContract.
      class ProviderContract < Dry::Validation::Contract
        params do
          required(:provider_name).filled(:string)
          optional(:provider_nick_name).maybe(:string)
          required(:npi).filled(:string)
          required(:is_active).filled(:bool)
          required(:mh).filled(:bool)
          required(:sud).filled(:bool)
          required(:adult_care).filled(:bool)
          required(:child_care).filled(:bool)
          required(:office_locations).array(::Validators::Api::V1::OfficeLocationContract.params)
        end

        rule(:npi) do
          key.failure(text: 'invalid npi with length not equal to 10 digits') if key && value && value.length != 10
        end
      end
    end
  end
end
