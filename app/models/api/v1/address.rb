# frozen_string_literal: true

module Api
  module V1
    # address object
    class Address
      include Mongoid::Document
      include Mongoid::Timestamps

      embedded_in :office_location, class: 'Api::V1::OfficeLocation'

      field :address_line1, type: String, default: ''
      field :address_line2, type: String, default: ''
      field :dc_ward, type: String, default: ''
      field :city, type: String
      field :state, type: String
      field :zip, type: String

      validates_presence_of :state, :address_line1, :city

      validates :zip,
                allow_blank: false,
                format: {
                  with: /\A\d{5}(-\d{4})?\z/,
                  message: 'should be in the form: 12345 or 12345-1234'
                }
    end
  end
end
