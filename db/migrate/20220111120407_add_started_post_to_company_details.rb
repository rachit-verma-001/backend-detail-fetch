class AddStartedPostToCompanyDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :company_details, :bug_posts, :string, array:true, default:[]
    add_column :company_details, :bug_names, :string, array:true, default:[]
  end
end
