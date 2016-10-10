class WelcomeController < ApplicationController
  def index
		require 'open-uri'
		db_url = "http://210.102.180.93:19002/query?query=" + params['query']
		render json: open(db_url).read
  end

	def analyzer
		render :layout => false
	end
end
