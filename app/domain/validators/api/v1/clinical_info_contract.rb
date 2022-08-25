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
          optional(:co_occurring_sud_mh).maybe(:string)
          optional(:sud_dx1).maybe(:string)
          optional(:mh_dx1).maybe(:string)

          # from episode
          optional(:collateral)
          optional(:record_type)
        end

        %i[smi_sed gaf_score_admission sud_dx1 mh_dx1].each do |field|
          rule(field) do
            key.failure(:missing_field) if key && !value
          end
        end

        %i[gaf_score_discharge gaf_score_admission].each do |field|
          rule(field) do
            key.failure(text: 'must be one of 1-100, 997, 998', category: 'Invalid Value') if key && value && !Types::GAF_OPTIONS.values.first.include?(value)
          end
        end

        { smi_sed: Types::SME_OPTIONS, co_occurring_sud_mh: Types::COOCCURRING_OPTIONS }.each do |field, types|
          rule(field) do
            key.failure(text: "must be one of #{types.values.join(', ')}", category: 'Invalid Value') if key && value && !types.include?(value)
          end
        end

        %i[sud_dx1 mh_dx1].each do |field|
          rule(field) do
            if key && value
              key.failure(:length_eq3_or8) unless value.length == 3 || value.length == 8
              unless value == '999.9996'
                pattern1 = Regexp.new('^[fF][1][0-9]{1}$').freeze
                pattern2 = Regexp.new('^[fF][1][0-9]{1}\.[a-zA-Z0-9]{4}$').freeze
                key.failure(:format_with3_or8) if value.length == 3 && !pattern1.match(value)
                key.failure(:format_with3_or8) if value.length == 8 && !pattern2.match(value)
              end
            end
          end
        end

        rule(:mh_dx1, :record_type, :co_occurring_sud_mh) do
          if key && value
            key.failure(:mh_dx1_mismatch_collateral) if (value == '999.9996') && %w[M X].include?(values[:record_type])
            key.failure(:mh_dx1_co_occuring_mismatch) if !schema_error?(:mh_dx1) && %w[A T].include?(values[:record_type]) && values[:co_occurring_sud_mh] != '1'
          end
        end

        rule(:sud_dx1, :record_type, :collateral, :co_occurring_sud_mh) do
          if key && value
            key.failure(:sud_dx1_mismatch_collateral) if (value == '999.9996') && %w[A T].include?(values[:record_type]) && values[:collateral] == '2'
            key.failure(:sud_dx1_co_occuring_mismatch) if !schema_error?(:sud_dx1) && %w[M X].include?(values[:record_type]) && values[:co_occurring_sud_mh] != '1'
          end
        end
      end
    end
  end
end
