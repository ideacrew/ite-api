# frozen_string_literal: true

require './app/models/types'
# require './app/domain/validators/api/v1/address_contract'
# require './app/domain/validators/api/v1/phone_contract'
# require './app/domain/validators/api/v1/email_contract'

module Validators
  module Api
    module V1
      # Contract for OfficeLocationContract.
      class OfficeLocationContract < Dry::Validation::Contract
        params do
          optional(:is_primary).maybe(:bool)
          required(:address).hash(Validators::Api::V1::AddressContract.params)
          required(:phones).array(Validators::Api::V1::PhoneContract.params)
          required(:emails).array(Validators::Api::V1::EmailContract.params)
        end
      end
    end
  end
end
