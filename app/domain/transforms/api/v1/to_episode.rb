# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Transforms
  module Api
    module V1
      # Take a transaction payload and structure it into an episode for validation
      class ToEpisode
        send(:include, Dry::Monads[:result, :do, :try])

        EPISODE_FIELDS = %i[episode_id codepedent admission_type admission_date treatment_type
                            service_request_date discharge_date discharge_type discharge_reason last_contact_date
                            num_of_prior_episodes referral_source criminal_justice_referral primary_payment_source
                            client client_profile clinical_info].freeze
        CLIENT_FIELDS = %i[client_id first_name middle_name last_name last_name_alt alias ssn medicaid_id
                           dob gender sexual_orientation race ethnicity primary_language phone1 phone2].freeze
        CLINICAL_INFO_FIELDS = %i[gaf_score smi_sed co_occurring_sud_mh opioid_therapy substance_problems
                                  sud_diagnostic_codes mh_diagnostic_codes].freeze
        CLIENT_PROFILE_FIELDS = %i[client_id marital_status veteran_status education employment not_in_labor
                                   income_source pregnant school_attendance legal_status arrests_past_30days
                                   self_help_group_attendance health_insurance].freeze

        def call(transaction)
          validated_payload = yield validate_transaction(transaction)
          construct_episode(validated_payload)
        end

        private

        def validate_transaction(transaction)
          transaction.payload.present? ? Success(transaction.payload.symbolize_keys) : Failure('No payload present')
        end

        def construct_episode(payload)
          # SUBSTANCE fields TBD : substance, level, drug_code, age_at_first_use, frequency, route,
          episode = {}
          client = {}
          client_profile = {}
          clinical_info = {}
          episode.merge!(payload.slice(*EPISODE_FIELDS))
          client.merge!(payload.slice(*CLIENT_FIELDS))
          client_profile.merge!(payload.slice(*CLIENT_PROFILE_FIELDS))
          clinical_info.merge!(payload.slice(*CLINICAL_INFO_FIELDS))
          Success(episode.merge!(client:, client_profile:, clinical_info:))
        end
      end
    end
  end
end
