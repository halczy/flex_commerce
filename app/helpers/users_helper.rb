module UsersHelper
  # Global
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  CN_CELLULAR = /\A0?(13[0-9]|15[012356789]|17[0135678]|18[0-9]|14[579])[0-9]{8}\z/

  def analyize_ident
    if is_email?
      params[:user][:email] = params[:user][:ident]
    elsif is_cell_number?
      params[:user][:cell_number] = params[:user][:ident]
    end
  end

  def is_email?
    EMAIL_REGEX.match?(params[:user][:ident])
  end

  def is_cell_number?
    CN_CELLULAR.match?(params[:user][:ident])
  end

end
