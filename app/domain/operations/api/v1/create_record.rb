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
          update_record(validation_result, record)
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

        def update_record(result, record)
          record.status = result.errors.any? ? 'Invalid' : 'Valid'
          errors = result.errors.to_h
          warnings = []
          errors.select { |_k, v| v.first.instance_of?(Hash) && v.first.key?(:warning) }.each do |warning|
            warnings << warning
          end
          failures = []
          failures << errors.select { |_k, v| v.first.instance_of?(String) }
          failures << errors.select { |_k, v| v.first.instance_of?(Hash) && !v.first.key?(:warning) }
          record.failures = failures.compact_blank!
          record.warnings = warnings.compact_blank!
          Success(record)
        end
      end
    end
  end
end
