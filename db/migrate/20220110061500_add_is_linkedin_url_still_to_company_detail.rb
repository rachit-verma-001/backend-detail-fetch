class AddIsLinkedinUrlStillToCompanyDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :is_linkedin_url, :boolean
  end
end
