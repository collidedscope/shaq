module Shaq
  class CloakDaggerGame < Game
    variant "Cloak and Dagger"

    def ply(from : Int32, to)
      super

      if real? && (e = enemies.find &.cloak)
        board[e.position] = e.disrobe
      end

      if piece = capture
        board[to] = board[to].not_nil!.encloak piece
      end

      self
    end
  end
end
