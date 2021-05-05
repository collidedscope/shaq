class Shaq::Game
  def pieces
    board.select Piece
  end

  def friends
    pieces.select &.side.== turn
  end

  def friends(piece)
    friends.select &.class.== piece
  end

  def enemies
    pieces.select &.side.!= turn
  end

  def enemies(piece)
    enemies.select &.class.== piece
  end
end
