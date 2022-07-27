# frozen_string_literal: true

module Api
  module V1
    # phone object for a location
    class Phone
      include Mongoid::Document
      include Mongoid::Timestamps

      embedded_in :office_location, class_name: 'Api::V1::OfficeLocation'

      field :area_code, type: String, default: ''
      field :number, type: String, default: ''
      field :extension, type: String, default: ''
      field :full_phone_number, type: String, default: ''

      before_save :set_full_phone_number

      # validates_presence_of :area_code, :number

      # validates :area_code,
      #           numericality: true,
      #           length: { minimum: 3, maximum: 3, message: '%<value>s is not a valid area code' },
      #           allow_blank: true

      # validates :number,
      #           numericality: true,
      #           length: { minimum: 7, maximum: 7, message: '%<value>s is not a valid phone number' },
      #           allow_blank: true

      def to_s
        full_number = (area_code + number).to_i
        if extension.present?
          full_number.to_s(:phone, area_code: true, extension:)
        else
          full_number.to_s(:phone, area_code: true)
        end
      end

      def set_full_phone_number
        self.full_phone_number = to_s
      end
    end
  end
end
