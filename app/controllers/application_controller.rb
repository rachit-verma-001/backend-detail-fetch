class ApplicationController < ActionController::API

  # include DeviseTokenAuth::Concerns::SetUserByToken
  # protect_from_forgery
  before_action :check_route
  rescue_from Exception, :with => :error_generic
  include ActionController::MimeResponds
  def check_route
    
    # if request.host == "azure-test-vm-window.eastus.cloudapp.azure.com"
    #   request.env["rack.url_scheme"] = "http"
    # end

    if request.path == "/users/sign_in" && request.method == "GET"
      redirect_to "https://fetch-detail-react.vercel.app/"
      # redirect_to "http://localhost:3000/"
    end
  end

  def error_generic(exception)
    ExceptionDetail.first.update(ex_status:exception.message)
    render json:{success:false, message:exception.message}, status:200
  end


end
