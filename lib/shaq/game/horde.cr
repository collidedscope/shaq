module Shaq
  class HordeGame < Game
    def self.new
      from_fen "rnbqkbnr/pppppppp/8/1PP2PP1#{"/PPPPPPPP" * 4} w kq - 0 1"
    end

    def check?
      black? && super
    end

    def checkmate?
      black? && super
    end
  end

  class Game
    def horde?
      is_a? HordeGame
    end
  end
end
