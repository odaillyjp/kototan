require 'firebase'
require 'unf'
require 'moji'

WordBasket.configure do |config|
  config.database_adapter = 'firebase'
  config.database_options = { app_name: ENV['FIREBASE_APP'] }
end
