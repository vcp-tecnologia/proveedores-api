class IngramProductScraperJob < ApplicationJob
  queue_as :default

  def perform(numProductsToScrape = 100)
    urls = Product.missing_data.limit(numProductsToScrape).pluck(:url).shuffle    
    if (urls.size == 0)
      return
    end

    puts "Retrieving data for #{urls.size} products"

    baseDir = "#{Rails.application.config.scrapers_dir}/ingram"
    phantomjsBin = "#{baseDir}/node_modules/phantomjs/bin/phantomjs"
    scriptPath = "#{baseDir}/dist/product_scraper.js"
    tmpFilepath = "#{Rails.application.config.scrapers_tmp_dir}/#{randTempFilename()}"

    File.open(tmpFilepath, 'w') do |file| 
      urls.each { |url| file.puts(url) }
    end

    puts "Putting urls in tmp file: #{tmpFilepath}"

    begin
      command = "#{phantomjsBin} #{scriptPath} #{tmpFilepath}"
      puts "Running command #{command}"

      output = %x`#{command}`

      puts "OUTPUT:\n\n#{output}"

      output.split("\n").each do |line|
        if line =~ /.* \[APP DATA\] (.*)/
          data = $1
          url = (data =~ /\"url\":\"([^\"]*)\"/) ? $1 : nil
          subcategory = (data =~ /\"subcategoria\":\"([^\"]*)\"/) ? $1 : nil
          category = (data =~ /\"categoria\":\"([^\"]*)\"/) ? $1 : nil
          sku = (data =~ /\"sku\":\"([^\"]*)\"/) ? $1 : nil
          manufacturer = (data =~ /\"fabricante\":\"([^\"]*)\"/) ? $1 : nil
          
          product = Product.find_by_url(url)
          if product
            product.update_attributes({
              category: category,
              subcategory: subcategory,
              data: data,
              vendor: "Ingram",
              vendor_id: sku,
              manufacturer: manufacturer
            })
          end
        end
      end

      File.delete(tmpFilepath)

    rescue Exception => e
      File.delete(tmpFilepath)
      raise e
    end

    if $?.exitstatus != 0
      raise ArgumentError, output
    end
  end


  private 

  def randTempFilename()
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...50).map { o[rand(o.length)] }.join
  end
end
