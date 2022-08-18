# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for client profile.
      class ClientProfileContract < Dry::Validation::Contract
        config.messages.default_locale = :en
        config.messages.top_namespace = 'dry_validation_with_codes'
        config.messages.load_paths = ['./config/locales/v1_messages.yml']
        params do
          optional(:marital_status).maybe(:string)
          optional(:veteran_status).maybe(:string)
          optional(:education).maybe(:string)
          optional(:employment).maybe(:string)
          optional(:not_in_labor).maybe(:string)
          optional(:income_source).maybe(:string)
          optional(:pregnant).maybe(:string)
          optional(:school_attendance).maybe(:string)
          optional(:legal_status).maybe(:string)
          optional(:arrests_past_30days).maybe(:string)
          optional(:self_help_group_attendance).maybe(:string)
          optional(:health_insurance).maybe(:string)
        end

        %i[marital_status veteran_status education employment not_in_labor pregnant school_attendance].each do |field|
          rule(field) do
            key.failure(:missing_field) if key && !value
          end
        end

        { marital_status: Types::MARITAL_STATUS_OPTIONS, veteran_status: Types::VETERAN_STATUS_OPTIONS, education: Types::EDUCATION_OPTIONS, employment: Types::EMPLOYMENT_OPTIONS, pregnant: Types::PREGNANCY_OPTIONS,
          school_attendance: Types::SCHOOL_ATTENDENCE_OPTIONS, health_insurance: Types::HEALTH_INSURANCE_OPTIONS }.each do |field, types|
          rule(field) do
            key.failure(text: "must be one of #{types.values.join(', ')}", category: 'Invalid Value') if key && value && !types.include?(value)
          end
        end
      end
    end
  end
end
