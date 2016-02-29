class UserMailer < ApplicationMailer

  def welcome(user)
    mail to: user.email, subject: "Welcome!"
  end
end
