class User < ApplicationRecord
  # Global
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  CN_CELLULAR = /\A0?(13[0-9]|15[012356789]|17[0135678]|18[0-9]|14[579])[0-9]{8}\z/

  # Password & Tokens
  has_secure_password
  has_secure_token :remember_token

  # Realtionships
  has_one  :wallet
  has_one  :cart
  has_many :orders
  has_many :addresses, as: :addressable, dependent: :destroy

  # Callbacks
  before_save :downcase_email
  before_validation :assign_member_id

  # Validations
  validates :email, length: { maximum: 255 }, allow_nil: true,
                    format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :cell_number, format: { with: CN_CELLULAR },
                          uniqueness: true, allow_nil: true
  validates :member_id, presence: true, uniqueness: true,
                        inclusion: { in: 100_000..999_999 }
  validates_with IdentificationValidator
  validates :password, length: { minimum: 6, maximum: 50 }, allow_blank: true

  # Attributes
  attribute :ident, :string
  attribute :remember_token, :string


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

  def set_as_customer
    update(type: 'Customer')
  end

  def customer?
    type == 'Customer'
  end

  def admin?
    User.admin_types.include?(self.class.to_s)
  end

  protected

    def self.admin_types
      ['Admin']
    end

  private

    def downcase_email
      email.downcase! unless email.nil?
    end

    def assign_member_id
      return if self.member_id
      begin
        self.member_id = SecureRandom.random_number(1_000_000)
        raise unless self.member_id >= 100_000
        raise if User.where(member_id: self.member_id).exists?
      rescue
        retry
      end
    end

end
