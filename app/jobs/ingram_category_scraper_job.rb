class IngramCategoryScraperJob < ApplicationJob
  queue_as :default

  def perform(numCategoriesToScrape = 4)
    phantomjsBin = "#{Rails.root}/node_modules/phantomjs/bin/phantomjs"
    scriptPath = "#{Rails.root.join('app', 'javascript')}/category_scraper.js"

    categoriesToScrape = IngramCategory.pending.limit(numCategoriesToScrape)

    puts "Scraping categories: #{categoriesToScrape.pluck(:name)}"

    command = "#{phantomjsBin} #{scriptPath} \"#{categoriesToScrape.pluck(:url).join(' ')}\""

    puts "Running command:\n\t#{command}"

    output = %x`#{command}`

    puts "Finshed running command, with exit status #{$?.exitstatus}"

    puts "OUTPUT:\n\n#{output}"

    if $?.exitstatus != 0
      raise ArgumentError, output
    end

    output.split("\n").each do |line|
      if line =~ /.* \[APP DATA\] (.*)/
        data = $1
        
        puts "Parsing data: #{data}"

        url = (data =~ /\"url\":\"([^\"]*)\"/) ? $1 : nil
        sku = (data =~ /\"sku\":\"([^\"]*)\"/) ? $1 : nil
        existencias = (data =~ /\"existencias\":\"([^\"]*)\"/) ? $1.to_i : nil
        precio = (data =~ /\"precio\":\"([^\"]*)\"/) ? $1.to_f : nil
        
        
        product = Product.find_by_url(url)
        if product
          puts "Found existing product, updating price: #{precio}, units: #{existencias}"
          product.update_attributes(
            price: precio,
            units: existencias
          )
        else
          puts "Did not find existing product. Creating one."
          Product.create(
            url: url,
            price: precio,
            units: existencias
          )
        end
      end
    end

    categoriesToScrape.update_all(last_scraped: Time.now)
  end
end
