Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'user_token', to: 'user_token#create'
      get 'search', to: 'search#index'
      get 'autocomplete', to: 'search#autocomplete'
      get 'timeline', to: 'timeline#index'

      resources :trending, only: %i[index]
      resources :follows, only: %i[create destroy]
      resources :likes, only: %i[create destroy]
      resources :tweets, only: %i[index show create update destroy] do
        member do
          post 'like', to: 'likes#create'
          delete 'like', to: 'likes#destroy'
        end
      end
      resources :users, only: %i[show create update destroy] do
        member do
          get 'following'
          get 'followers'
          post 'follow', to: 'follows#create'
          delete 'follow', to: 'follows#destroy'
        end
        get 'current', on: :collection
      end
    end
  end
end