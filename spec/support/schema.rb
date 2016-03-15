ActiveRecord::Schema.define do
  self.verbose = true

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.text :description, null: false
    t.timestamps null: false
  end
end
