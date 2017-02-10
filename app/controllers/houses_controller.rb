require 'rss'
require 'open-uri'
require 'nokogiri'

class HousesController < ApplicationController
  def craigslist
    @results = []
    house_types = ['duplex', '']
    cities = %w(denver boulder)
    @days_ago = params[:days_ago].blank? ? 1 : params[:days_ago]

    house_types.each do |house_type|
      updates = []
      cities.each do |city|
        url = "https://#{city}.craigslist.org/search/rea?availabilityMode=0&bedrooms=3&hasPic=1&max_price=400000&min_price=150000&query=#{house_type}"
        @page = Nokogiri::HTML(open(url))
        @feed = get_feed(url)
        @items = @feed.present? ? @feed .items : []
        data_ids = @page.css('body section#pagecontainer form#searchform div.content ul.rows li.result-row a.result-image').to_a
        populate_updates(data_ids, city, updates)
      end
      if house_type == ''
        house_type = 'all'
      end
      @results << {
        house_type: house_type,
        updates: updates.uniq {|i| i[:title]}.sort_by {|i| [i[:city], i[:date]]}.reverse
      }
    end
  end

  def populate_updates(data_ids, city, updates)
    @items.each_with_index do |item, index|
      date = item.date
      if Date.today > Date.today - @days_ago
        pics = []

        ids = data_ids[index].present? ? data_ids[index]['data-ids'].gsub('1:','').split(',') : []
        ids.each do |i|
          pics << "https://images.craigslist.org/#{i}_300x300.jpg"
        end

        updates << {
          city: city,
          title: item.title,
          pics: pics,
          link: item.link,
          date: date,
          description: item.description
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
end
