module Shaq
  class RacingKingsGame < Game
    variant "Racing Kings"

    def self.new
      game = from_fen "8/8/8/8/8/8/krbnNBRK/qrbnNBRQ w - - 0 1"
      game.tap &.add_tag "Variant", "Racing Kings"
    end

    def legal_moves_for(piece)
      piece.moves.reject { |square|
        sim = sim piece, square
        sim.check? || sim.ply.check?
      }
    end

    def lost?
      enemy_king = enemies.find(&.king?).not_nil!
      return false unless enemy_king.rank == 8
      return true if white?
      legal_moves_for(king).none? &.< 8
    end

    def draw?
      board.select(King).all? &.rank.== 8
    end
  end
end
