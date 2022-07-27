# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class EpisodeContract < Dry::Validation::Contract
        params do
          required(:episode_id).filled(:string)
          optional(:codepedent).maybe(:string)
          optional(:client_id).maybe(:string)
          optional(:record_type).maybe(:string)
          optional(:admission_type).maybe(:date)
          required(:admission_date).filled(:date)
          optional(:treatment_type).maybe(:string)
          optional(:service_request_date).maybe(:date)
          optional(:discharge_date).maybe(:date)
          optional(:discharge_type).maybe(:string)
          optional(:discharge_reason).maybe(:string)
          optional(:last_contact_date).maybe(:date)
          optional(:num_of_prior_episodes).maybe(:string)
          optional(:referral_source).maybe(:string)
          optional(:criminal_justice_referral).maybe(:string)
          optional(:primary_payment_source).maybe(:string)
          optional(:client).maybe(:hash)
          optional(:client_profile).maybe(:hash)
          optional(:clinical_info).maybe(:hash)
        end

        rule(:client_id) do
          if key && value && value.match(/[^a-zA-Z\d-]/)
            key.failure(text: 'Field cannot contain special characters', warning: true)
          end
          key.failure(text: 'Needs to be less than 16 digits', warning: true) if key && value && value.length > 16
          key.failure(text: 'Cannot be all 0s', warning: true) if key && value && value.chars.to_a.uniq == ['0']
        end

        rule(:codepedent) do
          if key && value && !Types::CODEPEDENT_OPTIONS.keys.map(&:to_s).include?(value)
            key.failure(text: 'Not in list of accepted values',
                        warning: true)
          end
        end

        rule(:admission_date) do
          key.failure(text: 'Must be a valid date', warning: true) if key && value && value.class != Date
          if key && value && value < Date.new(1920, 0o1, 0o1)
            key.failure(text: 'Must be after January 1, 1920', warning: true)
          end
        end
        rule(:admission_date, :last_contact_date) do
          if key && values[:last_contact_date] && values[:admission_date] > values[:last_contact_date]
            key.failure(text: 'Must be later than the date of last contact',
                        warning: true)
          end
        end
        rule(:admission_date, :discharge_date) do
          if key && values[:discharge_date] && values[:admission_date] > values[:discharge_date]
            key.failure(text: 'Must be later than the date of discharge',
                        warning: true)
          end
        end
      end
    end
  end
end
