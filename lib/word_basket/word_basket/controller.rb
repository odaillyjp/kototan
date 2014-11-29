using WordBasket::StringExtension

module WordBasket
  class Controller
    require 'pry'

    def initialize
      @input_value = nil
    end

    def run
      # 標準入力から「ひらがな」を受け取るまでループ
      loop { break if @input_value = receive_hira }

      @input_value.chars.each_cons(2).each do |head, last|
        puts WordBasket::Word.sample(head: head, last: last).name
      end
    end

    private

    def receive_hira
      chars = gets.chomp
      raise InputMojiTypeError unless chars.hira_only?
      chars
    rescue InputMojiTypeError
      puts '「ひらがな」を入力してください。'
      false
    end

    class InputMojiTypeError < StandardError; end
  end
end
