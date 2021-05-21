module Shaq
  class ThreeCheckGame < Game
    class_getter variant = "Three-check"
    property checks = {Side::Black => 0, Side::White => 0}

    def update
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
