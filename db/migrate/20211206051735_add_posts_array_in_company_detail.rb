class AddPostsArrayInCompanyDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :posts, :string, array: true, default: []
  end
end
