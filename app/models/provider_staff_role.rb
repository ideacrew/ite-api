# frozen_string_literal: true

# staff role information for provider users
class ProviderStaffRole
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :user, class_name: 'User'

  field :provider_gateway_identifier, type: String
  field :provider_id, type: BSON::ObjectId
  field :is_active, type: Boolean

  def active?
    is_active
  end

  def provider_name
    provider = Api::V1::Provider.find(provider_id)
    return unless provider

    provider.provider_name
  end
end
