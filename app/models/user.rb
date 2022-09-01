# frozen_string_literal: true

# User model
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include RailsJwtAuth::Authenticatable
  include RailsJwtAuth::Recoverable
  include RailsJwtAuth::Trackable

  field :email, type: String

  embeds_one :provider_staff_role, class_name: 'ProviderStaffRole', cascade_callbacks: true
  embeds_one :dbh_staff_role, class_name: 'DbhStaffRole', cascade_callbacks: true

  validates :email, presence: true,
                    uniqueness: true,
                    format: URI::MailTo::EMAIL_REGEXP

  def to_token_payload(_request = nil)
    if RailsJwtAuth.simultaneous_sessions.positive?
      auth_tokens&.last ? { auth_token: auth_tokens.last, dbh_user: dbh_user?, provider: provider?, provider_gateway_identifier:, provider_id: } : false
    else
      { id: id.to_s }
    end
  end

  def dbh_user?
    return false unless dbh_staff_role

    dbh_staff_role.active?.present?
  end

  def provider?
    return false unless provider_staff_role

    provider_staff_role.active?.present?
  end

  def provider_gateway_identifier
    return unless provider?

    provider_staff_role&.provider_gateway_identifier
  end

  def provider_id
    return unless provider?

    provider_staff_role&.provider_id&.to_s
  end
end
