Rails.application.routes.draw do
	root 'welcome#index'
  get 'welcome/index'

	resources :news
	get '/crawl_chosun' => "news#crawl_chosun"
	get '/crawl_hani' => "news#crawl_hani"
	get '/crawl_jungang' => "news#crawl_jungang"

	resources :articles

	resources :goals


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
