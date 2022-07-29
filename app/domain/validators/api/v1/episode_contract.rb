# frozen_string_literal: true

require './app/models/types'
require './app/domain/validators/api/v1/client_contract'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class EpisodeContract < Dry::Validation::Contract
        params do
          required(:episode_id).filled(:string)
          optional(:codepedent).maybe(Types::CODEPEDENT_OPTIONS)
          optional(:client_id).maybe(:string)
          optional(:record_type).maybe(:string)
          optional(:admission_type).maybe(:date)
          required(:admission_date).filled(:date)
          required(:treatment_type).filled(Types::TREATMENT_TYPE_OPTIONS)
          optional(:service_request_date).maybe(:date)
          optional(:discharge_date).maybe(:date)
          optional(:discharge_type).maybe(:string)
          optional(:discharge_reason).maybe(:string)
          optional(:last_contact_date).maybe(:date)
          optional(:num_of_prior_episodes).maybe(:string)
          optional(:referral_source).maybe(:string)
          optional(:criminal_justice_referral).maybe(:string)
          optional(:primary_payment_source).maybe(:string)
          optional(:client).hash(Validators::Api::V1::ClientContract.params)
          optional(:client_profile).maybe(:hash)
          optional(:clinical_info).maybe(:hash)

          # fields from the extract
          optional(:extracted_on)
          optional(:record_group).maybe(:string)
        end

        rule(:client_id) do
          key(:client_id).failure(text: 'Field cannot contain special characters', warning: true) if key && value && value.match(/[^a-zA-Z\d-]/)
          key.failure(text: 'Needs to be less than 16 digits', warning: true) if key && value && value.length > 16
          key.failure(text: 'Cannot be all 0s', warning: true) if key && value && value.chars.to_a.uniq == ['0']
        end

        rule(:admission_date) do
          key.failure(text: 'Must be a valid date', warning: true) if key && value && value.class != Date
          key.failure(text: 'Must be after January 1, 1920', warning: true) if key && value && value < Date.new(1920, 0o1, 0o1)
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
        rule(:admission_date, :extracted_on) do
          if key && values[:extracted_on] && values[:admission_date] > Date.parse(values[:extracted_on].to_s)
            key.failure(text: 'Must be later than the extraction date',
                        warning: true)
          end
        end

        rule(:treatment_type, :record_type) do
          record_group1 = %w[M E X]
          record_group2 = %w[A T D]
          key.failure(text: 'must correspond to record_type') if key && record_group1.include?(values[:record_type]) && values[:treatment_type].to_i < 70
          key.failure(text: 'must correspond to record_type') if key && record_group2.include?(values[:record_type]) && values[:treatment_type].to_i > 8
        end

        rule(:discharge_date, :extracted_on) do
          if key && (values[:extracted_on] && values[:discharge_date]) &&
             values[:discharge_date] > Date.parse(values[:extracted_on].to_s)
            key.failure(text: 'Must be later than the extraction date',
                        warning: true)
          end
        end
        rule(:discharge_date, :last_contact_date) do
          if key && (values[:last_contact_date] && values[:discharge_date]) &&
             values[:discharge_date] > values[:last_contact_date]
            key.failure(text: 'Must be later than the date of last contact',
                        warning: true)
          end
        end
        rule(:discharge_date, :record_type) do
          if key && values[:record_type] == 'U' && values[:discharge_date]
            key.failure(text: 'Must be blank if record type is Data Update for SU/MH Service (U)',
                        warning: true)
          end
        end

        rule(:last_contact_date, :record_group) do
          if key && values[:record_group]
            if values[:record_group] == 'active' && !values[:last_contact_date]
              key.failure(text: 'Must be included if is an active record')
            elsif values[:record_group] != 'active' && !values[:last_contact_date]
              key.failure(text: 'Should be included', warning: true)
            end
          end
        end
        rule(:last_contact_date, :extracted_on) do
          if key && (values[:last_contact_date] && values[:extracted_on]) &&
             values[:last_contact_date] > Date.parse(values[:extracted_on].to_s)
            key.failure(text: 'Must be later than the extraction date',
                        warning: true)
          end
        end
      end
    end
  end
end
