Rails.application.routes.draw do
  root 'home#index'
  get 'houses/craigslist' => 'houses#craigslist'
	get 'reddit/index' => 'reddit#index'
end
