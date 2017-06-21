module Codebreaker
  class Game
    WIN = :WIN
    LOSE = :LOSE
    PLAY = :PLAY

    FIELDS = [
      :code,
      :hint,
      :hashcode,
      :nickname,
      :game_stage,
      :tries_left
    ]

    def start
      generate

      @game_stage = PLAY
      @tries_left = NUM_OF_TRIES
    end

    def check(input)
      input = prepare input
      result = process input.chars

      @tries_left -= 1
      @game_stage = stage result

      @game_stage == PLAY ? result : @game_stage
    end

    def prepare(value)
      if value.is_a? String and value.match CODE_REGEXP
        value[0, NUM_OF_DIGITS]
      else
        message = 'Invalid input! It should contain only the digits!'
        raise ArgumentError, message
      end
    end

    def process(input)
      code = @code.chars
      result = String.new

      array = code.zip(input).sort_by! do |element|
        element.last == element.first ? -1 : 0
      end

      array.each do |element|
        next unless code.include? element.last
        result << (element.first == element.last ? '+' : '-')
        code.delete_at code.index(element.last)
      end

      result
    end

    def stage(result)
      if @game_stage == WIN or result.match WIN_CODE_REGEXP
        WIN
      elsif @tries_left == 0
        LOSE
      else
        PLAY
      end
    end

    def finish?
      @game_stage != PLAY
    end

    def win?
      @game_stage == WIN
    end

    def lose?
      @game_stage == LOSE
    end

    def hint
      begin
        @hint
      ensure
        @hint = nil
      end
    end

    def generate
      digits = Array.new(NUM_OF_DIGITS) do
        rand(MIN_DIGIT..MAX_DIGIT)
      end

      @code = digits * ''
      @hint = digits.sample.to_s
    end

    def write(path='score.yaml', nickname, hashcode)
      array = if File.exist? path
        YAML.load_file path
      else
        Array.new
      end

      data = FIELDS.inject(Hash.new) do |hash, field|
        hash[field] = eval "@#{field}"
        hash
      end

      data[:hashcode] = hashcode
      data[:nickname] = nickname

      array.unshift data

      File.open path, 'w' do |file|
        file.write array.to_yaml
      end
    end

    def self.read(path='score.yaml', hashcode: nil)
      return unless File.exist? path

      array = YAML.load_file path

      unless hashcode
        return array.map { |element| parse element }
      end

      array.each do |data|
        return parse data if data[:hashcode] == hashcode
      end
    end

    def self.parse(data)
      FIELDS.inject(Game.new) do |game, field|
        game.instance_variable_set "@#{field}", data[field]
        game
      end
    end

    private :stage

    private :hash
    private :process
    private :prepare
    private :generate

    private_class_method :parse
  end
end
