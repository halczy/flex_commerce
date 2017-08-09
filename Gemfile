source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails'
gem 'pg'
gem 'puma'
gem 'sass-rails'
gem 'uglifier'
gem 'webpacker'
gem 'coffee-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'redis'
gem 'bcrypt'
gem 'money-rails'
gem 'trix'
gem 'shrine'
gem 'image_processing'
gem 'mini_magick'
gem 'kaminari'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'capybara'
end

group :development do
  gem 'web-console'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'shrine-memory'
end
