class AddFirefoxStatusToCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :firefox_status, :string
  end
end
