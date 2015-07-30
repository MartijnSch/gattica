# encoding: utf-8
# This script parses the data from a CSV for a specific network.
# Example: ruby import_cost_data.rb linkedin sMO53xelRsGg7nig4B3Fiw files/linkedin.csv

require 'gattica'
require 'csv'

ACCOUNT_ID = 729494
WEB_PROPERTY_ID = "UA-729494-4"
NETWORK = ARGV[0]
CUSTOM_DATA_SOURCE_ID = ARGV[1]
FILE = ARGV[2]

case NETWORK
	when 'linkedin'
		parse_linkedin()
	when 'facebook'
		parse_facebook()
	when 'twitter'
		parse_twitter()
	when 'bing'
		parse_bing()
	else
		puts "Sorry, we don't recognize the network that you want the data to be parsed for."
end

def parse_linkedin
	headers = "ga:date,ga:medium,ga:source,ga:adClicks,ga:adCost,ga:impressions,ga:campaign"

	CSV.foreach(ARGV[0], { headers: true, skip_blanks: true, encoding: "ISO8859-1" }) do |row|
    puts row
  end
end


def send_data
  ga = Gattica.new({ token: 'oauth2_token' })
	upload = ga.upload_data(ACCOUNT_ID, WEB_PROPERTY_ID, CUSTOM_DATA_SOURCE_ID, FILE)
	puts "Succesfull upload for: #{NETWORK}!" if upload
end