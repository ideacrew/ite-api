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

  validate :password_custom_rules

  def to_token_payload(_request = nil)
    if RailsJwtAuth.simultaneous_sessions.positive?
      auth_tokens&.last ? { auth_token: auth_tokens.last, dbh_user: dbh_user?, provider: provider?, provider_gateway_identifier:, provider_id:, email: } : false
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

  def password_custom_rules
    if password.present? && (password.length < 8)
      errors.add :password, 'Password must be at least 8 characters'
    elsif password.present? && !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d ]).+$/)
      errors.add :password, 'Your password must include at least 1 lowercase letter, 1 uppercase letter, 1 number, and 1 character that’s not a number, letter, or space.'
    elsif password.present? && password.match(/#{::Regexp.escape(email)}/i)
      errors.add :password, 'Password cannot contain username'
    end
  end
end
