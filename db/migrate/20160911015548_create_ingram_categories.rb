class CreateIngramCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :ingram_categories do |t|
      t.string :name
      t.string :url
      t.datetime :last_scraped, default: nil

      t.timestamps
    end
  end
end
