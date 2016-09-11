class Product < ApplicationRecord
  scope :scraped_before, ->(date) { where("updated_at < ?", date.to_time.beginning_of_day) }
  scope :scraped_on, ->(date) { where("updated_at >= ? AND updated_at <= ?", date.to_time.beginning_of_day, date.to_time.end_of_day) }
  scope :scraped_today, -> { scraped_on(Date.today) }
  scope :missing_data, -> { where(data: nil) }
  scope :complete_data, -> { where.not(data: nil) }

  scope :fecha, ->(date) { where("updated_at >= ? AND updated_at <= ?", date.to_time.beginning_of_day, date.to_time.end_of_day) }
  scope :proveedor, ->(prov) { where(vendor: prov) }
  scope :categoria, ->(cat) { where(category: cat) }
  scope :subcategoria, ->(subcat) { where(subcategory: subcat) }
  scope :id_proveedor, ->(id) { where(vendor_id: id) }
  scope :fabricante, ->(fab) { where(manufacturer: fab) }

  def fetchProductData
    baseDir = "#{Rails.application.config.scrapers_dir}/ingram"
    phantomjsBin = "#{baseDir}/node_modules/phantomjs/bin/phantomjs"
    scriptPath = "#{baseDir}/dist/product_scraper.js"
    tmpFilepath = "#{Rails.application.config.scrapers_tmp_dir}/#{randTempFilename()}"

    File.open(tmpFilepath, 'w') do |file|
      file.puts(self.url) 
    end

    output = nil

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
          
          if self.url == url
            self.update_attributes({
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

    return output
  end

  private 

  def randTempFilename()
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...50).map { o[rand(o.length)] }.join
  end
end
