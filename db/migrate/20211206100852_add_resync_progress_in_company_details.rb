class AddResyncProgressInCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :resync_progress, :string
  end
end
