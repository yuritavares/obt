Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'user_token', to: 'user_token#create'
      resources :tweets, only: %i[index show create update destroy] do
        member do
          post 'like', to: 'likes#create'
          delete 'unlike', to: 'likes#destroy'
        end
      end
      resources :users, only: %i[show create update destroy] do
        member do
          get 'following'
          get 'followers'
          post 'follow', to: 'follows#create'
          delete 'unfollow', to: 'follows#destroy'
        end
        get 'current', on: :collection
      end
    end
  end
end