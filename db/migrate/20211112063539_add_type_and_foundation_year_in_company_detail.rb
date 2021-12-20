class AddTypeAndFoundationYearInCompanyDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :company_type,:string
    add_column :company_details, :foundation_year, :string
  end
end
