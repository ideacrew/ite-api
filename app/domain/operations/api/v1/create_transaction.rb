# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'dry/monads/try'

module Operations
  module Api
    module V1
      # operation to create transaction
      class CreateTransaction
        send(:include, Dry::Monads[:result, :do, :try])

        def call(params)
          transaction_entity = yield create_entity(params)
          transaction = yield create_transaction(transaction_entity)
          episode = yield structure_episode(transaction, params)
          validation_result = yield validate_episode(episode, params[:extract])
          update_transaction(validation_result, transaction)
        end

        private

        def create_entity(params)
          result = Try do
            ::Entities::Api::V1::Transaction.new(payload: params[:payload].to_h)
          end
          result.success? ? Success(result.value!) : Failure(result)
        end

        def create_transaction(transaction_entity)
          result = Try do
            ::Api::V1::Transaction.new(transaction_entity.to_h)
          end
          result.success? ? Success(result.value!) : Failure(result)
        end

        def structure_episode(transaction, _params)
          Transforms::Api::V1::ToEpisode.new.call(transaction)
        end

        def validate_episode(episode, extract)
          # merge in extract attributes to allow for validation against extract fields
          Success(::Validators::Api::V1::EpisodeContract.new.call(episode.merge(extract)))
        end

        def update_transaction(result, transaction)
          transaction.status = result.errors.any? ? 'Invalid' : 'Valid'
          errors = result.errors.to_h
          warnings = []
          errors.select { |_k, v| v.first.instance_of?(Hash) && v.first.key?(:warning) }.each do |warning|
            warnings << warning
          end
          failures = []
          failures << errors.select { |_k, v| v.first.instance_of?(String) }
          failures << errors.select { |_k, v| v.first.instance_of?(Hash) && !v.first.key?(:warning) }
          transaction.failures = failures.compact_blank!
          transaction.warnings = warnings.compact_blank!
          Success(transaction)
        end
      end
    end
  end
end
