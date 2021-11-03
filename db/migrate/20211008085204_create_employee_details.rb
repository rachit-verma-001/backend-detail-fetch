class CreateEmployeeDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :employee_details do |t|
      t.string :first_name
      t.string :last_name
      t.string :city
      t.string :description
      t.string :email
      t.string :connection
      t.string :designation
      t.string :image

      t.timestamps
    end
  end
end
