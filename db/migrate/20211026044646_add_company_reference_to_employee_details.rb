class AddCompanyReferenceToEmployeeDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :employee_details, :company_detail_id, :integer
  end
end
