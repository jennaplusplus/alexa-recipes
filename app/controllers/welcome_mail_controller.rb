class WelcomeMailController < Devise::RegistrationsController

  def create
    super
    if @user.persisted?
      UserMailer.welcome(@user).deliver
    end
  end

end
