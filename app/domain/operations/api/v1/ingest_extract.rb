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
          create_records(extract, params)
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

        def create_records(extract, params)
          if params[:records]
            params[:records].each do |record|
              result = Operations::Api::V1::CreateRecord.new.call(extract: extract.attributes.symbolize_keys,
                                                                  payload: record)
              record_object = extract.records.build
              record_object.assign_attributes(result.success.attributes)
            end
            extract.status = extract.records&.select { |t| t.status == 'Invalid' }&.any? ? 'Invalid' : 'Valid'
            extract.save!
          end
          Success(extract)
        end
      end
    end
  end
end
