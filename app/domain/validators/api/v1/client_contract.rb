# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class ClientContract < Dry::Validation::Contract
        json do
          optional(:client_id).maybe(:string)
          optional(:first_name).maybe(:string)
          optional(:middle_name).maybe(:string)
          optional(:last_name).maybe(:string)
          optional(:suffix).maybe(:string)
          optional(:alt_first_name).maybe(:string)
          optional(:alt_last_name).maybe(:string)
          optional(:ssn).maybe(:string)
          optional(:medicaid_id).maybe(:string)
          optional(:dob).maybe(:date)
          optional(:gender).maybe(:string)
          optional(:sexual_orientation).maybe(:string)
          optional(:race).maybe(:string)
          optional(:ethnicity).maybe(:string)
          optional(:primary_language).maybe(:string)
        end

        %i[first_name middle_name last_name alt_first_name alt_last_name].each do |field|
          rule(field) do
            if key && value
              key.failure('Length cannot be more than 50 characters') if value.length > 50
              pattern = Regexp.new('^[a-zA-Z\d\s\-\'\ ]*$').freeze
              key.failure('Name can only contain a hyphen (-), Apostrophe (‘), or a single space between characters') unless pattern.match(value)
            end
          end
        end

        %i[first_name last_name client_id gender race ethnicity].each do |field|
          rule(field) do
            key.failure('must be filled') if key && !value
          end
        end

        { gender: Types::GENDER_OPTIONS, sexual_orientation: Types::SEXUAL_ORIENTATION_OPTIONS, race: Types::RACE_OPTIONS, ethnicity: Types::ETHNICITY_OPTIONS, primary_language: Types::LANGUAGE_OPTIONS }.each do |field, types|
          rule(field) do
            key.failure("must be one of: #{types.values.join(', ')}") if key && value && !types.include?(value)
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
            key.failure('Verify age over 95') if age > 95
            key.failure('Should not be in the future') if value > now
          end
        end

        rule(:medicaid_id) do
          if key && value
            key.failure('Length must be 8 characters') if value.length != 8
            key.failure('Cannot be all 0s') if value.chars.to_a.uniq == ['0']
          end
        end
      end
    end
  end
end
