# frozen_string_literal: true

module Operations
  module Api
    module V1
      # operation to validate provider extract
      class Extract
        def call(params)
          validated_extract = yield validate_extract(params)
          extract_entity = yield create_entity(validated_extract)
          # save extract ?
          # validate payload for errors
          # add errors to extract, set extract status
          # save extract
        end

        private

        def validate_extract(params)
          result = ::Validators::Api::V1::ExtractContract.new.call(params)

          result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
        end

        def create_entity(_validated_extract)
          Success(::Api::V1::ExtractEntity.new.call(params))
        end
      end
    end
  end
end
