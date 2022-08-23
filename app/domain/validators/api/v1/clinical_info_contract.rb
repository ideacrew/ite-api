# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for clinical info.
      class ClinicalInfoContract < Dry::Validation::Contract
        config.messages.default_locale = :en
        config.messages.top_namespace = 'dry_validation_with_codes'
        config.messages.load_paths = ['./config/locales/v1_messages.yml']
        params do
          optional(:smi_sed).maybe(:string)
          optional(:gaf_score_admission).maybe(:string)
          optional(:gaf_score_discharge).maybe(:string)
        end

        %i[smi_sed gaf_score_admission].each do |field|
          rule(field) do
            key.failure(:missing_field) if key && !value
          end
        end

        %i[gaf_score_discharge gaf_score_admission].each do |field|
          rule(field) do
            key.failure(text: 'must be one of 1-100, 997, 998', category: 'Invalid Value') if key && !Types::GAF_OPTIONS.values.first.include?(value)
          end
        end

        { smi_sed: Types::SME_OPTIONS }.each do |field, types|
          rule(field) do
            key.failure(text: "must be one of #{types.values.join(', ')}", category: 'Invalid Value') if key && value && !types.include?(value)
          end
        end
      end
    end
  end
end
