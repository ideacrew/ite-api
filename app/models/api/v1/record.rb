# frozen_string_literal: true

module Api
  module V1
    # record model
    class Record
      include Mongoid::Document
      include Mongoid::Timestamps

      field :payload, type: Hash
      field :warnings, type: Array
      field :critical_errors, type: Array
      field :fatal_errors, type: Array
      field :status, type: String

      belongs_to :extract, inverse_of: :records, class_name: 'Api::V1::Extract'

      validates_presence_of :payload

      index({ status: 1 })

      def details
        return attributes unless payload[:ssn]
        return attributes if payload[:ssn].blank?
        return attributes if warnings.detect { |warning| warning[:ssn] }

        attributes['payload']['ssn'] = obscure_ssn(payload[:ssn])
        attributes
      end

      def obscure_ssn(original_ssn)
        "***-**-#{original_ssn[-4..]}"
      end
    end
  end
end
