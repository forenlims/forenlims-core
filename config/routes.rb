# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'home/index'
  root to: 'home#index'
  # for now, specify non-restful routes to the table conversion actions on the home controller.
  # WIP: once we have a proper database system in place, these need to be converted to appropriate restful routes.
  get 'home/autosomal'
  get 'home/ystr'
  post 'home/convert_autosomal'  
  get 'home/convert_autosomal'
  #get 'home/composite'
    
end
