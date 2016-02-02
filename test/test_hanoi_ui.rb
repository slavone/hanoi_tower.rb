require 'minitest/autorun'
require './hanoi_towers.rb'

class TestUI < MiniTest::Test
  def setup 
    @ui = HanoiTowers::UI.new
  end

  def test_interpret_user_commands
    assert_output "Type 'move' to move rings. Type 'exit' if you want to quit game.\n" do
      assert_equal false, @ui.interpret_user_commands('help')
    end

    assert_output "Sorry, i didn't understand that. Type 'help' to learn how to play\n" do
      assert_equal false, @ui.interpret_user_commands('sdsdsdsdsd')
    end
  end

  def test_move_skip
    assert_equal true, @ui.interpret_user_commands('move left middle')
    game = @ui.instance_variable_get(:@game)
    middle = game.get_column(:middle)
    assert_equal [0], middle
  end

  def test_interpret_get_move_directions
    assert_output "Move ring from? (left/middle/right)\nMove ring to? (left/middle/right)\n" do
      with_stdin do |user|
        user.puts 'left'
        user.puts 'right'
        assert_equal({ from: 'from_left', to: 'to_right' }, @ui.get_move_directions)
      end
    end
  end

  def test_get_user_input_basic_input
    assert_output "Correct user prompt\n" do
      with_stdin do |user|
        user.puts 'user input'
        assert_equal 'user input', @ui.get_user_input('Correct user prompt')
      end
    end
  end

  def test_get_user_input_basic_input_with_block
    assert_output "Correct user prompt\n" do
      with_stdin do |user|
        user.puts 'user input'
        assert_equal 'user input', @ui.get_user_input('Correct user prompt') { |input| input }
      end
    end
  end

  def test_get_user_input_with_parsing_method
    assert_output "Correct user prompt\n" do
      with_stdin do |user|
        user.puts 'string_to_parse_LEFT'
        assert_equal 'left', @ui.get_user_input('Correct user prompt', nil, :parse_direction)
      end
    end
  end

  def test_get_user_input_with_parsing_err_msg
    assert_output "Correct user prompt\nError msg\n" do
      with_stdin do |user|
        user.puts 'gibberish'
        assert_equal false, @ui.get_user_input('Correct user prompt', "Error msg", :parse_direction)
      end
    end
  end

  def test_get_user_input_with_parsing_method_and_block
    assert_output "Correct user prompt\n" do
      with_stdin do |user|
        user.puts 'string_to_parse_LEFT'
        assert_equal 'from_left', 
          @ui.get_user_input('Correct user prompt', nil, :parse_direction) { |input| "from_" + input }
      end
    end
  end

  private

  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end
end
