module HanoiTowers
  class HanoiStack
    def initialize(arr = [])
      @data = arr
    end

    def push(value)
      return nil if value.nil?
      @data.push value
    end

    def pop
      @data.pop
    end

    def top
      @data.last || -1
    end

    def size
      @data.size
    end

    def stack_reverse_sorted?
      @data.sort.reverse == @data
    end

    def inspect_data
      @data
    end
  end

  class GameEngine

    #define starting amount of rings
    #rings are represented as an array like [3, 2, 1, 0]
    #array is 'reversed' in the beginning by the rules of the game
    #with 0 being the smallest ring
    #

    COLUMNS = [:left, :middle, :right]

    def gen_rings(number_of_rings)
      (number_of_rings-1).downto(0).map { |r| r }
    end

    def rings_count
      @rings.size
    end

    def initialize(number_of_rings = 3)
      @rings = gen_rings(number_of_rings)
      @field = {
        left: HanoiStack.new(@rings.clone),
        middle: HanoiStack.new,
        right: HanoiStack.new
      }
    end

    def game_finished?
      @field[:right].stack_reverse_sorted? && @field[:right].size == rings_count
    end

    #To move 'rings' from one column to another
    #pass :from_%column_name% as the first arg,
    #pass :to_%column_name% as the second arg
    def move(from, to)
      from_parsed = $1.to_sym if from.to_s.match /from_(.*)/
      to_parsed = $1.to_sym if to.to_s.match /to_(.*)/
      return false unless COLUMNS.include?(from_parsed) && COLUMNS.include?(to_parsed)
      return false if from_parsed == to_parsed
      #by the rules of the game, bigger rings cant be placed on
      #top of the smaller ones
      return false unless @field[to_parsed].top == -1 || @field[to_parsed].top >= @field[from_parsed].top
      return false unless moved = @field[to_parsed].push(@field[from_parsed].pop)
      moved
    end

    def get_column(col)
      @field[col].inspect_data
    end

    #   (#)      |-|      |-|
    #  (###)     |-|      |-|
    #_(#####)____|-|______|-|___
    #
    #   |-|      |-|      |-|
    #  (###)     |-|      |-|
    #_(#####)____(#)______|-|___
    #
    #   |-|      |-|      |-|
    #   |-|     (###)     |-|
    #_(#####)____(#)______|-|___
    #
    #   |-|      |-|      |-|
    #   |-|     (###)     |-|
    #___|-|______(#)____(#####)_


    def draw_field
      tiers = []
      cols = []
      COLUMNS.each { |col| cols << draw_column(get_column col) }
      #number of rings is equal to number of tiers of the field
      (0...rings_count).each do |i|
        tiers[i] = ""
        cols.each { |col| tiers[i] += col[i] }
        #tiers[i] = cols[0][i] + cols[1][i] + cols[2][i]
      end
      tiers.reverse_each do |t|
        puts t
      end
    end

    def draw_column(column)
      tiers = []

      (0...rings_count).each do |i|
        if i == 0
          #because its the lowest row
          free_space = "_"
        else
          free_space = " "
        end

        #value of each element in a column array represents a size of a ring
        #size of a column is calculated in a way that max width of a column
        #is equal to size_of_a_largest_ring + 1, where 1 is one cell of 'free space', 
        #underscore or whitespace
        #for every possible ring size there should be at least one cell of 'free space'
        #so that columns do not stick together with their largest rings being on the same tier
        if column[i]
          tiers << free_space * (rings_count-column[i]) + draw_ring(column[i]) + free_space * (rings_count-column[i])
        else
          tiers << free_space * rings_count + POLE + free_space * rings_count
        end
      end
      tiers
    end

    private

    POLE = '|-|'.freeze

    def draw_ring(size)
      '(#' + '#' * (2*size) + ')'.freeze
    end
  end

  class UI
    def initialize(number_of_rings = 4)
      @game = GameEngine.new(number_of_rings)
      @turns = 0
    end

    def start_game(username = '')
      puts "Hello #{username}, can you solve the puzzle of the hanoi towers?"
      at_exit { puts "Goodbye, #{username}!" }
      input_loop do
        @game.draw_field
        get_user_input 'Whats your move going to be?' do |input|
          if interpret_user_commands input
            @turns += 1
            @game.game_finished?
          end
        end
      end
      @game.draw_field
      puts "Congratulations, you've beaten the puzzle! It took you #{@turns} turns."
    end

    def parse_direction(word)
      word.match /(left|middle|right)/
      $1
    end
    
    def get_user_input(input_prompt, err_msg = nil, string_parsing_method = nil)
      puts input_prompt
      input = gets.chomp.downcase
      if string_parsing_method
        if parsed_input = send(string_parsing_method, input)
          return yield parsed_input if block_given?
          parsed_input
        else
          puts err_msg if err_msg
          false
        end
      else
        return yield input if block_given?
        input
      end
    end

    def get_move_directions
      directions = { from: nil, to: nil }
      err_msg = "Sorry, i didnt understand that. Choose left, middle or right columns."
      directions.keys.each do |key|
        input_loop do
          get_user_input("Move ring #{key}? (left/middle/right)", err_msg, :parse_direction) do |input|
            directions[key] = "#{key}_" + input
          end
        end
      end
      directions
    end

    def interpret_user_commands(input)
      case input
      when /help/
        puts "Type 'move' to move rings. Type 'exit' if you want to quit game."
        false
      when 'move'
        directions = get_move_directions
        @game.move directions[:from], directions[:to]
        true
      when /move (\w+) (\w+)/
        @game.move 'from_' + $1, 'to_' + $2
        true
      when 'exit'
        exit
      else
        puts "Sorry, i didn't understand that. Type 'help' to learn how to play"
        false
      end
    end

    private

    def input_loop
      loop do
        break if yield
      end
    end
  end
end
