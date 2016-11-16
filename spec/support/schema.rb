ActiveRecord::Schema.define do

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.text :description, null: false
    t.timestamps null: false
  end

  add_index :posts, :title

end
