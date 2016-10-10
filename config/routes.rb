Rails.application.routes.draw do
	root 'news#index'
  get 'welcome/index'
  get '/analyzer' => 'welcome#analyzer'

	resources :news
	get '/crawl_chosun' => "news#crawl_chosun"
	get '/crawl_hani' => "news#crawl_hani"
	get '/crawl_jungang' => "news#crawl_jungang"
	get '/crawl_pressian' => "news#crawl_pressian"
	get '/crawl_donga' => "news#crawl_donga"
	get '/all' => 'news#all'

	get '/add_hot_topics' => 'news#add_hot_topics'

	resources :articles

	resources :goals


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
