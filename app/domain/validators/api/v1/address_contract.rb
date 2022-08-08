# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for AddressContract.
      class AddressContract < Dry::Validation::Contract
        params do
          required(:address_line1).filled(:string)
          optional(:address_line1).maybe(:string)
          optional(:dc_ward).maybe(:string)
          required(:city).filled(:string)
          required(:state).filled(:string)
          required(:zip).filled(:string)
        end

        rule(:zip) do
          key.failure(text: 'invalid zip with length not equal to 5 digits') if key && value && value.length != 5
        end
      end
    end
  end
end
