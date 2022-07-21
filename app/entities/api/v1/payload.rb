# frozen_string_literal: true

module Api
  module V1
    # entity for extract payload for use in validations
    class Payload < Dry::Struct
      attribute :provider_identifier, Types::String
      attribute :npi, Types::String.optional.meta(omittable: true)
      attribute :coverage_start, Types::Date.optional.meta(omittable: true)
      attribute :coverage_end, Types::Date.optional.meta(omittable: true)
      attribute :extracted_on, Types::Date.optional.meta(omittable: true)
      attribute :file_name, Types::String.optional.meta(omittable: true)
      attribute :file_type, Types::String.optional.meta(omittable: true)
      attribute :episodes, Types::Array.of(Episode).optional.meta(omittable: true)
    end
  end
end
