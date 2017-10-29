Rails.application.routes.draw do
	root 'news#index'
  get 'welcome/index'

	resources :news

	get '/crawl_chosun' => "news#crawl_chosun"
	get '/crawl_hani' => "news#crawl_hani"
	get '/crawl_jungang' => "news#crawl_jungang"
	get '/crawl_pressian' => "news#crawl_pressian"
	get '/crawl_donga' => "news#crawl_donga"
	get '/all' => 'news#all'

	get '/add_hot_topics' => 'news#add_hot_topics'
	post '/add_comatrix' => 'news#add_comatrix'
	get '/get_comatrix' => 'news#get_comatrix'
	get '/get_hot_topics' => 'news#get_hot_topics'
	post '/add_twitter' => 'news#add_twitter'

	get '/get_twitter/:topic' => 'news#get_twitter'

	resources :articles

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
