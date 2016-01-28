require 'minitest/autorun'
require './hanoi_towers.rb'

class TestHanoiStack < MiniTest::Test

  def setup
    @stack = HanoiTowers::HanoiStack.new([1, 2, 3])
  end

  def test_creation_from_array
    assert_equal [1, 2, 3], @stack.inspect_data
  end

  def test_pop
    initial_size = @stack.size
    assert_equal 3, @stack.pop
    assert_equal initial_size-1, @stack.size
  end

  def test_push
    initial_size = @stack.size
    @stack.push 5
    assert_equal initial_size+1, @stack.size
    assert_equal 5, @stack.pop
  end

  def test_nil_cant_be_pushed_into_stack
    @stack.push nil
    assert_equal [1, 2, 3], @stack.inspect_data
  end

  def test_is_stack_reverse_sorted?
    another_stack = HanoiTowers::HanoiStack.new([3, 2, 1])
    assert_equal false, @stack.stack_reverse_sorted?
    assert_equal true, another_stack.stack_reverse_sorted?
  end

  def test_top_gets_the_last_element
    assert_equal 3, @stack.top
    assert_equal 3, @stack.size
  end
    
end
