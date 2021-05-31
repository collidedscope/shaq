module Shaq
  class CloakDaggerGame < Game
    variant "Cloak and Dagger"

    property cloaks = {} of Side => Piece?

    def legal_moves_for(piece)
      moves = super
      return moves unless cloak = cloaks[piece.side]?

      if cloak.position == piece.position && cloak != piece
        moves.concat legal_moves_for cloak
      end

      moves
    end

    def ply(from : Int32, to)
      super
      cloaks[other_side] = (piece = capture) && piece.turncloak! if real?
      self
    end
  end
end
