class User < ApplicationRecord
  # Global
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  CN_CELLULAR = /\A0?(13[0-9]|15[012356789]|17[0135678]|18[0-9]|14[579])[0-9]{8}\z/

  # Password & Tokens
  has_secure_password
  has_secure_token :remember_token

  # Realtionships
  has_one  :cart
  has_one  :wallet
  has_many :orders
  has_many :addresses,     as: :addressable,       dependent: :destroy
  has_many :transfer_outs, class_name: 'Transfer', foreign_key: 'transferer_id'
  has_many :transfer_ins,  class_name: 'Transfer', foreign_key: 'transferee_id'
  has_many :referrals,     class_name: 'Referral', foreign_key: 'referer_id'
  has_many :referees,      through: :referrals

  # Callbacks
  after_initialize  :load_settings
  before_validation :assign_member_id
  before_save       :downcase_email
  after_create      :create_wallet
  after_touch       :load_settings

  # Validations
  validates :email,       length: { maximum: 255 }, allow_nil: true,
                          allow_blank: true, format: { with: EMAIL_REGEX },
                          uniqueness: { case_sensitive: false }
  validates :cell_number, uniqueness: true, allow_nil: true, allow_blank: true,
                          format: { with: CN_CELLULAR }
  validates :member_id,   presence: true, uniqueness: true,
                          inclusion: { in: 100_000..999_999 }
  validates :password,    length: { minimum: 6, maximum: 50 }, allow_blank: true
  validates_with          IdentificationValidator

  # Attributes
  attribute :ident,          :string
  attribute :remember_token, :string
  attribute :referer_id,     :string
  attribute :alipay_account, :string

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

  def referer
    Referral.where(referee: self).try(:first).try(:referer)
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

    def load_settings
      settings.each do |key, value|
        send("#{key}=", value)
      end
    end

end
