module Shaq
  class DouglasModernGame < Game
    variant "Douglas Modern"

    def self.new
      game = from_fen "1rbqkbr1/1nppppn1/2pppp2/8/8/2PPPP2/1NPPPPN1/1RBQKBR1 w - - 0 1"
      game.tap &.add_tag "Variant", "Douglas Modern"
    end
  end
end
