class RedditController < ApplicationController

	def index
		require 'net/http'
		require 'uri'
		require 'rubygems'
		require 'json'

		uri = URI.parse("https://www.reddit.com/api/v1/access_token")
		request = Net::HTTP::Post.new("/api/v1/access_token")
		request.set_form_data({
			"grant_type" => "authorization_code",
			"redirect_uri" => "http://localhost:3000",
			"code" => "3gKTWNZ7rBO_iUDpJj-iK-dX_r8"
		})
		res = Net::HTTP.post_form(uri, "grant_type" => "authorization_code", "redirect_uri" => "http://localhost:3000", "code" => "3gKTWNZ7rBO_iUDpJj-iK-dX_r8")

		response = http.request(request)

		"grant_type=authorization_code&code=CODE&"
		resp = Net::HTTP.get_response(URI.parse(reddit_api_url))

		# client_id = "XQGGfiz7TXSUKw"
		# secret = "ODfBTmT2_Cahr1FCT8AzvbAnaYM"
		# redirect_uri = "http://railsdashboard.herokuapp.com"
		# w = Redd.it(:web, client_id, secret, redirect_uri, user_agent: "TestSite v1.0.0")
		#
		# # w = Redd.it(:web, ENV["REDDIT_CLIENT"], ENV["REDDIT_SECRET"], ENV["REDDIT_REDIRECT"], user_agent: "TestSite v1.0.0")
		#
		# url = w.auth_url("random_state", ["identity", "read"], :permanent)
		# puts "Please go to #{url} and enter the code below:"
		# code = gets.chomp
		# w.authorize!(code)
	end

end
