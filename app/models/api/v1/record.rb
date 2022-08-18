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
    end
  end
end
