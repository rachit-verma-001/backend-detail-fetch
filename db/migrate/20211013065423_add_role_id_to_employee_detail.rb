class AddRoleIdToEmployeeDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :employee_details, :role_id, :integer
  end
end
