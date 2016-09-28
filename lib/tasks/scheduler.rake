desc "This task is called by the Heroku scheduler add-on"
task :scrape_ingram_categories => :environment do
  puts "Enqueuing an IngramCategoryScraperJob job."
  IngramCategoryScraperJob.perform_later(2)
  puts "Done enqueuing."
end

BLACK_LISTED_PRODUCTS = [
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=C1000B1",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=990005S",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=75400WU",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=990006P",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=C03000F",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=98400GS",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=C03000E",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=4150111",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=94602OM",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=97200HC",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=57801K9",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=210015X",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=644046G",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=97200HH",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=9210026",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=98400H8",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=A1700M7",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=A4600AT",
  "https://www.imstores.com/Ingrammicromx/ProductDetail.aspx?sku=990003R"
]

task :scrape_ingram_products => :environment do
  puts "Enqueuing an IngramProductScraperJob job."
  IngramProductScraperJob.perform_later(100, BLACK_LISTED_PRODUCTS)
  puts "Done enqueuing."
end