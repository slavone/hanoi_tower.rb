require 'minitest/autorun'
require './hanoi_towers.rb'

class TestGameEngine < MiniTest::Test
  def setup 
    @game = HanoiTowers::GameEngine.new
  end

  def test_starting_conditions
    assert_equal [2, 1, 0], @game.get_left_column
    assert_equal [], @game.get_middle_column
    assert_equal [], @game.get_right_column
    left_stack = @game.instance_variable_get :@left
    assert_equal 0, left_stack.pop
  end

  def test_victory_conditions
    @game.instance_variable_set(:@right, HanoiTowers::HanoiStack.new([3, 2, 1]))
    assert_equal true, @game.game_finished?
    @game.instance_variable_set(:@right, HanoiTowers::HanoiStack.new([1, 2, 3]))
    assert_equal false, @game.game_finished?
    @game.instance_variable_set(:@right, HanoiTowers::HanoiStack.new([3, 2]))
    assert_equal false, @game.game_finished?
  end

  def test_attr_readers
    assert_equal HanoiTowers::HanoiStack, @game.left.class
    assert_equal [2, 1, 0], @game.left.inspect_data
    assert_equal HanoiTowers::HanoiStack, @game.middle.class
    assert_equal HanoiTowers::HanoiStack, @game.right.class
  end

  def test_basic_move
    @game.instance_variable_set(:@left, HanoiTowers::HanoiStack.new([2, 1, 0]))
    assert_equal [0], @game.move(:from_left, :to_middle)
    assert_equal [2, 1], @game.get_left_column
    assert_equal [1], @game.move(:from_left, :to_right)
    assert_equal [2], @game.get_left_column
    assert_equal [2, 1], @game.move(:from_right, :to_left)
    assert_equal [], @game.get_right_column
  end
  

  def test_move_cant_place_bigger_ring_on_a_smaller_ring
    custom_stack = HanoiTowers::GameEngine.new
    custom_stack.instance_variable_set(:@left, HanoiTowers::HanoiStack.new([0]))
    custom_stack.instance_variable_set(:@middle, HanoiTowers::HanoiStack.new([1]))
    assert_equal false, custom_stack.move(:from_middle, :to_left)
    assert_equal [0], custom_stack.get_left_column
    assert_equal [1], custom_stack.get_middle_column
  end

  def test_move_if_both_args_are_the_same
    assert_equal false, @game.move(:from_left, :to_left)
    assert_equal [2, 1, 0], @game.get_left_column
  end

  def test_move_if_column_is_empty
    assert_equal false, @game.move(:from_right, :to_left)
    assert_equal [2, 1, 0], @game.get_left_column
    assert_equal [], @game.get_right_column
  end

  def test_draw_full_column
    col = @game.draw_column([2, 1, 0])
    tier = []
    tier[2] = '   (#)   '
    tier[1] = '  (###)  '
    tier[0] = '_(#####)_'
    assert_equal tier[0], col[0]
    assert_equal tier[1], col[1]
    assert_equal tier[2], col[2]
  end

  def test_draw_empty_column
    col = @game.draw_column([])
    tier = []
    tier[2] = '   |-|   '
    tier[1] = '   |-|   '
    tier[0] = '___|-|___'
    assert_equal tier[0], col[0]
    assert_equal tier[1], col[1]
    assert_equal tier[2], col[2]
  end

  def test_draw_reversed_column
    col = @game.draw_column([0, 1, 2])
    tier = []
    tier[2] = ' (#####) '
    tier[1] = '  (###)  '
    tier[0] = '___(#)___'
    assert_equal tier[0], col[0]
    assert_equal tier[1], col[1]
    assert_equal tier[2], col[2]
  end

  def test_draw_lower_tier_with_small_ring
    col = @game.draw_column([0])
    lower_tier = '___(#)___'
    assert_equal lower_tier, col[0]
  end
  
  def test_draw_lower_tier_with_medium_ring
    col = @game.draw_column([1])
    lower_tier = '__(###)__'
    assert_equal lower_tier, col[0]
  end

  def test_draw_lower_tier_with_big_ring
    col = @game.draw_column([2])
    lower_tier = '_(#####)_'
    assert_equal lower_tier, col[0]
  end

  def test_draw_field
    puts '-------------------------------'
    @game.draw_field
    puts '-------------------------------'
  end
    
end
