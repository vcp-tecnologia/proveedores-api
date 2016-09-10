class Product < ApplicationRecord
  scope :scraped_before, ->(date) { where("updated_at < ?", date.to_time.beginning_of_day) }
  scope :scraped_on, ->(date) { where("updated_at >= ? AND updated_at <= ?", date.to_time.beginning_of_day, date.to_time.end_of_day) }
  scope :scraped_today, -> { scraped_on(Date.today) }

  scope :fecha, ->(date) { where("updated_at >= ? AND updated_at <= ?", date.to_time.beginning_of_day, date.to_time.end_of_day) }
  scope :proveedor, ->(prov) { where(vendor: prov) }
  scope :categoria, ->(cat) { where(category: cat) }
  scope :subcategoria, ->(cat) { where(subcategory: subcat) }
  scope :id_proveedor, ->(id) { where(vendor_id: id) }
  scope :fabricante, ->(fab) { where(manufacturer: fab) }
end
