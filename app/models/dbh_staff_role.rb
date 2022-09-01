# frozen_string_literal: true

# staff role information for dbh users
class DbhStaffRole
  embedded_in :user, class_name: 'User'

  field :is_active, type: Boolean

  def active?
    is_active
  end
end
