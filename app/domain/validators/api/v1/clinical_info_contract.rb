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
          optional(:sud_dx2).maybe(:string)
          optional(:sud_dx3).maybe(:string)
          optional(:mh_dx1).maybe(:string)
          optional(:mh_dx2).maybe(:string)
          optional(:mh_dx3).maybe(:string)
          optional(:non_bh_dx1).maybe(:string)
          optional(:non_bh_dx2).maybe(:string)
          optional(:non_bh_dx3).maybe(:string)
          optional(:primary_substance).maybe(:string)
          optional(:secondary_substance).maybe(:string)
          optional(:tertiary_substance).maybe(:string)
          optional(:primary_su_frequency_admission).maybe(:string)
          optional(:secondary_su_frequency_admission).maybe(:string)
          optional(:tertiary_su_frequency_admission).maybe(:string)
          optional(:primary_su_frequency_discharge).maybe(:string)
          optional(:secondary_su_frequency_discharge).maybe(:string)
          optional(:tertiary_su_frequency_discharge).maybe(:string)
          optional(:primary_su_route).maybe(:string)
          optional(:secondary_su_route).maybe(:string)
          optional(:tertiary_su_route).maybe(:string)
          optional(:primary_su_age_at_first_use).maybe(:string)
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

        %i[primary_substance secondary_substance tertiary_substance].each do |field|
          rule(field) do
            key.failure(text: 'must be one of 1-18, 20, 96-98', category: 'Invalid Value') if key && value && !Types::SUBSTANCE_OPTIONS.values.include?(value)
          end
        end

        %i[primary_su_route secondary_su_route tertiary_su_route].each do |field|
          rule(field) do
            key.failure(text: 'must be one of 1-4, 20, 96-98', category: 'Invalid Value') if key && value && !Types::SU_ROUTE_OPTIONS.values.include?(value)
          end
        end

        %i[primary_su_frequency_admission secondary_su_frequency_admission tertiary_su_frequency_admission primary_su_frequency_discharge tertiary_su_frequency_discharge
           secondary_su_frequency_discharge].each do |field|
          rule(field) do
            key.failure(text: 'must be one of 1-5, 96-98', category: 'Invalid Value') if key && value && !Types::SU_FREQUENCY_ADMISSION.values.include?(value)
          end
        end

        %i[primary_su_age_at_first_use].each do |field|
          rule(field) do
            key.failure(text: 'must be one of 1-98', category: 'Invalid Value') if key && value && !Types::AGE_OPTIONS.values.first.include?(value)
          end
        end

        rule(:co_occurring_sud_mh, :record_type, :sud_dx1) do
          key.failure(:co_occurring_sud_mh_mismatch) if key && value && values[:co_occurring_sud_mh] != '1' && %w[M X].include?(values[:record_type]) && values[:sud_dx1] != '999.9996'
        end

        { smi_sed: Types::SME_OPTIONS, co_occurring_sud_mh: Types::COOCCURRING_OPTIONS }.each do |field, types|
          rule(field) do
            key.failure(text: "must be one of #{types.values.join(', ')}", category: 'Invalid Value') if key && value && !types.include?(value)
          end
        end

        %i[sud_dx1 sud_dx2 sud_dx3].each do |field|
          rule(field) do
            if key && value
              key.failure(:length_between3and8) unless value.length >= 3 && value.length <= 8
              unless value == '999.9996'
                pattern1 = Regexp.new('^[fF][1][0-9]{1}$').freeze
                pattern2 = Regexp.new('^[fF][1][0-9]{1}\.*[a-zA-Z0-9]{4,5}$').freeze
                key.failure(:sud_format_with3_or8) if value.length == 3 && !pattern1.match(value)
                key.failure(:sud_format_with3_or8) if value.length == 8 && !pattern2.match(value)
              end
            end
          end
        end

        %i[mh_dx1 mh_dx2 mh_dx3].each do |field|
          rule(field) do
            if key && value
              key.failure(:length_between3and8) unless value.length >= 3 && value.length <= 8
              unless value == '999.9996'
                pattern1 = Regexp.new('^[fF][^1][0-9]{1}$').freeze
                pattern2 = Regexp.new('^[fF][^1][0-9]{1}\.*[a-zA-Z0-9]{4,5}$').freeze
                key.failure(:mh_format_with3_or8) if value.length == 3 && !pattern1.match(value)
                key.failure(:mh_format_with3_or8) if value.length == 8 && !pattern2.match(value)
              end
            end
          end
        end

        rule(:sud_dx2, :sud_dx1) do
          key.failure(:sud_dx2_without_dx1) if key && value && !values[:sud_dx1]
        end

        rule(:sud_dx3, :sud_dx2, :sud_dx1) do
          key.failure(:sud_dx2_without_dx1_dx2) if key && value && !values[:sud_dx1] && !values[:sud_dx2]
        end

        rule(:mh_dx2, :mh_dx1) do
          key.failure(:mh_dx2_without_dx1) if key && value && !values[:mh_dx1]
        end

        rule(:mh_dx3, :mh_dx2, :mh_dx1) do
          key.failure(:mh_dx2_without_dx1_dx2) if key && value && !values[:mh_dx1] && !values[:mh_dx2]
        end

        %i[mh_dx1 mh_dx2 mh_dx3].each do |field|
          rule(field, :record_type, :co_occurring_sud_mh) do
            if key && value
              key.failure(:mh_dx1_mismatch_collateral) if (value == '999.9996') && %w[M X].include?(values[:record_type])
              key.failure(:mh_dx1_co_occuring_mismatch) if value != '999.9996' && !schema_error?(field) && %w[A T].include?(values[:record_type]) && values[:co_occurring_sud_mh] != '1'
            end
          end
        end

        %i[sud_dx1 sud_dx2 sud_dx3].each do |field|
          rule(field, :record_type, :collateral, :co_occurring_sud_mh) do
            if key && value
              key.failure(:sud_dx1_mismatch_collateral) if (value == '999.9996') && %w[A T].include?(values[:record_type]) && values[:collateral] == '2'
              key.failure(:sud_dx1_co_occuring_mismatch) if value != '999.9996' && !schema_error?(field) && %w[M X].include?(values[:record_type]) && values[:co_occurring_sud_mh] != '1'
            end
          end
        end

        %i[primary_substance].each do |field|
          rule(field, :sud_dx1) do
            key.failure(:primary_substance_missing) if key && (!value && values[:sud_dx1] && !schema_error?(:sud_dx1))
          end
        end

        %i[primary_su_frequency_admission].each do |field|
          rule(field, :primary_substance) do
            key.failure(:primary_su_frequency_admission_missing) if key && (!value && !schema_error?(:primary_substance))
          end
        end

        %i[secondary_su_frequency_admission].each do |field|
          rule(field, :secondary_substance) do
            key.failure(:secondary_su_frequency_admission_missing) if key && (!value && values[:secondary_substance] && !schema_error?(:secondary_substance))
          end
        end

        %i[tertiary_su_frequency_admission].each do |field|
          rule(field, :tertiary_substance) do
            key.failure(:tertiary_su_frequency_admission_missing) if key && (!value && values[:tertiary_substance] && !schema_error?(:tertiary_substance))
          end
        end

        rule(:primary_su_route, :primary_substance) do
          substance_options = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 20]
          key.failure(:su_route_missing) if !values[:primary_su_route] && substance_options.include?(values[:primary_substance])
        end

        rule(:secondary_su_route, :secondary_substance) do
          substance_options = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 20]
          key.failure(:su_route_missing) if !values[:secondary_su_route] && substance_options.include?(values[:secondary_substance])
        end

        rule(:tertiary_su_route, :tertiary_substance) do
          substance_options = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 20]
          key.failure(:su_route_missing) if !values[:tertiary_su_route] && substance_options.include?(values[:tertiary_substance])
        end

        %i[non_bh_dx1 non_bh_dx2 non_bh_dx3].each do |field|
          rule(field) do
            if key && value
              key.failure(:length_between3and8) unless value.length >= 3 && value.length <= 8
              unless value == '999.9996'
                pattern1 = Regexp.new('^[^fF][0-9]{2}$').freeze
                pattern2 = Regexp.new('^[^fF][0-9]{2}\.*[a-zA-Z0-9]{4,5}$').freeze
                key.failure(:bh_format_with3_or8) if value.length == 3 && !pattern1.match(value)
                key.failure(:bh_format_with3_or8) if value.length == 8 && !pattern2.match(value)
              end
            end
          end
        end
      end
    end
  end
end
