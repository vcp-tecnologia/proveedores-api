class CreateIngramNewProductQueueItems < ActiveRecord::Migration[5.0]
  def change
    create_table :ingram_new_product_queue_items do |t|
      t.string :product_url
      t.timestamps
    end

    add_index :ingram_new_product_queue_items, :product_url, :unique => true
  end
end
