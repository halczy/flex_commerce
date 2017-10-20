class ReferralValidator < ActiveModel::Validator

  def validate(record)
    if record.referer == record.referee
      record.errors.add(
        :base, 
        I18n.t('activerecord.validators.referral.invalid_relation'))
    end
  end

end
