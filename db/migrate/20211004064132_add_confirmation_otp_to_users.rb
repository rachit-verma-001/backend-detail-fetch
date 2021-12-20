class AddConfirmationOtpToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :confirmation_otp, :string
  end
end
