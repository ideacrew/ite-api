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
          transaction = yield create_entity(params)
          validated_episode = yield validate_episode(transaction)
        end

        private

        def create_entity(params)
          result = Try do
            ::Entities::Api::V1::Transaction.new(payload: params[:payload].to_h)
          end
          result.success? ? Success(result.value!) : Failure(result)
        end

        def validate_episode(transaction)
          binding.pry

          result = ::Validators::Api::V1::EpisodeContract.new.call(transaction.payload)

          result.success? ? Success(result.to_h) : Failure(result)
        end
      end
    end
  end
end
