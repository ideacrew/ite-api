# frozen_string_literal: true

module Api
  module V1
    # entity to define a service episode for use in payload validation
    class Episode < Dry::Struct
      # Codependent or Collateral
      # Admission Type
      # Admission Date
      # Treatment Setting or Service Type
      # Date of First Appointment Offered
      # Date of First Contact or Request for Service
      # Discharge Date
      # Discharge Type
      # Discharge Reason
      # Data of Last Contact
      # Number of Prior SU Treatment Episodes
      # Referral Source
      # Detailed Criminal Justice Referral
      # Payment Source, Primary (Expected or Actual)
      attribute :client, Client
      attribute :client_profile, ClientProfile
      attribute :clinical_info, ClinicalInfo
    end
  end
end
