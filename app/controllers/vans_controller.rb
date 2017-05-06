require 'open-uri'
require 'nokogiri'

class VansController < ApplicationController
	def craigslist
		@updates = []
		@states = %w(az ca co nm ut)
		@sort_by_options = %w(price date city)

		az_cities = %w(boulder cosprings denver eastco fortcollins rockies pueblo westslope)
		ca_cities = %w(bakersfield chico fresno goldcountry hanford humboldt imperial inlandempire losangeles mendocino merced modesto monterey orangecounty palmsprings redding reno sacramento sandiego slo santabarbara santamaria sfbay siskiyou stockton susanville ventura visalia yubasutter)
		co_cities = %w(phoenix flagstaff prescott showlow sierravista tucson yuma mohave)
		nm_cities = %w(albuquerque clovis farmington lascruces roswell santafe)
		ut_cities = %w(logan ogden provo saltlakecity stgeorge)

		index = @states.index(params[:state]) || 0
		selected_state = @states[index]
		city_name = "#{selected_state}_cities"
		cities = eval(city_name)

		@days_ago = params[:days_ago].blank? ? 1 : params[:days_ago]

		cities.each do |city|
			url = "https://#{city}.craigslist.org/search/cto?hasPic=1&auto_bodytype=12"
			@page = Nokogiri::HTML(open(url))
			@rows = @page.css('body section.page-container form#searchform div.content ul.rows li.result-row')
			@data_ids = @rows.css('a.result-image').to_a
			populate_updates(@rows, @data_ids, city)
		end

		@updates = @updates.uniq {|u| u[:title]}

		@updates = case params[:sort_by]
		when "price", "city"
			@updates.sort_by {|u| u[ params[:sort_by].to_sym ]}
		else
			@updates.sort_by {|u| u[ :datetime ]}.reverse
		end
		
	end

	def populate_updates(rows, data_ids, city)
		@rows.each_with_index do |item, index|
			info = item.css('p.result-info')
			if Date.today > Date.today - @days_ago
				pics = []

				ids = data_ids[index].present? ? data_ids[index]['data-ids'].gsub('1:','').split(',') : []
				ids.each do |i|
					pics << "https://images.craigslist.org/#{i}_300x300.jpg"
				end

				link = info.css('a.result-title')[0]['href']
				link = link.include?('craigslist.org') ? link : "https://#{city}.craigslist.org#{link}"
				@updates << {
					city: city,
					title: info.css('a.result-title').text,
					pics: pics,
					link: link,
					date: info.css('time.result-date')[0]['title'],
					datetime: info.css('time.result-date')[0]['datetime'],
					price: info.css('span.result-meta span.result-price').text.gsub('$','').to_i,
				}
			end
		end
	end

	def get_feed(url)
		begin
			@feed = RSS::Parser.parse(open("#{url}&format=rss") {|f| f.read.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')})
		rescue RSS::MissingTagError
			@feed = nil
		end
	end

	def saved
		"https://phoenix.craigslist.org/wvl/cto/6101606478.html"
	end
end
