# frozen_string_literal: true

module Api
  module V1
    # office location for a provider
    class Email
      include Mongoid::Document
      include Mongoid::Timestamps

      embedded_in :office_location, class: 'Api::V1::OfficeLocation'

      field :address, type: String

      validates :address, email: true, allow_blank: false
    end
  end
end
