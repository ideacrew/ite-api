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

      embeds_many :extracts, class_name: 'Api::V1::Extracts', cascade_callbacks: true
      embeds_many :office_locations, class_name: 'Api::V1::OfficeLocation', cascade_callbacks: true

      accepts_nested_attributes_for :office_locations, :extracts

      validates :npi,
                numericality: true,
                length: { minimum: 10, maximum: 10, message: '%<value>s is not a valid npi' },
                allow_blank: false

      validates_presence_of :provider_name, :is_active, :mh, :sud, :adult_care,
                            :child_care, :office_locations, :provider_gateway_identifier

      before_validation :generate_gateway_id

      index({ provider_gateway_identifier: 1 }, { sparse: true })

      private

      def generate_gateway_id
        loop do
          self.provider_gateway_identifier = (SecureRandom.random_number(9e2) + 1e2).to_i
          break unless self.class.all.detect { |p| p.provider_gateway_identifier == provider_gateway_identifier }
        end
      end
    end
  end
end
