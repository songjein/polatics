class NewsController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:create]
	def index
		# 좌/ 우파 신문
		@search_term = ""
		if params
			@search_term = params["search_term"]
		end
		@lefts = New.where(polarity: true)
			.where("news.title LIKE ?", "%#{@search_term}%")
			.order(news_time: :desc)
			.paginate(page: params[:page], per_page: 20)
		@rights = New.where(polarity: false)
			.where("news.title LIKE ?", "%#{@search_term}%")
			.order(news_time: :desc)
			.paginate(page: params[:page], per_page: 20)

		respond_to do |format|
			format.html
			format.js
		end
	end

	def all 
		titles = "" 
		news = New.all
		news.each do |n|
			titles += n.title + "\n"
		end
		render json: titles 
	end
	
	# api for adding hot topics
	def add_hot_topics
		hot_topics = params["hot"].split(",")		
		hot_topics.each do |h|
			t = HotTopic.new
			t.topic = h
			t.save	
		end
		render text: hot_topics 
	end

	# api for adding news
	def create 
		auth = params["auth"]
		if auth == ENV["AUTH"]
			c = 0
			results = JSON.parse params["news"]
			results.each do |paper|
				#if New.where(title: paper["title"]).length == 1
				#	break;
				#end
				news= New.new
				news.title = paper["title"] 
				news.news_url = paper["news_url"]
				news.news_name = paper["news_name"]
				news.news_time = paper["news_time"]
				news.polarity = paper["polarity"]
				news.save
				c += 1
			end
			render json: { result: c.to_s + " 개 삽입 @ " + Time.now.strftime("%I:%M:%S %z") }
		elsif 
			render json: { Auth: false, Result: params[:auth] + " / " + ENV["AUTH"] } 
		end
	end

end
