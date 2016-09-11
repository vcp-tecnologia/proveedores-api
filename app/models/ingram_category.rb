class IngramCategory < ApplicationRecord
  scope :scraped_before, ->(date) { where("last_scraped < ?", date.to_time.beginning_of_day) }
  scope :scraped_on, ->(date) { where("last_scraped >= ? AND last_scraped <= ?", date.to_time.beginning_of_day, date.to_time.end_of_day) }
  scope :scraped_today, -> { scraped_on(Date.today) }
  scope :pending, -> {
    where("last_scraped IS NULL OR last_scraped < ?", Date.today.to_time.beginning_of_day)
  }
end
