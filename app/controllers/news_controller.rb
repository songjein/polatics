class NewsController < ApplicationController
	def index
		# 좌/ 우파 신문
		@search_term = ""
		if params
			@search_term = params["search_term"]
		end
		@lefts = New.where(polarity: true)
			.where("news.title LIKE ?", "%#{@search_term}%").order(news_time: :desc)
		@rights = New.where(polarity: false)
			.where("news.title LIKE ?", "%#{@search_term}%").order(news_time: :desc)
	end

	def search 
	end

	def crawl_chosun
		# 조선일보
		require 'nokogiri' 
		require 'open-uri'

		base_url  = "http://news.chosun.com"

		candidates = [
			'economy', 'politics' #...
		]
		# http://wolfapple.tumblr.com/post/30861736496/open-uri-%EC%82%AC%EC%9A%A9%EC%8B%9C-%ED%95%9C%EA%B8%80%EC%9D%B4-%EA%B9%A8%EC%A7%88%EB%95%8C
		# 한글 깨질 때
		
		c = 0
		ret = ""
		(1..10).each do |i|
			doc = Nokogiri::HTML(open(base_url + "/svc/list_in/list.html?catid=2&pn=" + i.to_s, 'r:binary').read.encode('utf-8', 'euc-kr'))
			links = doc.search(".list_item dt a")

			links.each do |link|
				if New.where(title: link.inner_html).length == 1
					ret += link.inner_html
					break;
				end
				paper = New.new
				paper.title = link.inner_html 
				paper.news_url = link["href"]
				news = Nokogiri::HTML(open(link["href"]).read.encode('utf-8', 'euc-kr'))
				date_info  = news.search("#date_text").inner_html.strip.split(" ")
				paper.news_name = "조선일보"
				paper.news_time = Time.new(date_info[2].split(".")[0].to_i, date_info[2].split(".")[1].to_i, date_info[2].split(".")[2].to_i, date_info[3].split(":")[0], date_info[3].split(":")[1])
				paper.polarity = false 
				paper.save
				c += 1
			end
		end

		render text: "success " + c.to_s + " " + ret

	end

	def crawl_hani
		# 한겨례 
		require 'nokogiri' 
		require 'open-uri'

		base_url  = "http://www.hani.co.kr"

		candidates = [
			'economy', 'politics' #...
		]

		c = 0
		ret = ""
		(1..10).each do |i|
			doc = Nokogiri::HTML(open(base_url + "/arti/politics/list" + i.to_s +  ".html"))

			links = doc.search(".article-title a")
			dates = doc.search(".date")

			links.each_with_index  do |link, idx|
				if New.where(title: link.inner_html).length == 1
					ret += link.inner_html
					break;
				end
				paper = New.new
				paper.title = link.inner_html 
				paper.news_url = base_url + link["href"]
				date_info = dates[idx].inner_html.strip.split(" ")
				paper.news_name = "한겨례"
				paper.news_time = Time.new(date_info[0].split("-")[0].to_i, date_info[0].split("-")[1].to_i, date_info[0].split("-")[2].to_i, date_info[1].split(":")[0], date_info[1].split(":")[1]) 
				paper.polarity = true 
				paper.save
				c += 1
			end
		end

		render text: "success " + c.to_s + " " + ret

	end

	def crawl_jungang

		# 한겨례 
		require 'nokogiri' 
		require 'open-uri'

		base_url  = "http://news.joins.com"

		candidates = [
			'economy', 'politics' #...
		]

		c = 0
		ret = ""
		(1..10).each do |i|
			doc = Nokogiri::HTML(open(base_url + "/politics/assemgov/list/" + i.to_s))

			links = doc.search(".headline.mg a")
			dates = doc.search(".byline em:nth-child(2)")

			links.each_with_index  do |link, idx|
				if New.where(title: link.inner_html).length == 1
					ret += link.inner_html
					break;
				end
				paper = New.new
				paper.title = link.inner_html 
				paper.news_url = base_url + link["href"]
				date_info = dates[idx].inner_html.strip.split(" ")
				paper.news_name = "중앙일보"
				paper.news_time = Time.new(date_info[0].split(".")[0].to_i, date_info[0].split(".")[1].to_i, date_info[0].split(".")[2].to_i, date_info[1].split(":")[0], date_info[1].split(":")[1]) 
				paper.polarity = false 
				paper.save
				c += 1
			end
		end

		render text: "success " + c.to_s + " " + ret

	end


	def crawl_pressian
		# 한겨례 
		require 'nokogiri' 
		require 'open-uri'

		base_url  = "http://www.pressian.com"

		candidates = [
			'economy', 'politics' #...
		]

		c = 0
		ret = ""
		(1..10).each do |i|
			doc = Nokogiri::HTML(open(base_url + "/news/section_list_all.html?sec_no=66&page=" + i.to_s))

			links = doc.search("a.tt")
			dates = doc.search(".list_data")

			links.each_with_index  do |link, idx|
				if New.where(title: link.inner_html).length == 1
					ret += link.inner_html
					break;
				end
				paper = New.new
				paper.title = link.inner_html 
				paper.news_url = link["href"]
				date_info = dates[idx].inner_html.strip.split(" ")
				paper.news_name = "프레시안"
				paper.news_time = Time.new(date_info[0].split(".")[0].to_i, date_info[0].split(".")[1].to_i, date_info[0].split(".")[2].to_i, date_info[1].split(":")[0], date_info[1].split(":")[1]) 
				paper.polarity = true 
				paper.save
				c += 1
			end
		end

		render text: "success " + c.to_s + " " + ret

	end


end
