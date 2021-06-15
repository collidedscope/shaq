module Shaq
  class HordeGame < Game
    variant "Horde"

    def self.new
      game = from_fen "rnbqkbnr/pppppppp/8/1PP2PP1#{"/PPPPPPPP" * 4} w kq - 0 1"
      game.tap &.add_tag "Variant", "Horde"
    end

    def check?
      black? && super
    end

    def lost?
      white? ? friends.empty? : checkmate?
    end
  end
end
