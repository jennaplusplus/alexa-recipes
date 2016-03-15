class UserMailer < ApplicationMailer

  def welcome(user_id)
    user = User.find(user_id)
    @url = "https://www.alexarecipes.com/recipes"
    mail to: user.email, subject: "Welcome!"
  end
end
