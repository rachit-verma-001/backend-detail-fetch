class AddAboutToCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :about, :string
  end
end
