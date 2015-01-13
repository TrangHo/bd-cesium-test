source 'http://rubygems.org'

gem 'rails', '4.1.1'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'slim'

gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'

gem 'spring',        group: :development
gem 'rails_12factor', group: :production

group :development, :test do
  gem 'capistrano', '3.2.1'
  gem 'capistrano-rvm'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-maintenance', github: 'capistrano/maintenance', require: false
  gem 'byebug'
end

group :staging, :production do
  gem 'unicorn'
end

ruby "2.1.1"
