class CreateProductListings < ActiveRecord::Migration[5.0]
  def change
    create_table :product_listings do |t|
      t.string :category
      t.string :category_url
      t.string :product_url

      t.timestamps
    end

    add_index :product_listings, :product_url
  end
end
