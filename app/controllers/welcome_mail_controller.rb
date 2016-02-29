class WelcomeMailController < Devise::RegistrationsController

  def create
    super
    if @user.persisted?
      UserMailer.delay.welcome(@user)
    end
  end

end
