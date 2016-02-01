task :scrape_asset_ids => :environment do
  require 'watir-webdriver'
  browser = Watir::Browser.new :firefox, :profile => profile
  browser.goto "http://brand.qualcomm.com/app/login/login.aspx" #go to login page
  browser.forms.first.text_fields.first.value = "sarah.iskander@gateb.com" #set username
  browser.forms.first.text_fields[2].value = "gateB90024.." #set password
  browser.link(id: "ctl00_contentPage_btnLogin").click #click login which triggers js function to login
  
  #sleep(3.minutes)
  browser.links(title: "Assets").last.click

  #Showcase
  #browser.goto "http://brand.qualcomm.com/app/asset/asset_search.aspx?catid=0&libid=4"
  
  #Qualcom Diverge
  browser.links(href: "asset_home.aspx?libid=1").first.click

  #SnapDragon Diverge
  browser.links(href: "asset_home.aspx?libid=2").first.click

  #browser.link(title: "Qualcomm").click #go to Qualcomm (also need to do DragonSnap)
  browser.link(id: "ctl00_contentPage_hlGoToResults").click #go to all items (maybe)
  #browser.goto "http://brand.qualcomm.com/app/asset/asset_search.aspx?catid=0&libid=1"

  assets = [] #initialize asset array
  asset_ids = [] #initialize asset array
  browser.tds(class: "assetTitleCell").each do |row|
    assets << row.link.href #add hrefs to array
    asset_ids << row.link.href.scan(/assetid=(.+)&libid/).first.first #add just IDs
  end
  #browser.tds(class: "assetTitleCell").first.link.href #gives you the url of pages (maybe click through here)
  #need to parse url for asset_ids
  #maybe save to db?
  adder = 1
  incrementer = 1
  while adder < 106
    adder = incrementer.to_i + 1
    incrementer = adder.to_s
    browser.tds(class: "assetTitleCell").each do |row|
      assets << row.link.href #add hrefs to array
      asset_ids << row.link.href.scan(/assetid=(.+)&libid/).first.first
    end
    browser.inputs(id: "ctl00_contentPage_ucSearchNavBarBottom_ibNext").first.click #go to next page
    sleep(20.seconds)
  end
  require 'csv'

  CSV.open("asset-ids-showcase.csv", "wb") do |csv|
    assets.each do |asset_id|
      csv << [asset_id]
    end
    asset_ids.each do |asset_id|
      csv << [asset_id]
    end
  end
end




#Scrapping an asset page (still need previous request and actual asset)
task :scrape_asset_meta => :environment do
  require 'watir-webdriver'
  require 'csv'
  Watir.default_timeout = 240
  client = Selenium::WebDriver::Remote::Http::Default.new

  client.timeout = 240 # seconds – default is 60
  browser = Watir::Browser.new :firefox, :http_client => client
  browser.goto "http://brand.qualcomm.com/app/login/login.aspx"
  browser.forms.first.text_fields.first.value = "sarah.iskander@gateb.com"
  browser.forms.first.text_fields[2].value = "gateB90024.."
  browser.link(id: "ctl00_contentPage_btnLogin").click
  #browser.link(id: "ctl00_contentPage_ucAssetFileInfo_ibtnTriggerModal").click
  #browser.links(title: "Assets").when_present
  #csv_path = Rails.root.join("public", "asset-ids-showcase-urls.csv")
  #csv_text = File.read(csv_path)
  #urls = CSV.parse(csv_text)
  urls = ["3399", "2622", "3392", "3391", "3410", "3412", "3409", "3475", "3600", "3797", "3765", "3845", "3107"]
  urls.each do |url|
    unless url.to_i < 0 
      browser.goto "http://brand.qualcomm.com/app/asset/asset_details.aspx?assetid=#{url}"
      asset_meta = Hash.new
      asset_meta[:asset_id] = url
      asset_meta[:title] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblTitle").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblTitle").text : nil
      asset_meta[:description] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDescription").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDescription").text : nil
      asset_meta[:keywords] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblKeywords").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblKeywords").text : nil
      asset_meta[:library] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblLibrary").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblLibrary").text : nil
      asset_meta[:category] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetCategory").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetCategory").text : nil
      asset_meta[:subcategory] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetSubCategory").present?  ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetSubCategory").text : nil 
      asset_meta[:dimensions] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetDimensions").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetDimensions").text : nil
      asset_meta[:status] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetStatus").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAssetStatus").text : nil 
      asset_meta[:upload_by] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblUploadBy").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblUploadBy").text : nil
      asset_meta[:upload_date] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblUploadDate").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblUploadDate").text : nil
      asset_meta[:last_updated_by] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblLastUpdatedBy").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblLastUpdatedBy").text : nil
      asset_meta[:last_update_date] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblLastUpdateDate").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblLastUpdateDate").text : nil
      asset_meta[:admin_notes] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAdminNotes").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblAdminNotes").text : nil
      asset_meta[:bit_rate] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblBitRate").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblBitRate").text : nil
      asset_meta[:dload_file_type] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDloadFiletype").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDloadFiletype").text : nil
      asset_meta[:dload_resolution] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDloadResolution").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDloadResolution").text : nil
      asset_meta[:dload_size] = browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDloadSize").present? ? browser.span(id: "ctl00_contentPage_ucAssetFileInfo_lblDloadSize").text : nil

      #headers = asset_meta.keys.map{|h| h.to_s}
      values = asset_meta.values

      CSV.open("asset-metas-missing.csv", "a+", headers: true) do |csv|
        csv << values
      end
    end
  end
end

task :csv_test => :environment do
  require 'csv'
  csv_path = Rails.root.join("public", "qualcomm-assets.csv")
  csv_text = File.read(csv_path)
  urls = CSV.parse(csv_text)
  urls.each do |url|
    binding.pry

  end
end

task :scrape_assets => :environment do
  require 'watir-webdriver'
  require 'csv'
  require 'fileutils'
  #Watir.default_timeout = 240
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = 240 # seconds – default is 60
  profile = Selenium::WebDriver::Firefox::Profile.new
  download_directory = "/Users/GateB/Downloads"
  #download_directory = "/Users/bengruber/Downloads"
  profile['browser.download.dir'] = download_directory
  profile['browser.helperApps.neverAsk.saveToDisk'] = "text/csv,application/application/pdf/text/html"

  
  browser = Watir::Browser.new :firefox, :http_client => client, :profile => profile
  browser.goto "http://brand.qualcomm.com/app/login/login.aspx"
  browser.forms.first.text_fields.first.value = "sarah.iskander@gateb.com"
  browser.forms.first.text_fields[2].value = "gateB90024.."
  browser.link(id: "ctl00_contentPage_btnLogin").click
  #browser.link(id: "ctl00_contentPage_ucAssetFileInfo_ibtnTriggerModal").click
  #browser.links(title: "Assets").when_present
  #csv_path = Rails.root.join("public", "qualcomm-assets-urls.csv")
  #csv_text = File.read(csv_path)
  #urls = CSV.parse(csv_text)
  order_assets = []
  urls = ["3399", "2622", "3392", "3391", "3410", "3412", "3475", "3600", "3797", "3765", "3845", "3107"]
  urls.each do |url|
    begin
      unless url.to_i < 0
      file_name = nil
      downloads_before = Dir.entries(download_directory)
      browser.goto "http://brand.qualcomm.com/app/asset/asset_details.aspx?assetid=#{url}"
      if browser.link(id: "ctl00_contentPage_ucAssetFileInfo_ibtnTriggerModal").present?
        browser.link(id: "ctl00_contentPage_ucAssetFileInfo_ibtnTriggerModal").click
        sleep 5 #wait 10 seconds
        if browser.link(id: "ctl00_contentPage_ucAssetFileInfo_btnAcceptTerms").present? #check to see and check if pop up comes.
          browser.link(id: "ctl00_contentPage_ucAssetFileInfo_btnAcceptTerms").click
          sleep 5
          if browser.link(id: "ctl00_contentPage_ucAssetFileInfo_btnAcceptTerms").present?
            browser.link(id: "ctl00_contentPage_ucAssetFileInfo_btnAcceptTerms").click
          end
        end

        20.times do
          difference = Dir.entries(download_directory) - downloads_before
          if difference.size == 1
            file_name = difference.first
            unless file_name.split('.').last == "part"
              file_extention = file_name.split('.').last
              File.rename("#{download_directory}/#{file_name}","#{download_directory}/#{url}.#{file_extention}")
              FileUtils.mv("#{download_directory}/#{url}.#{file_extention}", "/Volumes/EXTERNAL HD/Qualcomm Assets/#{url}.#{file_extention}")
              break
            end
          end 
          sleep 1
        end
      else
        order_assets << url
        #binding.pry
      end
    end
    rescue => error
      #order_assets << url
      #binding.pry
    end
  end
  puts order_assets
end




task :asset_related => :environment do
  require 'watir-webdriver'
  require 'csv'
  Watir.default_timeout = 240
  client = Selenium::WebDriver::Remote::Http::Default.new

  client.timeout = 240 # seconds – default is 60
  browser = Watir::Browser.new :firefox, :http_client => client
  browser.goto "http://brand.qualcomm.com/app/login/login.aspx"
  browser.forms.first.text_fields.first.value = "sarah.iskander@gateb.com"
  browser.forms.first.text_fields[2].value = "gateB90024.."
  browser.link(id: "ctl00_contentPage_btnLogin").click
  #sleep 20
  #browser.link(id: "ctl00_contentPage_ucAssetFileInfo_ibtnTriggerModal").click
  #browser.links(title: "Assets").when_present
  csv_path = Rails.root.join("public", "related.csv")
  csv_text = File.read(csv_path)
  urls = CSV.parse(csv_text)
  urls.each do |url|
    if url[0].to_i > 3844 || url[0].to_i < 2479
      browser.goto "http://brand.qualcomm.com/app/asset/asset_edit.aspx?assetid=#{url[0]}"
      browser.links(class: "rtsLink").last.click #click related
      if browser.span(id: "ctl00_contentPage_ucRelatedAsset_dgAsset_ctl02_lblName").present?#check if any
        asset_meta = Hash.new
        asset_meta[:asset_id] = url[0]
        browser.spans(id: "ctl00_contentPage_ucRelatedAsset_dgAsset_ctl02_lblName").each do |name|        
          asset_meta[:title] = name.text
          values = asset_meta.values
          CSV.open("asset-related.csv", "a+", headers: true) do |csv|
            csv << values
          end        
        end        
      end
    end
  end
end

task :csv_test => :environment do
  require 'csv'
  csv_path = Rails.root.join("public", "qualcomm-assets.csv")
  csv_text = File.read(csv_path)
  urls = CSV.parse(csv_text)
  urls.each do |url|
    binding.pry
    asset_match[:asset_id] = url[0]
    if main.select{|a| a[1] == url[1] }.count > 0
      asset_match[:asset_related_id] = main.select{|a| a[1] == url[1] }.first.first
    else
      asset_match[:asset_related_id] = nil
    end
    asset_meta[:title] = url[1]

    values = asset_meta.values
    CSV.open("asset-related-match.csv", "a+", headers: true) do |csv|
      csv << values
    end
  end
end

task :remap => :environment do
  require 'csv'
  #set the main csv
  csv_path = Rails.root.join("public", "related.csv")
  csv_text = File.read(csv_path)
  main = CSV.parse(csv_text)

  #set the alt csv
  csv_path = Rails.root.join("public", "asset-related-match.csv")
  #qualcomm-related-assets.csv
  csv_text = File.read(csv_path)
  related = CSV.parse(csv_text)

  asset_match = Hash.new
  related.each_with_index do |url,index|
    if index.to_i > 0
      asset_match[:asset_id] = url[0]
      if main.select{|a| a[1] == url[1] }.count > 0
        asset_match[:asset_related_id] = main.select{|a| a[1] == url[1] }.first.first
      else
        asset_match[:asset_related_id] = nil
      end
      asset_match[:title] = url[1]

      values = asset_match.values
      CSV.open("asset-related-match.csv", "a+", headers: true) do |csv|
        csv << values
      end
    end
  end
end

task :compare_images => :environment do
  dir = "/Volumes/EXTERNAL HD/Qualcomm Assets"
  fdir = Dir.entries(dir)
  images = fdir.select{ |a| a.split('.').last != "zip" && a.split('.').last != "psd" && a.split('.').last != "mp4" && a.split('.').last != "docx" && a.split('.').last != "zip" && (a.length == 9 || a.length == 8) }
  same_hash = Hash.new
  require 'RMagick'
  images.each_with_index do |image, index|
    img1 = Magick::Image.read("#{dir}/#{image}")
    same_exts = images.select{|s| s.split('.').last == image.split('.').last}
    same_exts.each do |comp|
      img2 = Magick::Image.read("#{dir}/#{comp}")
      diff_img, diff_metric  = img1[0].compare_channel( img2[0], Magick::MeanSquaredErrorMetric )
      if diff_metric == 0.0 
        same_hash["original_#{index}"] = image
        same_hash["copy_#{index}"] = comp
      end
    end
  end
  puts same_hash
end