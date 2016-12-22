class AddPasswordToUsersTable < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :password, :text
  end
end
