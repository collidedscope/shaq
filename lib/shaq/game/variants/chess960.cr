module Shaq
  class Chess960Game < Game
    variant "Chess960"

    class_getter positions : Array(String) do
      File.read("#{__DIR__}/../../../../data/chess960_positions").split
    end

    def self.new(sp = nil)
      sp ||= rand 960
      rank = positions[sp]
      fen = "#{rank.downcase}/pppppppp/8/8/8/8/PPPPPPPP/#{rank} w KQkq - 0 1"

      from_fen(fen).tap { |game|
        game.add_tag "Variant", "Chess960"
        game.add_tag "FRC#", "SP-#{sp}"
      }
    end
  end
end
