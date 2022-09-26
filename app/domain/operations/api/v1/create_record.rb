# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'dry/monads/try'

module Operations
  module Api
    module V1
      # operation to create record
      class CreateRecord
        send(:include, Dry::Monads[:result, :do, :try])

        def call(params)
          record_entity = yield create_entity(params)
          record = yield create_record(record_entity)
          episode = yield structure_episode(record)
          validation_result = yield validate_episode(episode, params[:extract])
          errors = yield structure_errors(validation_result)
          cross_record_errors = yield check_admission_ids(errors, params[:dups], episode)
          update_record(cross_record_errors, record)
        end

        private

        def create_entity(params)
          result = Try do
            ::Entities::Api::V1::Record.new(payload: params[:payload].to_h)
          end
          result.success? ? Success(result.value!) : Failure(result)
        end

        def create_record(record_entity)
          result = Try do
            ::Api::V1::Record.new(record_entity.to_h)
          end
          result.success? ? Success(result.value!) : Failure(result)
        end

        def structure_episode(record)
          Transforms::Api::V1::ToEpisode.new.call(record)
        end

        def validate_episode(episode, extract)
          # merge in extract attributes to allow for validation against extract fields
          Success(::Validators::Api::V1::EpisodeContract.new.call(episode.merge(extract)))
        end

        def structure_errors(result)
          warnings = %i[address_ward ssn address_zipcode phone1 phone2 veteran_status not_in_labor income_source pregnant medicaid_id suffix sexual_orientation first_name_alt
                        last_name_alt self_help_group_admission middle_name suffix admission_id service_request_date criminal_justice_referral
                        health_insurance address_line2 address_line1 address_city address_state co_occurring_sud_mh non_bh_dx1 non_bh_dx2 non_bh_dx3 sud_dx2 sud_dx3 mh_dx2 mh_dx3]
          critical_error_fields = %i[gaf_score_admission smi_sed school_attendance marital_status employment education
                                     legal_status primary_language ethnicity race first_name last_name dob gender self_help_group_discharge
                                     arrests_past_30days_discharge num_of_prior_su_episodes gaf_score_discharge sud_dx1 mh_dx1
                                     discharge_reason referral_source living_arrangement arrests_past_30days_admission]
          fatal_error_fields = %i[collateral client_id record_type admission_date treatment_type discharge_date last_contact_date]
          errors = result.errors.messages.map { |message| { message.path.last => { text: message.text, category: message&.meta&.first&.last } } }
          warnings = errors.select { |error| warnings.include? error.keys.first }
          critical_error_fields = errors.select { |error| critical_error_fields.include? error.keys.first }
          fatal_error_fields = errors.select { |error| fatal_error_fields.include? error.keys.first }
          Success(warnings:, critical_error_fields:, fatal_error_fields:)
        end

        def update_record(errors, record)
          record.status = errors.except(:warnings).compact_blank.any? ? 'Fail' : 'Pass'
          record.warnings = errors[:warnings].uniq.compact_blank!
          record.critical_errors = errors[:critical_error_fields].uniq.compact_blank!
          record.fatal_errors = errors[:fatal_error_fields].uniq.compact_blank!
          Success(record)
        end

        def check_admission_ids(errors, dups, episode)
          return Success(errors) unless dups

          duplicate = dups.map(&:to_s).include?(episode[:admission_id])
          return Success(errors) unless duplicate

          failure = { admission_id: { text: 'must be a unique identifier for admission episodes', category: 'Data Inconsistency' } }
          errors[:warnings] << failure
          Success(errors)
        end
      end
    end
  end
end
