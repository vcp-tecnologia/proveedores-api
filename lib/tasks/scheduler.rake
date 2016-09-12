desc "This task is called by the Heroku scheduler add-on"
task :scrape_ingram_categories => :environment do
  puts "Enqueuing an IngramCategoryScraperJob job."
  IngramCategoryScraperJob.perform_later(1)
  puts "Done."
end

task :scrape_ingram_products => :environment do
  puts "Enqueuing an IngramProductScraperJob job."
  IngramProductScraperJob.perform_later(100)
  puts "Done."
end