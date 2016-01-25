task :scrape_asset_ids => :environment do
  require 'watir-webdriver'
  browser = Watir::Browser.new :firefox, :profile => profile
  browser.goto "http://brand.qualcomm.com/app/login/login.aspx" #go to login page
  browser.forms.first.text_fields.first.value = "sarah.iskander@gateb.com" #set username
  browser.forms.first.text_fields[2].value = "gateB90024.." #set password
  browser.link(id: "ctl00_contentPage_btnLogin").click #click login which triggers js function to login
  
  #sleep(3.minutes)
  browser.links(title: "Assets").last.click
  
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

  CSV.open("asset-ids-new.csv", "wb") do |csv|
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
  browser = Watir::Browser.new :chrome
  browser.goto "http://brand.qualcomm.com/app/login/login.aspx"
  browser.forms.first.text_fields.first.value = "sarah.iskander@gateb.com"
  browser.forms.first.text_fields[2].value = "gateB90024.."
  browser.link(id: "ctl00_contentPage_btnLogin").click
  #browser.links(title: "Assets").when_present
  csv_path = Rails.root.join("public", "qualcomm-assets-urls.csv")
  csv_text = File.read(csv_path)
  urls = CSV.parse(csv_text)
  urls.each do |url|
    unless url[1].to_i < 3220  
      browser.goto url.first
      asset_meta = Hash.new
      asset_meta[:asset_id] = url[1]
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

      CSV.open("asset-metas-jan-25.csv", "a+", headers: true) do |csv|
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