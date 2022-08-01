# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Transforms
  module Api
    module V1
      # Take a record payload and structure it into an episode for validation
      class ToEpisode
        send(:include, Dry::Monads[:result, :do, :try])

        EPISODE_FIELDS = %i[episode_id collateral record_type admission_type admission_date treatment_type
                            service_request_date discharge_date discharge_type discharge_reason last_contact_date
                            num_of_prior_episodes referral_source criminal_justice_referral primary_payment_source
                            client client_profile clinical_info].freeze
        CLIENT_FIELDS = %i[first_name middle_name last_name last_name_alt alias ssn medicaid_id
                           dob gender sexual_orientation race ethnicity primary_language phone1 phone2].freeze
        CLINICAL_INFO_FIELDS = %i[gaf_score smi_sed co_occurring_sud_mh opioid_therapy substance_problems
                                  sud_diagnostic_codes mh_diagnostic_codes].freeze
        CLIENT_PROFILE_FIELDS = %i[marital_status veteran_status education employment not_in_labor
                                   income_source pregnant school_attendance legal_status arrests_past_30days
                                   self_help_group_attendance health_insurance].freeze
        NON_STRING_FIELDS = %i[admission_date service_request_date discharge_date last_contact_date dob].freeze

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
          re = Regexp.new('^\d{2}\/\d{2}\/\d{2}$').freeze
          return Date.strptime(value, '%m/%d/%y') if value.match(re)

          Date.parse(value)
        rescue ArgumentError
          value
        end
      end
    end
  end
end
