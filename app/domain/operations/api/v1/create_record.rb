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
          errors = yield structure_errors(validation_result, params[:extract])
          cross_record_errors = yield check_episode_ids(errors, params[:dups], episode)
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

        def structure_errors(result, extract)
          # flatten errors and separate into warnings and failures
          key_fields = %i[client_id collateral record_type admission_date treatment_type]
          key_fields << :discharge_date if extract[:record_group] == 'discharge'
          key_fields << :last_contact_date if extract[:record_group] == 'active'
          errors = result.errors.messages.map { |message| { message.path.last => message.text } }
          warnings = errors.reject { |error| key_fields.include? error.keys.first }
          failures = errors.select { |error| key_fields.include? error.keys.first }
          Success(warnings:, failures:)
        end

        def update_record(errors, record)
          record.status = errors.compact_blank.any? ? 'Invalid' : 'Valid'
          record.failures = errors[:failures].uniq.compact_blank!
          record.warnings = errors[:warnings].uniq.compact_blank!
          Success(record)
        end

        def check_episode_ids(errors, dups, episode)
          return Success(errors) unless dups

          duplicate = dups.include?(episode[:episode_id].to_i)
          return Success(errors) unless duplicate

          failure = { episode_id: 'must be a unique identifier for admission episodes' }
          errors[:failures] << failure
          Success(errors)
        end
      end
    end
  end
end
