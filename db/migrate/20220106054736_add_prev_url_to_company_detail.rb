class AddPrevUrlToCompanyDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :prev_url, :string
  end
end
