# frozen_string_literal: true

module Api
  module V1
    # provider object
    class Provider
      include Mongoid::Document
      include Mongoid::Timestamps

      field :provider_name, type: String
      field :provider_nick_name, type: String
      field :npi, type: String # always length 10-digits
      field :provider_gateway_identifier, type: String # unique length->3 digits
      field :is_active, type: Boolean
      field :mh, type: Boolean
      field :sud, type: Boolean
      field :adult_care, type: Boolean
      field :child_care, type: Boolean

      # embeds_many :extracts
      embeds_many :office_locations, class_name: 'Api::V1::OfficeLocation', cascade_callbacks: true

      validates_presence_of :provider_gateway_identifier, :provider_name, :npi, :is_active, :mh, :sud, :adult_care,
                            :child_care, :office_locations

      index({ provider_gateway_identifier: 1 }, { sparse: true })
    end
  end
end
