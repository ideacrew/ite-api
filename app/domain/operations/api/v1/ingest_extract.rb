# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'dry/monads/try'
require 'csv'

module Operations
  module Api
    module V1
      # operation to validate provider extract
      class IngestExtract
        send(:include, Dry::Monads[:result, :do, :try])

        def call(params)
          validated_extract = yield validate_extract(params)
          extract_entity = yield create_entity(validated_extract)
          extract = yield create_extract(extract_entity)
          _transactions = create_transactions(extract, params)

          # validate payload for errors
          # add errors to extract, set extract status
          # save extract
        end

        private

        def validate_extract(params)
          result = ::Validators::Api::V1::ExtractContract.new.call(params)

          result.success? ? Success(result.to_h) : Failure(result)
        end

        def create_entity(validated_extract)
          result = Try do
            ::Entities::Api::V1::Extract.new(validated_extract)
          end

          result.success? ? Success(result.value!) : Failure(result)
        end

        def create_extract(extract_entity)
          extract = ::Api::V1::Extract.new(extract_entity.to_h)
          extract.save ? Success(extract) : Failure('Failed to save extract')
        end

        def validate_transactions(extract, params)
          if params[:csv].present?
            CSV.parse(File.read(params[:csv]), headers: true)
            Operations::Api :V1::CreateTransaction
          else
            Operations::Api :V1::CreateTransaction.new.call(extract:, payload: params[:json])
          end
        end
      end
    end
  end
end
