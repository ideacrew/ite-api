# frozen_string_literal: true

require './app/models/types'
require './app/domain/validators/api/v1/client_contract'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class EpisodeContract < Dry::Validation::Contract
        params do
          optional(:episode_id).maybe(:string)
          required(:collateral).filled(Types::CODEPEDENT_OPTIONS)
          required(:client_id).filled(:string)
          required(:record_type).filled(Types::RECORD_TYPE_OPTIONS)
          optional(:admission_type).maybe(:date)
          required(:admission_date).filled(:date)
          required(:treatment_type).filled(Types::TREATMENT_TYPE_OPTIONS)
          optional(:treatment_location).maybe(:string)
          optional(:service_request_date).maybe(:date)
          optional(:discharge_date).maybe(:date)
          optional(:discharge_type).maybe(:string)
          optional(:discharge_reason).maybe(Types::DISCHARGE_REASON_OPTIONS)
          optional(:last_contact_date).maybe(:date)
          optional(:num_of_prior_episodes).maybe(Types::PRIOR_SU_EPISODE_OPTIONS)
          optional(:referral_source).maybe(Types::REFERRAL_SOURCE_OPTIONS)
          optional(:criminal_justice_referral).maybe(Types::CRIMINAL_JUSTICE_REFERRAL_OPTIONS)
          optional(:primary_payment_source).maybe(Types::PAYMENT_SOURCE_OPTIONS)
          optional(:client).maybe(Validators::Api::V1::ClientContract.params)
          optional(:client_profile).maybe(:hash)
          optional(:clinical_info).maybe(:hash)

          # fields from the extract
          optional(:extracted_on)
          optional(:coverage_start)
          optional(:coverage_end)
          optional(:record_group).maybe(:string)
        end

        rule(:client_id) do
          key(:client_id).failure('Field cannot contain special characters') if key && value && value.match(/[^a-zA-Z\d-]/)
          key.failure('Needs to be 15 or less characters') if key && value && value.length > 15
          key.failure('Cannot be all 0s') if key && value && value.chars.to_a.uniq == ['0']
        end

        rule(:admission_date) do
          key.failure('Must be a valid date') if key && value && value.class != Date
          key.failure('Must be after January 1, 1920') if key && value && value < Date.new(1920, 0o1, 0o1)
        end
        rule(:admission_date, :last_contact_date) do
          key.failure('Cannot be later than the date of last contact') if key && values[:last_contact_date] && values[:admission_date] > values[:last_contact_date]
        end
        rule(:admission_date, :extracted_on) do
          key.failure('Cannot be later than the extraction date') if key && values[:extracted_on] && values[:admission_date] > Date.parse(values[:extracted_on].to_s)
        end
        rule(:admission_date, :coverage_start) do
          key.failure('Must be within the coverage period of the dataset') if key && values[:coverage_start] && values[:admission_date] < Date.parse(values[:coverage_start].to_s)
        end
        rule(:admission_date, :coverage_end) do
          key.failure('Must be within the coverage period of the dataset') if key && values[:coverage_end] && values[:admission_date] > Date.parse(values[:coverage_end].to_s)
        end

        rule(:record_type, :record_group) do
          admission_types = %w[A T M X]
          discharge_types = %w[D S E]
          # active_types = %w[U]
          if values[:record_group]
            key.failure('must correspond to record group') if key && admission_types.include?(values[:record_type]) && values[:record_group] != 'admission'
            key.failure('must correspond to record group') if key && discharge_types.include?(values[:record_type]) && values[:record_group] != 'discharge'
            # key.failure(text: 'must correspond to record group') if key && active_types.include?(values[:record_type]) && values[:record_group] != 'active'
          end
        end

        rule(:treatment_type, :record_type) do
          record_group1 = %w[M E X]
          record_group2 = %w[A T D]
          unless values[:treatment_type] == '96'
            key.failure('must correspond to record_type') if key && record_group1.include?(values[:record_type]) && (values[:treatment_type].to_i < 72 || values[:treatment_type].to_i > 77)
            key.failure('must correspond to record_type') if key && record_group2.include?(values[:record_type]) && values[:treatment_type].to_i > 9
          end
        end
        rule(:treatment_type, :collateral) do
          key.failure('can only specify 96 if client is Collateral/Codependent') if key && values[:treatment_type] && values[:collateral] && values[:collateral] != '1' && values[:treatment_type] == '96'
        end

        %i[discharge_date discharge_reason].each do |field|
          rule(field) do
            key.failure('Must be included for discharge records') if key && values[:record_group] && values[:record_group] == 'discharge' && !values[field]
          end
        end
        rule(:discharge_date, :extracted_on) do
          if key && (values[:extracted_on] && values[:discharge_date]) &&
             values[:discharge_date] > Date.parse(values[:extracted_on].to_s)
            key.failure('Must be earlier than the extraction date')
          end
        end
        rule(:discharge_date, :last_contact_date) do
          if key && (values[:last_contact_date] && values[:discharge_date]) &&
             values[:discharge_date] > values[:last_contact_date]
            key.failure('Must be earlier than the date of last contact')
          end
        end
        rule(:discharge_date, :record_group) do
          key.failure('Should not be included for active or admission records') if key && values[:record_group] != 'discharge' && values[:discharge_date]
        end
        rule(:discharge_date, :admission_date) do
          key.failure('Cannot be earlier than the date of admission') if key && values[:discharge_date] && values[:admission_date] && values[:admission_date] > values[:discharge_date]
        end

        rule(:last_contact_date, :record_group) do
          key.failure('must be included') if key && values[:record_group] && (values[:record_group] == 'active' && !values[:last_contact_date])
        end
        rule(:last_contact_date, :extracted_on) do
          if key && (values[:last_contact_date] && values[:extracted_on]) &&
             values[:last_contact_date] > Date.parse(values[:extracted_on].to_s)
            key.failure('Must be earlier than the data extraction date')
          end
        end
        rule(:last_contact_date, :admission_date) do
          if key && (values[:last_contact_date] && values[:admission_date]) &&
             values[:last_contact_date] < Date.parse(values[:admission_date].to_s)
            key.failure('Cannot be earlier than the date of admission')
          end
        end

        rule(:episode_id) do
          if key && value
            key.failure('Field cannot contain special characters') if value.match(/[^a-zA-Z\d-]/)
            key.failure('Needs to be 15 or less characters') if value.length > 15
          end
        end

        rule(:num_of_prior_episodes, :record_group) do
          key.failure('Must be included for admission or active records') if key && values[:record_group] && values[:record_group] != 'discharge' && !values[:num_of_prior_episodes]
        end

        rule(:treatment_location) do
          key.failure('must be filled') if key && !value
        end

        rule(:referral_source) do
          key.failure('must be filled') if key && !value
        end

        rule(:criminal_justice_referral, :referral_source) do
          key.failure('must be filled') if key && !value
          if key && values[:criminal_justice_referral] && values[:referral_source]
            key.failure('must be filled with a valid option if referral source is 7') if values[:criminal_justice_referral] == '96' && values[:referral_source] == '7'
            key.failure('must be filled with 96 if referral source is not 7') if values[:criminal_justice_referral] != '96' && values[:referral_source] != '7'
          end
        end

        rule(:service_request_date, :admission_date) do
          if key && (values[:service_request_date] && values[:admission_date]) &&
             values[:service_request_date] > Date.parse(values[:admission_date].to_s)
            key.failure('Cannot be later than the date of admission')
          end
        end

        rule(:primary_payment_source) do
          key.failure('must be filled') if key && !value
        end

        rule(:admission_date, client: :dob) do
          if key && (values[:admission_date] && values.dig(:client, :dob)) &&
             values[:client][:dob] > values[:admission_date]
            key(:dob).failure('Must be later than the admission date')
          end
        end
        rule(client: :dob) do
          if key && values.dig(:client, :dob) &&
             values[:client][:dob] > Date.today
            key(:dob).failure('Must be later than the current date')
          end
        end

        rule(:client) do
          if key && value
            result = Validators::Api::V1::ClientContract.new.call(value)
            result.errors.to_a.each do |error|
              key(error.path.last).failure(error.text)
            end
          end
        end

        # rule("client.dob", "client_profile.pregnant") do
        #   if key && (values[:admission_date] && values.dig(:client, :dob)) &&
        #      values[:client][:dob] > values[:admission_date]
        #     key(:dob).failure(text: 'Must be later than the admission date',
        #                 warning: true)
        #   end
        # end
      end
    end
  end
end
