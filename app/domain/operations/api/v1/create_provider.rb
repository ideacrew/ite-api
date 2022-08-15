# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'dry/monads/try'

module Operations
  module Api
    module V1
      # operation to validate provider extract
      class CreateProvider
        send(:include, Dry::Monads[:result, :do, :try])

        def call(params)
          validated_provider_params = yield validate_provider(params)
          provider_entity = yield create_provider_entity(validated_provider_params)
          create_provider(provider_entity)
        end

        private

        def validate_provider(params)
          result = ::Validators::Api::V1::ProviderContract.new.call(params)

          result.success? ? Success(result.to_h) : Failure(result)
        end

        # def check_for_existing_provider(validated_provider_params)
        # check for provider with provider gateway identifier OR same other combo of features? (name and npi and ??)
        # end

        def create_provider_entity(validated_provider_params)
          result = Try do
            ::Entities::Api::V1::Provider.new(validated_provider_params)
          end
          result.success? ? Success(result.value!) : Failure(result)
        end

        def create_provider(provider_entity)
          provider = ::Api::V1::Provider.new(provider_entity.to_h)
          provider.save ? Success(provider) : Failure('Failed to save provider')
        end
      end
    end
  end
end
