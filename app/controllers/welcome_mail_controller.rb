class WelcomeMailController < Devise::RegistrationsController

  def create
    super
    if @user.persisted?
      UserMailer.delay.welcome(@user.id)
    end
  end

end
