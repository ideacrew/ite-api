# frozen_string_literal: true

module Api
  module V1
    # entity to define a service episode for use in payload validation
    class Episode < Dry::Struct
      # Codependent or Collateral
      attribute :codepedent, Types::Integer.optional.meta(omittable: true) # confirm type
      # Admission Type
      attribute :admission_type, Types::Integer.optional.meta(omittable: true) # confirm type
      # Admission Date
      attribute :admission_date, Types::Date.optional.meta(omittable: true)
      # Treatment Setting or Service Type
      attribute :treatment_type, Types::Integer.optional.meta(omittable: true)
      # Date of First Contact or Request for Service
      attribute :service_request_date, Types::Date.optional.meta(omittable: true)
      # Discharge Date
      attribute :discharge_date, Types::Date.optional.meta(omittable: true)
      # Discharge Type
      attribute :discharge_type, Types::Integer.optional.meta(omittable: true) # confirm type
      # Discharge Reason
      attribute :discharge_reason, Types::Integer.optional.meta(omittable: true)
      # Data of Last Contact
      attribute :last_contact_date, Types::Date.optional.meta(omittable: true)
      # Number of Prior SU Treatment Episodes
      attribute :num_of_prior_episodes, Types::Integer.optional.meta(omittable: true) # confirm type
      # Referral Source
      attribute :referral_source, Types::Integer.optional.meta(omittable: true)
      # Detailed Criminal Justice Referral
      attribute :criminal_justice_referral, Types::Integer.optional.meta(omittable: true) # confirm type
      # Payment Source, Primary (Expected or Actual)
      attribute :primary_payment_source, Types::Integer.optional.meta(omittable: true)
      attribute :client, Client
      attribute :client_profile, ClientProfile
      attribute :clinical_info, ClinicalInfo
    end
  end
end
