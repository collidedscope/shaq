module Shaq
  class AtomicGame < Game
    def self.new
      game = from_fen STANDARD
      game.tap &.add_tag "Variant", "Atomic"
    end

    def ply(from : Int32, to)
      capture = occupied?(to % 64) || board[from].try &.pawn? && to == ep_target
      super
      return self unless capture

      Util.moore_neighborhood(to % 64).each do |square|
        if piece = board[square]
          board[square] = nil unless piece.pawn?
        end
      end

      tap { board[to % 64] = nil }
    end

    def no_king?
      friends.none? &.king?
    end

    # HACK: Consider our lack of a King to be check for legal move generation.
    def check?
      no_king? || super
    end

    def enemy_vision
      # We know they have one or the game would already be over.
      enemy_king = enemies.find(&.king?).not_nil!

      # We can move into "check" if they can't actually take because doing so
      # would explode their King: https://lichess.org/er8G4lr6
      super.reject { |square|
        Util.moore_neighborhood(square).includes? enemy_king.position
      }
    end

    def legal_moves_for(piece) : Array(Int32)
      return [] of Int32 if no_king?

      piece.moves(self).select { |square|
        sim = sim piece.position, square
        # A move is legal if it explodes the enemy King without exploding ours
        # OR doesn't leave us in check, with the former having higher priority.
        sim.ply.no_king? || !sim.ply.check? unless sim.no_king?
      }
    end
  end

  class Game
    def atomic?
      is_a? AtomicGame
    end
  end
end
