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

    RINGS = [3, 2, 1]

    SMALL_RING = '(#)'
    MEDIUM_RING = '(###)'
    BIG_RING = '(#####)'
    POLE = '|-|'

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

    attr_reader :left, :middle, :right

    def initialize
      @left = HanoiStack.new(RINGS.clone)
      @middle = HanoiStack.new
      @right = HanoiStack.new
    end

    def game_finished?
      @right.stack_reverse_sorted? && @right.size == RINGS.size
    end

    #To move 'rings' from one column to another
    #pass :from_%column_name% as the first arg,
    #pass :to_%column_name% as the second arg
    def move(from, to)
      from_parsed = $1 if from.to_s.match /from_(.*)/
      to_parsed = $1 if to.to_s.match /to_(.*)/
      return false if from_parsed == to_parsed
      return false unless moved = (send(to_parsed).push send(from_parsed).pop)
      moved
    end

    def get_left_column
      @left.inspect_data
    end

    def get_middle_column
      @middle.inspect_data
    end

    def get_right_column
      @right.inspect_data
    end

    def draw_field
      tiers = ['', '', '']
      col1 = draw_column get_left_column
      col2 = draw_column get_middle_column
      col3 = draw_column get_right_column
      tiers[0] << col1[0] + col2[0] + col3[0]
      tiers[1] << col1[1] + col2[1] + col3[1]
      tiers[2] << col1[2] + col2[2] + col3[2]
      tiers.reverse_each do |t|
        puts t
      end
    end

    def draw_column(column)
      tiers = []
      if column[0]
        tiers << "_" * (4-column[0]) + draw_ring(column[0]) + "_" * (4-column[0])
      else
        tiers << "___" + POLE + "___"
      end

      if column[1]
        tiers <<  " " * (4-column[1]) + draw_ring(column[1]) + " " * (4-column[1])
      else
        tiers <<  "   " + POLE + "   "
      end

      if column[2]
        tiers <<  " " * (4-column[2]) + draw_ring(column[2]) + " " * (4-column[2])
      else
        tiers <<  "   " + POLE + "   "
      end
      tiers
    end

    def draw_ring(size)
      case size
      when 1
        SMALL_RING
      when 2 
        MEDIUM_RING
      when 3
        BIG_RING
      end
    end
  end

  class UI
    def initialize
      @game = GameEngine.new
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
