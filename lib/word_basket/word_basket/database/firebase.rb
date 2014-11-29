module WordBasket
  module Database
    require 'uri'

    class Firebase
      ROOT_NAME = 'words'
      FIREBASE_DOMAIN = 'firebaseio.com'

      def initialize(app_name: nil)
        base_url = "https://#{app_name}.#{FIREBASE_DOMAIN}/"
        @client = ::Firebase::Client.new(base_url)
      end

      def set(data)
        response = @client.set(generate_path(data), data)
        response.success?
      end

      def sample(data)
        @words ||= @client.get(ROOT_NAME).body
        return if @words[data.head].nil? || @words[data.head][data.last].nil?
        word = @words[data.head][data.last].values.sample
        { name: word['name'], furigana: word['furigana'] }
      end

      private

      def generate_path(data)
        path = [ROOT_NAME, data.head, data.last, data.name].join('/')
        URI.escape(path)
      end
    end
  end

  Word.class_eval do
    def to_json
      "{ \"name\": \"#{@name}\", \"furigana\": \"#{@furigana}\" }"
    end
  end
end
