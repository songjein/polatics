class NewsController < ApplicationController 
	skip_before_action :verify_authenticity_token, only: [:create, :add_comatrix, :add_twitter]

	caches_page :get_comatrix

	def index
		# 좌/ 우파 신문
		@search_term = ""
		if params
			@search_term = params["search_term"]
		end
		'''
		@lefts = New.where(polarity: true)
			.where("news.title LIKE ?", "%#{@search_term}%")
			.order(news_time: :desc)
			.paginate(page: params[:page], per_page: 20)
		@rights = New.where(polarity: false)
			.where("news.title LIKE ?", "%#{@search_term}%")
			.order(news_time: :desc)
			.paginate(page: params[:page], per_page: 20)
		'''
		@lefts = get_lefts(@search_term, params[:page])
		@rights = get_rights(@search_term, params[:page])

		respond_to do |format|
			format.html
			format.js
		end
	end

	def get_lefts(search_term, page)
		cache_key = "get-lefts-#{search_term}-#{page}"
		Rails.cache.fetch(cache_key, expires_in: 3.hours) do
			New.where(polarity: true)
			.where("news.title LIKE ?", "%#{@search_term}%")
			.order(news_time: :desc)
			.paginate(page: params[:page], per_page: 30)
		end
	end

	def get_rights(search_term, page)
		cache_key = "get-rights-#{search_term}-#{page}"
		Rails.cache.fetch(cache_key, expires_in: 3.hours) do
			New.where(polarity: false)
			.where("news.title LIKE ?", "%#{@search_term}%")
			.order(news_time: :desc)
			.paginate(page: params[:page], per_page: 30)
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

	def get_hot_topics
		hot_topics = HotTopic.all.reverse[0..19].reverse
		render json: hot_topics 
	end

	def add_comatrix
		comatrix = Comatrix.new
		comatrix.matrix = params[:matrix]
		comatrix.save
		render text: "ok" 
	end

	def add_twitter
		twitters = JSON.parse(params[:twitter])

		# 만개의 트윗만 남긴다
		'''
		allTweets = Twitter.all
		len = allTweets.length
		maxLen = 10000
		allTweets.each do |t|
			if len > 10000
				t.destroy
			end
			len -= 1
		end
		'''
		Twitter.delete_all
		buf = []
		twitters.each do |tweet|
			tweet["topic"].each do |topic|
				begin 
					#buf << {topic: topic, text: strip_emoji(tweet["text"]), name: strip_emoji(tweet["name"]), screen_name: strip_emoji(tweet["screen_name"]), time: tweet["created_at"]}
					buf << {topic: topic, text: strip_emoji(tweet["text"]), name: strip_emoji(tweet["screen_name"]), screen_name: strip_emoji(tweet["screen_name"]), time: tweet["created_at"]}
				rescue => ex
					logger.error ex.message
				end
			end
			Twitter.create(buf)
		end
		render json: Twitter.all 
	end

	def strip_emoji(text)
    text = text.force_encoding('utf-8').encode
    clean = ""

    # symbols & pics
    regex = /[\u{1f300}-\u{1f5ff}]/
    clean = text.gsub regex, ""

    # enclosed chars 
    regex = /[\u{2500}-\u{2BEF}]/ # I changed this to exclude chinese char
    clean = clean.gsub regex, ""

    # emoticons
    regex = /[\u{1f600}-\u{1f64f}]/
    clean = clean.gsub regex, ""

    #dingbats
    regex = /[\u{2702}-\u{27b0}]/
    clean = clean.gsub regex, ""
  end

	def get_twitter
		if params[:topic] == "ALLTOPIC"
			twitters = Twitter.all.reverse[0..150].shuffle
		else
			twitters = Twitter.where(topic: params[:topic]).reverse[0..150].shuffle
		end
		render json: twitters
	end

	def get_comatrix
		@comatrix = JSON.parse(Comatrix.last.matrix)
		render json: @comatrix
	end

	# api for adding news
	def create 
		auth = params["auth"]
		if auth == ENV["AUTH"]
			c = 0
			results = JSON.parse params["news"]
			buf = []
			results.each do |paper|
				if New.where(title: paper["title"]).length > 0 
					break;
				end
				buf << {title: paper["title"], news_url: paper["news_url"], news_name: paper["news_name"], news_time: paper["news_time"], polarity: paper["polarity"]}
				c += 1
			end
			New.create(buf)
			render json: { result: c.to_s + " 개 삽입 @ " }
		elsif 
			render json: { Auth: false } 
		end
	end

end
