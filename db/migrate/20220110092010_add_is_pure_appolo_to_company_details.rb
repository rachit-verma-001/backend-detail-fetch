class AddIsPureAppoloToCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :is_pure_apollo, :boolean
  end
end
