class AddUrlInCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :url,:string
  end
end
