module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  before_action :configure_permitted_parameters, only: [:create, :update_password]
  # skip_before_action :verify_authenticity_token, only: :create
  def create
    build_resource(sign_up_params)
    if User.find_by_email(resource.email)
      render json: { message: "This user is already present",success: false }, status: 422
      return
    else
      resource.save
      return render json:{message: resource.errors.full_messages.join(" and "),success: false }, status:422 if resource.errors.present?
      token = Tiddle.create_and_return_token(resource, request)
      yield resource if block_given?
    end
    unless resource.persisted?
      clean_up_passwords resource
      set_minimum_password_length
      return render json:{message: resource.errors.as_json, :success=>false}, status: 422
    end
    if resource.active_for_authentication?
      sign_up(resource_name, resource)
    else
      expire_data_after_sign_in!
    end
      # Device.update_or_create_by(resource.id, params[:user][:one_signal_player_id]) if params[:user][:one_signal_player_id]

      @user = {id: resource.id, name: resource.name, email: resource.email, auth_token: token, is_social: false}

      # resource.update_attributes(confirmation_otp: rand.to_s[2..6])
      # UserMailer.welcome_email(resource).deliver_now

    render json: { success: false, message: "You will receive an confirmation email on registered email_id",user: @user }, status:422
  end

  # def forgot_password
  #   if params[:user][:email].blank? # check if email is present
  #     return render json: {message: 'Email not present', success: false}
  #   end
  #   user = User.find_by(email: params[:user][:email]) # if present find user by email
  #   if user.present?
  #     user.send_reset_password_instructions
  #     render json: {success: true, message:'You will receive an email with instructions on how to reset your password in a few minutes'}, status: :ok
  #   else
  #     render json: {success: false, error: ['Email address not found. Please check and try again.']}, status: :not_found
  #   end
  # end

  # def update_password
  #   user = User.find_by_reset_password_token(params[:token])
  #   if user.present? && params[:new_password] == params[:confirm_new_password]
  #     user.update(password: params[:new_password] )
  #     render json: {status: :success, message: "Password update successfully", :success=>true}
  #   else
  #     render json: {message: "Token or password does not match", :success=>false}
  #   end
  # end



  def change_password
    # if params['password'].present? && !current_user.valid_password?(params['old_password'])
    #             # render json: {success: true, message: "User updated successfully", user: user_format,status: 200}

    #   render json: {message: 'Old_password Does not match',success: false,user: user_format,status: 200}
    # else
    unless current_user
      render json: {message: 'Invalid Credentials',success: false}
    else
      current_user.update(password: params[:update_password])
      render json: {success: true, message: "Password changed successfully"}
    end
  end



  private
  def sign_up_params
    params.require(:user).permit(:email, :password)

  end

  protected

  def configure_permitted_parameters
    param_keys = [:email, :password ]
    devise_parameter_sanitizer.permit(:sign_up, keys: param_keys)
  end

  def resource_name
    :user
  end



    end
  end
end