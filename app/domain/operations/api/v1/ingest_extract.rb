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
          provider = yield get_provider(params)
          validated_extract = yield validate_extract(params)
          extract_entity = yield create_entity(validated_extract)
          extract = yield create_extract(extract_entity, provider)
          create_records(extract, params)
        end

        private

        def get_provider(params)
          return Failure('no provider identifier') unless params[:provider_gateway_identifier]

          providers = ::Api::V1::Provider.where(provider_gateway_identifier: params[:provider_gateway_identifier].to_i)
          return Failure("no provider exists or more than one provider was found with provider gatweway id #{params[:provider_gateway_identifier]}") unless providers.count == 1

          Success(providers.first)
        end

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

        def create_extract(extract_entity, provider)
          extract = provider.extracts.build(extract_entity.to_h)
          provider.save ? Success(provider.extracts.find(extract.id)) : Failure('Failed to save extract')
        end

        def create_records(extract, params)
          if params[:records]
            params[:records].each do |record|
              result = Operations::Api::V1::CreateRecord.new.call(extract: extract.attributes.symbolize_keys,
                                                                  payload: record, dups: dup_episode_ids(params))
              record_object = extract.records.build
              record_object.assign_attributes(result.success.attributes)
            end
            extract.status = extract.records&.select { |t| t.status == 'Invalid' }&.any? ? 'Invalid' : 'Valid'
            extract.save!
          end
          Success(extract)
        end

        def dup_episode_ids(params)
          episode_ids = params[:records].map.map { |r| r[:episode_id] }
          episode_ids.select { |e| episode_ids.count(e) > 1 }.uniq
        end
      end
    end
  end
end
