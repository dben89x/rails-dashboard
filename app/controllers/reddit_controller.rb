class RedditController < ApplicationController

	def index
		CLIENT_ID = "XQGGfiz7TXSUKw"
		SECRET = "ODfBTmT2_Cahr1FCT8AzvbAnaYM"
		REDIRECT_URI = "http://railsdashboard.herokuapp.com"
		w = Redd.it(:web, CLIENT_ID, SECRET, REDIRECT_URI, user_agent: "TestSite v1.0.0")
		
		# w = Redd.it(:web, ENV["REDDIT_CLIENT"], ENV["REDDIT_SECRET"], ENV["REDDIT_REDIRECT"], user_agent: "TestSite v1.0.0")

		url = w.auth_url("random_state", ["identity", "read"], :temporary)
		puts "Please go to #{url} and enter the code below:"
		code = gets.chomp
		w.authorize!(code)
	end

end
