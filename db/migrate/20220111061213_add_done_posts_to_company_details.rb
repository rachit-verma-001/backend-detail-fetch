class AddDonePostsToCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :done_posts, :string, array:true, default:[]
  end
end
