ruby '2.2.3'

source 'https://rubygems.org' do
  gem 'rails', '4.2.3'
  gem 'sass-rails', '~> 4.0.3'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'jquery-rails'
  gem 'turbolinks'
  gem 'jbuilder', '~> 2.0'
  gem 'web-console', '~> 2.0'

  gem 'foreman'
  gem 'haml-rails'
  gem 'handlebars_assets'
  gem 'puma'
  gem 'word_basket', github: 'odaillyjp/word_basket', tag: 'v1.0.1'

  group :doc do
    gem 'sdoc', '~> 0.4.0'
  end

  group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'quiet_assets'
    gem 'spring'
  end

  group :development, :test do
    gem 'capybara'
    gem 'coveralls', require: false
    gem 'pry'
    gem 'pry-rails'
    gem 'pry-doc'
    gem 'pry-byebug'
    gem 'rspec-rails'
    # NOTE: 1.8.0以上を使うとCapybara::Node::Findersのallが正しく動かないことがある
    gem 'poltergeist', '~> 1.7.0'
  end

  group :production do
    gem 'rails_12factor'
  end
end

source 'https://rails-assets.org' do
  gem 'rails-assets-lodash'
  gem 'rails-assets-backbone'
end
