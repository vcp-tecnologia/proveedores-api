class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :category
      t.string :subcategory
      t.string :url
      t.string :vendor
      t.string :vendor_id
      t.string :manufacturer

      t.float :price
      t.integer :units

      t.text :data

      t.timestamps
    end

    add_index :products, :url
  end
end
