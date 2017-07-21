Image::Engine.routes.draw do
  namespace :os_images do
    resources :public, only: %i[index show destroy] do
      put :unpublish
    end

    resources :private, only: %i[index show destroy] do
      put :publish
      resources :members, module: :private, except: %i[edit update show]
    end
    resources :suggested, only: %i[index show destroy] do
      put :accept
      put :reject
    end
  end
end
