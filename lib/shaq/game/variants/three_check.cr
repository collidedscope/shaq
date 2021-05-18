module Shaq
  class ThreeCheckGame < Game
    property checks = {Side::Black => 0, Side::White => 0}

    def self.new
      super.tap &.add_tag "Variant", "Three-check"
    end

    def ply
      super.tap { checks[turn] += 1 if check? }
    end

    def checkmate?
      super || checks[turn] == 3
    end
  end

  class Game
    def three_check?
      is_a? ThreeCheckGame
    end
  end
end
