module Shaq
  class CloakDaggerGame < Game
    variant "Cloak and Dagger"

    def friends(piece)
      friends.select &.class.<= piece
    end

    def enemies(piece)
      enemies.select &.class.<= piece
    end

    def ply(from : Int32, to)
      super

      if real? && (e = enemies.find &.cloak)
        board[e.position] = e.disrobe
      end

      if (piece = capture) && (mover = board[to])
        board[to] = mover.encloak piece
      end

      self
    end
  end
end
