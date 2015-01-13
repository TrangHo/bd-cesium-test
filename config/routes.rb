Rails.application.routes.draw do
  root 'home#index'

  get 'json_example.json', to: 'home#json'
end
