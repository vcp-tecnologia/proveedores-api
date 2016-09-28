class IngramProductScraperJob < ApplicationJob
  queue_as :default

  def perform(numProductsToScrape = 100, blacklistUrls = [])
    urls = Product.missing_data.pluck(:url).shuffle[0...numProductsToScrape] - blacklistUrls  
    if (urls.size == 0)
      return
    end

    puts "Retrieving data for #{urls.size} products"

    phantomjsBin = "#{Rails.root}/node_modules/phantomjs/bin/phantomjs"
    scriptPath = "#{Rails.root.join('app', 'javascript')}/product_scraper.js"
    tmpFilepath = "#{Rails.root.join('tmp')}/#{randTempFilename()}"

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
              manufacturer: manufacturer,
              product_info_updated_at: Time.now
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
