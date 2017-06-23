class User < ApplicationRecord
  # Global
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  CN_CELLULAR = /\A0?(13[0-9]|15[012356789]|17[0135678]|18[0-9]|14[579])[0-9]{8}\z/

  # Validations
  has_secure_password
  has_secure_token :remember_token
  validates_with IdentificationValidator
  validates :email, length: { maximum: 255 }, allow_nil: true,
                    format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :cell_number, format: { with: CN_CELLULAR },
                          uniqueness: true, allow_nil: true
  validates :password, length: { minimum: 6, maximum: 50 }, allow_blank: true

  # Attributes
  attribute :ident, :string

  # Filter
  before_save :downcase_email

  def forget
    update(remember_token: nil)
  end

  private

    def downcase_email
      email.downcase! unless email.nil?
    end
end
