# this is pretty rough, but I hope it helps!
# 
# if you run into any problems, this is a big help:
# https://developers.google.com/oauthplayground/

namespace :gattica do
  task :get_access_token do

    require 'net/http'
    require 'json'

    puts "

    FOLLOW THE DIRECTIONS BELOW:

    * Go to https://cloud.google.com/console
    * Click 'Create Project'
    * Enter a name, and click that you agree
      (uncheck email notifications too if you want)
    * Click 'Create'
    * Click 'APIs & auth' on the left
    * Make sure only the APIs you want to grant access to are tured on,
      like 'Analytics API' for example
    * Click 'Registered Apps' on he left
    * Click 'Register App' on the top
    * Give it a name, select 'Native' and click 'Register'

    -- Once you've done all that, enter your 'CLIENT ID':
    (Should look like 'NNNNNNNNNNNN-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com')"
    client_id = STDIN.gets.chomp

    puts "\n\nenter your 'CLIENT SECRET':
    don't worry we won't tell :)"
    client_secret = STDIN.gets.chomp

    puts "\n\nenter all the scopes you want access to separated by spaces:
    for example 'https://www.googleapis.com/auth/analytics.readonly'
    see https://developers.google.com/gdata/faq#AuthScopes for a list"
    scope = STDIN.gets.chomp

    http = Net::HTTP.new('accounts.google.com', 443)
    http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE # uncomment if you need to not verify the SSL cert

    request = Net::HTTP::Post.new("/o/oauth2/device/code")
    request.form_data = {client_id:client_id, scope:scope}
    response = JSON.parse(http.request(request).body)

    puts "\n\n* Go to #{response['verification_url']} and log in or select your account
    * type in '#{response['user_code']}' (without the quotes) in the box provided
    * Click 'Continue' and then 'Allow Access'
    * Press enter after the success page loads"
    STDIN.gets

    request = Net::HTTP::Post.new("/o/oauth2/token")
    request.form_data = {client_id:client_id, client_secret:client_secret, code:response['device_code'], grant_type:'http://oauth.net/grant_type/device/1.0'}
    puts "\n\nrefresh token:"
    puts refresh_token = JSON.parse(http.request(request).body)['refresh_token']

    puts "\n\nTo use the refresh token, copy and paste the code below into your app:\n
    http = Net::HTTP.new('accounts.google.com', 443)
    http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE # uncomment if you need to NOT verify the SSL cert
    request = Net::HTTP::Post.new('/o/oauth2/token')
    request.form_data = {client_id:'#{client_id}', client_secret:'#{client_secret}', refresh_token:'#{refresh_token}', grant_type:'refresh_token'}
    access_token = JSON.parse(http.request(request).body)['access_token']\n"
  end
end