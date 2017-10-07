class ReferralsController < ApplicationController

  def set_referral
    user = User.find_by(email: params[:id]) ||
           User.find_by(cell_number: params[:id]) ||
           User.find_by(member_id: params[:id]) ||
           User.find_by(id: params[:id])

    if user
      redirect_to(signup_path(referer_id: user.id))
    else
      flash[:warning] = 'The referral link is invalid.'
      redirect_to(signup_path)
    end
  end

end
