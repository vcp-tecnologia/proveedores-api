class CreateIngramProductListings < ActiveRecord::Migration[5.0]
  def change
    create_table :ingram_product_listings do |t|
      t.string :category
      t.string :category_url
      t.string :product_url

      t.timestamps
    end

    add_index :ingram_product_listings, :product_url
  end
end
