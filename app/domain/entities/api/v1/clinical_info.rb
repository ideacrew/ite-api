# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity to define the clinical info for use in payload validation
      class ClinicalInfo < Dry::Struct
        # GAF/CGAS Score – Optional
        attribute :gaf_score, Types::String.optional.meta(omittable: true)
        # SMI/SED Status
        attribute :smi_sed, Types::String.optional.meta(omittable: true)
        # Co-occurring substance abuse and mental health problems
        attribute :co_occurring_sud_mh, Types::String.optional.meta(omittable: true)
        # Medication-Assisted Opioid Therapy
        attribute :opioid_therapy, Types::String.optional.meta(omittable: true)
        attribute :primary_substance, Types::String.optional.meta(omittable: true)
        attribute :secondary_substance, Types::String.optional.meta(omittable: true)
        attribute :tertiary_substance, Types::String.optional.meta(omittable: true)
        attribute :primary_drug_code, Types::String.optional.meta(omittable: true)
        attribute :secondary_drug_code, Types::String.optional.meta(omittable: true)
        attribute :tertiary_drug_code, Types::String.optional.meta(omittable: true)
        attribute :primary_su_frequncy_admission, Types::String.optional.meta(omittable: true)
        attribute :secondary_su_frequency_admission, Types::String.optional.meta(omittable: true)
        attribute :tertiary_su_frequency_admission, Types::String.optional.meta(omittable: true)
        attribute :primary_su_frequency_discharge, Types::String.optional.meta(omittable: true)
        attribute :secondary_su_frequency_discharge, Types::String.optional.meta(omittable: true)
        attribute :tertiary_su_frequency_discharge, Types::String.optional.meta(omittable: true)
        attribute :primary_su_route, Types::String.optional.meta(omittable: true)
        attribute :secondary_su_route, Types::String.optional.meta(omittable: true)
        attribute :tertiary_su_route, Types::String.optional.meta(omittable: true)
        attribute :primary_su_age_at_first_use, Types::String.optional.meta(omittable: true)
        attribute :sud_diagnostic_codes, Types::Array.of(Types::String)
        attribute :mh_diagnostic_codes, Types::Array.of(Types::String)
        attribute :non_bh_dx1, Types::String.optional.meta(omittable: true)
        attribute :non_bh_dx2, Types::String.optional.meta(omittable: true)
        attribute :non_bh_dx3, Types::String.optional.meta(omittable: true)
      end
    end
  end
end
