class IngramCategoryScraperJob < ApplicationJob
  queue_as :default

  def perform(categoryName, categoryUrl)
    baseDir = "#{Rails.application.config.scrapers_dir}/ingram"
    phantomjsBin = "#{baseDir}/node_modules/phantomjs/bin/phantomjs"
    scriptPath = "#{baseDir}/dist/category_scraper.js"

    command = "#{phantomjsBin} #{scriptPath} \"#{categoryName}\" \"#{categoryUrl}\""
    output = %x`#{command}`

    if $?.exitstatus != 0
      raise ArgumentError, output
    end

    output.split("\n").each do |line|
      if line =~ /.* \[APP DATA\] (.*)/
        url = $1
        pl = IngramProductListing.find_by_product_url(url)
        if pl
          pl.touch
        else
          IngramProductListing.create(category: categoryName, category_url: categoryUrl, product_url: url)
        end
      end
    end
  end
end
