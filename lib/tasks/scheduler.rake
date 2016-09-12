desc "This task is called by the Heroku scheduler add-on"
task :scrape_ingram_categories => :environment do
  puts "Enqueuing an IngramCategoryScraperJob job."
  IngramCategoryScraperJob.perform_later(3)
  puts "Done enqueuing."
end

BLACK_LISTED_PRODUCTS = ["https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=C1000B1"]

task :scrape_ingram_products => :environment do
  puts "Enqueuing an IngramProductScraperJob job."
  IngramProductScraperJob.perform_later(400, BLACK_LISTED_PRODUCTS)
  puts "Done enqueuing."
end