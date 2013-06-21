Dummy::Application.routes.draw do
  resources :posts do
    collection do
      get 'restricted'
      get 'special_access'
      get 'cookies_action'
      get 'secure'
      post "create_with_response"
    end
  end

  match 'no_method_error' => 'error#no_method_error', :as => :no_method_error
  match 'argument_error' => 'error#argument_error', :as => :argument_error
  
end
