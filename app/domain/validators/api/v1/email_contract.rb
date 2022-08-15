# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for EmailContract.
      class EmailContract < Dry::Validation::Contract
        params do
          required(:address).filled(:string)
        end

        rule(:address) do
          key.failure(text: 'invalid email address') if key && value && !EmailValidator.valid?(value)
        end
      end
    end
  end
end
