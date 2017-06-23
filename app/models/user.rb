class User < ApplicationRecord
  # Global
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  CN_CELLULAR = /\A0?(13[0-9]|15[012356789]|17[0135678]|18[0-9]|14[579])[0-9]{8}\z/

  # Password & Tokens
  has_secure_password
  has_secure_token :remember_token

  # Validations
  validates_with IdentificationValidator
  validates :email, length: { maximum: 255 }, allow_nil: true,
                    format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :cell_number, format: { with: CN_CELLULAR },
                          uniqueness: true, allow_nil: true
  validates :password, length: { minimum: 6, maximum: 50 }, allow_blank: true

  # Attributes
  attribute :ident, :string
  attribute :remember_token, :string

  # Filter
  before_save :downcase_email


  def self.create_digest(token)
    BCrypt::Password.create(token, cost: 10)
  end

  def authenticate_token?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest) == token
  end

  def remember
    regenerate_remember_token
    update(remember_digest: User.create_digest(remember_token))
  end

  def forget
    update(remember_token: nil, remember_digest: nil)
  end

  private

    def downcase_email
      email.downcase! unless email.nil?
    end
end
