# frozen_string_literal: true

class Api::V1::Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  # skip_before_action :verify_authenticity_token, only: :create

  def create
    user = User.find_by(email:params[:user][:email])
    if user && user.confirmed_at?
    # if user
      return render json: { success: false, message: "Invalid Credentials" }, status: 422 unless warden.authenticate?(auth_options)
      @user = warden.authenticate!(auth_options)
      token = Tiddle.create_and_return_token(@user, request)
      [:one_signal_player_id]
      user_details = {id: @user.id, name: @user.name, email: @user.email, auth_token: token, is_social: false}
      render json: { message: "User successfully logged in", user: user_details,success: true}
    else
      render json: { success: false, message: 'Invalid credentials, confirm you email first'}, status: 422
    end
  end

  def destroy
    if current_user
      Tiddle.expire_token(current_user, request)
      render json: {message: "successfully Logout",success: true}
     else
      render json: {error: "Invalid Token",success: false}, status: 422
     end
  end

  private

   def verify_signed_out_user; end
  def resource_name
     :user
  end
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
