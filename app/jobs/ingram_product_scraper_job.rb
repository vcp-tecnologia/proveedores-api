class IngramProductScraperJob < ApplicationJob
  queue_as :default

  def perform()
    urls = IngramProductListing.pending.limit(100).pluck(:product_url)    
    if (urls.size == 0)
      return
    end

    baseDir = "#{Rails.application.config.scrapers_dir}/ingram"
    phantomjsBin = "#{baseDir}/node_modules/phantomjs/bin/phantomjs"
    scriptPath = "#{baseDir}/dist/product_scraper.js"
    tmpFilepath = "#{Rails.application.config.scrapers_tmp_dir}/#{randTempFilename()}"

    File.open(tmpFilepath, 'w') do |file| 
      urls.each { |url| file.puts(url) }
    end

    begin
      command = "#{phantomjsBin} #{scriptPath} #{tmpFilepath}"
      output = %x`#{command}`

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
            Product.update_attributes(data: data)
          else
            Product.create({
              category: category,
              subcategory: subcategory,
              data: data,
              url: url,
              vendor: "Ingram",
              vendor_id: sku,
              manufacturer: manufacturer
            })
          end
        end
      end
    rescue Exception => e
      File.delete(tmpFilepath)
      raise e
    end

    File.delete(tmpFilepath)

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
