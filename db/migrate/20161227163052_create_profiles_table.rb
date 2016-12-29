class CreateProfilesTable < ActiveRecord::Migration[5.0]
  def change
  		create_table :profiles do |t|
  			t.string :fname
  			t.string :lname
  end
end
end
