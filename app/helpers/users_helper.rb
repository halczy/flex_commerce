module UsersHelper
  # Global
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  CN_CELLULAR = /\A0?(13[0-9]|15[012356789]|17[0135678]|18[0-9]|14[579])[0-9]{8}\z/
  MEMBER_ID = /\A^\d{6}$|^\d{3}-\d{3}$\z/

  def convert_ident
    if is_email?
      params[:customer][:email] = params[:customer][:ident]
    elsif is_cell_number?
      params[:customer][:cell_number] = params[:customer][:ident]
    elsif is_member_id?
      params[:customer][:member_id] = params[:customer][:ident].delete('-')
    end
  end

  def is_email?
    EMAIL_REGEX.match?(params[:customer][:ident])
  end

  def is_cell_number?
    CN_CELLULAR.match?(params[:customer][:ident])
  end
  
  def is_member_id?
    MEMBER_ID.match?(params[:customer][:ident])
  end

end
