module Shaq
  class AtomicGame < Game
    variant "Atomic"

    def ply(from : Int32, to)
      super
      return self unless piece = capture

      epicenter = piece.position
      Util.moore_neighborhood(epicenter).each do |square|
        if piece = board[square]
          board[square] = nil unless piece.pawn?
        end
      end

      tap { board[epicenter] = nil }
    end

    def no_king?
      friends.none? &.king?
    end

    def lost?
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

    def legal_moves_for(piece)
      return [] of Int32 if no_king?

      piece.moves.select { |square|
        sim = sim piece, square
        # A move is legal if it explodes the enemy King without exploding ours
        # OR doesn't leave us in check, with the former having higher priority.
        sim.ply.no_king? || !sim.ply.check? unless sim.no_king?
      }
    end
  end
end
