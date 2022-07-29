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
          update_record(errors, record)
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
          # flatten errors and separate into warnings and failures
          warnings = result.errors.messages.select { |message| message.meta[:warning] }.map { |message| { message.path.last => message.text } }
          failures = result.errors.messages.reject { |message| message.meta[:warning] }.map { |message| { message.path.last => message.text } }
          Success(warnings:, failures:)
        end

        def update_record(errors, record)
          record.status = errors.compact_blank.any? ? 'Invalid' : 'Valid'
          record.failures = errors[:failures].compact_blank!
          record.warnings = errors[:warnings].compact_blank!
          Success(record)
        end
      end
    end
  end
end
