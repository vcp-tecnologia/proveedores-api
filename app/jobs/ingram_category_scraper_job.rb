class IngramCategoryScraperJob < ApplicationJob
  queue_as :default

  def perform(categoryName, categoryUrl)
    scraperBaseDir = "/Users/work/Developer/vcp/ingramscraper"
    phantomjsBin = "#{scraperBaseDir}/node_modules/phantomjs/bin/phantomjs"
    scriptPath = "#{scraperBaseDir}/dist/category_scraper.js"
    command = "#{phantomjsBin} #{scriptPath} \"#{categoryName}\" #{categoryUrl}"
    output = %x`#{command}`

    if $?.exitstatus != 0
      raise ArgumentError, output
    end

    output.split("\n").each do |line|
      if line =~ /.* \[APP DATA\] (.*)/
        url = $1
        pl = ProductListing.find_by_product_url(url)
        if pl
          pl.touch
        else
          ProductListing.create(category: categoryName, category_url: categoryUrl, product_url: url)
        end
      end
    end
  end
end
