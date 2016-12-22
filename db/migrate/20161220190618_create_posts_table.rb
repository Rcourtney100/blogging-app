class CreatePostsTable < ActiveRecord::Migration[5.0]
  def change
  	create_table :posts do |t|
  		t.string :title
  		t.text :content
  		t.text :category
  		t.integer :user_id
  		end
	end
end