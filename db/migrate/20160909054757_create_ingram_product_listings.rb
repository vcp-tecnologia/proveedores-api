class CreateIngramProductListings < ActiveRecord::Migration[5.0]
  def change
    create_table :ingram_product_listings do |t|
      t.string :product_url
      t.string :sku
      
      t.boolean :is_new_product, default: true
      t.integer :units
      t.float :price
      
      t.timestamps
    end

    add_index :ingram_product_listings, :product_url
  end
end
