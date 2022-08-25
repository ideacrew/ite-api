# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Transforms
  module Api
    module V1
      # Take a record payload and structure it into an episode for validation
      class ToEpisode
        send(:include, Dry::Monads[:result, :do, :try])

        EPISODE_FIELDS = %i[admission_id collateral record_type admission_type admission_date treatment_type
                            service_request_date discharge_date discharge_type discharge_reason last_contact_date
                            num_of_prior_su_episodes referral_source criminal_justice_referral primary_payment_source
                            client client_profile clinical_info treatment_location].freeze
        CLIENT_FIELDS = %i[first_name middle_name last_name first_name_alt last_name_alt suffix alias ssn medicaid_id
                           dob gender sexual_orientation race ethnicity primary_language phone1 phone2 living_arrangement
                           address_line2 address_line1 address_zip_code address_state address_city address_ward].freeze
        CLINICAL_INFO_FIELDS = %i[smi_sed co_occurring_sud_mh opioid_therapy substance_problems gaf_score_admission gaf_score_discharge
                                  sud_diagnostic_codes mh_diagnostic_codes non_bh_dx1 non_bh_dx2 non_bh_dx3 sud_dx1 mh_dx1 sud_dx2 sud_dx3].freeze
        CLIENT_PROFILE_FIELDS = %i[marital_status veteran_status education employment not_in_labor
                                   income_source pregnant school_attendance legal_status arrests_past_30days_admission
                                   arrests_past_30days_discharge self_help_group_admission self_help_group_discharge health_insurance].freeze
        NON_STRING_FIELDS = %i[admission_date service_request_date discharge_date last_contact_date dob coverage_end coverage_start].freeze

        def call(record)
          validated_payload = yield validate_record(record)
          stringified_payload = yield stringify_values(validated_payload)
          construct_episode(stringified_payload)
        end

        private

        def validate_record(record)
          record.payload.present? ? Success(record.payload.symbolize_keys) : Failure('No payload present')
        end

        def stringify_values(validated_payload)
          stringified = validated_payload.except(*NON_STRING_FIELDS).transform_values { |v| v&.to_s }
          dates = validated_payload.slice(*NON_STRING_FIELDS).transform_values { |v| valid_date(v) }
          Success(dates.merge(stringified))
        end

        def construct_episode(payload)
          # SUBSTANCE fields TBD : substance, level, drug_code, age_at_first_use, frequency, route,
          episode = {}
          client = {}
          client_profile = {}
          clinical_info = {}
          episode.merge!(payload.slice(*EPISODE_FIELDS))
          episode.merge!(client_id: payload[:client_id])
          client.merge!(payload.slice(*CLIENT_FIELDS))
          client.merge!(client_id: payload[:client_id])
          client_profile.merge!(payload.slice(*CLIENT_PROFILE_FIELDS))
          client_profile.merge!(client_id: payload[:client_id])
          clinical_info.merge!(payload.slice(*CLINICAL_INFO_FIELDS))
          Success(episode.merge!(client:, client_profile:, clinical_info:))
        end

        def valid_date(value)
          return value if value.nil?

          re = Regexp.new('^\d{1,2}\/\d{1,2}\/\d{4}$').freeze
          return Date.strptime(value, '%m/%d/%Y') if value.match(re)

          re = Regexp.new('^\d{4}\-\d{1,2}\-\d{1,2}$').freeze
          return Date.strptime(value, '%Y-%m-%d') if value.match(re)

          value
        rescue ArgumentError
          value
        end
      end
    end
  end
end
