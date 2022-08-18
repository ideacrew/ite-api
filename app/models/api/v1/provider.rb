# frozen_string_literal: true

module Api
  module V1
    # provider object
    class Provider
      include Mongoid::Document
      include Mongoid::Timestamps

      field :provider_name, type: String
      field :provider_nick_name, type: String
      field :npi, type: String
      field :provider_gateway_identifier, type: String
      field :is_active, type: Boolean
      field :mh, type: Boolean
      field :sud, type: Boolean
      field :adult_care, type: Boolean
      field :child_care, type: Boolean

      has_many :extracts, inverse_of: :provider, class_name: 'Api::V1::Extract'
      embeds_many :office_locations, class_name: 'Api::V1::OfficeLocation', cascade_callbacks: true

      accepts_nested_attributes_for :office_locations, :extracts

      validates :npi,
                numericality: true,
                length: { minimum: 10, maximum: 10, message: '%<value>s is not a valid npi' },
                allow_blank: false

      validates_presence_of :provider_name, :is_active, :mh, :sud, :adult_care,
                            :child_care, :office_locations

      validates :provider_gateway_identifier, numericality: true, uniqueness: true,
                                              length: { minimum: 3, maximum: 3, message: '%<value>s is not a valid provider_gateway_identifier' },
                                              allow_blank: false

      before_validation :generate_gateway_id, on: [:create]

      index({ provider_gateway_identifier: 1 }, { sparse: true })

      private

      def generate_gateway_id
        ids = self.class.all.map(&:provider_gateway_identifier)
        return if provider_gateway_identifier && !ids.include?(provider_gateway_identifier)

        loop do
          self.provider_gateway_identifier = (SecureRandom.random_number(9e2) + 1e2).to_i
          break unless ids.include?(provider_gateway_identifier)
        end
      end
    end
  end
end
