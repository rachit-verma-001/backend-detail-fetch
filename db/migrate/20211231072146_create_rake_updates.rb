class CreateRakeUpdates < ActiveRecord::Migration[6.0]
  def change
    create_table :rake_updates do |t|
      t.string :status
      t.integer :company_detail_id

      t.timestamps
    end
  end
end
