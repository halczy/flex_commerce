module UsersHelper
  # Global
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  CN_CELLULAR = /\A0?(13[0-9]|15[012356789]|17[0135678]|18[0-9]|14[579])[0-9]{8}\z/
  MEMBER_ID = /\A^\d{6}$|^\d{3}-\d{3}$\z/

  def convert_ident
    @ctl = controller.controller_name.singularize.to_sym

    if is_email?
      params[@ctl][:email] = params[@ctl][:ident]
    elsif is_cell_number?
      params[@ctl][:cell_number] = params[@ctl][:ident]
    elsif is_member_id?
      params[@ctl][:member_id] = params[@ctl][:ident].delete('-')
    end
  end

  def is_email?
    EMAIL_REGEX.match?(params[@ctl][:ident])
  end

  def is_cell_number?
    CN_CELLULAR.match?(params[@ctl][:ident])
  end

  def is_member_id?
    MEMBER_ID.match?(params[@ctl][:ident])
  end

  def convert_to_dashed_id(integer_id)
    member_id_str = integer_id.to_s
    "#{member_id_str[0..2]}-#{member_id_str[-3..-1]}"
  end

end
