class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :category
      t.string :subcategory
      t.text :data
      t.string :url
      t.string :vendor
      t.string :vendor_id
      t.string :manufacturer

      t.timestamps
    end

    add_index :products, :url
  end
end
