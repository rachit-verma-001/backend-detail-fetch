class ApplicationController < ActionController::API

  # include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :check_route
  include ActionController::MimeResponds
  def check_route
    if request.path == "/users/sign_in" && request.method == "GET"
      # redirect_to "https://fetch-detail-react.vercel.app/"
      redirect_to "http://localhost:3000/"
    end
  end
end
