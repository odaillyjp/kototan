WordBasket.configure do |config|
  config.database_adapter = 'firebase'
  config.database_options = { app_name: 'odailly-wordbaskets' }
end
