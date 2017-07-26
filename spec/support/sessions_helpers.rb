module SessionsHelpers
  def signin_as(user)
    session[:user_id] = user.id
  end

  def feature_signin_as(user)
    visit signin_path
    fill_in 'session[ident]', with: user.email
    fill_in 'session[password]', with: 'example'
    click_button 'Submit'
  end
end

RSpec.configure do |c|
  c.include SessionsHelpers
end
