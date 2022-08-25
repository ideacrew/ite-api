# frozen_string_literal: true

require './app/models/types'
require './app/domain/validators/api/v1/client_contract'
require './app/domain/validators/api/v1/client_profile_contract'
require './app/domain/validators/api/v1/clinical_info_contract'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class EpisodeContract < Dry::Validation::Contract
        config.messages.default_locale = :en
        config.messages.top_namespace = 'dry_validation_with_codes'
        config.messages.load_paths = ['./config/locales/v1_messages.yml']
        params do
          optional(:admission_id).maybe(:string)
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
          required(:last_contact_date).filled(:date)
          required(:num_of_prior_su_episodes).filled(Types::PRIOR_SU_EPISODE_OPTIONS)
          required(:referral_source).filled(Types::REFERRAL_SOURCE_OPTIONS)
          optional(:criminal_justice_referral).maybe(Types::CRIMINAL_JUSTICE_REFERRAL_OPTIONS)
          optional(:primary_payment_source).maybe(Types::PAYMENT_SOURCE_OPTIONS)
          optional(:client).maybe(Validators::Api::V1::ClientContract.params)
          optional(:client_profile).maybe(Validators::Api::V1::ClientProfileContract.params)
          optional(:clinical_info).maybe(Validators::Api::V1::ClinicalInfoContract.params)

          # fields from the extract
          optional(:extracted_on)
          optional(:coverage_start)
          optional(:coverage_end)
          # optional(:record_group).maybe(:string)
        end

        rule(:client_id) do
          key(:client_id).failure(:special_characters) if key && value && value.match(/[^a-zA-Z\d-]/)
          key.failure(:length) if key && value && value.length > 15
          key.failure(:all_zeros) if key && value && value.chars.to_a.uniq == ['0']
        end

        %i[discharge_date admission_date].each do |field|
          rule(field) do
            key.failure(:before1920) if key && value && value < Date.new(1920, 0o1, 0o1)
          end
        end

        rule(:admission_date, :last_contact_date) do
          key.failure(:after_last_contact) if key && values[:last_contact_date] && values[:admission_date] > values[:last_contact_date]
        end

        rule(:admission_date, :extracted_on) do
          key.failure(:after_extraction) if key && values[:extracted_on] && values[:admission_date] > Date.parse(values[:extracted_on].to_s)
        end

        rule(:admission_date, :coverage_start) do
          key.failure(:outside_coverage) if key && values[:coverage_start] && values[:admission_date] < Date.parse(values[:coverage_start].to_s)
        end

        rule(:admission_date, :coverage_end) do
          key.failure(:outside_coverage) if key && values[:coverage_end] && values[:admission_date] > Date.parse(values[:coverage_end].to_s)
        end

        rule(:treatment_type, :record_type) do
          record_group1 = %w[M X]
          record_group2 = %w[A T]
          unless values[:treatment_type] == '96'
            key.failure(:record_type_mismatch) if key && record_group1.include?(values[:record_type]) && (values[:treatment_type].to_i < 72 || values[:treatment_type].to_i > 77)
            key.failure(:record_type_mismatch) if key && record_group2.include?(values[:record_type]) && values[:treatment_type].to_i > 9
          end
        end

        rule(:treatment_type, :collateral) do
          key.failure(:treatment_type96) if key && values[:treatment_type] && values[:collateral] && values[:collateral] != '1' && values[:treatment_type] == '96'
        end

        rule(:discharge_date, :extracted_on) do
          if key && (values[:extracted_on] && values[:discharge_date]) &&
             values[:discharge_date] > Date.parse(values[:extracted_on].to_s)
            key.failure(:after_extraction)
          end
        end

        rule(:discharge_date, :last_contact_date) do
          if key && (values[:last_contact_date] && values[:discharge_date]) &&
             values[:discharge_date] > values[:last_contact_date]
            key.failure(:after_last_contact)
          end
        end

        rule(:discharge_date, :admission_date) do
          key.failure(:earlier_than_admission) if key && values[:discharge_date] && values[:admission_date] && values[:admission_date] > values[:discharge_date]
        end

        rule(:discharge_date, :coverage_end) do
          key.failure(:later_than_coverage_end) if key && values[:discharge_date] && values[:coverage_end] && Date.parse(values[:coverage_end].to_s) < Date.parse(values[:discharge_date].to_s)
        end

        rule(:discharge_date, :discharge_reason) do
          key.failure(:discharge_date_cannot_be_nil) if values[:discharge_reason] && !values[:discharge_date]
        end

        rule(:discharge_reason, :discharge_date) do
          key.failure(:discharge_reason_cannot_be_nil) if values[:discharge_date] && !values[:discharge_reason]
        end

        rule(:last_contact_date, :extracted_on) do
          if key && (values[:last_contact_date] && values[:extracted_on]) &&
             values[:last_contact_date] > Date.parse(values[:extracted_on].to_s)
            key.failure(:after_extraction)
          end
        end

        rule(:last_contact_date, :admission_date) do
          if key && (values[:last_contact_date] && values[:admission_date]) &&
             values[:last_contact_date] < Date.parse(values[:admission_date].to_s)
            key.failure(:earlier_than_admission)
          end
        end

        rule(:admission_id) do
          if key && value
            key.failure(:special_characters) if value.match(/[^a-zA-Z\d-]/)
            key.failure(:length) if value.length > 15
          end
        end

        rule(:treatment_location) do
          key.failure(:missing_field) if key && !value
        end

        rule(:criminal_justice_referral, :referral_source) do
          # key(:criminal_justice_referral).failure(:missing_field) if key && !value
          if key && values[:criminal_justice_referral] && values[:referral_source]
            key.failure(:referral7_value96) if values[:criminal_justice_referral] == '96' && values[:referral_source] == '7'
            key.failure(:referral_not7_value_not96) if values[:criminal_justice_referral] != '96' && values[:referral_source] != '7'
          end
        end

        rule(:service_request_date, :admission_date) do
          if key && (values[:service_request_date] && values[:admission_date]) &&
             values[:service_request_date] > Date.parse(values[:admission_date].to_s)
            key.failure(:later_than_admission)
          end
        end

        rule(:admission_date, client: :dob) do
          if key && (values[:admission_date] && values.dig(:client, :dob)) &&
             values[:client][:dob] > values[:admission_date]
            key(:dob).failure(:earlier_than_admission)
          end
        end

        rule(client: :dob) do
          if key && values.dig(:client, :dob) &&
             values[:client][:dob] > Date.today
            key(:dob).failure(:earlier_than_today)
          end
        end

        rule(:client) do
          if key && value
            result = Validators::Api::V1::ClientContract.new.call(value)
            result.errors.to_a.each do |error|
              key(error.path.last).failure(text: error.text, category: error.meta[:category])
            end
          end
        end

        rule(:client_profile) do
          if key && value
            result = Validators::Api::V1::ClientProfileContract.new.call(value)
            result.errors.to_a.each do |error|
              key(error.path.last).failure(text: error.text, category: error.meta[:category])
            end
          end
        end

        rule(:clinical_info) do
          if key && value
            result = Validators::Api::V1::ClinicalInfoContract.new.call(value)
            result.errors.to_a.each do |error|
              key(error.path.last).failure(text: error.text, category: error.meta[:category])
            end
          end
        end

        rule('client.gender', 'client_profile.pregnant') do
          if key && (values.dig(:client_profile, :pregnant) && values.dig(:client, :gender)) &&
             (values.dig(:client_profile, :pregnant) == '1' && values.dig(:client, :gender) == '1')
            key(:pregnant).failure(:gender_pregnancy_mismatch)
          end
        end

        rule('client.dob', 'client_profile.school_attendance') do
          if key && (values.dig(:client_profile, :school_attendance) && values.dig(:client, :dob))
            now = Time.now.utc.to_date
            dob = values.dig(:client, :dob)
            age = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
            key(:school_attendance).failure(:over21) if values.dig(:client_profile, :school_attendance) != '96' && age > 21
          end
        end

        rule('client.dob', 'clinical_info.smi_sed') do
          if key && (values.dig(:clinical_info, :smi_sed) && values.dig(:client, :dob))
            now = Time.now.utc.to_date
            dob = values.dig(:client, :dob)
            age = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
            key(:smi_sed).failure(:under22) if values.dig(:clinical_info, :smi_sed) == '1' && age < 22
            key(:smi_sed).failure(:over22) if %w[2 3].include?(values.dig(:clinical_info, :smi_sed)) && age >= 22
          end
        end

        %i[self_help_group_discharge arrests_past_30days_discharge].each do |field|
          rule(:discharge_date, client_profile: field) do
            key(field).failure(:discharge_date_nil) if key && (!values[:discharge_date] && values.dig(:client_profile, field))
            key(field).failure(:discharge_reason_cannot_be_nil) if key && (values[:discharge_date] && !values.dig(:client_profile, field))
          end
        end

        %i[gaf_score_discharge].each do |field|
          rule(:discharge_date, clinical_info: field) do
            key(field).failure(:discharge_date_nil) if key && (!values[:discharge_date] && values.dig(:clinical_info, field))
            key(field).failure(:discharge_reason_cannot_be_nil) if key && (values[:discharge_date] && !values.dig(:clinical_info, field))
          end
        end
      end
    end
  end
end
