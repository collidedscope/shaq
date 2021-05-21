module Shaq
  class AntichessGame < Game
    class_getter variant = "Antichess"

    def check?
      false
    end

    def can_capture?
      !(vision & enemies.map &.position).empty?
    end

    def legal_moves_for(piece) : Array(Int32)
      moves = piece.moves
      moves.select! &->occupied?(Int32) if can_capture?
      moves
    end
  end

  class Game
    def antichess?
      is_a? AntichessGame
    end
  end
end
