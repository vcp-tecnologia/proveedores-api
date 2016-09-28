class AddUpdatedProductInfoToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :product_info_updated_at, :datetime
    Product.reset_column_information
    Product.complete_data.update_all(product_info_updated_at: Time.now)
  end
end
