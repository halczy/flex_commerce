class ReferralValidator < ActiveModel::Validator

  def validate(record)
    if record.referer == record.referee
      record.errors.add(:base, 'Referer and referee cannot be the same user.')
    end
  end

end
