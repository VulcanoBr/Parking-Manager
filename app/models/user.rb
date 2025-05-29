
class User < ApplicationRecord

  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: :password_required?
  validates :user_type, presence: true, inclusion: { in: %w[admin manager] }

  before_save :downcase_email

  enum user_type: { admin: 'admin', manager: 'manager' }

  scope :admins, -> { where(user_type: 'admin') }
  scope :managers, -> { where(user_type: 'manager') }

  def admin?
    user_type == 'admin'
  end

  def manager?
    user_type == 'manager'
  end

  def display_name
    email.present? ? email.split('@').first.capitalize : ""
  end

  def can_access_dashboard?
    admin?
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def password_required?
    new_record? || password.present?
  end
end
