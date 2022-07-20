# frozen_string_literal: true

module Api
  module V1
    # entity to define a client for use in payload validation
    class Client < Dry::Struct
      # Client ID
      # First Name
      # Middle Name
      # Last Name
      # Alternate Last Name
      # Alias
      # Social Security Number
      # Medicaid ID
      # Date of Birth
      # Gender
      # Sexual Orientation
      # Race
      # Hispanic or Latino Origin (Ethnicity)
      # Primary Language
      # attribute :address, Types::Array.of(Address)
      # phone 1
      # phone 2
    end
  end
end
