module SessionsHelpers
  def signin_as(user)
    session[:user_id] = user.id
  end
end

RSpec.configure do |c|
  c.include SessionsHelpers
end
