class IdentificationValidator < ActiveModel::Validator

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate(record)
    if record.email.nil? && record.cell_number.nil?
      record.errors.add(
        :base,
        I18n.t('activerecord.validators.user.ident')
      )
    end
  end
end
