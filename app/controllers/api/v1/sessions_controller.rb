module Api
  module V1
   class SessionsController < Devise::SessionsController
    def create
      user = User.find_by(email:params[:user][:email])
      if user
        return render json: { success: false, message: "Invalid Credentials" }, status: 422 unless warden.authenticate?(auth_options)
        @user = warden.authenticate!(auth_options)
        token = Tiddle.create_and_return_token(@user, request)
        user_details = {id: @user.id, name: @user.name, email: @user.email, auth_token: token, is_social: false}
        render json: { message: "User successfully logged in", user: user_details,success: true}
      else
        render json: { success: false, message: 'Invalid credentials'}, status: 422
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

    end
  end
end