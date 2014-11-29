module WordBasket
  class Configuration
    attr_reader :database
    attr_writer :database_adapter, :database_options

    def initialize
      @database_adapter = 'local_file'
      @database_options = {}
    end

    def setting
      configure_database(@database_adapter)
    end

    private

    # database_nameで指定したデータベースを使用可能な状態にする
    def configure_database(database_name)
      require_relative("database/#{database_name}")
      @database = WordBasket::Database.const_get(database_name.classify).new(@database_options)
    end
  end
end
