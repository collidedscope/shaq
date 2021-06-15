module Shaq
  class ThreeCheckGame < Game
    variant "Three-check"

    property checks = {Side::Black => 0, Side::White => 0}

    def update
      super.tap { checks[turn] += 1 if check? }
    end

    def lost?
      super || checks[turn] == 3
    end
  end
end
