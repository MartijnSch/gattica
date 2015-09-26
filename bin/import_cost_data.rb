# encoding: utf-8
# This script parses the data from a CSV for a specific network.
# Example: ruby import_cost_data.rb linkedin sMO53xelRsGg7nig4B3Fiw files/linkedin.csv
require 'gattica'
require 'csv'
require 'cgi'

if ARGV.empty?
	abort "usage: import_cost_data.rb <source> <data-source-id> <file-name.csv>"
end

ACCOUNT_ID = "" #239694
WEB_PROPERTY_ID = "" #UA-29726363-27
NETWORK = ARGV[0]
CUSTOM_DATA_SOURCE_ID = ARGV[1]
FILE = ARGV[2]
TOKEN = ""
HEADERS = ["ga:date","ga:medium","ga:source","ga:adClicks","ga:adCost","ga:impressions","ga:campaign"]

# Helpers
def parse_date(date)
	return DateTime.parse(date).strftime("%Y%m%d")
end

def parse_utm(url, utm)
	params = CGI::parse(URI::parse(url.gsub("&utm_term={QueryString}","")).query)
	return params["utm_#{utm}"][0]
end

def send_data
  ga = Gattica.new({ token: TOKEN })
	upload = ga.upload_data(ACCOUNT_ID, WEB_PROPERTY_ID, CUSTOM_DATA_SOURCE_ID, "files/#{NETWORK}_cost_data.csv")
	puts "Succesfull upload for: #{NETWORK}!" if upload
end


# Networks
def parse_linkedin()
	CSV.open("files/#{NETWORK}_cost_data.csv", "wb") do |csv|
		csv << HEADERS

		CSV.foreach(FILE, { headers: true, skip_blanks: true, encoding: "ISO8859-1" }) do |row|
			array = []

			if row["CLICK URL"].include? "utm_"
				values = {
					date: parse_date(row[0]),
					medium: parse_utm(row["CLICK URL"], 'medium'),
					source: parse_utm(row["CLICK URL"], 'source'),
					clicks: row["CLICKS"],
					cost: row["TOTAL SPENT"],
					impressions: row["IMPRESSIONS"].gsub(',',''),
					campaign: parse_utm(row["CLICK URL"], 'campaign')
				}

				values.each { |k,v| array.push(v) }
				csv << array
			end

	  end
	end

	send_data()
end

# Facebook, need to clean the CSV to add the right URLs though
# https://business.facebook.com/ads/manager/account/ads/?act=24845147&time_breakdown=days_1&columns=[%22name%22%2C%22reach%22%2C%22cost_per_result%22%2C%22spend%22%2C%22impressions%22%2C%22actions%3Alink_click%22]&business_id=10152810332878523
def parse_facebook()
	CSV.open("files/#{NETWORK}_cost_data.csv", "wb") do |csv|
		csv << HEADERS

		CSV.foreach(FILE, { headers: true, skip_blanks: true, encoding: "ISO8859-1", col_sep: ";" }) do |row|
			array = []

			if row["Advert Name"].include? "utm_"
				values = {
					date: parse_date(row[0]),
					medium: parse_utm(row["Advert Name"], 'medium'),
					source: parse_utm(row["Advert Name"], 'source'),
					clicks: row["Website Clicks"],
					cost: row["Amount Spent (USD)"].gsub(',','.'),
					impressions: row["Impressions"],
					campaign: parse_utm(row["Advert Name"], 'campaign')
				}

				values.each { |k,v| array.push(v) }
				csv << array
			end

	  end
	end

	send_data()
end

# Clean URLs + Remove last lines + First Lines
def parse_bing()
	CSV.open("files/#{NETWORK}_cost_data.csv", "wb") do |csv|
		csv << HEADERS

		CSV.foreach(FILE, { headers: true, skip_blanks: true, encoding: "ISO8859-1", col_sep: ";" }) do |row|
			array = []

			if row["Destination URL"].include? "utm_"
				values = {
					date: parse_date(row[0]),
					medium: parse_utm(row["Destination URL"], 'medium'),
					source: parse_utm(row["Destination URL"], 'source'),
					clicks: row["Clicks"],
					cost: row["Spend"],
					impressions: row["Impressions"],
					campaign: parse_utm(row["Destination URL"], 'campaign')
				}

				values.each { |k,v| array.push(v) }
				csv << array
			end

	  end
	end

	send_data()
end

# Add the right UTM tags to the document
def parse_twitter()
	CSV.open("files/#{NETWORK}_cost_data.csv", "wb") do |csv|
		csv << HEADERS

		CSV.foreach(FILE, { headers: true, skip_blanks: true, encoding: "ISO8859-1", col_sep: ";" }) do |row|
			array = []

			if row["campaign url"].include? "utm_"
				values = {
					date: parse_date(row["time"]),
					medium: parse_utm(row["campaign url"], 'medium'),
					source: parse_utm(row["campaign url"], 'source'),
					clicks: row["link clicks"],
					cost: row["spend"],
					impressions: row["impressions"],
					campaign: parse_utm(row["campaign url"], 'campaign')
				}

				values.each { |k,v| array.push(v) }
				csv << array
			end

	  end
	end

	send_data()
end

case NETWORK
	when 'linkedin'
		parse_linkedin
	when 'facebook'
		parse_facebook
	when 'bing_ads'
		parse_bing
	when 'twitter'
		parse_twitter
	else
		puts "Sorry, we don't recognize the network that you want the data to be parsed for."
end