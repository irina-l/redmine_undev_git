RedmineApp::Application.routes.draw do
  resources :global_hooks, :except => :show, :path => 'hooks'

  resources :projects do
    resources :hooks, :except => :show, :controller => 'project_hooks'
  end

  match 'gitlab_hooks' => 'undev_git_hooks#gitlab_push', :via => :post, :as => :gitlab_hooks
  match 'github_hooks' => 'undev_git_hooks#github_push', :via => :post, :as => :github_hooks
  match 'bitbucket_hooks' => 'undev_git_hooks#bitbucket_push', :via => :post, :as => :bitbucket_hooks
end
