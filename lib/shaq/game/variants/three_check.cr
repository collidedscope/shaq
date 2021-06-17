module Shaq
  class ThreeCheckGame < Game
    variant "Three-check"

    def lost?
      super || san_history.each_with_index.count { |move, i|
        i & 1 == turn.to_i && move[-1] == '+'
      } > 2
    end
  end
end
