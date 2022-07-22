# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity to define a client for use in payload validation
      class Client < Dry::Struct
        # Client ID
        attribute :client_id, Types::String
        # First Name
        attribute :first_name, Types::String.optional.meta(omittable: true)
        # Middle Name
        attribute :middle_name, Types::String.optional.meta(omittable: true)
        # Last Name
        attribute :last_name, Types::String.optional.meta(omittable: true)
        # Alternate Last Name
        attribute :last_name_alt, Types::String.optional.meta(omittable: true)
        # Alias
        attribute :alias, Types::String.optional.meta(omittable: true)
        # Social Security Number
        attribute :ssn, Types::String.optional.meta(omittable: true)
        # Medicaid ID
        attribute :medicaid_id, Types::String.optional.meta(omittable: true)
        # Date of Birth
        attribute :dob, Types::Date.optional.meta(omittable: true)
        # Gender
        attribute :gender, Types::String.optional.meta(omittable: true)
        # Sexual Orientation
        attribute :sexual_orientation, Types::String.optional.meta(omittable: true)
        # Race
        attribute :race, Types::String.optional.meta(omittable: true)
        # Hispanic or Latino Origin (Ethnicity)
        attribute :ethnicity, Types::String.optional.meta(omittable: true)
        # Primary Language
        attribute :primary_language, Types::String.optional.meta(omittable: true)
        # attribute :address, Types::Array.of(Address)
        attribute :phone1, Types::String.optional.meta(omittable: true)
        attribute :phone2, Types::String.optional.meta(omittable: true)
      end
    end
  end
end
