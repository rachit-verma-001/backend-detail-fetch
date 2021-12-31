class CreateExceptionDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :exception_details do |t|
      t.integer :company_detail_id
      t.string :ex_status

      t.timestamps
    end
  end
end
