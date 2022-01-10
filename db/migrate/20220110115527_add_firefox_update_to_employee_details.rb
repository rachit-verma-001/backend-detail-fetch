class AddFirefoxUpdateToEmployeeDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :employee_details, :firefox_update, :string
  end
end
