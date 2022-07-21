# frozen_string_literal: true

module Operations
  module Api
    module V1
      # operation to validate provider extract
      class IngestExtract

        def call(params)
          validated_extract = yield validate_extract(params)
          extract_entity = yield create_entity(validated_extract)
          extract = yield create_extract(extract_entity)

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

        def create_extract(extract_entity)
          extract = Api::V1::Extract.new(extract_entity)
          extract.save ? Success(extract) : Failure("Failed to save extract")
        end

        def validate_transactions(extract_entity)
          Operations::Api:V1::CreateTransactions
        end
      end
    end
  end
end
