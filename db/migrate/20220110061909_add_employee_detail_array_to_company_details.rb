class AddEmployeeDetailArrayToCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :details, :string, array:true, default:[]
  end
end
