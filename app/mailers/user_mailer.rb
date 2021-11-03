class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers

  def welcome_email(user)
    @user = user
    @content = EmailSetting.where(event_name: "welcome email").first&.content
    mail(to: @user.email.downcase, subject: 'Account created successfull.')
  end

end