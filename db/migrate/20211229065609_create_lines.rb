class CreateLines < ActiveRecord::Migration[6.0]
  def change
    create_table :lines do |t|
      t.integer :line_number
      t.integer :company_detail_id
      t.boolean :completed

      t.timestamps
    end
  end
end
