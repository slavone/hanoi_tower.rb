require 'minitest/autorun'
require './hanoi_towers.rb'

class TestUI < MiniTest::Test
  def setup 
    @ui = HanoiTowers::UI.new
  end

  def test_parse_input
    assert_output "Type 'move' to move rings. Type 'exit' if you want to quit game.\n" do
      @ui.parse_input 'help'
    end
  end
end
