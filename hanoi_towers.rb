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
      return false if from_parsed == to_parsed
      #by the rules of the game, bigger rings cant be placed on
      #top of the smaller ones
      return false unless @field[to_parsed].top == -1 || @field[to_parsed].top >= @field[from_parsed].top
      return false unless moved = @field[to_parsed].push(@field[from_parsed].pop)
      moved
    end

    def get_left_column
      @field[:left].inspect_data
    end

    def get_middle_column
      @field[:middle].inspect_data
    end

    def get_right_column
      @field[:right].inspect_data
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

    POLE = '|-|'.freeze

    def draw_field
      tiers = []
      col1 = draw_column get_left_column
      col2 = draw_column get_middle_column
      col3 = draw_column get_right_column
      (0...rings_count).each do |i|
        tiers[i] = col1[i] + col2[i] + col3[i]
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

        #each element of a column array represents a size of a ring
        #for every possible ring size there should be at least one cell of 'free space'
        #for columns not to stick together with the biggest possible ring
        if column[i]
          tiers << free_space * (rings_count-column[i]) + draw_ring(column[i]) + free_space * (rings_count-column[i])
        else
          tiers << free_space * rings_count + POLE + free_space * rings_count
        end
      end
      tiers
    end

    private

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
      loop do
        @game.draw_field
        if parse_input prompt_user_command
          @turns += 1
          break if @game.game_finished?
        end
      end
      @game.draw_field
      puts "Congratulations, you've beaten the puzzle! It took you #{@turns} turns."
    end

    def prompt_user_command
      puts "Whats your move going to be?"
      input = gets.chomp
    end
    
    def sanitize_input(word)
      word.match /(left|middle|right)/
      $1
    end

    def parse_move_commands
      from, to = nil, nil
      loop do
        puts 'From which column do you want to move ring? (left / middle / right)'
        from = gets.chomp
        from.downcase!
        if from = sanitize_input(from)
          from = 'from_' + from
          break
        else
          puts "Sorry, i didnt understand that. Choose left, middle or right columns."
        end
      end

      loop do
        puts 'And on what column do you want to put it? (left / middle / right)'
        to = gets.chomp
        to.downcase!
        if to = sanitize_input(to)
          to = 'to_' + to
          break
        else
          puts "Sorry, i didnt understand that. Choose left, middle or right columns."
        end
      end
      @game.move from, to
    end

    def parse_input(input)
      input.downcase!
      case input
      when 'help'
        puts "Type 'move' to move rings. Type 'exit' if you want to quit game."
        false
      when 'move'
        parse_move_commands
        true
      when 'exit'
        exit
      else
        puts "Sorry, i didn't understand that. Type 'help' to learn how to play"
        false
      end
    end
  end
end
