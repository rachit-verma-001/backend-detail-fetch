class CreateCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :company_details do |t|
      t.string :name
      t.string :tagline
      t.string :description
      t.string :city
      t.string :followers
      t.integer :no_of_employees
      t.string :logo
      t.integer :founders_count

      t.timestamps
    end
  end
end
