# frozen_string_literal: true

module Operations
  module Api
    module V1
      # operation to validate provider extract
      class Extract
        def call(params)
          validated_extract = yield validate_extract(params)
          extract_entity = yield create_entity(validated_extract)
        end

        private

        def validate_extract(params)
          result = ::Validators::Api::V1::ExtractContract.new.call(params)

          result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
        end

        def create_entity(validated_extract)
          # TBD
        end
      end
    end
  end
end
