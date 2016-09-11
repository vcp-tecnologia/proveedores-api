class IngramNewProductQueueItem < ApplicationRecord
  scope :scraped_before, ->(date) { where("updated_at < ?", date.to_time.beginning_of_day) }
  scope :scraped_on, ->(date) { where("updated_at >= ? AND updated_at <= ?", date.to_time.beginning_of_day, date.to_time.end_of_day) }
  scope :scraped_today, -> { scraped_on(Date.today) }
  scope :pending, -> {
    scraped_today.where.not(product_url: Product.scraped_today.pluck(:url))    
  }
end
