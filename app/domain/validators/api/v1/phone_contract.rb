# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for PhoneContract.
      class PhoneContract < Dry::Validation::Contract
        params do
          required(:area_code).filled(:string)
          required(:number).filled(:string)
          optional(:extension).maybe(:string)
        end

        rule(:area_code) do
          key.failure(text: 'invalid area code with length not equal to 3 digits') if key && value && value.length != 3
        end

        rule(:number) do
          key.failure(text: 'invalid area code with length not equal to 7 digits') if key && value && value.length != 7
        end
      end
    end
  end
end
