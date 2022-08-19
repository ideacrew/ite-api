# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class ClientContract < Dry::Validation::Contract
        config.messages.default_locale = :en
        config.messages.top_namespace = 'dry_validation_with_codes'
        config.messages.load_paths = ['./config/locales/v1_messages.yml']
        params do
          optional(:client_id).maybe(:string)
          optional(:first_name).maybe(:string)
          optional(:middle_name).maybe(:string)
          optional(:last_name).maybe(:string)
          optional(:suffix).maybe(:string)
          optional(:first_name_alt).maybe(:string)
          optional(:last_name_alt).maybe(:string)
          optional(:ssn).maybe(:string)
          optional(:medicaid_id).maybe(:string)
          optional(:dob).maybe(:date)
          optional(:gender).maybe(:string)
          optional(:sexual_orientation).maybe(:string)
          optional(:race).maybe(:string)
          optional(:ethnicity).maybe(:string)
          optional(:primary_language).maybe(:string)
          optional(:living_arrangement).maybe(:string)
          optional(:suffix).maybe(:string)
          optional(:address_line1).maybe(:string)
          optional(:address_line2).maybe(:string)
          optional(:phone1).maybe(:string)
          optional(:phone2).maybe(:string)
          optional(:address_zip_code).maybe(:string)
          optional(:address_state).maybe(:string)
          optional(:address_city).maybe(:string)
          optional(:address_ward).maybe(:string)
        end

        %i[first_name middle_name last_name first_name_alt last_name_alt address_line1 address_line2].each do |field|
          rule(field) do
            if key && value
              key.failure(:length_more_than50) if value.length > 50
              pattern = Regexp.new('^[a-zA-Z\d\s\-\'\ ]*$').freeze
              key.failure(:unsuported_name_characters) unless pattern.match(value)
            end
          end
        end

        %i[first_name last_name client_id gender race ethnicity dob primary_language living_arrangement address_state address_city].each do |field|
          rule(field) do
            key.failure(:missing_field) if key && !value
          end
        end

        rule(:address_state) do
          key.failure(:not_a_state) if key && value && !Types::UsStateAbbreviationKind.include?(value)
        end

        rule(:address_city) do
          if key && value
            key.failure(:length_more_than30) if value.length > 30
            pattern = Regexp.new('^[a-zA-Z\s\-\'\ ]*$').freeze
            key.failure(:unsuported_city_characters) unless pattern.match(value)
          end
        end

        %i[phone2 phone1].each do |field|
          rule(field) do
            if key && value
              key.failure(:length_not10) if value.length != 10
              key.failure(:non_numeric) unless value.scan(/\D/).empty?
              key.failure(:start_with0) if value.start_with?('0')
            end
          end
        end

        { gender: Types::GENDER_OPTIONS, sexual_orientation: Types::SEXUAL_ORIENTATION_OPTIONS, race: Types::RACE_OPTIONS, ethnicity: Types::ETHNICITY_OPTIONS, primary_language: Types::LANGUAGE_OPTIONS,
          living_arrangement: Types::LIVING_ARRANGEMENT_OPTIONS, address_ward: Types::WARD_OPTIONS }.each do |field, types|
          rule(field) do
            key.failure(text: "must be one of #{types.values.join(', ')}", category: 'Invalid Value') if key && value && !types.include?(value)
          end
        end

        rule(:suffix) do
          if key && value
            pattern = Regexp.new('^[a-zA-Z\d\s\-\'\ ]*$').freeze
            key.failure(:unsuported_name_characters) unless pattern.match(value)
            key.failure(:length_more_than10) if value.length > 10
          end
        end

        rule(:ssn) do
          if key && value
            key.failure(:length) if value.length != 9
            key.failure(:all_same_digits) if value.chars.to_a.uniq.length == 1
            key.failure(:sequential_ascending_order) if value.chars.to_a.each_cons(2).all? { |left, right| left < right }
            key.failure(:sequential_descending_order) if value.chars.to_a.each_cons(2).all? { |left, right| left > right }
            key.failure(:cannot_start_with) if value.start_with?('9')
            key.failure(:cannot_start_with) if value.start_with?('666')
            key.failure(:cannot_start_with) if value.start_with?('000')
            key.failure(:end_with_all_zeros) if value.end_with?('0000')
            pattern = Regexp.new('^\d{3}0{2}\d{4}$').freeze
            key.failure(:middle_zeros) if pattern.match(value)
          end
        end

        rule(:dob) do
          if key && value
            now = Time.now.utc.to_date
            age = now.year - value.year - (now.month > value.month || (now.month == value.month && now.day >= value.day) ? 0 : 1)
            key.failure(:dob_over95) if age > 95
            key.failure(:cannot_be_in_future) if value > now
          end
        end

        rule(:medicaid_id) do
          if key && value
            key.failure(:length) if value.length != 8
            key.failure(:all_zeros) if value.chars.to_a.uniq == ['0']
            key.failure(:non_numeric) unless value.scan(/\D/).empty?
            key.failure(:doesnt_start_with7) unless value.start_with?('7')
          end
        end

        rule(:address_zip_code) do
          if key && value
            pattern = Regexp.new('^\d{5}(-\d{4})?$')
            key.failure(:length) unless [5, 10].include?(value.length)
            key.failure(:start_with00) if value.start_with?('0')
            key.failure(:invalid_zip) unless pattern.match(value)
          end
        end
      end
    end
  end
end
