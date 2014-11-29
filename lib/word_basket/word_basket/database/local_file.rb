module WordBasket
  module Database
    require 'json'

    class LocalFile
      def initialize(storage_path: 'db/words.json')
        @storage_path = [APP_ROOT, storage_path].join('/')
        @words ||= load_storage_file
      end

      def set(data)
        return if @words.any? { |word| word['name'] == data.name }

        @words.push(data.to_h)
        File.open(@storage_path, 'w') { |file| file.write(@words.to_json) }
      end

      def sample(data)
        words = @words.select { |word| word['head'] == data.head && word['last'] == data.last }

        return nil if words.empty?
        word = words.sample
        { name: word['name'], furigana: word['furigana'] }
      end

      private

      def load_storage_file
        File.exist?(@storage_path) ? JSON.parse(File.read(@storage_path)) : []
      rescue JSON::ParserError
        fail StorageLoadError, 'データベースファイルの解析に失敗しました。'
      end

      class StorageLoadError < StandardError; end
    end
  end

  Word.class_eval do
    def to_h
      { 'name' => @name, 'furigana' => @furigana, 'head' => @head, 'last' => @last }
    end
  end
end
