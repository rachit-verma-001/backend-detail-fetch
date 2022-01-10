class AddLinkedinUrlToEmployeeDetails < ActiveRecord::Migration[6.0]
  def change
  	add_column :employee_details, :linedin_url, :string
  end
end
