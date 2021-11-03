class AddMobileNoInEmployeeDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :employee_details, :mobile_no, :string
  end
end
