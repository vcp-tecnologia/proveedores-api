class AddUpdatedPriceAndUnitsToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price_and_units_updated_at, :datetime
  end
end
