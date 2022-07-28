# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class ClientContract < Dry::Validation::Contract
        params do
          required(:client_id).filled(:string)
          required(:first_name).filled(:string)
          optional(:middle_name).maybe(:string)
          required(:last_name).filled(:string)
          optional(:alt_first_name).maybe(:string)
          optional(:alt_last_name).maybe(:string)
          optional(:ssn).maybe(:string)
          optional(:medicaid_id).maybe(:string)
          optional(:dob).maybe(:date)
          required(:gender).filled(Types::GENDER_OPTIONS)
          optional(:sexual_orientation).filled(Types::SEXUAL_ORIENTATION_OPTIONS)
          required(:race).filled(Types::RACE_OPTIONS)
          required(:ethnicity).filled(Types::ETHNICITY_OPTIONS)
          optional(:primary_language).maybe(Types::LANGUAGE_OPTIONS)
        end

        %i[first_name middle_name last_name alt_first_name alt_last_name].each do |field|
          rule(field) do
            key.failure('Length cannot be more than 30 characters') if key && value && value.length > 30
          end
        end

        rule(:ssn) do
          key.failure('Length should be 9 digits') if key && value && value.length != 9
        end

        rule(:medicaid_id) do
          key.failure('Length cannot be more than 8 characters') if key && value && value.length > 8
        end
      end
    end
  end
end
