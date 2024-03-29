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
          warnings = ::Api::V1::Record::OPTIONAL_FIELDS
          critical_error_fields = ::Api::V1::Record::REQUIRED_FIELDS
          fatal_error_fields = ::Api::V1::Record::KEY_FIELDS
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
