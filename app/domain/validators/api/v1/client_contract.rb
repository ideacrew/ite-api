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
          if key && value
            key.failure('Length should be 9 digits') if value.length != 9
            key.failure('Cannot be all the same digits') if value.chars.to_a.uniq.length == 1
            key.failure('Cannot be in sequential ascending order') if value.chars.to_a.each_cons(2).all? { |left, right| left < right }
            key.failure('Cannot be in sequential descending order') if value.chars.to_a.each_cons(2).all? { |left, right| left > right }
            key.failure('Cannot start with a 9') if value.start_with?('9')
            key.failure('Cannot start with 666') if value.start_with?('666')
            key.failure('Cannot start with 000') if value.start_with?('000')
            key.failure('Cannot end with 0000') if value.end_with?('0000')
            pattern = Regexp.new('^\d{3}0{2}\d{4}$').freeze
            key.failure('the 5th and 6th numbers from the right cannot be 00') if pattern.match(value)
          end
        end

        rule(:dob) do
          if key && value
            now = Time.now.utc.to_date
            age = now.year - value.year - (now.month > value.month || (now.month == value.month && now.day >= value.day) ? 0 : 1)
            key.failure(text: 'Verify age over 95', warning: true) if age > 95
            key.failure(text: 'Should not be in the future', warning: true) if value > now
          end
        end

        rule(:medicaid_id) do
          key.failure('Length cannot be more than 8 characters') if key && value && value.length > 8
        end
      end
    end
  end
end
