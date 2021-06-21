module Shaq
  class AsymmetricalGame < Game
    variant "Asymmetrical"

    def self.new
      game = from_fen "3prnbk/4ppqn/5ppb/P5pr/RP5p/BPP5/NQPP4/KBNRP3 w - - 0 1"
      game.tap &.add_tag "Variant", "Asymmetrical"
    end
  end
end
