# frozen_string_literal: true

module Api
  module V1
    # office location for a provider
    class OfficeLocation
      include Mongoid::Document
      include Mongoid::Timestamps

      embedded_in :provider, class: 'Api::V1::Provider'

      field :is_primary, type: Boolean, default: true
      field :provider_location, type: String

      embeds_one :address, class_name: 'Api::V1::Address'
      embeds_many :phone, class_name: 'Api::V1::Phone'
      embeds_many :email, class_name: 'Api::V1::Email'

      validates_presence_of :address, class_name: 'Api::V1::Address'
      validates_presence_of :phone, class_name: 'Api::V1::Phone'
    end
  end
end
